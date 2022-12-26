-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <12-09-2022>
-- Description:	<Get TOP 20 guides in LinehaulRoutePreparationContainerDetail>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetTopGuidesLinehaulRoutePreparation]
	@LinehaulRoutePreparationId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT		TOP 40
				[LRPCD].[GuideSerie],
				[LRPCD].[GuideNumber],
				[LRPCD].[DryPieceQuantity],
				[LRPCD].[ColdPieceQuantity],
				[CTC].[TypeContainerSerie],
				[C].[ContainerNumber]
	FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
		ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
		AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
	INNER JOIN	[dbo].[Container] C
		ON		[LRPC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTC
		ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
	WHERE		[LRPCD].[RowStatus] = 1
	AND			[LRPCD].[IsOpenProcess] = 0
	ORDER BY	[LRPCD].[DateCreated] DESC;
    
END