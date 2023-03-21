USE [DeliveryBackOffice]
GO

DECLARE @ModuleID INT = (SELECT ModIdModule FROM CatModule WITH(NOLOCK) WHERE ModPath = 'FrmPackagesRangeBySegment' AND ModRowStatus = 1)

INSERT INTO [dbo].[CatalogbyModule] ([NameCatalog]
, [ModuleID]
, [SystemID]
, [RowStatus]
, [TokenCreated]
, [DateCreated]
, [TokenUpdated]
, [DateUpdated])
	VALUES ('RateType', @ModuleID , 2, 1, 'SYS-OMORALES', GETDATE(), NULL, NULL),
			('BusinessSegment', @ModuleID , 2, 1, 'SYS-OMORALES', GETDATE(), NULL, NULL)
GO

