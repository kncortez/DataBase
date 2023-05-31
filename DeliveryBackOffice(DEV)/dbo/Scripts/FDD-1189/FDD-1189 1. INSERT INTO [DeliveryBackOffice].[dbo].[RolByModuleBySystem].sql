
DECLARE @DesktopSystemId INT = 
(
	SELECT 
		[CS].[SysIdSystem] 
	FROM
		[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
	WHERE
		[CS].[SysNameSystem] = 'Hermes Desktop'  COLLATE Latin1_General_CI_AI 
);
DECLARE @DesktopRoleId INT = 
(
	SELECT 
		[CR].[RolIdRol] 
	FROM
		[DeliveryBackOffice].[dbo].[CatRol] CR  WITH(NOLOCK) 
	WHERE
		[CR].[RolName] = 'Super Administrator HD'  COLLATE Latin1_General_CI_AI 
);

DECLARE @NewModule TABLE
(
	IdModule INT
)

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatModule] CM  WITH(NOLOCK) WHERE [CM].[ModPath] = 'FrmSetServiceIncidence'  COLLATE Latin1_General_CI_AI  )
)
BEGIN

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
	OUTPUT [Inserted].[ModIdModule] INTO @NewModule ([IdModule])
	VALUES
	(   
		N'Ingreso manual de incidencias',       -- ModName - nvarchar(200)
		NULL,      -- ModIdModuleParent - int
		'FrmSetServiceIncidence',        -- ModPath - varchar(200)
		'Módulo de ingreso manual de incidencias',      -- ModDescription - varchar(150)
		0,         -- ModOrder - int
		NULL,      -- ModMetadata - varchar(50)
		1,      -- ModVisible - bit
		1,      -- ModRowStatus - bit
		'SYS-ARUIZ',        -- ModTokenCreated - varchar(50)
		GETDATE(), -- ModDateCreated - datetime
		0    -- ModGroup - int
	)

END
ELSE
BEGIN

	INSERT INTO	@NewModule
	(
	    [IdModule]
	)
	SELECT
		TOP (1)
			[CM].[ModIdModule]
	FROM
		[DeliveryBackOffice].[dbo].[CatModule] CM  WITH(NOLOCK) 
	WHERE
		[CM].[ModPath] = 'FrmSetServiceIncidence'  COLLATE Latin1_General_CI_AI 

END

IF 
( 
	NOT EXISTS 
	( 
		SELECT 
			TOP (1) 
				1 
		FROM 
			[DeliveryBackOffice].[dbo].[RolByModuleBySystem] RBMBS  WITH(NOLOCK)  
			INNER JOIN
				@NewModule NM
				ON
					[RBMBS].[RmsIdModule] = [NM].[IdModule]
		WHERE
			[RBMBS].[RmsIdRol] = @DesktopRoleId
			AND
			[RBMBS].[RmsIdSystem] = @DesktopSystemId
	)
)
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[RolByModuleBySystem]
	(
	    [RmsIdRol],
	    [RmsIdSystem],
	    [RmsIdModule],
	    [RmsRowStatus],
	    [RmsTokenCreated],
	    [RmsDateCreated]
	)
	SELECT 
		TOP (1) 
			@DesktopRoleId
			,@DesktopSystemId
			,[NM].[IdModule]
			,1
			,'SYS-ARUIZ'
			,GETDATE()
	FROM 
		@NewModule NM
    
END