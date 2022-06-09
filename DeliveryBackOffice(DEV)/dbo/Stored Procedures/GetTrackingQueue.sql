
create PROCEDURE [dbo].[GetTrackingQueue] AS
BEGIN
SELECT [WebhookTrackingQueueId]
      ,[Guide_Serie]
      ,[Guide_Number]
      ,[IdCustomer]
      ,[Status]
      ,[WebhookEndpointId]
      ,[HasNotified]
      ,[ChangedDate]
  FROM [DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
  WHERE HasNotified = 0
END
