DECLARE @HermesWebSystem INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes Web')
DECLARE @NewHermesWebStandardRole INT = (SELECT CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Nuevo estandar' AND CR.RolIdSystem = @HermesWebSystem)

--- DELIVERY PARENT MODULES
DECLARE @StandardDeliveryModuleId INT = (
SELECT
	TOP 1
		CM.ModIdModule
FROM
	[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK)
WHERE
	CM.ModIdModuleParent IS NULL
	AND
	CM.ModName = 'Envíos estándar'
	AND
	CM.ModPath = '/envios'
)
DECLARE @CODDeliveryModuleId INT = (
SELECT
	TOP 1
		CM.ModIdModule
FROM
	[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK)
WHERE
	CM.ModIdModuleParent IS NULL
	AND
	CM.ModName = 'Envíos COD'
	AND
	CM.ModPath = '/envios'
)
--- DELIVERY SON MODULES
DECLARE @StandardDeliveryOptModuleId INT = (
SELECT
	TOP 1
		CM.ModIdModule
FROM
	[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK)
WHERE
	CM.ModName = 'Envío Estándar'
	AND
	CM.ModPath = '/individual/crear-guia/estandar'
)
DECLARE @CODDeliveryOptModuleId INT = (
SELECT
	TOP 1
		CM.ModIdModule
FROM
	[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK)
WHERE
	CM.ModName = 'Envío COD'
	AND
	CM.ModPath = '/individual/crear-guia/cod'
)
--- PICKUP SERVICES
DECLARE @StandardDeliveryPuModuleId INT = (
SELECT
	TOP 1
		CM.ModIdModule
FROM
	[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK)
WHERE
	CM.ModName = 'Recolecciones'
	AND
	CM.ModPath = '/individual/recolecciones'
	AND
	CM.ModDescription LIKE '%estándar%' COLLATE Latin1_General_CI_AI
)
DECLARE @CODDeliveryPuModuleId INT = (
SELECT
	TOP 1
		CM.ModIdModule
FROM
	[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK)
WHERE
	CM.ModName = 'Recolecciones'
	AND
	CM.ModPath = '/individual/recolecciones'
	AND
	CM.ModDescription LIKE '%COD%'
)
-- Modificar modulos
BEGIN TRANSACTION
BEGIN TRY

	--- REMOVER MODULOS PADRE DE ENVIO ESTANDAR Y ENVIO COD
	UPDATE
		RBMBS
	SET
		RmsRowStatus = 0,
		RmsTokenUpdated = 'SYS-ARUIZ',
		RmsDateUpdated = GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[RolByModuleBySystem] RBMBS
	WHERE
		RBMBS.RmsIdRol = @NewHermesWebStandardRole
		AND
		RBMBS.RmsIdSystem = @HermesWebSystem
		AND
		RmsIdModule IN (@StandardDeliveryModuleId, @CODDeliveryModuleId)

	UPDATE
		CM
	SET
		ModRowStatus = 0,
		ModTokenUpdated = 'SYS-ARUIZ',
		ModDateUpdated = GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[CatModule] CM
	WHERE
		CM.ModIdModule IN (@StandardDeliveryModuleId, @CODDeliveryModuleId, @CODDeliveryPuModuleId)

	UPDATE
		CM
	SET
		ModIdModuleParent = NULL,
		ModOrder = 3
	FROM
		[DeliveryBackOffice].[dbo].[CatModule] CM
	WHERE
		CM.ModIdModule = @StandardDeliveryOptModuleId

	UPDATE
		CM
	SET
		ModIdModuleParent = NULL,
		ModOrder = 4
	FROM
		[DeliveryBackOffice].[dbo].[CatModule] CM
	WHERE
		CM.ModIdModule = @CODDeliveryOptModuleId

	UPDATE
		CM
	SET
		ModName = 'Mis recolecciones',
		ModIdModuleParent = NULL,
		ModOrder = 5
	FROM
		[DeliveryBackOffice].[dbo].[CatModule] CM
	WHERE
		CM.ModIdModule = @StandardDeliveryPuModuleId

	--;THROW 50001, 'Controlado', 100;

	COMMIT TRANSACTION;
	SELECT
		1 'ResultCode'
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SELECT
		0 'ResultCode'
END CATCH