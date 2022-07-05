-- RolByModuleBySystem

INSERT INTO [dbo].[RolByModuleBySystem]
			([RmsIdRol],
			 [RmsIdSystem],
			 [RmsIdModule],
			 [RmsRowStatus],
			 [RmsTokenCreated],
			 [RmsDateCreated])
		VALUES ((SELECT [dbo].[CatRol].[RolIdRol]
				 FROM [CatRol]
				 WHERE [dbo].[CatRol].[RolName] = 'Admin Hermes Mobile'),
			    (SELECT [dbo].[CatSystem].[SysIdSystem]
				 FROM [CatSystem]
				 WHERE [dbo].[CatSystem].[SysNameSystem] = 'Hermes Mobile'),
				(SELECT [dbo].[CatModule].[ModIdModule]
				 FROM [CatModule]
				 WHERE [dbo].[CatModule].[ModName] = 'Despacho de linehaul'),
				1, 
				'SYS-ADMIN',
				SYSDATETIME());

INSERT INTO [dbo].[RolByModuleBySystem]
			([RmsIdRol],
			 [RmsIdSystem],
			 [RmsIdModule],
			 [RmsRowStatus],
			 [RmsTokenCreated],
			 [RmsDateCreated])
		VALUES ((SELECT [dbo].[CatRol].[RolIdRol]
				 FROM [CatRol]
				 WHERE [dbo].[CatRol].[RolName] = 'Admin Hermes Mobile'),
			    (SELECT [dbo].[CatSystem].[SysIdSystem]
				 FROM [CatSystem]
				 WHERE [dbo].[CatSystem].[SysNameSystem] = 'Hermes Mobile'),
				(SELECT [dbo].[CatModule].[ModIdModule]
				 FROM [CatModule]
				 WHERE [dbo].[CatModule].[ModName] = 'Liquidación de linehaul'),
				1, 
				'SYS-ADMIN',
				SYSDATETIME());