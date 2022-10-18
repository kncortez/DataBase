-- CatSystem - Registro de sistema Hermes Mobile
INSERT INTO [dbo].[CatSystem]
			([SysNameSystem],
			 [SysPlataform],
			 [SysDescription],
			 [SysRowStatus],
			 [SysTokenCreated],
			 [SysDateCreated])
		VALUES 
			('Hermes Mobile', 
			 'Forza Delivery Mobile', 
			 'App Operaciones Mobile', 
			 1, 
			 'SYS-JOCHOA', 
			 SYSDATETIME());