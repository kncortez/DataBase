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
		 LRPC.HubDestinyId
  FROM   LinehaulRoutePreparationContainer LRPC
		INNER JOIN LinehaulRoutePreparationContainerDetail LRPCD WITH (NOLOCK)
				ON LRPC.IdLinehaulRoutePreparationContainer = LRPCD.LinehaulRoutePreparationContainerId
		LEFT JOIN Container C WITH (NOLOCK)
				ON LRPC.ContainerId = C.IdContainer
  WHERE C.ContainerDescription  LIKE ('%lh%') AND LRPC.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
  GROUP BY LRPC.HubDestinyId,C.ContainerDescription



  
END