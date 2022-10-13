
DECLARE @HermesWebSystemId INT = (
	SELECT
		TOP 1
			CS.SysIdSystem
	FROM
		[DeliveryBackOffice].[dbo].[CatSystem] CS WITH(NOLOCK)
	WHERE
		CS.SysNameSystem = 'Hermes Web' COLLATE Latin1_General_CI_AI
)

IF( NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Nuevo estandar' COLLATE Latin1_General_CI_AI AND CR.RolIdSystem = @HermesWebSystemId AND CR.RolRowStatus = 1 ) )
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[CatRol]
		(RolIdSystem, RolName, RolDescription, RolAdminBrothers, RolAdminClient, RolRowStatus, RolTokenCreated, RolDateCreated)
	VALUES
		(@HermesWebSystemId, 'Nuevo estandar', 'Nuevos usuarios individuales estandar', 0, 0, 1, 'SYS-ARUIZ', GETDATE())

END