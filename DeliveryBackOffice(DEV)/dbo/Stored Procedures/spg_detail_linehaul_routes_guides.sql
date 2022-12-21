-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-12-2>
-- Description:	<Obtiene información de las guías del manifiesto de rutas linehaul>
-- =============================================
CREATE PROCEDURE [dbo].[spg_detail_linehaul_routes_guides]
	-- Add the parameters for the stored procedure here
	@IdLinehaulRoutePreparation INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		ROW_NUMBER() OVER(ORDER BY hl.HubName ASC) [No]
		,CONCAT(lrpcd.GuideSerie, lrpcd.GuideNumber) Guide
	   ,CONCAT((lrpcd.DryPieceQuantity + lrpcd.ColdPieceQuantity), '/', (lrpcd.GuideDryPieceTotal + lrpcd.GuideColdPieceTotal)) Pieces
	   ,c.ContainerDescription ContainerDescription
	   ,hl.HubAbbreviation
	   ,so.OrderDescription StatusDescription
	   ,ad.ActId Act
	FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
	INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
		ON lrpcd.LinehaulRoutePreparationContainerId = lrpc.IdLinehaulRoutePreparationContainer
			AND lrpcd.RowStatus = 1
	INNER JOIN Container c WITH (NOLOCK)
		ON c.IdContainer = lrpc.ContainerId
	INNER JOIN HubLogistics hl WITH (NOLOCK)
		ON hl.IdHubLogistic = lrpc.HubDestinyId
	INNER JOIN DeliveryOrder do WITH (NOLOCK)
		ON lrpcd.GuideSerie = do.Guide_Serie
			AND lrpcd.GuideNumber = do.Guide_Number
	INNER JOIN StatusOrder so WITH (NOLOCK)
		ON do.StatusOrderId = so.StatusOrderId
	LEFT JOIN ActDetail ad WITH (NOLOCK)
		ON lrpcd.GuideSerie = ad.GuideSerie
			AND lrpcd.GuideNumber = ad.GuideNumber
			AND ad.RowStatus = 1
	WHERE lrpc.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
	AND lrpc.RowStatus = 1
	ORDER BY hl.HubName
END