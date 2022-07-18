CREATE PROCEDURE [dbo].[Get_FilterCodeGuide]
@GuideSerie VARCHAR(2),
@GuideNumber INT,
@NumberPiece AS INT
--@IdLinehauls INT

AS
	BEGIN
			SELECT 
				ctci.TypeContainerSerie AS ContainerSerie, 
				cti.ContainerNumber ContainerNumber, 
				hlg.HubName Hub,
				tws.TownshipName AS Township,
				lrpcdp.DateCreated AS DateCreated, 
				lrpc.LinehaulRoutePreparationId AS Route, 
				(prs.PerFirstName+ ' '+ prs.PerLastName) AS UserName
				INTO #Data
				FROM LinehaulRoutePreparationContainerDetailPiece lrpcdp WITH (NOLOCK)
				INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
				ON lrpcdp.LinehaulRoutePreparationContainerDetailId = lrpcd.IdLinehaulRoutePreparationContainerDetail
				INNER JOIN LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
				ON lrpcd.LinehaulRoutePreparationContainerId = lrpc.IdLinehaulRoutePreparationContainer
				INNER JOIN TokenLog tl WITH (NOLOCK)
				ON lrpcdp.TokenCreated = tl.TknIdToken
				INNER JOIN RegisterUser rgu WITH (NOLOCK)
				ON tl.TknIdUser = rgu.UsrIdUser
				INNER JOIN Person prs WITH (NOLOCK)
				ON rgu.UsrIdPerson = prs.PerIdPerson
				INNER JOIN Container cti WITH (NOLOCK)
				ON lrpc.ContainerId = cti.IdContainer
				INNER JOIN CatTypeContainer ctci WITH (NOLOCK)
				ON cti.IdContainer = ctci.IdCatTypeContainer
				INNER JOIN HubLogistics hlg WITH (NOLOCK)
				ON lrpc.HubDestinyId = hlg.IdHubLogistic
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON lrpcd.GuideNumber = do.Guide_Number
				AND lrpcd.GuideSerie = do.Guide_Serie
				INNER JOIN Township tws WITH (NOLOCK)
				ON do.ReceiverIdTownship = tws.IdTownship
				WHERE lrpcd.GuideNumber = @GuideNumber
				AND lrpcd.GuideSerie = @GuideSerie
				AND lrpcdp.PieceNumber = @NumberPiece
				AND do.StatusOrderId <> 7
				

			IF(SELECT COUNT(*)FROM #Data) > 0 
				BEGIN

						SELECT
						200 AS 'StatusCode'
						,'Datos encontrados exitosamente.' AS 'Description'
 
						SELECT *FROM #Data

				END
			ELSE
				BEGIN

					SELECT
						404 AS 'StatusCode'
						,'No se encontraron datos relacionados con la guía.' AS 'Description'

					 IF OBJECT_ID('tempdb.dbo.#User', 'U') IS NOT NULL
						DROP TABLE #Data;
				END

	END