-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <11-07-2022>
-- Description:	<Get list of associated containers in a Linehaul Route Preparation process>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getContainersListByLinehaulRoutePreparationId] 
	@LinehaulRoutePreparationId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT	[LRPC].[IdLinehaulRoutePreparationContainer],
			[LRPC].[LinehaulRoutePreparationId],
			[LRPC].[ContainerId],
			[CNT].[CatTypeContainerId],
			[CTC].[TypeContainerSerie],
			[CNT].[ContainerNumber],
			[CNT].[ContainerDescription],
			[LRPC].[GuideQuantity],
			[LRPC].[DryPieceQuantity],
			[LRPC].[ColdPieceQuantity]
	FROM [dbo].[LinehaulRoutePreparationContainer] LRPC
	INNER JOIN	[dbo].[Container] CNT
		ON	[LRPC].[ContainerId] = [CNT].[IdContainer]
		AND	[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
	INNER JOIN [dbo].[CatTypeContainer] CTC
		ON	[CNT].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
	ORDER BY [CNT].[IdContainer];
END