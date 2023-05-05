USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[ConfigExternalPlatform] ([ExternalPlatformId]
, [ConfigParameterName]
, [ConfigParameterValue]
, [ConfigMaxValidDate]
, [RowStatus]
, [TokenCreated]
, [DateCreated])
	VALUES ((SELECT IdExternalPlatform FROM CatExternalPlatform WHERE NameExternalPlatform = 'SMSTwo-StepVerificationCourierApp'), 'SMSTwo-StepVerificationCourierApp', '<CODE> es tu código de verificación de Courier App. <DATETIME>', NULL, 1, 'SYS-OMORALES', GETDATE())
GO

--Datos dinámicos en el mensaje: <DATE>, <TIME>, <DATETIME>, <CODE>