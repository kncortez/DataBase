
DECLARE @NewModules AS TABLE (
	ModuleId INT,
	ModuleName NVARCHAR(50),
	ModuleDescription NVARCHAR(200),
	ModuleParent INT,
	ModuleMenu INT
);
DECLARE @NewSubModules AS TABLE (
	ModuleId INT,
	ModuleName NVARCHAR(50),
	ModuleDescription NVARCHAR(200),
	ModuleParent INT,
	ModuleMenu INT
);
DECLARE @HermesWebSystemId INT = (
	SELECT
		TOP 1
			CS.SysIdSystem
	FROM
		[DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK)
	WHERE
		CS.SysNameSystem = 'Hermes Web' COLLATE Latin1_General_CI_AI
)

DECLARE @NewIndRol INT = (
	SELECT 
		TOP 1 
			CR.RolIdRol
	FROM 
		[DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) 
	WHERE 
		CR.RolName = 'Nuevo estandar' COLLATE Latin1_General_CI_AI 
		AND 
		CR.RolIdSystem = @HermesWebSystemId 
		AND 
		CR.RolRowStatus = 1
)

BEGIN TRANSACTION
BEGIN TRY

	IF( EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] WHERE ModDescription LIKE 'Nuevo módulo%' AND ModTokenCreated = 'SYS-ARUIZ'))
	BEGIN

		DECLARE @ModulesToDelete AS TABLE (
			IdModule INT
		);

		INSERT INTO @ModulesToDelete
		SELECT
			CM.ModIdModule
		FROM
			[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK)
		WHERE
			ModDescription LIKE 'Nuevo módulo%'
			AND
			ModTokenCreated = 'SYS-ARUIZ'

		DELETE
		FROM	
			[DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		WHERE
			RmsIdRol = @NewIndRol
			AND
			RmsIdSystem = @HermesWebSystemId
			AND
			RmsIdModule IN (SELECT IdModule FROM @ModulesToDelete)

		DELETE
		FROM
			[DeliveryBackOffice].[dbo].[CatModule]
		WHERE
			ModIdModule IN (SELECT IdModule FROM @ModulesToDelete)
	END

	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
		(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
	OUTPUT inserted.ModIdModule, inserted.ModName, inserted.ModDescription INTO @NewModules(ModuleId, ModuleName, ModuleDescription)
	VALUES
		('Dashboard'			,NULL	,	'/dashboard'		,	'Nuevo módulo principal de portal web'	,1,'fa fa-chart-bar fa-1x'	,1,1,'SYS-ARUIZ',GETDATE()),
		('Envíos estándar'		,NULL	,	'/envios'			,	'Nuevo módulo de envios portal web'		,2,'bi bi-box-seam'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Envíos COD'			,NULL	,	'/envios'			,	'Nuevo módulo de envios portal web'		,3,'bi bi-box-seam'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Mis Envíos'		,NULL	,	'/mis-envios'		,	'Nuevo módulo de mis envíos'			,1,'fa fa-boxes fa-1x'		,1,1,'SYS-ARUIZ',GETDATE()),
		('Mi perfil'		,NULL	,	'/individual'		,	'Nuevo módulo individual de perfil'		,4,'icon-user'				,1,1,'SYS-ARUIZ',GETDATE()),
		('Link Envíos'		,NULL	,	'/link-envios'		,	'Nuevo módulo de link de envíos'		,5,'fa fa-link fa-1x'		,1,1,'SYS-ARUIZ',GETDATE()),
		('Promociones'		,NULL	,	'/promociones'		,	'Nuevo módulo de promociones'			,6,'icon-tag'				,1,1,'SYS-ARUIZ',GETDATE()),
		('Tiendas Forza'	,NULL	,	'/tiendas-forza'	,	'Nuevo módulo de tiendas forza'			,7,'fa fa-store fa-1x'		,1,1,'SYS-ARUIZ',GETDATE()),
		('Soporte'			,NULL	,	'/soporte'			,	'Nuevo módulo de soporte'				,8,'icon-question'			,1,1,'SYS-ARUIZ',GETDATE())

	DECLARE @NewShipmentsSTDID		INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Envíos estándar' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo%')
	DECLARE @NewShipmentsCODID		INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Envíos COD' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo%')
	DECLARE @NewMyProfileID		INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Mi perfil' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo%')
	
	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
		(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
	OUTPUT inserted.ModIdModule, inserted.ModName, inserted.ModDescription, inserted.ModIdModuleParent INTO @NewSubModules(ModuleId, ModuleName, ModuleDescription, ModuleParent)
	VALUES
		('Envío Estándar'				,@NewShipmentsSTDID	,	'/individual/crear-guia/estandar'	,	'Nuevo módulo individual de creación de guías estandar'	,1,'bi bi-send-plus'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Envío COD'					,@NewShipmentsCODID	,	'/individual/crear-guia/cod'		,	'Nuevo módulo individual de creación de guías estandar'	,1,'bi bi-send-check'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Recolecciones'				,@NewShipmentsSTDID	,	'/individual/recolecciones'			,	'Nuevo módulo individual de recolecciones estándar'		,2,'fa fa-shipping-fast fa-1x'	,1,1,'SYS-ARUIZ',GETDATE()),
		('Recolecciones'				,@NewShipmentsCODID	,	'/individual/recolecciones'			,	'Nuevo módulo individual de recolecciones COD'			,2,'fa fa-shipping-fast fa-1x'	,1,1,'SYS-ARUIZ',GETDATE()),
		('Mis Datos'					,@NewMyProfileID	,	'/individual/perfil'				,	'Nuevo módulo individual de datos de usuario'			,1,'icon-user-follow'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Facturación'					,@NewMyProfileID	,	'/individual/facturacion'			,	'Nuevo módulo individual de datos de facturación'		,2,'fa fa-file fa-1x'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Mis Cuentas Bancarias'		,@NewMyProfileID	,	'/individual/mis-cuentas-bancarias'	,	'Nuevo módulo individual de cuentas para CoD'			,3,'bi bi-person-lines-fill'	,1,1,'SYS-ARUIZ',GETDATE()),
		('Mis Direcciones Favoritas'	,@NewMyProfileID	,	'/individual/direcciones'			,	'Nuevo módulo individual de direcciones favoritas'		,4,'bi bi-journal-medical'		,1,1,'SYS-ARUIZ',GETDATE())

	UPDATE
		@NewModules
	SET
		ModuleMenu = 2
	WHERE
		ModuleName = 'Mi perfil'
		
	UPDATE
		@NewSubModules
	SET
		ModuleMenu = 2
	WHERE
		ModuleParent = @NewMyProfileID

	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsModuleMenu)
	SELECT
		@NewIndRol, @HermesWebSystemId,  NM.ModuleId, 1, 'SYS-ARUIZ', GETDATE(), ISNULL(NM.ModuleMenu, 1)
	FROM	
		@NewModules NM
	UNION
	SELECT
		@NewIndRol, @HermesWebSystemId, NSM.ModuleId, 1, 'SYS-ARUIZ', GETDATE(), ISNULL(NSM.ModuleMenu, 1)
	FROM
		@NewSubModules NSM
		
	IF(@@TRANCOUNT > 0)
		COMMIT TRANSACTION

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION;

	SELECT
		ERROR_MESSAGE()

END CATCH
