--region PROCEDURE dbo.SetWebhookLog
IF OBJECT_ID('dbo.SetWebhookLog') IS NOT NULL
BEGIN 
    DROP PROC dbo.SetWebhookLog
END 
GO
CREATE PROCEDURE dbo.SetWebhookLog
    @Guide_Serie varchar(5),
    @Guide_Number bigint,
    @WebhookTrackingQueueId bigint,
    @DataSent nvarchar(max),
    @DataReceived nvarchar(max),
	@ErrorDesc nvarchar(max),
    @ErrorModule nvarchar(max)
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    INSERT INTO dbo.WebhookLog ( Guide_Serie, Guide_Number, WebhookTrackingQueueId, DataSent, 
                                DataReceived, ErrorDesc,ErrorModule,[Date], RowStatus)
    SELECT @Guide_Serie, @Guide_Number, @WebhookTrackingQueueId, @DataSent, @DataReceived, 
	       @ErrorDesc, @ErrorModule, GETDATE(), 1;

    COMMIT
GO
--endregion