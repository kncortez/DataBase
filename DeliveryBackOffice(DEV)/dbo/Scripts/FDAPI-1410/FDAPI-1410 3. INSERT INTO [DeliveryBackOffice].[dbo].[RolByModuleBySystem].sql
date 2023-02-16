
DECLARE @BaseSystem INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes web operaciones' COLLATE Latin1_General_CI_AI)
DECLARE @TelemarketingRole INT = (SELECT TOP 1 CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Ventas telemercadeo' COLLATE Latin1_General_CI_AI)
DECLARE @TelemarketingHeadModule INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Telemercadeo' COLLATE Latin1_General_CI_AI AND CM.ModPath = '/telemercadeo' COLLATE Latin1_General_CI_AI)

DECLARE @NewTelemarketingModules TABLE (
	NewModuleId INT
);

BEGIN TRANSACTION
BEGIN TRY

	-- Submodulos
	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Venta de suscripciones' COLLATE Latin1_General_CI_AI))
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
			(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModGroup)
		OUTPUT inserted.ModIdModule INTO @NewTelemarketingModules (NewModuleId)
		VALUES
			('Venta de suscripciones', @TelemarketingHeadModule, '/telemercadeo/detalle-suscripciones', 'Módulo para venta de suscripciones con usuarios de telemercadeo', 25, 'bi-file-text-fill', 1, 1, 'SYS-ARUIZ', GETDATE(), NULL)

	END

	-- Registro de módulos a rol
	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsModuleMenu, RmsHasNewFunction)
	SELECT
		@TelemarketingRole, @BaseSystem, NTM.NewModuleId, 1, 'SYS-ARUIZ', GETDATE(), 1, 0
	FROM
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