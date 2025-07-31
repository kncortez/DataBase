-- Author:		<Eduardo, López>
-- Create date: <2023-05-31>
-- Description:	<Insertar piezas escaneadas he insertar checkpoint de recolectado al escanear todas las piezas de cada guía>

CREATE PROCEDURE [dbo].[Set_GuidePiecesScan_BNHL]
@SerieNumber VARCHAR(2),
@GuideNumber INT,
@PieceNumber INT,
@Token VARCHAR(100),
@TSEMark VARCHAR(25)

AS

BEGIN
	DECLARE @IdDetail INT;
	DECLARE @IdHeader INT;
	DECLARE @CountPieces INT;
	DECLARE @ScanPieces INT;
	DECLARE @ScanPiecesTotal INT;
	DECLARE @GuideValidPieces INT;

	BEGIN TRANSACTION 
	BEGIN TRY
	    
		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
		DROP TABLE #listGuides;
	
		DECLARE @StatusRecolect INT;
		SET @StatusRecolect = (SELECT TOP 1 StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Recolectado')
		SET @GuideValidPieces = (SELECT COUNT(GuideNumber) FROM DeliveryOrderPiece WHERE GuideSerie = @SerieNumber AND GuideNumber = @GuideNumber)
		SET @IdHeader = (SELECT TOP 1 tsed.TSERoutePreparationHeaderID FROM TSERoutePreparationHeader tseh WITH(NOLOCK)
							INNER JOIN TSERoutePreparationDetail tsed WITH(NOLOCK)
							ON tseh.IDTSERoutePreparationHeader = tsed.TSERoutePreparationHeaderID
							AND tseh.RowStatus = 1
							INNER JOIN DeliveryOrderPiece dopc WITH(NOLOCK)
							ON tsed.GuideSerie = dopc.GuideSerie AND tsed.GuideNumber = dopc.GuideNumber
							WHERE tsed.GuideSerie = @SerieNumber AND tsed.GuideNumber =@GuideNumber AND @GuideValidPieces >1) /*625196*/
		SET @IdDetail = (SELECT IDTSERoutePreparationDetail FROM TSERoutePreparationDetail WITH(NOLOCK) WHERE GuideSerie = @SerieNumber AND GuideNumber = @GuideNumber AND RowStatus = 1)

		SET @CountPieces =(SELECT COUNT(GuideNumber) FROM DeliveryOrderPiece WITH(NOLOCK) WHERE GuideSerie =@SerieNumber AND GuideNumber = @GuideNumber)

		SET @ScanPiecesTotal =(SELECT COUNT(TSERoutePreparationDetailId) FROM TSERoutePreparationDetailPiece WITH(NOLOCK) WHERE TSERoutePreparationDetailId = @IdDetail AND RowStatus = 1)
		SET @ScanPieces = @ScanPiecesTotal+1
		 IF(@IdHeader IS NOT NULL)
			BEGIN
					IF(@ScanPiecesTotal < @CountPieces)
						BEGIN
							IF(@ScanPieces = @CountPieces)
								 BEGIN
									IF((SELECT COUNT(GuideNumber) FROM DeliveryOrderPiece WITH(NOLOCK) WHERE GuideSerie =@SerieNumber/*'FD'*/ AND GuideNumber = @GuideNumber /*625196*/ AND NoPiece = @PieceNumber)>0)
										 BEGIN
											IF ((SELECT COUNT(TSERoutePreparationDetailId) FROM TSERoutePreparationDetailPiece WITH(NOLOCK) WHERE TSERoutePreparationDetailId = @IdDetail AND RowStatus = 1 AND PieceNumber = @PieceNumber) = 0)
												BEGIN
														INSERT INTO [dbo].[TSERoutePreparationDetailPiece]
													   ([TSERoutePreparationDetailId]
													   ,[PieceNumber]
													   ,[RowStatus]
													   ,[DateCreated]
													   ,[TokenCreated])
													   VALUES
													   (@IdDetail
													   ,@PieceNumber
													   ,1
													   ,GETDATE()
													   ,@Token)
		
		
													   INSERT INTO [dbo].[DeliveryOrderDetail]
													   ([Guide_Serie]
													   ,[Guide_Number]
													   ,[StatusOrderId]
													   ,[UserCreated]
													   ,[DateCreated]
													   ,[DateCreatedInSystem]
													   ,[RowStatus])
													   VALUES
													   (@SerieNumber
													   ,@GuideNumber
													   ,@StatusRecolect
													   ,@Token
													   ,GETDATE()
													   ,GETDATE()
													   ,1
													   )
		
														UPDATE DeliveryOrder 
														SET StatusOrderId = @StatusRecolect
																WHERE Guide_Serie = @SerieNumber
					    										AND Guide_Number = @GuideNumber

														DECLARE @TotalPiecesExist INT;
														DECLARE @TotalPiecesScanned INT;

														SELECT
															tsd.GuideSerie
														   ,tsd.GuideNumber
														   ,tsd.IDTSERoutePreparationDetail
														   INTO #listGuides
														FROM TSERoutePreparationDetail tsd WITH(NOLOCK)
														WHERE TSERoutePreparationHeaderID = @IdHeader--29
														--SELECT *from #listGuides
										
											

														SET @TotalPiecesExist = (SELECT COUNT(dyop.GuideNumber) FROM DeliveryOrderPiece dyop WITH(NOLOCK)
														INNER JOIN #listGuides lsg
														ON dyop.GuideSerie = lsg.GuideSerie
														AND dyop.GuideNumber = lsg.GuideNumber)

														SET @TotalPiecesScanned = (SELECT COUNT(TSERoutePreparationDetailId) FROM TSERoutePreparationDetailPiece tsep WITH(NOLOCK)
														INNER JOIN #listGuides lsg2
														ON tsep.TSERoutePreparationDetailId = lsg2.IDTSERoutePreparationDetail AND tsep.RowStatus = 1)
													
														UPDATE
															[dbo].[DeliveryOrderPiece]
														SET
															[StatusOrderId] = @StatusRecolect
															,[DateUpdated] = GETDATE()
														WHERE
															[GuideSerie] = @SerieNumber
															AND
															[GuideNumber] = @GuideNumber
															AND
															[NoPiece] = @PieceNumber

														IF(@TotalPiecesExist=@TotalPiecesScanned)
															BEGIN
																/*UPDATE TSERoutePreparationHeader
																SET HasFirstPickupProcess = 1
																WHERE IDTSERoutePreparationHeader = @IdHeader--29*/

																SELECT 7 AS ValueMessage,
																	'El total de piezas de las guías han sido ingresadas correctamente' AS MessageDescription

																--RETURN;
															END

														SELECT 1 AS ValueMessage,
																'Pieza de la guía registrada correctamente' AS MessageDescription
												 
										
												 END
											 ELSE
												 BEGIN
														SELECT 5 AS ValueMessage,
																'El numero de pieza de la guía que intenta ingresar ya fue registrada' AS MessageDescription
												 END
										END
									ELSE
										 BEGIN
											SELECT 6 AS ValueMessage,
													'El numero de pieza que desea registrar no forma parte de la guía' AS MessageDescription
										 END
		
								 END
							ELSE
								 BEGIN
									 IF((SELECT COUNT(GuideNumber) FROM DeliveryOrderPiece WITH(NOLOCK) WHERE GuideSerie =@SerieNumber/*'FD'*/ AND GuideNumber = @GuideNumber /*625196*/ AND NoPiece = @PieceNumber)>0)
										 BEGIN
												IF ((SELECT COUNT(TSERoutePreparationDetailId) FROM TSERoutePreparationDetailPiece WITH(NOLOCK) WHERE TSERoutePreparationDetailId = @IdDetail AND RowStatus = 1 AND PieceNumber = @PieceNumber) = 0)
													BEGIN
														INSERT INTO [dbo].[TSERoutePreparationDetailPiece]
														([TSERoutePreparationDetailId]
														,[PieceNumber]
														,[RowStatus]
														,[DateCreated]
														,[TokenCreated])
														VALUES
														(@IdDetail
														,@PieceNumber
														,1
														,GETDATE()
														,@Token)

														UPDATE
															[dbo].[DeliveryOrderPiece]
														SET
															[StatusOrderId] = @StatusRecolect
															,[DateUpdated] = GETDATE()
														WHERE
															[GuideSerie] = @SerieNumber
															AND
															[GuideNumber] = @GuideNumber
															AND
															[NoPiece] = @PieceNumber

											
														IF((SELECT TSECustomsMark FROM TSERoutePreparationHeader WITH(NOLOCK) WHERE IDTSERoutePreparationHeader = @IdHeader AND RowStatus = 1)IS NULL )
														BEGIN
															UPDATE [dbo].[TSERoutePreparationHeader]
															SET TSECustomsMark = @TSEMark
															WHERE IDTSERoutePreparationHeader = @IdHeader
												
														END
														SELECT 1 AS ValueMessage,
																'Pieza de la guía registrada correctamente' AS MessageDescription
													END
												ELSE
													BEGIN
														SELECT 2 AS ValueMessage,
																'La pieza que intenta ingresar ya fue registrada anteriormente' AS MessageDescription
										
													END
										 END
								 ELSE
										 BEGIN
											SELECT 3 AS ValueMessage,
												'El numero de pieza que desea ingresar no forma parte de la guía' AS MessageDescription

										 END

								 END
						END


					 ELSE
						BEGIN

							SELECT 4 AS ValueMessage,
								'Las piezas de la guía que desea ingresar ya han sido ingresadas por completo' AS MessageDescription


						END
			 END
		ELSE
		BEGIN
				SELECT 8 AS ValueMessage,
				'La guía no corresponde a la ruta o es un sobre' AS MessageDescription
		END

		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SELECT ERROR_LINE(),ERROR_MESSAGE(),ERROR_NUMBER()

		SELECT 
			8 AS ValueMessage,
			'Marchamo ingresado anteriormente en otra ruta, verifique su información.' AS MessageDescription
	END CATCH

	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
	DROP TABLE #listGuides;
END