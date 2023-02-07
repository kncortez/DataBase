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
	VALUES ('BusinessSegment', 23, 2, 1, 'SYS-OMORALES', GETDATE(), NULL, NULL),
			('PackagesRange', 23, 2, 1, 'SYS-OMORALES', GETDATE(), NULL, NULL)
GO

