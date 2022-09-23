-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <18-08-2022>
-- Description:	<Update open process field in LinehaulRouteSettlementContainerDetail>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_UpdateOpenProcessLinehaulSettlement] 
	@LinehaulRouteSettlementContainerId AS INT,
	@GuideSerie AS NVARCHAR(25),
	@GuideNumber AS NVARCHAR(25),
	@OpenProcess AS INT,
	@GuideReceived AS INT,
	@RowStatus AS INT,
	@TknUser AS NVARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE	[LinehaulRouteSettlementContainerDetail]
		SET		[IsOpenProcess] = @OpenProcess,
				[UserProcess] = @TknUser,
				[TokenUpdated] = @TknUser,
				[DateUpdated] = SYSDATETIME(),
				[RowStatus] = @RowStatus,
				[GuideReceived] = @GuideReceived
		WHERE	[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
			AND [GuideSerie] = @GuideSerie
			AND [GuideNumber] = @GuideNumber;

		SELECT	[LRSCD].[IdLinehaulRouteSettlementContainerDetail],
				[LRSCD].[LinehaulRouteSettlementContainerId],
				[LRSCD].[GuideSerie],
				[LRSCD].[GuideNumber],
				[LRSCD].[IsOpenProcess],
				[LRSCD].[GuideReceived]
		FROM	[dbo].[LinehaulRouteSettlementContainerDetail] LRSCD
		WHERE	[LRSCD].[LinehaulRouteSettlementContainerId] = @LinehaulRouteSettlementContainerId
			AND [LRSCD].[GuideSerie] = @GuideSerie
			AND [LRSCD].[GuideNumber] = @GuideNumber;

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