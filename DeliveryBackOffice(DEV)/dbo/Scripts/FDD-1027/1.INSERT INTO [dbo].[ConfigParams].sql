USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[ConfigParams] ([Name]
, [Description]
, [Value]
, [Status]
, [CreateDate])
	VALUES ('AllDestinyHead', 'Porcentaje para Cabeceras de Todo Destino', '100', 1, GETDATE())

INSERT INTO [dbo].[ConfigParams] ([Name]
, [Description]
, [Value]
, [Status]
, [CreateDate])
	VALUES ('AllDestinyDepartamental', 'Porcentaje para Departamental de Todo Destino', '100', 1, GETDATE())

INSERT INTO [dbo].[ConfigParams] ([Name]
, [Description]
, [Value]
, [Status]
, [CreateDate])
	VALUES ('AllDestinySpecial', 'Porcentaje para Especial de Todo Destino', '125', 1, GETDATE())

INSERT INTO [dbo].[ConfigParams] ([Name]
, [Description]
, [Value]
, [Status]
, [CreateDate])
	VALUES ('RateCODLimit', 'Porcentaje para el cobro por ad valorem', '3.5', 1, GETDATE())