-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <20-07-2022>
-- Description:	<Check for open processes with mutiple pieces Guides>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_checkOpenProcessLinehaulRoutePreparationContainerDetail]
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(50),
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SELECT		[LRPCD].[IdLinehaulRoutePreparationContainerDetail],
				[LRPCD].[LinehaulRoutePreparationContainerId],
				[LRPCD].[GuideSerie],
				[LRPCD].[GuideNumber],
				[LRPCD].[GuideDryPieceTotal],
				[LRPCD].[GuideColdPieceTotal],
				[LRPCD].[DryPieceQuantity], 
				[LRPCD].[ColdPieceQuantity],
				[LRPCD].[RowStatus],
				[LRPCD].[TokenCreated],
				[TL].[TknIdUser],
				[IU].[IdUser],
				[IU].[Username],
				COALESCE([LRPCD].[TokenUpdated], '') [TokenUpdated],
				COALESCE([TLB].[TknIdUser], 0) [TknIdUserUpdated] ,
				COALESCE([IUB].[IdUser], 0) [IdUserUpdated],
				COALESCE([IUB].[Username], '') [UsernameUpdated]
	FROM		[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD WITH(NOLOCK)
	INNER JOIN	[dbo].[TokenLog] TL WITH(NOLOCK)
		ON		[LRPCD].[TokenCreated] = [TL].[TknIdToken]
	INNER JOIN	[dbo].[InternalUser] IU
		ON		[TL].[TknIdUser] = [IU].[RegisterUserID]
	LEFT JOIN	[dbo].[TokenLog] TLB WITH(NOLOCK)
		ON		[LRPCD].[TokenUpdated] = [TLB].[TknIdToken]
	LEFT JOIN	[dbo].[InternalUser] IUB
		ON		[TLB].[TknIdToken] = [IUB].[RegisterUserID]
	WHERE		[LRPCD].[GuideSerie] = @GuideSerie
		AND		[LRPCD].[GuideNumber] = @GuideNumber
		AND		[LRPCD].[IsOpenProcess] = 1
		AND		[LRPCD].[RowStatus] = 1;
END