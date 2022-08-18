-- =============================================
-- Author:		<Edelma Vásquez>
-- Create date: <2022-08-05>
-- Description:	<Detalle de reporte rutas linehauls contenedor de piso >
-- =============================================
CREATE PROCEDURE [dbo].[spHM_LinehaulRouteManifestReportDetailFloor] 
	
	@IdLinehaulRoutePreparation AS INT 	
AS
BEGIN

	SET NOCOUNT ON;

	 SELECT 
	     C.ContainerDescription,
		 SUM(ISNULL(LRPC.GuideQuantity,0))      AS Totaldeguiasasignadasacontenedor,
		 SUM(ISNULL(LRPC.ColdPieceQuantity,0))  AS TotaldePiezasFriasAsignadasaPiso,
		 SUM(ISNULL(LRPC.DryPieceQuantity,0))   AS TotaldePiezasAsignadasaPiso,
		  HL.HubName AS HubDestinyId
  FROM   LinehaulRoutePreparationContainer LRPC WITH (NOLOCK)
		INNER JOIN LinehaulRoutePreparationContainerDetail LRPCD WITH (NOLOCK)
				ON LRPC.IdLinehaulRoutePreparationContainer = LRPCD.LinehaulRoutePreparationContainerId
		LEFT JOIN Container C WITH (NOLOCK)
				ON LRPC.ContainerId = C.IdContainer
		LEFT JOIN dbo.HubLogistics HL
		       ON HL.IdHubLogistic = LRPC.HubDestinyId
  WHERE C.ContainerDescription  LIKE ('%lh%') AND LRPC.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
  GROUP BY LRPC.HubDestinyId,C.ContainerDescription, HL.HubName



  
END