DECLARE @NewModules AS TABLE (
	ModuleId INT,
	ModuleName NVARCHAR(50),
	ModuleDescription NVARCHAR(200)
);
DECLARE @NewSubModules AS TABLE (
	ModuleId INT,
	ModuleName NVARCHAR(50),
	ModuleDescription NVARCHAR(200)
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

	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
		(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
	OUTPUT inserted.ModIdModule, inserted.ModName, inserted.ModDescription INTO @NewModules(ModuleId, ModuleName, ModuleDescription)
	VALUES
		('Dashboard'		,NULL	,	'/dashboard'		,	'Nuevo módulo principal de portal web'	,1,'fa fa-chart-bar fa-1x'	,1,1,'SYS-ARUIZ',GETDATE()),
		('Envíos'			,NULL	,	'/envios'			,	'Nuevo módulo de envios portal web'		,2,'bi bi-box-seam'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Mis Envíos'		,NULL	,	'/mis-envios'		,	'Nuevo módulo de mis envíos'			,3,'fa fa-boxes fa-1x'		,1,1,'SYS-ARUIZ',GETDATE()),
		('Mi perfil'		,NULL	,	'/individual'		,	'Nuevo módulo individual de perfil'		,4,'icon-user'				,1,1,'SYS-ARUIZ',GETDATE()),
		('Link Envíos'		,NULL	,	'/link-envios'		,	'Nuevo módulo de link de envíos'		,5,'fa fa-link fa-1x'		,1,1,'SYS-ARUIZ',GETDATE()),
		('Promociones'		,NULL	,	'/promociones'		,	'Nuevo módulo de promociones'			,6,'icon-tag'				,1,1,'SYS-ARUIZ',GETDATE()),
		('Tiendas Forza'	,NULL	,	'/tiendas-forza'	,	'Nuevo módulo de tiendas forza'			,7,'fa fa-store fa-1x'		,1,1,'SYS-ARUIZ',GETDATE()),
		('Soporte'			,NULL	,	'/soporte'			,	'Nuevo módulo de soporte'				,8,'icon-question'			,1,1,'SYS-ARUIZ',GETDATE())

	DECLARE @NewShipmentsID		INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Envíos' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo%')
	DECLARE @NewMyProfileID		INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Mi perfil' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo%')
	
	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
		(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
	OUTPUT inserted.ModIdModule, inserted.ModName, inserted.ModDescription INTO @NewSubModules(ModuleId, ModuleName, ModuleDescription)
	VALUES
		('Envío Estándar'				,@NewShipmentsID	,	'/individual/crear-guia/estandar'	,	'Nuevo módulo individual de creación de guías estandar'	,1,'bi bi-send-plus'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Envío COD'					,@NewShipmentsID	,	'/individual/crear-guia/cod'		,	'Nuevo módulo individual de creación de guías estandar'	,2,'bi bi-send-check'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Recolecciones'				,@NewShipmentsID	,	'/individual/recolecciones'			,	'Nuevo módulo individual de recolecciones'				,3,'fa fa-shipping-fast fa-1x'	,1,1,'SYS-ARUIZ',GETDATE()),
		('Mis Datos'					,@NewMyProfileID	,	'/individual/perfil'				,	'Nuevo módulo individual de datos de usuario'			,1,'icon-user-follow'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Facturación'					,@NewMyProfileID	,	'/individual/facturacion'			,	'Nuevo módulo individual de datos de facturación'		,2,'fa fa-file fa-1x'			,1,1,'SYS-ARUIZ',GETDATE()),
		('Mis Cuentas Bancarias'		,@NewMyProfileID	,	'/individual/mis-cuentas-bancarias'	,	'Nuevo módulo individual de cuentas para CoD'			,3,'bi bi-person-lines-fill'	,1,1,'SYS-ARUIZ',GETDATE()),
		('Mis Direcciones Favoritas'	,@NewMyProfileID	,	'/individual/direcciones'			,	'Nuevo módulo individual de direcciones favoritas'		,4,'bi bi-journal-medical'		,1,1,'SYS-ARUIZ',GETDATE())

	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated)
	SELECT
		@NewIndRol, @HermesWebSystemId,  NM.ModuleId, 1, 'SYS-ARUIZ', GETDATE()
	FROM	
		@NewModules NM
	UNION
	SELECT
		@NewIndRol, @HermesWebSystemId, NSM.ModuleId, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		@NewSubModules NSM
		
	IF(@@TRANCOUNT > 0)
		COMMIT TRANSACTION

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION

END CATCH
