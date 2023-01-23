
DECLARE @BaseSystem INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes web operaciones' COLLATE Latin1_General_CI_AI)

DECLARE @NewTelemarketingRole TABLE (
	NewRoleId INT
);

DECLARE @NewTelemarketingHeadModule TABLE (
	NewHeadModuleId INT
);

DECLARE @NewTelemarketingModules TABLE (
	NewModuleId INT
);

BEGIN TRANSACTION
BEGIN TRY

	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Ventas telemercadeo' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatRol]
			(RolIdSystem, RolName, RolDescription, RolAdminBrothers, RolAdminClient, RolAdminInternal, RolRowStatus, RolTokenCreated, RolDateCreated)
		OUTPUT inserted.RolIdRol INTO @NewTelemarketingRole (NewRoleId)
		VALUES
			(@BaseSystem, 'Ventas telemercadeo', 'Rol para ventas desde portal de telemercadeo', 0, 0, 0, 1, 'SYS-ARUIZ', GETDATE())

	END

	IF(NOT EXISTS(SELECT TOP 1 1 FROM @NewTelemarketingRole))
	BEGIN
	
		;THROW 50001, 'SIN ROL', 1;

	END

	-- Módulo padre
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = '' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModGroup)
		OUTPUT inserted.ModIdModule INTO @NewTelemarketingHeadModule (NewHeadModuleId)
		VALUES
			('Telemercadeo', NULL, '/telemercadeo', 'Módulo de ventas de telemercadeo', 10, 'bi bi-briefcase', 1, 1, 'SYS-ARUIZ', GETDATE(), NULL)

	END

	-- Submodulos
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Registro de clientes' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModGroup)
		OUTPUT inserted.ModIdModule INTO @NewTelemarketingModules (NewModuleId)
		VALUES
			('Registro de clientes', (SELECT TOP 1 NTHM.NewHeadModuleId FROM @NewTelemarketingHeadModule NTHM), '/telemercadeo/crear-cuenta', 'Módulo para registro de usuarios individuales', 10, 'bi bi-person-fill-add', 1, 1, 'SYS-ARUIZ', GETDATE(), NULL)

	END
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Venta de membresías' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModGroup)
		OUTPUT inserted.ModIdModule INTO @NewTelemarketingModules (NewModuleId)
		VALUES
			('Venta de membresías', (SELECT TOP 1 NTHM.NewHeadModuleId FROM @NewTelemarketingHeadModule NTHM), '/telemercadeo/detalle-membresias', 'Módulo para venta de membresías con usuarios de telemercadeo', 20, 'bi-file-text-fill', 1, 1, 'SYS-ARUIZ', GETDATE(), NULL)

	END
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Monitoreo de clientes' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModGroup)
		OUTPUT inserted.ModIdModule INTO @NewTelemarketingModules (NewModuleId)
		VALUES
			('Monitoreo de clientes', (SELECT TOP 1 NTHM.NewHeadModuleId FROM @NewTelemarketingHeadModule NTHM), '/telemercadeo/reporte-clientes-cartera', 'Módulo de seguimiento de clientes para telemercadeo', 30, 'bi bi-file-text-fill', 1, 1, 'SYS-ARUIZ', GETDATE(), NULL)

	END

	-- Registro de módulos a rol
	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsModuleMenu, RmsHasNewFunction)
	SELECT
		NTR.NewRoleId, @BaseSystem, NTHM.NewHeadModuleId, 1, 'SYS-ARUIZ', GETDATE(), 1, 0
	FROM
		@NewTelemarketingRole NTR
		CROSS JOIN
			@NewTelemarketingHeadModule NTHM
	UNION
	SELECT
		NTR.NewRoleId, @BaseSystem, NTM.NewModuleId, 1, 'SYS-ARUIZ', GETDATE(), 1, 0
	FROM
		@NewTelemarketingRole NTR
		CROSS JOIN
			@NewTelemarketingModules NTM

	COMMIT TRANSACTION;

	SELECT
		1 'codeResult',
		'Exitoso' 'messageResult'

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION;

	SELECT
		0 'codeResult',
		ERROR_MESSAGE() 'messageResult'

END CATCH