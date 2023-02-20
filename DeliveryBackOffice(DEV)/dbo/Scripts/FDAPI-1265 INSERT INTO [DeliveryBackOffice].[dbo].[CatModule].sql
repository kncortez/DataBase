DECLARE @RolID INT = (SELECT TOP 1 CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Nuevo estandar' COLLATE Latin1_General_CI_AI)
DECLARE @SystemId INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes Web' COLLATE Latin1_General_CI_AI);

DECLARE @InsertedModule TABLE (
	ModuleId INT
);
INSERT INTO [DeliveryBackOffice].[dbo].[CatModule]
	(ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModTokenUpdated, ModDateUpdated, ModGroup)
OUTPUT inserted.ModIdModule INTO @InsertedModule (ModuleId)
VALUES
	('Mis transacciones', NULL, '/individual/mis-transacciones', 'Nuevo módulo individual de transacciones con tarjeta dentro del portal', 85, 'bi bi-receipt', 1, 1, 'SYS-ARUIZ', GETDATE(), NULL, NULL, 0)
	
INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
	(RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsTokenUpdated, RmsDateUpdated, RmsModuleMenu, RmsHasNewFunction)
SELECT
	@RolID, @SystemId, IM.ModuleId, 1, 'SYS-ARUIZ', GETDATE(), NULL, NULL, 1, NULL
FROM
	@InsertedModule IM