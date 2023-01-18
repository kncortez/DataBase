-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <25-07-2022>
-- Description:	<Get all open processes in LinehaulRoutePreparationContainerDetail by IdLinehaulRoutePreparation>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getOpenProcessByIdLinehauLRoutePreparation]
	@IdLinehaulRoutePreparation AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT		[LRPC].[ContainerId],
				[LRPCD].[IdLinehaulRoutePreparationContainerDetail],
				[LRPCD].[LinehaulRoutePreparationContainerId],
				[LRPCD].[GuideSerie],
				[LRPCD].[GuideNumber],
				[LRPCD].[GuideDryPieceTotal], 
				[LRPCD].[GuideColdPieceTotal],
				[LRPCD].[DryPieceQuantity], 
				[LRPCD].[ColdPieceQuantity],
				[LRPCD].[IsOpenProcess]
	FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
		ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
	INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
		ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
		AND		[LRP].IdLinehaulRoutePreparation = @IdLinehaulRoutePreparation
	WHERE		[LRPCD].[IsOpenProcess] = 1 
		AND		[LRPCD].[RowStatus] = 1;

END