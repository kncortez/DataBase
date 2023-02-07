USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatTypeRate] ([Name]
, [Description]
, [RowStatus]
, [TokenCreated]
, [DateCreated]
, [TokenUpdated]
, [DateUpdated])
	VALUES ('Por Paquetes', 'Tarifas por Paquetes', 1, 'SYS-OMORALES', GETDATE(), NULL, NULL)