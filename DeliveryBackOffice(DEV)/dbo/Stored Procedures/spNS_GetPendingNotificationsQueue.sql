-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <03-05-2023>
-- Description:	<Get all pending notifications from Notification Queue>
-- =============================================
CREATE PROCEDURE [dbo].[spNS_GetPendingNotificationsQueue]
	
AS
BEGIN
	SET NOCOUNT ON;

    SELECT		[NQ].[IdNotificationQueue], 
				[NQ].[CatNotificationMediumId],
				[CNM].[NotificationMediumName],
				[NQ].[CatNotificationTypeId],
				[CNT].[NotificationTypeName],
				ISNULL([CNT].[ConfigExternalPlatformId], 0) [ConfigExternalPlatformId],
				ISNULL([CEP].[ConfigParameterName], '') [ConfigParameterName],
				ISNULL([CEP].[ConfigParameterValue], '') [ConfigParameterValue],
				ISNULL([CNT].[EmailTemplateName], '') [EmailTemplateName],
				ISNULL([NQ].[CustomerId], 0) [CustomerId],
				ISNULL([C].[Name], '') [CustomerName],
				ISNULL([NQ].[AccountId], 0) [AccountId],
				ISNULL([A].[AccName], '') [AccName],
				ISNULL([NQ].[DestinationPhone], '') [DestinationPhone],
				ISNULL([NQ].[DestinationEmail], '') [DestinationEmail],
				[NQ].[NotificationDate],
				[NQ].[DateToSend],
				[CNT].[NotificationStartTime],
				[CNT].[NotificationEndTime]
	FROM		[dbo].[NotificationQueue] NQ
	INNER JOIN	[dbo].[CatNotificationMedium] CNM
		ON		[NQ].[CatNotificationMediumId] = [CNM].[IdCatNotificationMedium]
	INNER JOIN	[dbo].[CatNotificationType] CNT
		ON		[NQ].[CatNotificationTypeId] = [CNT].[IdCatNotificationType]
	LEFT JOIN	[dbo].[ConfigExternalPlatform] CEP
		ON		[CNT].[ConfigExternalPlatformId] = [CEP].[IdConfigExternalPlatform]
	LEFT JOIN	[dbo].[Customer] C
		ON		[NQ].[CustomerId] = [C].[IdCustomer]
	LEFT JOIN	[dbo].[Account] A
		ON		[NQ].[AccountId] = [A].[AccIdAccount]
	WHERE		[NQ].[IsSent] = 0
		AND		[NQ].[DateToSend] >= CAST(GETDATE() AS DATE)
		AND		CAST(GETDATE() AS TIME) BETWEEN [CNT].[NotificationStartTime] AND [CNT].[NotificationEndTime]
		AND		[NQ].[RowStatus] = 1;
END