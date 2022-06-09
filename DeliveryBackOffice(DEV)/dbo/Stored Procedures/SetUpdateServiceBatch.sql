
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-11-02>
-- Description:	< añade o quita piezas a un lote de servicio (actualmente solo servicios de recolección) >
-- =============================================

CREATE PROCEDURE [dbo].[SetUpdateServiceBatch]
	@IdServiceBatch INT = 0,
	@VisitPoint INT = 0,
	@Action NVARCHAR(5) = 'PUSH',
	@Pieces TblBatchGuides READONLY,
	@CourierToken NVARCHAR(50) = ''
AS
BEGIN
	-- Json de salida
	DECLARE @JsonResult VARCHAR(MAX) = ''
	DECLARE @JsonAdded VARCHAR(MAX) = ''
	DECLARE @JsonRejects VARCHAR(MAX) = ''

	-- Variables de lote de servicios
	DECLARE @BatchExists BIT = ISNULL(( SELECT 1 FROM DeliveryBackOffice.dbo.ServiceBatch SB WHERE SB.IdServiceBatch = @IdServiceBatch ), 0)
	DECLARE @BatchStatus BIT = 0;
	DECLARE @BatchCount INT = 0;

	-- Variables para verificación de Courierman
	DECLARE @TokenStatus INT  = (SELECT TOP 1 RowStatus FROM LogTokenPOD WHERE LogTokenPOD LIKE '%' + @CourierToken + '%' ORDER BY DateCreated DESC)
	DECLARE @TokenLife INT = (SELECT TOP 1 DATEDIFF(HOUR, DateCreated, GETDATE() ) FROM LogTokenPOD WHERE LogTokenPOD  LIKE '%' + @CourierToken + '%' ORDER BY DateCreated DESC)

	-- Variables para control de proceso
	DECLARE @TblAcepted TblBatchGuides;
	DECLARE @TblRejected AS TABLE(
		RejectRowNumber INT,
		RejectFullId NVARCHAR(50),
		RejectInternalCode INT,
		RejectMessage NVARCHAR(100),
		RejectStatusId INT,
		RejectStatusName NVARCHAR(20)
	)

	-- Copy Pieces into TblAcepted
	INSERT INTO @TblAcepted (RowNumber,GuideId,GuideSerie,GuideNumber,GuidePiece,InternalCode)
	SELECT P.RowNumber, P.GuideId, P.GuideSerie, P.GuideNumber, P.GuidePiece, P.InternalCode
	FROM @Pieces P;

	IF (@TokenStatus = 1 AND @TokenLife <= 8)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			IF (@BatchExists = 1)
			BEGIN
				SET @BatchStatus =	ISNULL((
										SELECT SB.RowStatus FROM [DeliveryBackOffice].[dbo].[ServiceBatch] SB WHERE SB.IdServiceBatch = @IdServiceBatch
									),0)
				IF (@BatchStatus = 1)
				BEGIN
						IF(@Action = 'PUSH')
						BEGIN
							-- IDENTIFICADORES INCORRECTOS
							INSERT INTO @TblRejected (RejectRowNumber, RejectFullId, RejectInternalCode, RejectMessage, RejectStatusId, RejectStatusName)
							SELECT TA.RowNumber, TA.GuideId,4,'Identificador de pieza incorrecta.',null,null 
							FROM @TblAcepted TA
							WHERE TA.InternalCode IS NOT NULL AND TA.InternalCode = 4;

							DELETE TA 
							FROM @TblAcepted TA
							JOIN @TblRejected TR
							ON TA.RowNumber = TR.RejectRowNumber;

							-- REVISAR DUPLICADOS
							INSERT INTO @TblRejected (RejectRowNumber, RejectFullId, RejectInternalCode, RejectMessage, RejectStatusId, RejectStatusName)
							SELECT TA.RowNumber, TA.GuideId, 1, 'La pieza esta duplicada.',null,null
							FROM @TblAcepted TA
							JOIN
							(SELECT MIN(TA2.RowNumber) RowNumber, TA2.GuideId, COUNT(*) Duplicates
							FROM @TblAcepted TA2
							GROUP BY TA2.GuideId
							HAVING COUNT(*) > 1) TA2
							ON TA.RowNumber > TA2.RowNumber
							AND TA.GuideId = TA2.GuideId
							ORDER BY TA.RowNumber
							
							DELETE TA 
							FROM @TblAcepted TA
							JOIN @TblRejected TR
							ON TA.RowNumber = TR.RejectRowNumber;

							-- REVISAR POR ESTADO
							INSERT INTO @TblRejected (RejectRowNumber, RejectFullId, RejectInternalCode, RejectMessage, RejectStatusId, RejectStatusName)
							SELECT TA.RowNumber, TA.GuideId, 2, 'El estado de la guía no es válido.',DO.StatusOrderId,SO.OrderDescription
							FROM @TblAcepted TA
							JOIN
							[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
							ON TA.GuideSerie = DO.Guide_Serie
							AND TA.GuideNumber = DO.Guide_Number
							AND DO.StatusOrderId NOT IN (1, 16) -- Estados Permitidos: Solicitado, Programado para recolección
							JOIN [DeliveryBackOffice].[dbo].[StatusOrder] SO
							ON DO.StatusOrderId = SO.StatusOrderId

							DELETE TA 
							FROM @TblAcepted TA
							JOIN @TblRejected TR
							ON TA.RowNumber = TR.RejectRowNumber;

							-- REVISAR PERTENENCIA
							INSERT INTO @TblRejected (RejectRowNumber, RejectFullId, RejectInternalCode, RejectMessage, RejectStatusId, RejectStatusName)
							SELECT TA.RowNumber, TA.GuideId, 2, 'El estado de la guía no es válido.',null,null
							FROM @TblAcepted TA
							JOIN
							[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
							ON TA.GuideSerie = DO.Guide_Serie
							AND TA.GuideNumber = DO.Guide_Number
							JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPC
							ON VPC.CodeOfReference = DO.Sender_ID
							JOIN [DeliveryBackOffice].[dbo].[Customer] C
							ON C.IdCustomer = ISNULL(DO.IdCustomer,VPC.CustomerID)
							WHERE VPC.CodeOfReference <> @VisitPoint

							DELETE TA 
							FROM @TblAcepted TA
							JOIN @TblRejected TR
							ON TA.RowNumber = TR.RejectRowNumber;
							

							-- INGRESAR POSIBLES
							INSERT INTO [DeliveryBackOffice].[dbo].[ServiceBatchDetail] (ServiceBatchId, GuideNumber, GuideSerie, PieceNumber, RowStatus, TokenCreated, DateCreated)
							SELECT @IdServiceBatch, TA.GuideNumber, TA.GuideSerie, TA.GuidePiece, 1, @CourierToken, GETDATE()
							FROM @TblAcepted TA
							WHERE NOT EXISTS (
								SELECT 1 
								FROM [DeliveryBackOffice].[dbo].[ServiceBatchDetail] SBD2
								WHERE SBD2.GuideNumber = TA.GuideNumber
								AND SBD2.GuideSerie = TA.GuideSerie
								AND SBD2.ServiceBatchId = @IdServiceBatch
							);

							UPDATE SBD
							SET RowStatus = 1
							FROM [DeliveryBackOffice].[dbo].[ServiceBatchDetail] SBD
							JOIN @TblAcepted TA
							ON SBD.GuideNumber = TA.GuideNumber
							AND SBD.GuideSerie = TA.GuideSerie
							AND SBD.ServiceBatchId = @IdServiceBatch;

							-- TABLAS A JSON
							-- ACEPTADAS
							SET @JsonAdded = (SELECT STUFF(( 
												SELECT  
												',{"Id":"' + TA.GuideId + '"}'
												FROM @TblAcepted TA
												FOR XML PATH(''), TYPE
												).value('.', 'varchar(max)'),1,1,''
												) )

							-- RECHAZADAS
							SET @JsonRejects = (SELECT STUFF(( 
												SELECT  
												',{"Id":"' + TR.RejectFullId + '",' + 
												'"InternalCode":' + TR.RejectInternalCode + ',' +
												'"Message":"' + TR.RejectMessage + '",' +
												'"Status":' + ( CASE WHEN TR.RejectStatusId IS NULL THEN NULL
																	ELSE '{"Id":' + TR.RejectStatusId + ',' +
																		'"Name":"'+ TR.RejectStatusName + '"' +
																	'}'
																END ) + 
												'}'
												FROM @TblRejected TR
												FOR XML PATH(''), TYPE
												).value('.', 'varchar(max)'),1,1,''
												) )

							SET @JsonResult =(
										SELECT STUFF(( 
										SELECT '{{"IdResult":200,' 
										+ '"Guides":['+@JsonAdded+']' + ',' + 
										+ '"Rejects":['+@JsonRejects+']'
										+ '}'
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,'') )
							SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
							COMMIT TRANSACTION;
						END
						ELSE IF (@Action = 'PULL')
						BEGIN
							-- IDENTIFICADORES INCORRECTOS
							INSERT INTO @TblRejected (RejectRowNumber, RejectFullId, RejectInternalCode, RejectMessage, RejectStatusId, RejectStatusName)
							SELECT TA.RowNumber, TA.GuideId,4,'Identificador de pieza incorrecta.',null,null 
							FROM @TblAcepted TA
							WHERE TA.InternalCode IS NOT NULL AND TA.InternalCode = 4;

							DELETE TA 
							FROM @TblAcepted TA
							JOIN @TblRejected TR
							ON TA.RowNumber = TR.RejectRowNumber;

							-- REVISAR DUPLICADOS
							INSERT INTO @TblRejected (RejectRowNumber, RejectFullId, RejectInternalCode, RejectMessage, RejectStatusId, RejectStatusName)
							SELECT TA.RowNumber, TA.GuideId, 1, 'La pieza esta duplicada.',null,null
							FROM @TblAcepted TA
							JOIN
							(SELECT MIN(TA2.RowNumber) RowNumber, TA2.GuideId, COUNT(*) Duplicates
							FROM @TblAcepted TA2
							GROUP BY TA2.GuideId
							HAVING COUNT(*) > 1) TA2
							ON TA.RowNumber > TA2.RowNumber
							AND TA.GuideId = TA2.GuideId
							ORDER BY TA.RowNumber
							
							DELETE TA 
							FROM @TblAcepted TA
							JOIN @TblRejected TR
							ON TA.RowNumber = TR.RejectRowNumber;

							-- REVISAR POR ESTADO
							INSERT INTO @TblRejected (RejectRowNumber, RejectFullId, RejectInternalCode, RejectMessage, RejectStatusId, RejectStatusName)
							SELECT TA.RowNumber, TA.GuideId, 2, 'El estado de la guía no es válido.',DO.StatusOrderId,SO.OrderDescription
							FROM @TblAcepted TA
							JOIN
							[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
							ON TA.GuideSerie = DO.Guide_Serie
							AND TA.GuideNumber = DO.Guide_Number
							AND DO.StatusOrderId NOT IN (15, 16) -- Estados Permitidos: Generado, Programado para recolección
							JOIN [DeliveryBackOffice].[dbo].[StatusOrder] SO
							ON DO.StatusOrderId = SO.StatusOrderId

							DELETE TA 
							FROM @TblAcepted TA
							JOIN @TblRejected TR
							ON TA.RowNumber = TR.RejectRowNumber;

							-- REVISAR PERTENENCIA
							INSERT INTO @TblRejected (RejectRowNumber, RejectFullId, RejectInternalCode, RejectMessage, RejectStatusId, RejectStatusName)
							SELECT TA.RowNumber, TA.GuideId, 2, 'El estado de la guía no es válido.',null,null
							FROM @TblAcepted TA
							JOIN
							[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
							ON TA.GuideSerie = DO.Guide_Serie
							AND TA.GuideNumber = DO.Guide_Number
							JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPC
							ON VPC.CodeOfReference = DO.Sender_ID
							JOIN [DeliveryBackOffice].[dbo].[Customer] C
							ON C.IdCustomer = ISNULL(DO.IdCustomer,VPC.CustomerID)
							WHERE VPC.CodeOfReference <> @VisitPoint

							DELETE TA 
							FROM @TblAcepted TA
							JOIN @TblRejected TR
							ON TA.RowNumber = TR.RejectRowNumber;

							-- PIEZA NO REGISTARDA
							INSERT INTO @TblRejected (RejectRowNumber, RejectFullId, RejectInternalCode, RejectMessage, RejectStatusId, RejectStatusName)
							SELECT TA.RowNumber, TA.GuideId, 5, 'La pieza no ha sido ingresada al lote.',null,null
							FROM @TblAcepted TA
							LEFT JOIN 
							[DeliveryBackOffice].[dbo].[ServiceBatchDetail] SBD
							ON SBD.GuideNumber = TA.GuideNumber
							AND SBD.GuideSerie = TA.GuideSerie
							AND SBD.ServiceBatchId = @IdServiceBatch
							AND SBD.IdServiceBatchDetail IS NULL;

							DELETE TA 
							FROM @TblAcepted TA
							JOIN @TblRejected TR
							ON TA.RowNumber = TR.RejectRowNumber;


							-- CAMBIAR POSIBLES
							UPDATE SBD
							SET RowStatus = 0
							FROM [DeliveryBackOffice].[dbo].[ServiceBatchDetail] SBD
							JOIN @TblAcepted TA
							ON SBD.GuideNumber = TA.GuideNumber
							AND SBD.GuideSerie = TA.GuideSerie
							AND SBD.ServiceBatchId = @IdServiceBatch;
							
							-- TABLAS A JSON
							SET @JsonAdded = (SELECT STUFF(( 
												SELECT  
												',{"Id":"' + TA.GuideId + '"}'
												FROM @TblAcepted TA
												FOR XML PATH(''), TYPE
												).value('.', 'varchar(max)'),1,1,''
												) )

							-- RECHAZADAS
							SET @JsonRejects = (SELECT STUFF(( 
												SELECT  
												',{"Id":"' + TR.RejectFullId + '",' + 
												'"InternalCode":' + TR.RejectInternalCode + ',' +
												'"Message":"' + TR.RejectMessage + '",' +
												'"Status":' + ( CASE WHEN TR.RejectStatusId IS NULL THEN NULL
																	ELSE '{"Id":' + TR.RejectStatusId + ',' +
																		'"Name":"'+ TR.RejectStatusName + '"' +
																	'}'
																END ) + 
												'}'
												FROM @TblRejected TR
												FOR XML PATH(''), TYPE
												).value('.', 'varchar(max)'),1,1,''
												) )

							SET @JsonResult =(
										SELECT STUFF(( 
										SELECT '{{"IdResult":200,' 
										+ '"Guides":['+@JsonAdded+']' + ',' + 
										+ '"Rejects":['+@JsonRejects+']'
										+ '}'
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,'') )
							SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
							COMMIT TRANSACTION;
						END
						ELSE
						BEGIN
							SET @JsonResult =(
										SELECT STUFF(( 
										SELECT '{{"IdResult":404,' 
										+ '"Message":"Tipo de accion no existe, solo puede ser PUSH o PULL."}' 
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,'') )
							SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
							ROLLBACK TRANSACTION;
						END
				END
				ELSE
				BEGIN
					SET @JsonResult =(
									SELECT STUFF(( 
									SELECT '{{"IdResult":406,' 
									+ '"Message":"Lote de servicios ya fue procesado."}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
					SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
					ROLLBACK TRANSACTION;
				END
			END
			ELSE
			BEGIN
				SET @JsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":404,' 
								+ '"Message":"No existe lote de servicios."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
				SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
				ROLLBACK TRANSACTION;
			END
		END TRY
		BEGIN CATCH
			SET @JsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":500,' 
								+ '"Message":"Error en la transacción."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
			ROLLBACK TRANSACTION;
		END CATCH
	END
	ELSE
	BEGIN
		SET @JsonResult =(
						SELECT STUFF(( 
						SELECT '{{"IdResult":401,' 
						+ '"Message":"Token de repartidor expirado."}' 
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,'') )
		SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
	END
END