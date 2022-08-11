-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-11>
-- Description:	<Actualiza un proceso abierto en LinehaulRouteSetlementContainerDetail>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_updateOpenProcessInLinehaulRouteSettlementContainerDetail]
	@LinehaulRouteSettlementContainerId AS INT,
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
		
		UPDATE LinehaulRouteSettlementContainerDetail
		SET IsOpenProcess = @OpenProcess
		   ,TokenUpdated = @TknUser
		   ,DateUpdated = GETDATE()
		   ,RowStatus = @RowStatus
		WHERE LinehaulRouteSettlementContainerId = @LinehaulRouteSettlementContainerId
		AND GuideSerie = @GuideSerie
		AND GuideNumber = @GuideNumber

		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION;

		SELECT 
			IdLinehaulRouteSettlementContainerDetail
			,LinehaulRouteSettlementContainerId
			,GuideSerie
			,GuideNumber
			,IsOpenProcess
		FROM LinehaulRouteSettlementContainerDetail
		WHERE LinehaulRouteSettlementContainerId = @LinehaulRouteSettlementContainerId 
			AND GuideSerie = @GuideSerie
			AND GuideNumber = GuideNumber

		
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		SELECT 0 [spResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [ErrorMessage];
	END CATCH
END