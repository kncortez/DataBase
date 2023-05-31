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
	VALUES ('BusinessSegment', 24, 2, 1, 'SYS-OMORALES', GETDATE(), NULL, NULL),
			('PackagesRange', 24, 2, 1, 'SYS-OMORALES', GETDATE(), NULL, NULL)
GO

