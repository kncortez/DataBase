-- RolByUserBySystem
-- Editar el parámetro 'Username' en la consulta de la tabla 'InternalUser' especificado como 'my.username.here' por el usuario deseado para asignarle los roles de Administrador

INSERT INTO [dbo].[RolByUserBySystem]
			([RusIdRol],
			 [RusIdSystem],
			 [RusIdUser],
			 [RusRowStatus],
			 [RusTokenCreated],
			 [RusDateCreated],
			 [StationId])
		VALUES ((SELECT [dbo].[CatRol].[RolIdRol]
				 FROM [CatRol]
				 WHERE [dbo].[CatRol].[RolName] = 'Admin Hermes Mobile'),
				 (SELECT [dbo].[CatSystem].[SysIdSystem]
				  FROM [CatSystem]
				  WHERE [dbo].[CatSystem].[SysNameSystem] = 'Hermes Mobile'),
				 (SELECT [dbo].[InternalUser].[RegisterUserID]
				  FROM [InternalUser]
				  WHERE [dbo].[InternalUser].[Username] = 'my.username.here'),
				 1,
				 'SYS-JOCHOA', 
				 SYSDATETIME(), 
				 (SELECT [dbo].[CatStation].[IdStation]
				  FROM [CatStation]
				  WHERE [dbo].[CatStation].[StationName] = 'GUATEMALA'));