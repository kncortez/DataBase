-- FDAPI-3292 - SCRIPTS

INSERT INTO [dbo].[CatSystem] (	[SysNameSystem], 
								[SysPlataform],
								[SysDescription],
								[SysRowStatus],
								[SysTokenCreated],
								[SysDateCreated])
VALUES						(	'App Móvil',
								'Delivery App',
								'App móvil clientes individuales y corporativos',
								1, 
								'SYS-ARECINOS',
								SYSDATETIME());