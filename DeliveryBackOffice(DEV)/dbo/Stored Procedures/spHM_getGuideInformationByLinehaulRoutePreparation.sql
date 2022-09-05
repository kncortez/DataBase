-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <02-09-2022>
-- Description:	<Get guide information by filter in Linehaul Route Preparation>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getGuideInformationByLinehaulRoutePreparation]
	@LinehaulRoutePreparationId AS INT,
	@GuideSerie AS NVARCHAR(5),
	@GuideNumber AS NVARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT		[LRP].[IdLinehaulRoutePreparation],
				[LRP].[CatLinehaulStatusId],
				[CLS].[StatusName],
				[LRPC].[ContainerId],
				[C].[CatTypeContainerId],
				[CTC].[TypeContainerSerie],
				[C].[ContainerNumber],
				[C].[ContainerDescription],
				[LRPC].[HubDestinyId],
				[HL].[HubAbbreviation],
				[HL].[HubName],
				[LRPCD].[GuideSerie],
				[LRPCD].[GuideNumber],
				[LRPCD].[GuideColdPieceTotal],
				[LRPCD].[GuideDryPieceTotal],
				[LRPCDP].[PieceNumber],
				[LRPCDP].[IsDryPiece],
				COALESCE([LRPCDP].[ActCode], 0) AS ActCode
	FROM		[dbo].[LinehaulRoutePreparationContainerDetailPiece] LRPCDP
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		ON		[LRPCDP].[LinehaulRoutePreparationContainerDetailId] = [LRPCD].[IdLinehaulRoutePreparationContainerDetail]
		AND		[LRPCD].[GuideSerie] = @GuideSerie
		AND		[LRPCD].[GuideNumber] = @GuideNumber
		AND		[LRPCD].[RowStatus] = 1
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
		ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
	INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
		ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
		AND		[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId
		AND		[LRP].[RowStatus] = 1
	INNER JOIN	[dbo].[CatLinehaulStatus] CLS
		ON		[LRP].[CatLinehaulStatusId] = [CLS].[IdCatLinehaulStatus]
	INNER JOIN	[dbo].[Container] C
		ON		[LRPC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTC
		ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
	INNER JOIN	[dbo].[HubLogistics] HL
		ON		[LRPC].[HubDestinyId] = [HL].[IdHubLogistic];
END