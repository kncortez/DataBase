
BEGIN TRANSACTION
BEGIN TRY

	DECLARE @InsertedParModule TABLE (
		IdModule INT
	)

	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Entregas' AND CM.ModDescription LIKE '%Nuevo módulo operativo%'))
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
		OUTPUT inserted.ModIdModule INTO @InsertedParModule(IdModule)
		VALUES
			('Entregas', NULL, '/operaciones/entregas', '[SACW][OPW] Nuevo módulo operativo de entregas', 2, 'fa fa-1x fa-shipping-fast', 1, 1, 'SYS-ARUIZ', GETDATE())

	END

	DECLARE @OpDeliveries INT = (
	SELECT
		TOP 1
			CM.ModIdModule
	FROM
		[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK)
	WHERE
		CM.ModIdModuleParent IS NULL
		AND
		CM.ModName = 'Entregas'
		AND
		CM.ModPath = '/operaciones/entregas'
	)

	DECLARE @HermesWebSystem INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes Web operaciones' COLLATE Latin1_General_CI_AI)

	DECLARE @NewHermesWebSACRole INT = (SELECT CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'SAC Web' AND CR.RolIdSystem = @HermesWebSystem)
	DECLARE @NewHermesWebOPRole INT = (SELECT CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Operaciones Web' AND CR.RolIdSystem = @HermesWebSystem)

	DECLARE @InsertedSACModule TABLE (
		IdModule INT
	)
	DECLARE @InsertedOPModule TABLE (
		IdModule INT
	)

	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
		(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
	OUTPUT inserted.ModIdModule INTO @InsertedSACModule(IdModule)
	VALUES
		('Monitoreo de visitas fallidas', @OpDeliveries, '/operaciones/entregas/visitas-fallidas', '[SACW] Nuevo módulo operativo para monitoreo de visitas fallidas', 1, 'fa bi-file-text-fill fa-1x', 1, 1, 'SYS-ARUIZ', GETDATE())
	

	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
		(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
	OUTPUT inserted.ModIdModule INTO @InsertedOPModule(IdModule)
	VALUES
		('Dashboard de visitas fallidas', @OpDeliveries, '/operaciones/entregas/dashboard-incidencias', '[OPW] Nuevo módulo operativo de dashboard de visitas fallidas', 1, 'fa fa-chart-bar fa-1x', 1, 1, 'SYS-ARUIZ', GETDATE())
	
	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsModuleMenu)
	VALUES
		(@NewHermesWebSACRole, @HermesWebSystem, @OpDeliveries, 1, 'SYS-ARUIZ', GETDATE(), NULL),
		(@NewHermesWebOPRole, @HermesWebSystem, @OpDeliveries, 1, 'SYS-ARUIZ', GETDATE(), NULL)
		
	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsModuleMenu)
	SELECT
		TOP 1
			@NewHermesWebSACRole, @HermesWebSystem, IM.IdModule, 1, 'SYS-ARUIZ', GETDATE(), NULL
	FROM
		@InsertedSACModule IM

	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsModuleMenu)
	SELECT
		TOP 1
			@NewHermesWebOPRole, @HermesWebSystem, IM.IdModule, 1, 'SYS-ARUIZ', GETDATE(), NULL
	FROM
		@InsertedOPModule IM
	

	COMMIT TRANSACTION

	SELECT
		1 'ResultCode'

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION

	SELECT
		0 'ResultCode'

END CATCH