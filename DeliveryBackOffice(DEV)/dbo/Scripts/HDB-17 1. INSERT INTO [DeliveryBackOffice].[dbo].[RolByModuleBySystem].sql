
DECLARE @NewSystem AS TABLE(
	IdSystem INT
);
DECLARE @NewSACWebRole AS TABLE(
	IdRole INT
);
DECLARE @NewOPWebRole AS TABLE(
	IdRole INT
);
DECLARE @NewPickupParentModule AS TABLE(
	IdModule INT
);
DECLARE @NewModule AS TABLE(
	IdModule INT
);
DECLARE @NewSACModules AS TABLE(
	IdModule INT
);
DECLARE @NewOPModules AS TABLE(
	IdModule INT
);

BEGIN TRANSACTION
BEGIN TRY

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes web operaciones' COLLATE Latin1_General_CI_AI) )
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatSystem]
			( SysNameSystem, SysPlataform, SysDescription, SysRowStatus, SysTokenCreated, SysDateCreated, SysShow)
		OUTPUT inserted.SysIdSystem INTO @NewSystem(IdSystem)
		VALUES
			('Hermes web operaciones', 'forzadelivery.com', 'Sistema de operaciones desde portal web', 1, 'SYS-ARUIZ', GETDATE(), 0)

	END


	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'SAP web' COLLATE Latin1_General_CI_AI) )
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatRol]
			(RolIdSystem, RolName, RolDescription, RolAdminBrothers, RolAdminClient, RolAdminInternal, RolRowStatus, RolTokenCreated, RolDateCreated)
		OUTPUT inserted.RolIdRol INTO @NewSACWebRole(IdRole)
		SELECT
			TOP 1
				NS.IdSystem, 'SAC web', 'Servicio al cliente en portal web', 0, 0, 0, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			@NewSystem NS

	END

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Operaciones web' COLLATE Latin1_General_CI_AI) )
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatRol]
			(RolIdSystem, RolName, RolDescription, RolAdminBrothers, RolAdminClient, RolAdminInternal, RolRowStatus, RolTokenCreated, RolDateCreated)
		OUTPUT inserted.RolIdRol INTO @NewOPWebRole(IdRole)
		SELECT
			TOP 1
				NS.IdSystem, 'Operaciones web', 'Área de operaciones en portal web', 0, 0, 0, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			@NewSystem NS

	END

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Recolecciones' COLLATE Latin1_General_CI_AI AND CM.ModPath = '/' COLLATE Latin1_General_CI_AI) )
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
		OUTPUT inserted.ModIdModule INTO @NewPickupParentModule
		VALUES
			('Recolecciones', NULL, '/operaciones/recolecciones', 'Nuevo módulo operacional de recolecciones', 1, 'fa fa-shipping-fast fa-1x', 1, 1, 'SYS-ARUIZ', GETDATE())

		INSERT INTO @NewSACModules
			(IdModule)
		SELECT
			TOP 1
				NPPM.IdModule
		FROM
			@NewPickupParentModule NPPM

		INSERT INTO @NewOPModules
			(IdModule)
		SELECT
			TOP 1
				NPPM.IdModule
		FROM
			@NewPickupParentModule NPPM

	END

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Solicitud de recolección' COLLATE Latin1_General_CI_AI) )
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
		OUTPUT inserted.ModIdModule INTO @NewModule(IdModule)
		SELECT
			TOP 1
				'Solicitud de recolección', NPPM.IdModule, '/operaciones/recolecciones/manual', 'Nuevo módulo operacional de creación de solicitudes de recolección', 1, '', 1, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			@NewPickupParentModule NPPM
		
		INSERT INTO @NewSACModules
			(IdModule)
		SELECT
			TOP 1
				NM.IdModule
		FROM
			@NewModule NM
		
		INSERT INTO @NewOPModules
			(IdModule)
		SELECT
			TOP 1
				NM.IdModule
		FROM
			@NewModule NM

		DELETE FROM @NewModule



	END

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Monitoreo de recolecciones' COLLATE Latin1_General_CI_AI) )
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
		OUTPUT inserted.ModIdModule INTO @NewModule(IdModule)
		SELECT
			TOP 1
				'Monitoreo de recolecciones', NPPM.IdModule, '/operaciones/recolecciones/monitoreo', 'Nuevo módulo operacional de monitoreo de solicitudes de recolección', 1, '', 1, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			@NewPickupParentModule NPPM
		
		INSERT INTO @NewSACModules
			(IdModule)
		SELECT
			TOP 1
				NM.IdModule
		FROM
			@NewModule NM
		
		INSERT INTO @NewOPModules
			(IdModule)
		SELECT
			TOP 1
				NM.IdModule
		FROM
			@NewModule NM

		DELETE FROM @NewModule

	END

	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Recolecciones pendientes' COLLATE Latin1_General_CI_AI) )
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
		OUTPUT inserted.ModIdModule INTO @NewModule(IdModule)
		SELECT
			TOP 1
				'Recolecciones pendientes', NPPM.IdModule, '/operaciones/recolecciones/asignacion', 'Nuevo módulo operacional de asignación de solicitudes de recolección', 1, '', 1, 1, 'SYS-ARUIZ', GETDATE()
		FROM
			@NewPickupParentModule NPPM
		
		INSERT INTO @NewOPModules
			(IdModule)
		SELECT
			TOP 1
				NM.IdModule
		FROM
			@NewModule NM

		DELETE FROM @NewModule

	END


	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsModuleMenu, RmsRowStatus, RmsTokenCreated, RmsDateCreated)
	SELECT
		NSWR.IdRole, NS.IdSystem, NSM.IdModule, 1, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		@NewSACModules NSM
		CROSS JOIN
			@NewSACWebRole NSWR
		CROSS JOIN
			@NewSystem NS
			
	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsModuleMenu, RmsRowStatus, RmsTokenCreated, RmsDateCreated)
	SELECT
		NOWR.IdRole, NS.IdSystem, NOM.IdModule, 1, 1, 'SYS-ARUIZ', GETDATE()
	FROM
		@NewOPModules NOM
		CROSS JOIN
			@NewOPWebRole NOWR
		CROSS JOIN
			@NewSystem NS

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
END CATCH