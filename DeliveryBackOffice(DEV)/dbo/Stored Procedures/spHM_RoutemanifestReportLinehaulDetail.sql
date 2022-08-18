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

 SELECT  LRPC.LinehaulRoutePreparationId,
         C.ContainerDescription,
		sum(LRPC.GuideQuantity)                 AS Totaldeguiasasignadasacontenedor,
		SUM(ISNULL(LRPC.ColdPieceQuantity,0))   AS TotaldePiezasFriasAsignadasaContenedor,
		SUM(ISNULL(LRPC.DryPieceQuantity,0))    AS TotaldePiezasAsignadasContenedor,
		 HL.HubName AS HubDestinyId
  FROM   LinehaulRoutePreparationContainer LRPC WITH (NOLOCK)
		INNER JOIN LinehaulRoutePreparationContainerDetail LRPCD WITH (NOLOCK)
			ON LRPC.IdLinehaulRoutePreparationContainer = LRPCD.LinehaulRoutePreparationContainerId
		LEFT JOIN Container C WITH (NOLOCK)
			ON LRPC.ContainerId = C.IdContainer
		LEFT JOIN dbo.HubLogistics HL
		    ON HL.IdHubLogistic = LRPC.HubDestinyId
  WHERE C.ContainerDescription NOT LIKE ('%lh%') AND LRPC.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
	  GROUP BY LRPC.LinehaulRoutePreparationId, 
	              C.ContainerDescription, 
			     HL.HubName

END