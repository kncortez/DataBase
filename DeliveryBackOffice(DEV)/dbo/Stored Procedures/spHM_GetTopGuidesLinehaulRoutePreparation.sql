-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <12-09-2022>
-- Description:	<Get TOP 20 guides in LinehaulRoutePreparationContainerDetail>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <20-01-2025>
-- Description:	<Se agrego ticket number para guías que tengan código de referencia>
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
				ISNULL([DO].[Ticket_Number],'') AS 'TicketNumber',
				[LRPCD].[DryPieceQuantity],
				[LRPCD].[ColdPieceQuantity],
				[CTC].[TypeContainerSerie],
				[C].[ContainerNumber]
	FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD  WITH(NOLOCK)
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC WITH(NOLOCK)
		ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
		AND		[LRPC].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
	INNER JOIN	[dbo].[Container] C WITH(NOLOCK)
		ON		[LRPC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTC WITH(NOLOCK)
		ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
	LEFT JOIN	[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		ON		[LRPCD].[GuideSerie] = [DO].[Guide_Serie] AND [LRPCD].[GuideNumber] = [DO].[Guide_Number]
	WHERE		[LRPCD].[RowStatus] = 1
	AND			[LRPCD].[IsOpenProcess] = 0
	ORDER BY	[LRPCD].[DateCreated] DESC;
    
END