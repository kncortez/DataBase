ALTER PROCEDURE dbo.SetWebhookTrackingQueue(@TMP_WebhookTrackingQueue Type_WebhookTrackingQueue READONLY )
AS BEGIN

DECLARE @Result AS VARCHAR(250);

BEGIN TRY


    INSERT INTO [dbo].[WebhookTrackingQueue]
           ([Guide_Serie]
           ,[Guide_Number]
           ,[IdCustomer]
           ,[Status]
           ,[WebhookEndpointId]
           ,[HasNotified]
           ,[ChangedDate])
    SELECT  ty.[Guide_Serie]
           ,ty.[Guide_Number]
           ,ty.[IdCustomer]
           ,ty.[Status]
           ,(SELECT WebhookEndpointId FROM WebhookEndpoint WHERE IdCustomer = ty.IdCustomer)
           ,[HasNotified]
           ,GETDATE()
	FROM   @TMP_WebhookTrackingQueue ty
		   END TRY
		   BEGIN CATCH
		   SET @Result = 'Error when try to push a change status in a queue';

			INSERT INTO [dbo].[WebhookLog]
			           ([ErrorDesc]
			           ,[ErrorModule]
			           ,[Date]
			           ,[RowStatus])
			     VALUES
			           (
			             @Result
			           ,'PROCEDURE dbo.SetWebhookTrackingQueue'
			           ,GETDATE()
			           ,1)
			
		   --Espacio destinado para log de errores
		   END CATCH

END