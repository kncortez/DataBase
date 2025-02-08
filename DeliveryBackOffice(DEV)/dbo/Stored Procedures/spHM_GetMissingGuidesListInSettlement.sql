-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <19-08-2022>
-- Description:	<Get missing guides list>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <23-01-2025>
-- Description:	<Enviar Ticket Number si tiene relación con una guía.>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetMissingGuidesListInSettlement]
	@LinehaulRoutePreparationId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT		[CTC].[TypeContainerSerie],
				[C].[ContainerNumber],
				[LRPCD].[GuideSerie],
				[LRPCD].[GuideNumber],
				ISNULL([DO].[Ticket_Number],'') AS TicketNumber,
				COALESCE([LRPCDP].[PieceNumber], 0) AS PieceNumber,
				COALESCE([LRPCDP].[IsDryPiece], 0) AS IsDryPiece
	FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP WITH(NOLOCK)
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH(NOLOCK)
		ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC WITH(NOLOCK)
		ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
	INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP WITH(NOLOCK)
		ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
		AND		[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId
	INNER JOIN	[dbo].[Container] C WITH(NOLOCK)
		ON		[LRPC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTC WITH(NOLOCK)
		ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
	LEFT JOIN	[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		ON		[LRPCD].[GuideSerie] = [DO].[Guide_Serie] AND [LRPCD].[GuideNumber] = [DO].[Guide_Number]
	WHERE		[LRPCDP].[CatLinehaulStatusId] = (SELECT	[CLS].[IdCatLinehaulStatus] 
												FROM	[dbo].[CatLinehaulStatus] CLS
												WHERE	[CLS].[StatusName] = 'IN TRANSIT')
		AND		[LRPCDP].[ActCode] IS NULL
		AND		[LRPCDP].[RowStatus] = 1
	UNION
	SELECT		[CTC].[TypeContainerSerie],
				[C].[ContainerNumber],
				[LRSCD].[GuideSerie],
				[LRSCD].[GuideNumber],
				ISNULL([DO].[Ticket_Number],'') AS TicketNumber,
				COALESCE([LRSCDP].[PieceNumber], 0) AS PieceNumber,
				COALESCE([LRSCDP].[IsDryPiece], 0) AS IsDryPiece
	FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP WITH(NOLOCK)
	INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD WITH(NOLOCK)
		ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
	INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC WITH(NOLOCK)
		ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
	INNER JOIN	[dbo].[LinehaulRouteSettlement] LRS WITH(NOLOCK)
		ON		[LRSC].[LinehaulRouteSettlementId] = [LRS].[IdLinehaulRouteSettlement]
		AND		[LRS].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
	INNER JOIN	[dbo].[Container] C WITH(NOLOCK)
		ON		[LRSC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTC WITH(NOLOCK)
		ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
	LEFT JOIN	[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		ON		[LRSCD].[GuideSerie] = [DO].[Guide_Serie] AND [LRSCD].[GuideNumber] = [DO].[Guide_Number]
	WHERE 		[LRSCDP].[RowStatus] = 0
	ORDER BY	[CTC].[TypeContainerSerie],
				[C].[ContainerNumber],
				[GuideNumber],
				[PieceNumber];
END