/*

Name: GetTrackingQueue
Description: se genera la cola con los cambios de estados de las guías.
CreatedDate: 03/03/2021
     Author: Marco Jiménez
	  Email: marco.jimenez@forzalatam.com

*/


--EXEC [dbo].[GetTrackingQueue] 1,	'FD',	180123,	312,	15,	1
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetTrackingQueue] AS
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
END
