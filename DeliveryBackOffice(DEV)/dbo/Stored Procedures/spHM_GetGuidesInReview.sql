
-- =============================================
-- Author:		<Cristian, Suazo>
-- Create date: <05-10-2025>
-- Description:	<Trae las guias que faltan por escanear para linehaul>
-- =============================================

ALTER PROCEDURE spHM_GetGuidesInReview
@LinehaulRouteSettlementId INT 

AS
BEGIN
	DECLARE @IN_TRANSIT_STATUS_ID INT = (SELECT	[CLS].[IdCatLinehaulStatus]
											FROM	[dbo].[CatLinehaulStatus] CLS WITH (NOLOCK)
											WHERE	[CLS].[StatusName] = 'IN TRANSIT');

	DECLARE @LRP_ID INT = (SELECT	[LRS].[LinehaulRoutePreparationId]
							FROM	[dbo].[LinehaulRouteSettlement] LRS WITH (NOLOCK)
							WHERE	[LRS].[IdLinehaulRouteSettlement] = @LinehaulRouteSettlementId)

	SELECT 
		CONCAT(LRPCD.GuideSerie,
		LRPCD.GuideNumber,'-',
		LRPCDP.PieceNumber) AS Guides
	FROM dbo.LinehaulRoutePreparationContainerDetailPiece LRPCDP WITH (NOLOCK)
	INNER JOIN dbo.LinehaulRoutePreparationContainerDetail LRPCD WITH (NOLOCK)
		ON LRPCDP.LinehaulRoutePreparationContainerDetailId = LRPCD.IdLinehaulRoutePreparationContainerDetail
	INNER JOIN dbo.LinehaulRoutePreparationContainer LRPC WITH (NOLOCK)
		ON LRPCD.LinehaulRoutePreparationContainerId = LRPC.IdLinehaulRoutePreparationContainer
	INNER JOIN dbo.LinehaulRoutePreparation LRP WITH (NOLOCK)
		ON LRPC.LinehaulRoutePreparationId = LRP.IdLinehaulRoutePreparation
	INNER JOIN dbo.Container C WITH (NOLOCK)
		ON LRPC.ContainerId = C.IdContainer
	INNER JOIN dbo.CatTypeContainer CTC WITH (NOLOCK)
		ON C.CatTypeContainerId = CTC.IdCatTypeContainer
	WHERE LRPCDP.CatLinehaulStatusId = @IN_TRANSIT_STATUS_ID
		AND LRPCDP.ActCode IS NULL
		AND LRPCD.RowStatus = 1
		AND LRP.IdLinehaulRoutePreparation = @LRP_ID
END