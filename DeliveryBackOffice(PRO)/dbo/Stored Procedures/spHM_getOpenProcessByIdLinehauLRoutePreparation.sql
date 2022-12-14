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
				[CTC].[TypeContainerSerie],
				[C].[ContainerNumber],
				[LRPCD].[GuideSerie],
				[LRPCD].[GuideNumber],
				[LRPCD].[GuideDryPieceTotal], 
				[LRPCD].[GuideColdPieceTotal],
				[LRPCD].[DryPieceQuantity], 
				[LRPCD].[ColdPieceQuantity],
				[LRPCD].[IsOpenProcess],
				[LRPCD].[TokenCreated],
				[IU].[Username] [TknCreatedUser],
				COALESCE([LRPCD].[TokenUpdated], '') [TokenUpdated],
				COALESCE([IUB].[Username], '') [TknUpdatedUser]
	FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
	INNER JOIN	[dbo].[LinehaulRoutePreparationContainer] LRPC
		ON		[LRPCD].[LinehaulRoutePreparationContainerId] = [LRPC].[IdLinehaulRoutePreparationContainer]
	INNER JOIN	[dbo].[LinehaulRoutePreparation] LRP
		ON		[LRPC].[LinehaulRoutePreparationId] = [LRP].[IdLinehaulRoutePreparation]
		AND		[LRP].IdLinehaulRoutePreparation = @IdLinehaulRoutePreparation
	INNER JOIN	[dbo].[Container] C
		ON		[LRPC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTC
		ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
	INNER JOIN	[dbo].[TokenLog] TL
		ON		[LRPCD].[TokenCreated] = [TL].[TknIdToken]
	INNER JOIN	[dbo].[InternalUser] IU
		ON		[TL].[TknIdUser] = [IU].[RegisterUserID]
	LEFT JOIN	[dbo].[TokenLog] TLB
		ON		[LRPCD].[TokenUpdated] = [TLB].[TknIdToken]
	LEFT JOIN	[dbo].[InternalUser] IUB
		ON		[TLB].[TknIdUser] = [IUB].[RegisterUserID]
	WHERE		[LRPCD].[IsOpenProcess] = 1 
		AND		[LRPCD].[RowStatus] = 1;

END