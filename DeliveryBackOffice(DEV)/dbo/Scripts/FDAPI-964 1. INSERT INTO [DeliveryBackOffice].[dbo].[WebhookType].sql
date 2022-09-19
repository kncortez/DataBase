IF ( NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.WebhookName = 'GuideStatusChange' COLLATE Latin1_General_CI_AI AND WT.RowStatus = 1))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[WebhookType]
		(WebhookName, WebhookDescription, TokenCreated, DateCreated)
	VALUES
		('GuideStatusChange', 'Webhook de cambio de estados de guías', 'SYS-ARUIZ', GETDATE())

END