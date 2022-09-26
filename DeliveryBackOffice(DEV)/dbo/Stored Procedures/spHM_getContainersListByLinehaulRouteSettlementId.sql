-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <09-08-2022>
-- Description:	<Get list of all containers in Linehaul settlement process>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getContainersListByLinehaulRouteSettlementId]
	@LinehaulRouteSettlementId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT		[LRSC].[IdLinehaulRouteSettlementContainer],
				[LRSC].[LinehaulRouteSettlementId], 
				[LRSC].[ContainerId],
				[C].[CatTypeContainerId],
				[CTC].[TypeContainerSerie],
				[C].[ContainerNumber],
				[LRSC].[HubId],
				[HL].[HubAbbreviation],
				[HL].[HubName],
				[LRSC].[GuideQuantity],
				[LRSC].[DryPiecesQuantity], 
				[LRSC].[ColdPiecesQuantity]
	FROM		[dbo].[LinehaulRouteSettlementContainer] LRSC
	INNER JOIN	[dbo].[Container] C
		ON		[LRSC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTC
		ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
	INNER JOIN	[dbo].[HubLogistics] HL
		ON		[LRSC].[HubId] = [HL].[IdHubLogistic]
	WHERE		[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
		AND		[LRSC].[RowStatus] = 1;
END