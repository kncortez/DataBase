-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <21-07-2022>
-- Description:	<Get an existing guide in LinehaulRoutePreparation with rowStatus = 1>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getGuideInLinehaulRoutePreparation]
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT		[LRP].[CatRouteId],
				[CR].[CodeRoute],
				[CR].[Description],
				COALESCE([LRP].[CatVehicleId], 0) AS CatVehicleId,
				[CV].[UnitNumber],
				COALESCE([LRP].[SenderReceiverId], 0) AS SenderReceiverId,
				COALESCE([LRP].[CatLinehaulStatusId], 0) AS CatLinehaulStatusId,
				[CLS].[StatusName],
				[LRP].[DateLinehaulRoutePreparation],
				[LRP].[DateCreated],
				[LRPC].[LinehaulRoutePreparationId],
				[LRPC].[ContainerId],
				[C].[CatTypeContainerId],
				[CTP].[TypeContainerSerie],
				[C].[ContainerNumber],
				[LRPC].[HubDestinyId],
				[HL].[HubName],
				[HL].[HubAbbreviation],
				[LRPCD].[IdLinehaulRoutePreparationContainerDetail],
				[LRPCD].[LinehaulRoutePreparationContainerId],
				[LRPCD].[GuideSerie],
				[LRPCD].[GuideNumber],
				[LRPCD].[GuideDryPieceTotal],
				[LRPCD].[GuideColdPieceTotal],
				[LRPCD].[DryPieceQuantity],
				[LRPCD].[ColdPieceQuantity]
	FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
		ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
	INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
		ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
	INNER JOIN	[dbo].[CatRoute] CR
		ON		[LRP].[CatRouteId] = [CR].[IdRoute]
	LEFT JOIN	[dbo].[CatVehicle] CV
		ON		[LRP].[CatVehicleId] = [CV].[IdVehicle]
	INNER JOIN	[dbo].[CatLinehaulStatus] CLS
		ON		[LRP].[CatLinehaulStatusId] = [CLS].[IdCatLinehaulStatus]
	INNER JOIN	[dbo].[Container] C
		ON		[LRPC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTP
		ON		[C].[CatTypeContainerId] = [CTP].[IdCatTypeContainer]
	INNER JOIN	[dbo].[HubLogistics] HL
		ON		[LRPC].[HubDestinyId] = [HL].[IdHubLogistic]
	WHERE		[LRPCD].[GuideSerie] = @GuideSerie
		AND		[LRPCD].[GuideNumber] = @GuideNumber
		AND		[LRPCD].[RowStatus] = 1;
END