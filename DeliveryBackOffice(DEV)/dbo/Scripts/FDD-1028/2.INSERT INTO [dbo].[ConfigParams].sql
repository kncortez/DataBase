USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[ConfigParams] ([Name]
, [Description]
, [Value]
, [Status]
, [CreateDate])
	VALUES ('CoverageHead', 'Porcentaje para Cabeceras de Coberturas', '120', 1, GETDATE())

INSERT INTO [dbo].[ConfigParams] ([Name]
, [Description]
, [Value]
, [Status]
, [CreateDate])
	VALUES ('CoverageDepartamental', 'Porcentaje para Departamental de Coberturas', '120', 1, GETDATE())

INSERT INTO [dbo].[ConfigParams] ([Name]
, [Description]
, [Value]
, [Status]
, [CreateDate])
	VALUES ('CoverageSpecial', 'Porcentaje para Especial de Coberturas', '125', 1, GETDATE())
