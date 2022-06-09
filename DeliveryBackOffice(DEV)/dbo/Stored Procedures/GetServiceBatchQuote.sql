
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-11-02>
-- Description:	< Devuelve el resumen y detalle de precio del lote de servicios (actualmente solo servicios de recolección) >
-- =============================================

CREATE PROCEDURE [dbo].[GetServiceBatchQuote]
	@IdServiceBatch INT = 0,
	@VisitPoint INT = 0,
	@CourierToken NVARCHAR(50) = ''
AS
BEGIN
	-- Json de salida
	DECLARE @JsonResult VARCHAR(MAX) = ''
	DECLARE @JsonSummary NVARCHAR(MAX) = ''
	DECLARE @JsonDetail NVARCHAR(MAX) = ''
	DECLARE @JsonRejects NVARCHAR(MAX) = ''

	-- Variables de lote de servicios
	DECLARE @BatchExists BIT = ISNULL(( SELECT 1 FROM DeliveryBackOffice.dbo.ServiceBatch SB WHERE SB.IdServiceBatch = @IdServiceBatch ), 0)
	DECLARE @BatchStatus BIT = 0;
	DECLARE @BatchCount INT = 0;

	-- Variables para verificación de Courierman
	DECLARE @TokenStatus INT  = (SELECT TOP 1 RowStatus FROM LogTokenPOD WHERE LogTokenPOD LIKE '%' + @CourierToken + '%' ORDER BY DateCreated DESC)
	DECLARE @TokenLife INT = (SELECT TOP 1 DATEDIFF(HOUR, DateCreated, GETDATE() ) FROM LogTokenPOD WHERE LogTokenPOD  LIKE '%' + @CourierToken + '%' ORDER BY DateCreated DESC)

	-- Variables para control de proceso
	DECLARE @Pieces TblBatchGuides;
	DECLARE @TblAcepted TblBatchGuides;
	DECLARE @TblRejected AS TABLE(
		RejectRowNumber INT,
		RejectFullId NVARCHAR(50),
		RejectInternalCode INT,
		RejectMessage NVARCHAR(100),
		RejectStatusId INT,
		RejectStatusName NVARCHAR(20)
	)

	DECLARE @PickupRate DECIMAL(12,2) =  (SELECT TOP 1 isnull(ct.Value,15) FROM dbo.CatToCharge ct WHERE ct.Name ='PickupRate') -- tarifa de recoleccion 

	-- Tablas temporales para manejo de cotización
	IF OBJECT_ID('tempdb.dbo.##tempay', 'U') IS NOT NULL DROP TABLE #tempay;

	IF (@TokenStatus = 1 AND @TokenLife <= 8)
	BEGIN
		BEGIN TRY
			IF (@BatchExists = 1)
			BEGIN
				SET @BatchStatus =	ISNULL((
										SELECT SB.RowStatus FROM [DeliveryBackOffice].[dbo].[ServiceBatch] SB WHERE SB.IdServiceBatch = @IdServiceBatch
									),0)
				IF (@BatchStatus = 1)
				BEGIN
					--BEGIN TRANSACTION

					-- Copy Pieces into TblAcepted
					INSERT INTO @TblAcepted (RowNumber,GuideId,GuideSerie,GuideNumber,GuidePiece,InternalCode)
					SELECT null, CONCAT(SBD.GuideSerie, CAST(SBD.GuideNumber AS VARCHAR), '-', CAST(SBD.PieceNumber AS VARCHAR)), SBD.GuideSerie, SBD.GuideNumber, SBD.PieceNumber, null
					FROM [DeliveryBackOffice].[dbo].[ServiceBatchDetail] SBD
					JOIN 
					[DeliveryBackOffice].[dbo].[ServiceBatch] SB
					ON SBD.ServiceBatchId = SB.IdServiceBatch
					AND SB.RowStatus = 1;

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
					AND DO.StatusOrderId NOT IN (1,15, 16) -- Estados Permitidos: Generado, Solicitado, Programado para recolección
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
							

					DECLARE @FoundErrors INT = ISNULL((SELECT COUNT(*) FROM @TblRejected),0);
					IF ( @FoundErrors IS NULL OR @FoundErrors = 0 )
					BEGIN
						-- REALIZAR COTIZACIÓN
						SELECT  
							price,
							ItemNumber,
							ItemSerie,
							AmountPickup
						INTO #tempay
						FROM 
						(
							SELECT 
								(
									CASE WHEN (ou.TimePlaId = 2 OR ou.TimePlaId IS NULL ) AND ou.TransaccionFAC IS NULL THEN ord.PriceShippment 
									ELSE 0.00 END
								) as price
								,TA.GuideNumber ItemNumber
								,TA.GuideSerie ItemSerie
								,sp.AmountPickup
							FROM  @TblAcepted TA
							LEFT JOIN dbo.DeliveryOrderPaymentDetail ou
							ON (TA.GuideNumber = ou.GuideNumber AND TA.GuideSerie = ou.GuideSerie)
							INNER JOIN DeliveryOrder ord
							ON (ord.Guide_Number = TA.GuideNumber AND ord.Guide_Serie = TA.GuideSerie)
							LEFT JOIN DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail dt
							ON dt.SerieNumber = ou.GuideSerie  AND  dt.ProductNumber = ou.GuideNumber 
							LEFT JOIN CreditCardTransactionByCustomer cr
							ON cr.OrderNumber = dt.OrderNumber 
							LEFT JOIN SchedulePickup sp
							ON ou.IdHeaderRecolection = sp.SchedulePickupId
							WHERE ou.GuideNumber IN (TA.GuideNumber)
							AND ou.GuideSerie IN (TA.GuideSerie) 
							OR ( ord.StatusOrderId IN (15,1,16) OR ou.GuideNumber IS NULL) 
							AND dt.OrderNumber IS NULL
						) AS table1


						-- DETALLE
						set @jsonDetail = (SELECT STUFF(( 
												SELECT 
													',{"GuideSerie":"' +   isnull(tbl.GuideSerie,'N/A') + '",' +
													'"GuideNumber":"' + CONVERT(varchar, Isnull(tbl.GuideNumber, 'N/A')) + '",' + 
													'"Amount":"' +convert(varchar, isnull(tp.price,'0.00')) +  '",' +
													'"PickupRate":"' + convert(varchar,'0.00') + 
													+ '"}'
												FROM @TblAcepted tbl
												JOIN #tempay tp 
												ON (tp.ItemNumber = tbl.GuideNumber and tp.ItemSerie = tbl.GuideSerie)
												GROUP BY tbl.GuideSerie, tbl.GuideNumber, tp.price
												FOR XML PATH(''), TYPE
											).value('.', 'varchar(max)'),1,1,'') )
									

						-- RESUMEN
						set @jsonSummary = (SELECT STUFF((
												select 
													',{"Amount":"' + convert(varchar,isnull(SUM(tp.price),'0.00')) + '",' +
													'"PickupRate":"' + convert(varchar,ISNULL(@PickupRate, '0.00')) + '",' +
													'"Collect":"' + 'false' + 
													+ '"}'
												from @TblAcepted tbl
												join #tempay tp on (tp.ItemNumber = tbl.GuideNumber and tp.ItemSerie = tbl.GuideSerie)
												FOR XML PATH(''), TYPE
												).value('.', 'varchar(max)'),1,1,'') )
						
						SET @JsonResult =(
									SELECT STUFF(( 
									SELECT '{{"IdResult":200,' 
									+ '"Message":"Exito procesando datos de lote."' + ',' + 
									+ '"Summary":['+@jsonSummary+']' + ',' + 
									+ '"Detail":['+@jsonDetail+']' + 
									+ '}'
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )

						IF @jsonResult is null 
						BEGIN
							SET @jsonResult =(
										SELECT STUFF(( 
										SELECT '{"IdResult":412,' 
										+ '"Message":" No se encontraron registros"'
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,'') )
						END

						SELECT ('[' + @JsonResult +  ']') JsonResult 
					END
					ELSE
					BEGIN
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
									SELECT '{{"IdResult":400,' 
									+ '"Message":"Se encontraron rechazos dentro del lote."' + ',' + 
									+ '"Rejects":['+@JsonRejects+']' +
									+ '}'
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )

						IF @jsonResult is null 
						BEGIN
							SET @jsonResult =(
										SELECT STUFF(( 
										SELECT '{"IdResult":412,' 
										+ '"Message":" No se encontraron registros"'
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,'') )
						END
						SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
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