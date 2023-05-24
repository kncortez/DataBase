USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatSystem] ([SysNameSystem]
, [SysPlataform]
, [SysDescription]
, [SysRowStatus]
, [SysTokenCreated]
, [SysDateCreated])
	VALUES ('Hermes Invoice Helper', 'Hermes Invoice Helper', 'Servicio para facturación automática', 1, 'SYS-OMORALES', GETDATE())
GO
