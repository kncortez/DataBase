DECLARE @NewMyPackages INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Mis Envíos' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo %' COLLATE Latin1_General_CI_AI);

DECLARE @NewStandardServices INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Envíos estándar' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo %' COLLATE Latin1_General_CI_AI);
DECLARE @NewStandardCODServices INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Envíos COD' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo %' COLLATE Latin1_General_CI_AI);

DECLARE @DeliveryLinks INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Link Envíos' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo %' COLLATE Latin1_General_CI_AI);

DECLARE @Promos INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Promociones' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo %' COLLATE Latin1_General_CI_AI);
DECLARE @ForzaStores INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Tiendas Forza' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo %' COLLATE Latin1_General_CI_AI);
DECLARE @Support INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Soporte' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo %' COLLATE Latin1_General_CI_AI);

UPDATE
	[DeliveryBackOffice].[dbo].[CatModule]
SET
	ModGroup = 1,
	ModTokenUpdated = 'SYS-ARUIZ',
	ModDateUpdated = GETDATE()
WHERE
	ModIdModule = @NewMyPackages

UPDATE
	[DeliveryBackOffice].[dbo].[CatModule]
SET
	ModGroup = 2,
	ModTokenUpdated = 'SYS-ARUIZ',
	ModDateUpdated = GETDATE()
WHERE
	ModIdModule IN (@NewStandardServices, @NewStandardCODServices)

UPDATE
	[DeliveryBackOffice].[dbo].[CatModule]
SET
	ModGroup = 3,
	ModTokenUpdated = 'SYS-ARUIZ',
	ModDateUpdated = GETDATE()
WHERE
	ModIdModule = @DeliveryLinks

UPDATE
	[DeliveryBackOffice].[dbo].[CatModule]
SET
	ModGroup = 4,
	ModTokenUpdated = 'SYS-ARUIZ',
	ModDateUpdated = GETDATE()
WHERE
	ModIdModule IN (@Promos,@ForzaStores,@Support)