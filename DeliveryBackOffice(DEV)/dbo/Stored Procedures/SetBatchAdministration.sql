/* =================================================
   SP:        [dbo].[SetBatchAdministration]
   Propósito: <Administración de lotes - Creación de lotes>
   Autor:     <Walter Orozco>
   Historia:  <FDAPI-3044>
   Fecha:     2024-09-06
============================================
=== CHANGELOG ================================
-- 2025-01-16 | Historia/épica: FDAPI-2982 | Autor: Cristian Azurdia |
-- 2024-09-18 | Historia/épica: FDAPI-3045 | Autor: Walter Orozco |
-- 2024-09-11 | Historia/épica: FDAPI-3052 | Autor: Walter Orozco |
=========================================== */

CREATE PROCEDURE SetBatchAdministration
@TblBatch AS TblBatch READONLY,
@Token NVARCHAR(100),
@Action INT = 0 --0 editar, 1 agregar
AS
BEGIN

	--Se creo para poder modificar los datos
	DECLARE @TblBatchTemp TABLE
	(
		Id_Lote INT,
		RTN NVARCHAR(50),
		NoDeclaracion NVARCHAR(50),
		CAI NVARCHAR(100), -- SOLICITADO
		LimitDateEmision DATETIME, -- SOLICITADO
		Establishment INT, -- SOLICITADO
		Emision_Point INT, -- SOLICITADO
		TypeDocument INT, -- SOLICITADO PERO CON PALABRAS
		RecepcionDate DATETIME, -- SOLICITADO
		Administration_Code INT, -- SOLICITADO
		Status BIT,
		Enable BIT,
		InitialRange BIGINT, -- SOLICITADO
		FinalRange BIGINT, -- SOLICITADO
		Last_Process BIGINT,
		AmountGranted BIGINT, -- SOLICITADO
		AmountRequested BIGINT, --SOLICITADO
		EmailNotification NVARCHAR(50), -- SOLICITADO
		DaysLeftNotifycation INT, -- SOLICITADO
		PercentInvoiceLeftNotifycation INT, -- SOLICITADO
		RowStatus BIT
	);

    BEGIN TRY
		BEGIN TRANSACTION;

			DECLARE @CAI NVARCHAR(100);

			INSERT INTO @TblBatchTemp
			SELECT *
			FROM @TblBatch;

			SELECT TOP 1 @CAI = CAI FROM @TblBatch;

			IF (@Action = 1) --Agregar un nuevo lote
			BEGIN
				--CAI es único pero puede insertarse si es diferente tipo de documento el que se esta ingresando
				IF NOT EXISTS( SELECT  1 FROM DeliveryBackOffice.dbo.InvoiceBatchHeader A WITH (NOLOCK)
								INNER JOIN @TblBatchTemp B ON A.CAI = B.CAI AND A.TypeDocument = B.TypeDocument)
				BEGIN

					--Eliminamos todos los registros que ya se encuentren ingresados
					UPDATE B
					SET B.RowStatus =  'false'
					FROM DeliveryBackOffice.dbo.InvoiceBatchHeader A WITH (NOLOCK)
					INNER JOIN @TblBatchTemp B ON A.Emision_Point = B.Emision_Point 
					AND A.Establishment = B.Establishment 
					AND A.TypeDocument = B.TypeDocument 
					WHERE A.[Status] = 1
					AND A.RowStatus = 1
					AND A.[Enable] = 1;

					--Cambiar de estado los detenidos a inactivos si se ingresa uno
					UPDATE A
					SET A.[Status] = 0, A.[Enable] = 1
					FROM DeliveryBackOffice.dbo.InvoiceBatchHeader A WITH (NOLOCK)
					INNER JOIN @TblBatchTemp B ON A.Emision_Point = B.Emision_Point 
					AND A.Establishment = B.Establishment 
					AND A.TypeDocument = B.TypeDocument 
					WHERE A.RowStatus = 1
					AND A.[Enable] = 0
					AND B.RowStatus = 'true';

					-- Guardar el lote
					INSERT INTO [dbo].[InvoiceBatchHeader]
						([RTN]
						,[NoDeclaracion]
						,[CAI]
						,[LimitDateEmision]
						,[Establishment]
						,[Emision_Point]
						,[TypeDocument]
						,[RecepcionDate]
						,[Administration_Code]
						,[Status]
						,[Enable]
						,[InitialRange]
						,[FinalRange]
						,[Last_Process]
						,[AmountGranted]
						,[EmailNotification]
						,[DaysLeftNotifycation]
						,[PercentInvoiceLeftNotifycation]
						,[RowStatus]
						,[TokenCreated]
						,[DateCreated]
						,[TokenUpdated]
						,[DateUpdated]
						,[AmountRequested])
					SELECT
						RTN,
						NoDeclaracion,
						CAI,
						LimitDateEmision,
						Establishment,
						Emision_Point,
						TypeDocument,
						RecepcionDate,
						Administration_Code,
						Status,
						Enable,
						InitialRange,
						FinalRange,
						Last_Process,
						AmountGranted,
						EmailNotification,
						DaysLeftNotifycation,
						PercentInvoiceLeftNotifycation,
						RowStatus,
						@token,
						GETDATE(),
						NULL,
						NULL,
						AmountRequested
					FROM @TblBatchTemp
					WHERE RowStatus = 'true';

					IF EXISTS (SELECT 1 FROM @TblBatchTemp WHERE RowStatus = 'false')
					BEGIN

						SELECT
							'401'	IdResult,
							''	MessageResult
					
						SELECT Emision_Point ,Establishment , TypeDocument
						FROM @TblBatchTemp
						WHERE RowStatus = 'false';

					END;
					ELSE
					BEGIN
						SELECT
							'200'	IdResult,
							'El lote con el CAI ' + @CAI + ' se ha creado correctamente y está lista para su uso.'	MessageResult
					END;

				END;
				ELSE
				BEGIN
					SELECT
						'400'	IdResult,
						'Ya existe un lote creado para este documento fiscal '+
						'con el mismo CAI. Utiliza el lote existente o verifica '+ 
						'la información antes de intentar crear uno nuevo.'	MessageResult
				END;
			END;
			ELSE IF (@Action = 0) --Modificar un lote existente
			BEGIN
				--CAI es único pero puede insertarse si es diferente tipo de documento el que se esta ingresando
				IF NOT EXISTS( SELECT  1 FROM DeliveryBackOffice.dbo.InvoiceBatchHeader A
				   INNER JOIN @TblBatchTemp B ON A.CAI = B.CAI AND A.TypeDocument = B.TypeDocument 
				   AND A.Emision_Point = B.Emision_Point AND A.Id_Lote != B.Id_Lote)
				BEGIN

					UPDATE A
						SET A.RTN = B.RTN,
							A.NoDeclaracion = B.NoDeclaracion,
							A.CAI = B.CAI,
							A.LimitDateEmision = B.LimitDateEmision,
							A.Establishment = B.Establishment,
							A.Emision_Point = B.Emision_Point,
							A.TypeDocument = B.TypeDocument,
							A.RecepcionDate = B.RecepcionDate,
							A.Administration_Code = B.Administration_Code,
							A.Status = B.Status,
							A.Enable = B.Enable,
							A.InitialRange = B.InitialRange,
							A.FinalRange = B.FinalRange,
							A.Last_Process = B.Last_Process,
							A.AmountGranted = B.AmountGranted,
							A.EmailNotification = B.EmailNotification,
							A.DaysLeftNotifycation = B.DaysLeftNotifycation,
							A.PercentInvoiceLeftNotifycation = B.PercentInvoiceLeftNotifycation,
							A.RowStatus = B.RowStatus,
							--A.TokenCreated = B.TokenCreated,
							--A.DateCreated = B.DateCreated,
							A.TokenUpdated = @Token,
							A.DateUpdated = GETDATE(),
							A.AmountRequested = B.AmountRequested
						FROM [dbo].[InvoiceBatchHeader] A
						INNER JOIN @TblBatchTemp B
							ON A.Id_Lote = B.Id_Lote;
					
						SELECT
							'201'	IdResult,
							'El lote con el CAI ' + @CAI + 
							' se ha modificado correctamente y está lista para su uso.'	MessageResult
				END;
				ELSE
				BEGIN
					SELECT

						'402'	IdResult,
						'Ya existe un lote creado para este documento fiscal '+
						'con el mismo CAI. Utiliza el lote existente o verifica '+ 
						'la información antes de intentar modificarla.'	MessageResult
				END;
			END;
			
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;

		-- Manejo de errores con PRINT
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
    
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END;