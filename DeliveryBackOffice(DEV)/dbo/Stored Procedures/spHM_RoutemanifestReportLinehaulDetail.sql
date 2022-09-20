-- =============================================
-- Author:		<Edelman vásquez>
-- Create date: <2022-08-05>
-- Description:	<detalle de reporte manifiesto linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_RoutemanifestReportLinehaulDetail] 
@IdLinehaulRoutePreparation AS INT 	
AS
BEGIN
	
	SET NOCOUNT ON;

 SELECT  ROW_NUMBER() OVER(
       ORDER BY  LRPC.LinehaulRoutePreparationId) AS NumberRow,
        LRPC.LinehaulRoutePreparationId,
         C.ContainerDescription,
		ISNULL(LRPC.GuideQuantity,0)   AS Totaldeguiasasignadasacontenedor,
		ISNULL(LRPC.ColdPieceQuantity,0)  AS TotaldePiezasFriasAsignadasaContenedor,
		ISNULL(LRPC.DryPieceQuantity,0)    AS TotaldePiezasAsignadasContenedor,
		 HL.HubName AS HubDestinyId
  FROM   LinehaulRoutePreparationContainer LRPC WITH (NOLOCK)
		INNER JOIN LinehaulRoutePreparationContainerDetail LRPCD WITH (NOLOCK)
			ON LRPC.IdLinehaulRoutePreparationContainer = LRPCD.LinehaulRoutePreparationContainerId
		LEFT JOIN Container C WITH (NOLOCK)
			ON LRPC.ContainerId = C.IdContainer
		LEFT JOIN dbo.HubLogistics HL
		    ON HL.IdHubLogistic = LRPC.HubDestinyId
  WHERE C.ContainerDescription NOT LIKE ('%lh%') AND LRPC.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
	    AND LRPC.GuideQuantity>0
	 GROUP BY LRPC.LinehaulRoutePreparationId, 
	              C.ContainerDescription, 
			     HL.HubName,
				 LRPC.GuideQuantity,
				 LRPC.ColdPieceQuantity,
				 LRPC.DryPieceQuantity

END