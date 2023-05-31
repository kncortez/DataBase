-- FDAPI-1613 - SCRIPTS

INSERT INTO [dbo].[CatSystem] (	[SysNameSystem], 
								[SysPlataform],
								[SysDescription],
								[SysRowStatus],
								[SysTokenCreated],
								[SysDateCreated])
VALUES						(	'SimplirouteConnect',
								'SimplirouteConnect',
								'Servicio de recolecciones programadas SimpliRoute',
								1, 
								'SYS-JOCHOA',
								SYSDATETIME());