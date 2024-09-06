-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-05>
-- Description:	<Administraci�n de lotes - Creaci�n de lotes>
-- =============================================

CREATE PROCEDURE SetBatchAdministration
@TblBatch AS TblBatch READONLY,
@Token NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
		BEGIN TRANSACTION;
			
			--CAI es �nico pero puede insertarse si es diferente tipo de documento el que se esta ingresando
			IF NOT EXISTS( SELECT  1 FROM DeliveryBackOffice.dbo.InvoiceBatchHeader A
							INNER JOIN @TblBatch B ON A.CAI = B.CAI AND A.TypeDocument = B.TypeDocument)
			BEGIN
				--SOLO SE PUEDE GUARDAR SI EL PUNTO DE EMISION, ESTABLECIMIENTO Y DOCUMENTO FISCAL VARIAN
				IF NOT EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.InvoiceBatchHeader A
								INNER JOIN @TblBatch B ON A.Emision_Point = B.Emision_Point 
								AND A.Establishment = B.Establishment AND A.TypeDocument = B.TypeDocument)
				BEGIN
					
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
					   ,[DateUpdated])
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
						NULL
					FROM @TblBatch;

					SELECT
						'200'	IdResult,
						'Se ingreso el lote correctamente.'	MessageResult
				END;
				ELSE
				BEGIN
					
					SELECT
						'400'	IdResult,
						'El lote ya fue ingresado.'	MessageResult
				END;

			END;
			ELSE
			BEGIN
				SELECT
					'400'	IdResult,
					'El CAI ya fue ingresado.'	MessageResult
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
