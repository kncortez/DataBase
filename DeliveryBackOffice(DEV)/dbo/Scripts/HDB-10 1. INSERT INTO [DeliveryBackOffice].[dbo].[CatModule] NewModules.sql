
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

	DECLARE @NewMyProfileID		INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Mi perfil' COLLATE Latin1_General_CI_AI AND CM.ModDescription LIKE 'Nuevo módulo%')
	
	INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
		(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated)
	OUTPUT inserted.ModIdModule, inserted.ModName, inserted.ModDescription INTO @NewSubModules(ModuleId, ModuleName, ModuleDescription)
	VALUES
		('Administrador de tarjetas'	,@NewMyProfileID	,	'/individual/tarjetas'			,	'Nuevo módulo individual de tarjetas de crédito o débito'		,5,'bi bi-credit-card'		,1,1,'SYS-ARUIZ',GETDATE())

	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
		(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsModuleMenu)
	SELECT
		@NewIndRol, @HermesWebSystemId, NSM.ModuleId, 1, 'SYS-ARUIZ', GETDATE(), 2
	FROM
		@NewSubModules NSM
		
	IF(@@TRANCOUNT > 0)
		COMMIT TRANSACTION

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION

END CATCH
