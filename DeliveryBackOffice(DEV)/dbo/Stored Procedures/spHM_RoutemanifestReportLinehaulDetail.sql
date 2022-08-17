USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spHM_RoutemanifestReportLinehaulDetail]    Script Date: 17/08/2022 12:58:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Edelman vásquez>
-- Create date: <2022-08-05>
-- Description:	<detalle de reporte manifiesto linehauls>
-- =============================================
ALTER PROCEDURE [dbo].[spHM_RoutemanifestReportLinehaulDetail] 
@IdLinehaulRoutePreparation AS INT 	
AS
BEGIN
	
	SET NOCOUNT ON;

 SELECT  LRPC.LinehaulRoutePreparationId,
         C.ContainerDescription,
		sum(LRPC.GuideQuantity)                 AS Totaldeguiasasignadasacontenedor,
		SUM( ISNULL(LRPC.ColdPieceQuantity,0))  AS TotaldePiezasFriasAsignadasaContenedor,
		SUM( ISNULL(LRPC.DryPieceQuantity,0))   AS TotaldePiezasAsignadasContenedor,
		 LRPC.HubDestinyId
  FROM   LinehaulRoutePreparationContainer LRPC WITH (NOLOCK)
		INNER JOIN LinehaulRoutePreparationContainerDetail LRPCD WITH (NOLOCK)
			ON LRPC.IdLinehaulRoutePreparationContainer = LRPCD.LinehaulRoutePreparationContainerId
		LEFT JOIN Container C WITH (NOLOCK)
			ON LRPC.ContainerId = C.IdContainer
  WHERE C.ContainerDescription NOT LIKE ('%lh%') AND LRPC.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
	  GROUP BY LRPC.LinehaulRoutePreparationId, 
	              C.ContainerDescription, 
			   LRPC.HubDestinyId

END
