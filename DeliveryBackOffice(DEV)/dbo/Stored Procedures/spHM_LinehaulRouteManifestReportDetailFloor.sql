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

	 SELECT DISTINCT
	     ROW_NUMBER () OVER(ORDER BY LRPC.IdLinehaulRoutePreparationContainer ) NumberRow,
	     C.ContainerDescription,
		 --isnull(LRPC.GuideQuantity,0)      AS Totaldeguiasasignadasacontenedor,
		 -- nuevo hacer rolback si falla con la linea de arriba
		 count(lrpcd.GuideNumber) AS Totaldeguiasasignadasacontenedor,
		 ISNULL(LRPC.ColdPieceQuantity,0)  AS TotaldePiezasFriasAsignadasaPiso,
		 --isnull(LRPC.DryPieceQuantity,0)   AS TotaldePiezasAsignadasaPiso,
		-- nuevo hacer rolback si falla con la linea de arriba
		sum(LRPCD.GuideDryPieceTotal)AS TotaldePiezasAsignadasaPiso,
		  HL.HubAbbreviation AS HubDestinyId
  FROM   LinehaulRoutePreparationContainer LRPC WITH (NOLOCK)
		INNER JOIN LinehaulRoutePreparationContainerDetail LRPCD WITH (NOLOCK)
				ON LRPC.IdLinehaulRoutePreparationContainer = LRPCD.LinehaulRoutePreparationContainerId
		LEFT JOIN Container C WITH (NOLOCK)
				ON LRPC.ContainerId = C.IdContainer
		LEFT JOIN dbo.HubLogistics HL
		       ON HL.IdHubLogistic = LRPC.HubDestinyId
  WHERE C.ContainerDescription  LIKE ('%lh%') AND LRPC.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
  GROUP BY LRPC.IdLinehaulRoutePreparationContainer,
           LRPC.HubDestinyId,C.ContainerDescription, 
		   HL.HubAbbreviation, LRPC.GuideQuantity,
		   LRPC.ColdPieceQuantity,
		   LRPC.DryPieceQuantity



  
END