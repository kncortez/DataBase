USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA PARAMETRIZACION DE LOS MODULOS
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
	VALUES  ('Servicios',
			 NULL,
			 '/servicios',
			 'Identificador de los servicios',
			 13,
			 'file.png',
			 1,
			 1,
			 'AORTIZ',
			 GETDATE())

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
	VALUES  ('Servicio Recepción',
			 33,
			 '/servicios/recoleccion/registro',
			 'Servicio que marca las guías recolectadas',
			 1,
			 'file.png',
			 1,
			 1,
			 'AORTIZ',
			 GETDATE())

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
	VALUES  ('Servicio Entrega',
			 33,
			 '/servicios/entrega/registro',
			 'Servicio que marca las guías entregadas',
			 2,
			 'file.png',
			 1,
			 1,
			 'AORTIZ',
			 GETDATE())

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
	VALUES  ('Servicio Devolución',
			 33,
			 '/servicios/devolucion/registro',
			 'Servicio que marca las guías por devolución',
			 3,
			 'file.png',
			 1,
			 1,
			 'AORTIZ',
			 GETDATE())

--COMMIT


SELECT *
FROM CatModule