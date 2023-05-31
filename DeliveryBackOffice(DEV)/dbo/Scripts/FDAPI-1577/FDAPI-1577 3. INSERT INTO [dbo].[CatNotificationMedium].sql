IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatNotificationMedium] CNM  WITH(NOLOCK) WHERE [CNM].[NotificationMediumName] = 'Mensaje de texto claro'  COLLATE Latin1_General_CI_AI  ) )
BEGIN

	INSERT INTO [dbo].[CatNotificationMedium]
	(
		[NotificationMediumName],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated]
	)
	VALUES
	(   
		'Mensaje de texto claro',        -- NotificationMediumName - varchar(50)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL       -- DateUpdated - datetime
	)
    
END

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatNotificationMedium] CNM  WITH(NOLOCK) WHERE [CNM].[NotificationMediumName] = 'Correo MailGun'  COLLATE Latin1_General_CI_AI  ) )
BEGIN

	INSERT INTO [dbo].[CatNotificationMedium]
	(
		[NotificationMediumName],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated]
	)
	VALUES
	(   
		'Correo MailGun',        -- NotificationMediumName - varchar(50)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL       -- DateUpdated - datetime
	)
    
END

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatNotificationMedium] CNM  WITH(NOLOCK) WHERE [CNM].[NotificationMediumName] = 'Correo SMTP'  COLLATE Latin1_General_CI_AI  ) )
BEGIN

	INSERT INTO [dbo].[CatNotificationMedium]
	(
		[NotificationMediumName],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated]
	)
	VALUES
	(   
		'Correo SMTP',        -- NotificationMediumName - varchar(50)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL       -- DateUpdated - datetime
	)
    
END