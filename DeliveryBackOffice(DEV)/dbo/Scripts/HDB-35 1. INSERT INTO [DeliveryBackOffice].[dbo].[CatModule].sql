DECLARE @MyProfileModuleId INT = (
SELECT
	TOP 1
		CM.ModIdModule
FROM
	[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK)
WHERE
	CM.ModIdModuleParent IS NULL
	AND
	CM.ModName = 'Mi perfil'
	AND
	CM.ModPath = '/individual'
)

DECLARE @NextOrderModule INT = (
SELECT
	MAX(CM.ModOrder) + 1
FROM
	[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK)
WHERE
	CM.ModIdModuleParent = @MyProfileModuleId
)

DECLARE @HermesWebSystem INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes Web')
DECLARE @NewHermesWebStandardRole INT = (SELECT CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Nuevo estandar' AND CR.RolIdSystem = @HermesWebSystem)
DECLARE @InsertedModule TABLE (
	IdModule INT
)

IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Terminos y condiciones' AND CM.ModIdModuleParent = @MyProfileModuleId))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
		(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
	OUTPUT inserted.ModIdModule INTO @InsertedModule(IdModule)
	VALUES
		('Terminos y condiciones', @MyProfileModuleId, '/individual/terminos-condiciones', 'Nuevo módulo individual de terminos y condiciones', @NextOrderModule, 'fa bi-file-text-fill fa-1x', 1, 1, 'SYS-ARUIZ', GETDATE())

	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsModuleMenu)
	SELECT
		TOP 1
			@NewHermesWebStandardRole, @HermesWebSystem, IM.IdModule, 1, 'SYS-ARUIZ', GETDATE(), 2
	FROM
		@InsertedModule IM
END