Declare @ModIdModuleParent INT = (SELECT TOP 1 ModIdModule FROM CatModule WITH(NOLOCK) WHERE ModName like '%Gestión%' AND ModRowStatus = 1)

INSERT INTO [dbo].[CatModule] ([ModName]
, [ModIdModuleParent]
, [ModPath]
, [ModDescription]
, [ModOrder]
, [ModMetadata]
, [ModVisible]
, [ModRowStatus]
, [ModTokenCreated]
, [ModDateCreated]
, [ModTokenUpdated]
, [ModDateUpdated]
, [ModGroup])
	VALUES ('Precios por Segmento de Negocio', @ModIdModuleParent, 'FrmPackagesRangeBySegment', 'Administración de Precios por Segmento de Negocio', 7, '', 1, 1, 'SYS-OMORALES', GETDATE(), NULL, NULL, NULL)
GO
