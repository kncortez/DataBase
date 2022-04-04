USE [DeliveryBackOffice]
GO
 
INSERT INTO [dbo].[CatModule]
   ([ModName]
   ,[ModIdModuleParent]
   ,[ModPath]
   ,[ModDescription]
   ,[ModOrder]
   ,[ModMetadata]
   ,[ModVisible]
   ,[ModRowStatus]
   ,[ModTokenCreated]
   ,[ModDateCreated]
   ,[ModTokenUpdated]
   ,[ModDateUpdated]
   )
VALUES
   ('Cierre Operador',
	(SELECT ModIdModule FROM CatModule
	WHERE ModName = 'Cierres'),
	'/cierre-operador',
	'Cierre de Operador',
	16,
	'file.png',
	1,
	1,
	'SYS-ORODRIGUEZ',
	GETDATE(),
	NULL,
	NULL	
	)
GO


USE [DeliveryBackOffice]
GO
 
INSERT INTO [dbo].[CatModule]
   ([ModName]
   ,[ModIdModuleParent]
   ,[ModPath]
   ,[ModDescription]
   ,[ModOrder]
   ,[ModMetadata]
   ,[ModVisible]
   ,[ModRowStatus]
   ,[ModTokenCreated]
   ,[ModDateCreated]
   ,[ModTokenUpdated]
   ,[ModDateUpdated]
   )
VALUES
   ('Cierre General',
	(SELECT ModIdModule FROM CatModule
	WHERE ModName = 'Cierres'),
	'/cierres',
	'Cierre General por Punto de Visita',
	16,
	'file.png',
	1,
	1,
	'SYS-ORODRIGUEZ',
	GETDATE(),
	NULL,
	NULL	
	)
GO