-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <21-07-2022>
-- Description:	<UPDATE an Open process in LinehaulRoutePreparationContainerDetail>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_updateOpenProcessInLinehaulRoutePreparationContainerDetail]
	@LinehaulRoutePreparationContainerId AS INT,
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(50),
	@OpenProcess AS INT,
	@RowStatus AS INT,
	@TknUser AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE	[LinehaulRoutePreparationContainerDetail]
		SET		[IsOpenProcess] = @OpenProcess,
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME(),
				[RowStatus] = @RowStatus
		WHERE	[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
			AND [GuideSerie] = @GuideSerie
			AND [GuideNumber] = @GuideNumber;

		SELECT	[LRPCD].[IdLinehaulRoutePreparationContainerDetail],
				[LRPCD].[LinehaulRoutePreparationContainerId],
				[LRPCD].[GuideSerie],
				[LRPCD].[GuideNumber],
				[LRPCD].[IsOpenProcess]
		FROM	[dbo].[LinehaulRoutePreparationContainerDetail] LRPCD
		WHERE	[LRPCD].[LinehaulRoutePreparationContainerId] = @LinehaulRoutePreparationContainerId
			AND [LRPCD].[GuideSerie] = @GuideSerie
			AND [LRPCD].[GuideNumber] = @GuideNumber;

		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		SELECT 0 [spResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [ErrorMessage];

		ROLLBACK TRANSACTION
	END CATCH
END