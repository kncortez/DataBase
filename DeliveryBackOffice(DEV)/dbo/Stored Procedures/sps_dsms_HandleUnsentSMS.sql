
-- =============================================
-- Author:		<RUIZ, ANDRES>
-- Create date: <2021-09-13>
-- Description:	<DELETE unsent SMS from SMS Table>
-- =============================================
CREATE PROCEDURE [dbo].[sps_dsms_HandleUnsentSMS] 
	@BatchId bigint ,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		DELETE FROM [dbo].[SMS_Sent]
		WHERE [dbo].[SMS_Sent].[Sent_Batch_Id] = @BatchId
		AND [dbo].[SMS_Sent].[Sent_Guide_Series] = @GuideSerie
		AND [dbo].[SMS_Sent].[Sent_Guide_Number] = @GuideNumber
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		SELECT 0 'Deleted';
	END CATCH
	IF @@TRANCOUNT > 0
	BEGIN
		SELECT 1 'Deleted';
		COMMIT TRANSACTION;
	END
END
