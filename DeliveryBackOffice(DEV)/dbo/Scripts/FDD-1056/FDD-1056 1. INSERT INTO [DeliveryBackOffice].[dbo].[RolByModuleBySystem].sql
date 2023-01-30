
DECLARE @SystemId INT = (SELECT TOP 1 CS.SysIdSystem FROM [DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK) WHERE CS.SysNameSystem = 'Hermes Desktop' COLLATE Latin1_General_CI_AI)
DECLARE @NewModule TABLE (
	ModuleId INT
);
DECLARE @NewRole TABLE (
	RoleId INT
);

BEGIN TRANSACTION
BEGIN TRY

	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) WHERE CM.ModName = 'Notas de Credito' COLLATE Latin1_General_CI_AI))
	BEGIN

		Insert into [DeliveryBackOffice].[dbo].CatModule 
			(ModName, ModIdModuleParent, ModPath,ModDescription,ModOrder,ModVisible,ModRowStatus,ModTokenCreated, ModDateCreated)
		OUTPUT inserted.ModIdModule INTO @NewModule(ModuleId)
		Values
			('Notas de Credito',18,'FrmNotasCredito','Módulo notas de credito',3,1,1,'ELOPEZ',GETDATE())

	END
	ELSE
	BEGIN

		INSERT INTO @NewModule
			(ModuleId)
		SELECT 
			TOP 1 CM.ModIdModule 
		FROM 
			[DeliveryBackOffice].[dbo].[CatModule] CM WITH(NOLOCK) 
		WHERE 
			CM.ModName = 'Notas de Credito' COLLATE Latin1_General_CI_AI

	END

	IF(NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Notas Crédito' COLLATE Latin1_General_CI_AI))
	BEGIN

		Insert into [DeliveryBackOffice].[dbo].CatRol 
			(RolIdSystem,RolName,RolDescription,RolAdminClient, RolRowStatus, RolTokenCreated, RolDateCreated) 
		OUTPUT inserted.RolIdSystem INTO @NewRole(RoleId)
		values
			(2,'Notas Crédito','Rol para uso de módulo de notas de crédito',0,1,'ELOPEZ',GETDATE())

	END
	ELSE
	BEGIN

		INSERT INTO @NewRole
			(RoleId)
		SELECT 
			TOP 1 
				CR.RolIdRol
		FROM 
			[DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) 
		WHERE 
			CR.RolName = 'Notas Crédito' COLLATE Latin1_General_CI_AI

	END

	IF(EXISTS(SELECT TOP 1 1 FROM @NewModule) AND EXISTS(SELECT TOP 1 1 FROM @NewRole) AND @SystemId IS NOT NULL)
	BEGIN

		INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
			(RmsIdRol, RmsIdModule, RmsIdSystem, RmsDateCreated, RmsTokenCreated, RmsRowStatus)
		SELECT
			TOP 1
				NR.RoleId, NM.ModuleId, @SystemId, GETDATE(), 'ELOPEZ', 1
		FROM
			@NewRole NR
			CROSS JOIN
				@NewModule NM

	END

	COMMIT TRANSACTION 

	SELECT
		1

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION

	SELECT
		0

END CATCH