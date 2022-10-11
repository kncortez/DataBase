-- HDB-14
INSERT INTO [dbo].[CatModule] 
			([ModName],
			 [ModIdModuleParent],
			 [ModPath],
			 [ModDescription],
			 [ModOrder],
			 [ModMetadata],
			 [ModVisible],
			 [ModRowStatus],
			 [ModTokenCreated],
			 [ModDateCreated])
VALUES		('Preparación de ruta',
			 NULL,					-- ModIdModuleParent
			 'route-preparation',	
			 'Módulo para preparación de ruta en Hermes Mobile',
			 3,						-- ModOrder
			 NULL,					-- ModMetadata
			 1,						-- ModVisible
			 1,						-- ModRowStatus
			 'SYS-JOCHOA',
			 SYSDATETIME());

INSERT INTO [dbo].[CatModule] 
			([ModName],
			 [ModIdModuleParent],
			 [ModPath],
			 [ModDescription],
			 [ModOrder],
			 [ModMetadata],
			 [ModVisible],
			 [ModRowStatus],
			 [ModTokenCreated],
			 [ModDateCreated])
VALUES		('Liquidación de ruta',
			 NULL,					-- ModIdModuleParent
			 'route-settlement',	
			 'Módulo para liquidación de ruta en Hermes Mobile',
			 4,						-- ModOrder
			 NULL,					-- ModMetadata
			 1,						-- ModVisible
			 1,						-- ModRowStatus
			 'SYS-JOCHOA',
			 SYSDATETIME());


INSERT INTO [dbo].[RolByModuleBySystem]
			([RmsIdRol],
			 [RmsIdSystem],
			 [RmsIdModule],
			 [RmsRowStatus],
			 [RmsTokenCreated],
			 [RmsDateCreated])
	VALUES ((SELECT [dbo].[CatRol].[RolIdRol] FROM [CatRol] WHERE [dbo].[CatRol].[RolName] = 'Admin Hermes Mobile'),				-- RmsIdRol
			(SELECT [dbo].[CatSystem].[SysIdSystem] FROM [CatSystem] WHERE [dbo].[CatSystem].[SysNameSystem] = 'Hermes Mobile'),	-- RmsIdSystem
			(SELECT [dbo].[CatModule].[ModIdModule] FROM [CatModule] WHERE [dbo].[CatModule].[ModName] = 'Preparación de ruta'),	-- RmsIdModule
			1,																														-- RmsRowStatus
			'SYS-JOCHOA',																											-- RmsTokenCreated
			SYSDATETIME());																											-- RmsDateCreated

INSERT INTO [dbo].[RolByModuleBySystem]
			([RmsIdRol],
			 [RmsIdSystem],
			 [RmsIdModule],
			 [RmsRowStatus],
			 [RmsTokenCreated],
			 [RmsDateCreated])
	VALUES ((SELECT [dbo].[CatRol].[RolIdRol] FROM [CatRol] WHERE [dbo].[CatRol].[RolName] = 'Admin Hermes Mobile'),				-- RmsIdRol
			(SELECT [dbo].[CatSystem].[SysIdSystem] FROM [CatSystem] WHERE [dbo].[CatSystem].[SysNameSystem] = 'Hermes Mobile'),	-- RmsIdSystem
			(SELECT [dbo].[CatModule].[ModIdModule] FROM [CatModule] WHERE [dbo].[CatModule].[ModName] = 'Liquidación de ruta'),	-- RmsIdModule
			1,																														-- RmsRowStatus
			'SYS-JOCHOA',																											-- RmsTokenCreated
			SYSDATETIME());																											-- RmsDateCreated
