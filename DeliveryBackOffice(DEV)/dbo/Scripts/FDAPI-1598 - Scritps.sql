-- FDAPI-1598 - SCRIPTS

INSERT INTO [dbo].[CatExternalPlatform]([NameExternalPlatform],
										[RowStatus],
										[TokenCreated],
										[DateCreated])
VALUES								(	'NotificationsService',
										1, 
										'SYS-JOCHOA',
										SYSDATETIME());


INSERT INTO [dbo].[ConfigExternalPlatform] ([ExternalPlatformId],
											[ConfigParameterName],
											[ConfigParameterValue],
											[RowStatus],
											[TokenCreated],
											[DateCreated])
VALUES									(	(SELECT [CEP].[IdExternalPlatform] FROM [dbo].[CatExternalPlatform] CEP WHERE [CEP].[NameExternalPlatform] = 'NotificationsService'),
											'NotificationEmailText1',
											'Hemos recibido una alerta de incidencia de parte de nuestros couriers, abajo encontrarás un detalle de los servicios involucrados, puedes dirigirte a nuestro portal para ver el detalle por cada guía o puedes comunicarte a nuestro call center.',
											1,
											'SYS-JOCHOA',
											SYSDATETIME());

INSERT INTO [dbo].[ConfigExternalPlatform] ([ExternalPlatformId],
											[ConfigParameterName],
											[ConfigParameterValue],
											[RowStatus],
											[TokenCreated],
											[DateCreated])
VALUES									(	(SELECT [CEP].[IdExternalPlatform] FROM [dbo].[CatExternalPlatform] CEP WHERE [CEP].[NameExternalPlatform] = 'NotificationsService'),
											'NotificationSMSIncidenceText1',
											'Hola <Name>, hemos detectado una incidencia con tus paquetes, para más detalles ingresa a https://portal.forzadelivery.com',
											1,
											'SYS-JOCHOA',
											SYSDATETIME());

INSERT INTO [dbo].[CatNotificationType] (	[ConfigExternalPlatformId],
											[EmailTemplateName],
											[NotificationTypeName],
											[NotificationTypeDescription],
											[NotificationStartTime],
											[NotificationEndTime],
											[RowStatus],
											[TokenCreated],
											[DateCreated])
VALUES									(	(SELECT [CEP].[IdConfigExternalPlatform] FROM [dbo].[ConfigExternalPlatform] CEP WHERE [CEP].[ConfigParameterName] = 'NotificationEmailText1'),
											'',
											'DailyGuideIncidenceToOrigin',
											'Correo consolidado de guías con incidencia durante el día',
											'22:00:00',
											'23:00:00',
											1, 
											'SYS-JOCHOA',
											SYSDATETIME());

INSERT INTO [dbo].[CatNotificationType] (	[ConfigExternalPlatformId],
											[EmailTemplateName],
											[NotificationTypeName],
											[NotificationTypeDescription],
											[NotificationStartTime],
											[NotificationEndTime],
											[RowStatus],
											[TokenCreated],
											[DateCreated])
VALUES									(	(SELECT [CEP].[IdConfigExternalPlatform] FROM [dbo].[ConfigExternalPlatform] CEP WHERE [CEP].[ConfigParameterName] = 'NotificationSMSIncidenceText1'),
											'',
											'DailySmsIncidenceToOrigin',
											'Notificación mediante mensaje de texto',
											'22:00:00',
											'23:00:00',
											1, 
											'SYS-JOCHOA',
											SYSDATETIME());

INSERT INTO [dbo].[CatNotificationMedium] ( [NotificationMediumName],
											[RowStatus], 
											[TokenCreated],
											[DateCreated])
VALUES									(	'Mensaje de texto claro',
											1,
											'SYS-JOCHOA',
											SYSDATETIME());

INSERT INTO [dbo].[CatNotificationMedium] ( [NotificationMediumName],
											[RowStatus], 
											[TokenCreated],
											[DateCreated])
VALUES									(	'Correo MailGun',
											1,
											'SYS-JOCHOA',
											SYSDATETIME());

INSERT INTO [dbo].[CatNotificationMedium] ( [NotificationMediumName],
											[RowStatus], 
											[TokenCreated],
											[DateCreated])
VALUES									(	'Correo SMTP',
											1,
											'SYS-JOCHOA',
											SYSDATETIME());