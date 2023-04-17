USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatTypeRate] ([Name]
, [Description]
, [RowStatus]
, [TokenCreated]
, [DateCreated]
, [TokenUpdated]
, [DateUpdated])
	VALUES ('Cobertura', 'Tarifas por Coberturas', 1, 'SYS-OMORALES', GETDATE(), NULL, NULL)