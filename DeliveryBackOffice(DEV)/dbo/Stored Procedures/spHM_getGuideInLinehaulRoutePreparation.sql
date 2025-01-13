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
	DECLARE @LIQUIDATED_STATUS_ID AS INT;
	DECLARE @STOPOVER_STATUS_ID AS INT;

	SET @LIQUIDATED_STATUS_ID = (SELECT [CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'LIQUIDATED');

	SET @STOPOVER_STATUS_ID = (SELECT	[CLS].[IdCatLinehaulStatus]
								FROM	[dbo].[CatLinehaulStatus] CLS
								WHERE	[CLS].[StatusName] = 'STOPOVER');

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
	FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH (NOLOCK)
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
		ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
	INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
		ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
	INNER JOIN	[dbo].[CatRoute] CR WITH (NOLOCK)
		ON		[LRP].[CatRouteId] = [CR].[IdRoute]
	LEFT JOIN	[dbo].[CatVehicle] CV WITH (NOLOCK)
		ON		[LRP].[CatVehicleId] = [CV].[IdVehicle]
	INNER JOIN	[dbo].[CatLinehaulStatus] CLS WITH (NOLOCK)
		ON		[LRP].[CatLinehaulStatusId] = [CLS].[IdCatLinehaulStatus]
	INNER JOIN	[dbo].[Container] C WITH (NOLOCK)
		ON		[LRPC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTP WITH (NOLOCK)
		ON		[C].[CatTypeContainerId] = [CTP].[IdCatTypeContainer]
	INNER JOIN	[dbo].[HubLogistics] HL WITH (NOLOCK)
		ON		[LRPC].[HubDestinyId] = [HL].[IdHubLogistic]
	WHERE		[LRPCD].[GuideSerie] = @GuideSerie
		AND		[LRPCD].[GuideNumber] = @GuideNumber
		AND		[LRPCD].[IsOpenProcess] = 0
		AND		[LRPCD].[RowStatus] = 1
		AND		[LRPC].[CatLinehaulStatusId] != @LIQUIDATED_STATUS_ID
		AND		[LRPC].[CatLinehaulStatusId] != @STOPOVER_STATUS_ID
END