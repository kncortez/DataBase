-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <29-08-2022>
-- Description:	<Get active (ActCode = NULL && RowStatus = 1) pieces added in LinehaulRoutePreparation by Guide Number>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetActivePiecesInDispatchByGuideNumber]
	@LinehaulRoutePreparationId AS INT,
	@GuideSerie AS NVARCHAR(5),
	@GuideNumber AS NVARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT		[LRPCD].[GuideSerie],
				[LRPCD].[GuideNumber],
				[LRPCDP].[PieceNumber]
	FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
		AND		[LRPCD].[GuideSerie] = @GuideSerie
		AND		[LRPCD].[GuideNumber] = @GuideNumber
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
		ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
	INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
		ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
		AND		[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId
	WHERE		[LRPCDP].[ActCode] IS NULL
		AND		[LRPCDP].[RowStatus] = 1;
END