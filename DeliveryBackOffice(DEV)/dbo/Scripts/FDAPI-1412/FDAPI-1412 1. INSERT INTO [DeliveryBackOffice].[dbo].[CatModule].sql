
DECLARE @BaseSystem INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes web operaciones' COLLATE Latin1_General_CI_AI)
DECLARE @SACRole INT = (SELECT TOP 1 CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'SAC web' COLLATE Latin1_General_CI_AI)
DECLARE @OPSRole INT = (SELECT TOP 1 CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Operaciones web' COLLATE Latin1_General_CI_AI)
DECLARE @DeliveriesHeadModule INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Entregas' COLLATE Latin1_General_CI_AI AND CM.ModPath = '/operaciones/entregas' COLLATE Latin1_General_CI_AI)

DECLARE @NewSACgModules TABLE (
	NewModuleId INT
);

DECLARE @NewOPSModules TABLE (
	NewModuleId INT
);
BEGIN TRANSACTION
BEGIN TRY

	-- Submodulos
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Seguimiento de incidencias' COLLATE Latin1_General_CI_AI AND CM.ModPath = '/operaciones/incidencias-sac' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModGroup)
		OUTPUT inserted.ModIdModule INTO @NewSACgModules (NewModuleId)
		VALUES
			('Seguimiento de incidencias', @DeliveriesHeadModule, '/operaciones/incidencias-sac', 'Módulo para seguimiento de incidencias desde servicio al cliente', 50, 'bi bi-exclamation-diamond-fill', 1, 1, 'SYS-ARUIZ', GETDATE(), NULL)

	END

	-- Submodulos2
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Seguimiento de incidencias' COLLATE Latin1_General_CI_AI AND CM.ModPath = '/operaciones/incidencias-operaciones' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModGroup)
		OUTPUT inserted.ModIdModule INTO @NewOPSModules (NewModuleId)
		VALUES
			('Seguimiento de incidencias', @DeliveriesHeadModule, '/operaciones/incidencias-operaciones', 'Módulo para seguimiento de incidencias desde servicio al cliente', 50, 'bi bi-exclamation-diamond-fill', 1, 1, 'SYS-ARUIZ', GETDATE(), NULL)

	END

	-- Registro de módulos a rol
	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsModuleMenu, RmsHasNewFunction)
	SELECT
		@SACRole, @BaseSystem, NTM.NewModuleId, 1, 'SYS-ARUIZ', GETDATE(), 1, 0
	FROM
		@NewSACgModules NTM

	-- Registro de módulos a rol
	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsModuleMenu, RmsHasNewFunction)
	SELECT
		@OPSRole, @BaseSystem, NTM.NewModuleId, 1, 'SYS-ARUIZ', GETDATE(), 1, 0
	FROM
		@NewOPSModules NTM

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