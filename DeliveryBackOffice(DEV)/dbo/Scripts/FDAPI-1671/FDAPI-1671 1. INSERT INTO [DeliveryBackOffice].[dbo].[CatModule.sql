
DECLARE @Token NVARCHAR(50) = 'SYS-ARUIZ';

DECLARE @ExpressCenterRole INT =
(
	SELECT 
		TOP (1)
			[CR].[RolIdRol] 
	FROM
		[DeliveryBackOffice].[dbo].[CatRol] CR  WITH(NOLOCK) 
	WHERE
		[CR].[RolName] = 'ADMINISTRACION Y CIERRES EXC PORTAL WEB'  COLLATE Latin1_General_CI_AI
)

DECLARE @WebSystem INT =
(
	SELECT 
		TOP 1 
			[CS].[SysIdSystem]
	FROM
		[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
	WHERE
		[CS].[SysNameSystem] = 'Hermes Web'  COLLATE Latin1_General_CI_AI 
)

BEGIN TRANSACTION 
BEGIN TRY

	UPDATE
		[RBMBS]
	SET
		[RBMBS].[RmsRowStatus] = 0
		,[RBMBS].[RmsTokenUpdated] = @Token
		,[RBMBS].[RmsDateUpdated] = GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[RolByModuleBySystem] RBMBS  WITH(NOLOCK) 
	WHERE
		[RBMBS].[RmsIdRol] = @ExpressCenterRole
		AND
		[RBMBS].[RmsRowStatus] = 1

	DECLARE @NewExpressCenterModules TABLE
	(
		NewModuleId INT
		,NewModuleName NVARCHAR(200)
		,NewModuleRoute NVARCHAR(200)
		,NewModuleParent INT
		,NewModuleParentName NVARCHAR(200)
		,NewModulePath NVARCHAR(200)
		,NewModuleDescription NVARCHAR(150)
		,NewModuleOrder INT
		,NewModuleMetadata NVARCHAR(50)
		,NewModuleGroup INT
	);

	INSERT INTO @NewExpressCenterModules
	(
	    [NewModuleId],
	    [NewModuleName],
	    [NewModuleParent],
	    [NewModuleParentName],
	    [NewModulePath],
	    [NewModuleDescription],
	    [NewModuleOrder],
	    [NewModuleMetadata],
	    [NewModuleGroup]
	)
	VALUES
	(   
		NULL,
	    'Mi perfil',
	    NULL,
	    NULL,
	    '/express',
	    '[EXP] Mi perfil para usuarios express center',
	    10,
	    'icon-user',
	    2
	),
	(   
		NULL,
	    'Mis Datos',
	    NULL,
	    'Mi perfil',
	    '/express/perfil',
	    '[EXP] Mis datos de perfil para usuarios express center',
	    11,
	    'icon-user-follow',
	    2
	),
	(   
		NULL,
	    'Cartera de clientes',
	    NULL,
	    'Mi perfil',
	    '/express/cartera-clientes',
	    '[EXP] Cartera de clientes de usuarios express center',
	    12,
	    'bi bi-person-lines-fill',
	    2
	),
	(   
		NULL,
	    'Terminos y condiciones',
	    NULL,
	    'Mi perfil',
	    '/express/terminos-condiciones',
	    '[EXP] Terminos y condiciones de usuarios express center',
	    13,
	    'bi-file-text-fill',
	    2
	),
	(   
		NULL,
	    'Mis Envíos',
	    NULL,
	    NULL,
	    '/mis-envios',
	    '[EXP] Mis envíos express center',
	    20,
	    'fa fa-1x fa-boxes',
	    1
	),
	(   
		NULL,
	    'Servicio estándar',
	    NULL,
	    NULL,
	    '/express/crear-guia',
	    '[EXP] Servicio estandar express center',
	    30,
	    'bi bi-send-plus',
	    1
	),
	(   
		NULL,
	    'Servicio COD',
	    NULL,
	    NULL,
	    '/express/crear-guia-cod',
	    '[EXP] Servicio COD express center',
	    40,
	    'bi bi-send-check',
	    1
	),
	(   
		NULL,
	    'Rastreo',
	    NULL,
	    NULL,
	    '/rastreo',
	    '[EXP] Restreo de guías de usuarios express center',
	    50,
	    'bi bi-search',
	    1
	),
	(   
		NULL,
	    'Cierres',
	    NULL,
	    NULL,
	    '/cierres',
	    '[EXP] Cierres de usuarios express center',
	    60,
	    'bi bi-file-text',
	    1
	),
	(   
		NULL,
	    'Cierre Operador',
	    NULL,
	    'Cierres',
	    '/express/cierre-operador',
	    '[EXP] Cierre de operador para usuarios express center',
	    61,
	    'bi bi-journal-check',
	    1
	),
	(   
		NULL,
	    'Cierre General',
	    NULL,
	    'Cierres',
	    '/express/cierres',
	    '[EXP] Cierre general para usuarios express center',
	    62,
	    'bi bi-journal-check',
	    1
	),
	(   
		NULL,
	    'Reportes',
	    NULL,
	    NULL,
	    '/reportes',
	    '[EXP] Reporte de cierres de usuarios express center',
	    70,
	    'bi bi-journal-medical',
	    1
	),
	(   
		NULL,
	    'Reporte Operador',
	    NULL,
	    'Reportes',
	    '/express/reporte-operador',
	    '[EXP] Reporte de cierre de operador para usuarios express center',
	    71,
	    'bi bi-journal',
	    1
	),
	(   
		NULL,
	    'Reporte General',
	    NULL,
	    'Reportes',
	    '/express/reporte-general',
	    '[EXP] Reporte de cierre general para usuarios express center',
	    72,
	    'bi bi-journal',
	    1
	),
	(   
		NULL,
	    'Servicios',
	    NULL,
	    NULL,
	    '/servicios',
	    '[EXP] Servicios de usuarios express center',
	    80,
	    'bi bi-window-sidebar',
	    1
	),
	(   
		NULL,
	    'Recepción',
	    NULL,
	    'Servicios',
	    '/express/servicio-recepcion',
	    '[EXP] Recepción de guías para usuarios express center',
	    81,
	    'bi bi-boxes',
	    1
	),
	(   
		NULL,
	    'Entrega',
	    NULL,
	    'Servicios',
	    '/express/servicio-entrega',
	    '[EXP] Entrega de guías para usuarios express center',
	    82,
	    'bi bi-box-arrow-right',
	    1
	),
	(   
		NULL,
	    'Devolución',
	    NULL,
	    'Servicios',
	    '/express/servicio-devolucion',
	    '[EXP] Devoluciones de guías para usuarios express center',
	    83,
	    'bi bi-box-arrow-left',
	    1
	),
	(   
		NULL,
	    'Traslados',
	    NULL,
	    'Servicios',
	    '/express/servicio-traslado',
	    '[EXP] Traslado de guías para usuarios express center',
	    84,
	    'bi bi-truck',
	    1
	)

	IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @NewExpressCenterModules ) )
	BEGIN
	    ;THROW 50000, 'Sin datos a ingresar', 1;
	END

	DECLARE @InsertedParentModules TABLE
	(
		ModuleId INT,
		ModuleName NVARCHAR(200)
	)

	DECLARE @InsertedSonModules TABLE
	(
		ModuleId INT,
		ModuleName NVARCHAR(200)
	)

	DECLARE @UpdatedParentModules TABLE
	(
		ModuleId INT
	)

	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
	(
	    [ModName],
	    [ModIdModuleParent],
	    [ModPath],
	    [ModDescription],
	    [ModOrder],
	    [ModMetadata],
	    [ModVisible],
	    [ModRowStatus],
	    [ModTokenCreated],
	    [ModDateCreated],
	    [ModGroup]
	)
	OUTPUT [Inserted].[ModIdModule], [Inserted].[ModName] INTO @InsertedParentModules ([ModuleId], [ModuleName])
	SELECT 
		[NECM].[NewModuleName]
		,NULL	
		,[NECM].[NewModulePath]
		,[NECM].[NewModuleDescription]
		,[NECM].[NewModuleOrder]
		,[NECM].[NewModuleMetadata]
		,1
		,1
		,@Token
		,GETDATE()
		,[NECM].[NewModuleGroup]
	FROM
		@NewExpressCenterModules NECM
	WHERE
		[NECM].[NewModuleParentName] IS NULL

	IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @InsertedParentModules ) )
	BEGIN
	    ;THROW 50000, 'No ingreso nuevos módulos padre', 1;
	END

	-- Actualizar padres
	UPDATE
		[NECM]
	SET
		[NECM].[NewModuleId] = [IPM].[ModuleId]
	OUTPUT [Inserted].[NewModuleId] INTO @UpdatedParentModules([ModuleId])
	FROM
		@NewExpressCenterModules NECM
		INNER JOIN
			@InsertedParentModules IPM
			ON
				[NECM].[NewModuleName] = [IPM].[ModuleName]

	-- Actualizar hijos con padres
	UPDATE
		[NECM]
	SET
		[NECM].[NewModuleParent] = [IPM].[ModuleId]
	OUTPUT [Inserted].[NewModuleParent] INTO @UpdatedParentModules([ModuleId])
	FROM
		@NewExpressCenterModules NECM
		INNER JOIN
			@InsertedParentModules IPM
			ON
				[NECM].[NewModuleParentName] = [IPM].[ModuleName]

	IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @UpdatedParentModules ) )
	BEGIN
	    ;THROW 50000, 'No actualizo modulos padre', 1;
	END

	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
	(
	    [ModName],
	    [ModIdModuleParent],
	    [ModPath],
	    [ModDescription],
	    [ModOrder],
	    [ModMetadata],
	    [ModVisible],
	    [ModRowStatus],
	    [ModTokenCreated],
	    [ModDateCreated],
	    [ModGroup]
	)
	OUTPUT [Inserted].[ModIdModule], [Inserted].[ModName] INTO @InsertedSonModules ([ModuleId], [ModuleName])
	SELECT 
		[NECM].[NewModuleName]
		,[NECM].[NewModuleParent]	
		,[NECM].[NewModulePath]
		,[NECM].[NewModuleDescription]
		,[NECM].[NewModuleOrder]
		,[NECM].[NewModuleMetadata]
		,1
		,1
		,@Token
		,GETDATE()
		,[NECM].[NewModuleGroup]
	FROM
		@NewExpressCenterModules NECM
	WHERE
		[NECM].[NewModuleParentName] IS NOT NULL

	IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @InsertedSonModules ) )
	BEGIN
	    ;THROW 50000, 'sin módulos hijos ingresados', 1;
	END

	UPDATE
		[NECM]
	set
		[NECM].[NewModuleId] = [ISM].[ModuleId]
	FROM
		@NewExpressCenterModules NECM
		INNER JOIN
			@InsertedSonModules ISM
			ON
				[NECM].[NewModuleName] = [ISM].[ModuleName]

	IF 
	(
		(
			SELECT
				COUNT([NECM].[NewModuleName])
			FROM
				@NewExpressCenterModules NECM
			WHERE
				[NECM].[NewModuleId] IS NOT NULL
		)
		<>
		(
			SELECT
				COUNT([NECM].[NewModuleName])
			FROM
				@NewExpressCenterModules NECM
		)
	)
	BEGIN
	    ;THROW 50000, 'No se ingresaron todos los modulos', 1;
	END

	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
	(
	    [RmsIdRol],
	    [RmsIdSystem],
	    [RmsIdModule],
	    [RmsRowStatus],
	    [RmsTokenCreated],
	    [RmsDateCreated],
	    [RmsModuleMenu]
	)
	SELECT 
		@ExpressCenterRole
		,@WebSystem
		,[NECM].[NewModuleId]
		,1
		,@Token
		,GETDATE()
		,[NECM].[NewModuleGroup]
	FROM
		@NewExpressCenterModules NECM

	COMMIT TRANSACTION

	SELECT
		200
    
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

	SELECT
		500,
		ERROR_MESSAGE()
END CATCH
