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

	SELECT	[LRPCD].[IdLinehaulRoutePreparationContainerDetail],
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
			[IU].[Username]
	FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD,
			[dbo].[TokenLog] TL,
			[dbo].[InternalUser] IU
	WHERE	[LRPCD].[GuideSerie] = @GuideSerie
		AND	[LRPCD].[GuideNumber] = @GuideNumber
		AND [LRPCD].[TokenCreated] != @TknUser
		AND [TL].[TknIdToken] = [LRPCD].[TokenCreated]
		AND [IU].[RegisterUserID] = [TL].[TknIdUser]
		AND [LRPCD].[IsOpenProcess] = 1
		AND [LRPCD].[RowStatus] = 1;
END