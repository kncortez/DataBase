-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <09-12-2022>
-- Description:	<Get open process list in linehaul settlement>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_checkOpenProcessLinehaulSettlement]
	@LinehaulRouteSettlementId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT		[CTC].[TypeContainerSerie],
				[C].[ContainerNumber],
				[LRSCD].[GuideSerie],
				[LRSCD].[GuideNumber],
				[LRSCD].[UserProcess],
				[IU].[Username]
	FROM		[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
	INNER JOIN	[dbo].[LinehaulRouteSettlementContainer] LRSC
		ON		[LRSCD].[LinehaulRouteSettlementContainerId] = [LRSC].[IdLinehaulRouteSettlementContainer]
		AND		[LRSC].[LinehaulRouteSettlementId] = @LinehaulRouteSettlementId
	INNER JOIN	[dbo].[Container] C
		ON		[LRSC].[ContainerId] = [C].[IdContainer]
	INNER JOIN	[dbo].[CatTypeContainer] CTC
		ON		[C].[CatTypeContainerId] = [CTC].[IdCatTypeContainer]
	INNER JOIN	[dbo].[TokenLog] TL
		ON		[LRSCD].[UserProcess] = [TL].[TknIdToken]
	INNER JOIN	[dbo].[InternalUser] IU
		ON		[TL].[TknIdUser] = [IU].[RegisterUserID]
	WHERE		[LRSCD].[IsOpenProcess] = 1;

END