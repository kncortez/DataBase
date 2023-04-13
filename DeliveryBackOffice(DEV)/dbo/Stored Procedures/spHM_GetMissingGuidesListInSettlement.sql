-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <19-08-2022>
-- Description:	<Get missing guides list>
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
				COALESCE([LRPCDP].[PieceNumber], 0) AS PieceNumber,
				COALESCE([LRPCDP].[IsDryPiece], 0) AS IsDryPiece
	FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
		ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
	INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
		ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
		AND		[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId
	INNER JOIN	[dbo].[Container] C
		ON		[LRPC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTC
		ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
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
				COALESCE([LRSCDP].[PieceNumber], 0) AS PieceNumber,
				COALESCE([LRSCDP].[IsDryPiece], 0) AS IsDryPiece
	FROM		[dbo].[LinehaulRouteSettlementContainerDetailPiece] LRSCDP
	INNER JOIN	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
		ON		[LRSCDP].[LinehaulRouteSettlementContainerDetailId] = [LRSCD].[IdLinehaulRouteSettlementContainerDetail]
	INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
		ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
	INNER JOIN	[dbo].[LinehaulRouteSettlement] LRS
		ON		[LRSC].[LinehaulRouteSettlementId] = [LRS].[IdLinehaulRouteSettlement]
		AND		[LRS].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
	INNER JOIN	[dbo].[Container] C
		ON		[LRSC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTC
		ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
	WHERE 		[LRSCDP].[RowStatus] = 0
	ORDER BY	[CTC].[TypeContainerSerie],
				[C].[ContainerNumber],
				[GuideNumber],
				[PieceNumber];
END