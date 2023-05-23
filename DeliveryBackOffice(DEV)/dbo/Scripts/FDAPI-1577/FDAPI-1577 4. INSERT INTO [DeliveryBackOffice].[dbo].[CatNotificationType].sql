IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatNotificationType] CNT  WITH(NOLOCK) WHERE [CNT].[NotificationTypeName] = 'DailyGuideIncidenceToOrigin'  COLLATE Latin1_General_CI_AI  ) )
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[CatNotificationType]
	(
		[NotificationTypeName],
		[NotificationTypeDescription],
		[NotificationStartTime],
		[NotificationEndTime],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated]
	)
	VALUES
	(   
		N'DailyGuideIncidenceToOrigin',        -- NotificationTypeName - nvarchar(100)
		'Correo consolidado de guías con incidencia durante el día',       -- NotificationTypeDescription - nvarchar(600)
		'22:00:00', -- NotificationStartTime - time(7)
		'23:00:00', -- NotificationEndTime - time(7)
		1,    -- RowStatus - bit
		N'SYS-ARUIZ',        -- TokenCreated - nvarchar(50)
		GETDATE(),  -- DateCreated - datetime
		NULL,       -- TokenUpdated - nvarchar(50)
		NULL        -- DateUpdated - datetime
	)
    
END