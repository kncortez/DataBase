USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatalogbyModule] ([NameCatalog]
, [ModuleID]
, [SystemID]
, [RowStatus]
, [TokenCreated]
, [DateCreated]
, [TokenUpdated]
, [DateUpdated])
	VALUES ('PackagesRange', 22, 2, 1, 'SYS-OMORALES', GETDATE(), NULL, NULL)
GO

