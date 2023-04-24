USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[ConfigExternalPlatform] ([ExternalPlatformId]
, [ConfigParameterName]
, [ConfigParameterValue]
, [ConfigMaxValidDate]
, [RowStatus]
, [TokenCreated]
, [DateCreated])
	VALUES ((SELECT IdExternalPlatform FROM CatExternalPlatform WHERE NameExternalPlatform = 'SMSLinehaulsAct'), 'SMSLinehaulsAct', 'Se ha generado el acta <ACT> de piezas incompletas en Linehauls, por favor revise su correo electrónico. <DATETIME>', NULL, 1, 'SYS-OMORALES', GETDATE())
GO

--Datos dinámicos en el mensaje: <DATE>, <TIME>, <DATETIME>, <ACT>