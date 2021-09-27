USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA CONFIGURACION DE LOS MODULOS 
--PARA QUE SEAN VISIBLES EN EL MENU
INSERT INTO [dbo].[RolByModuleBySystem] 
			([RmsIdRol], 
			 [RmsIdSystem], 
			 [RmsIdModule], 
			 [RmsRowStatus], 
			 [RmsTokenCreated], 
			 [RmsDateCreated]) 
	VALUES  (5, 
			 1, 
			 33, 
			 1, 
			 'EDUARDO-LOPEZ', 
			 GETDATE())

INSERT INTO [dbo].[RolByModuleBySystem] 
			([RmsIdRol], 
			 [RmsIdSystem], 
			 [RmsIdModule], 
			 [RmsRowStatus], 
			 [RmsTokenCreated], 
			 [RmsDateCreated]) 
	VALUES  (5, 
			 1, 
			 34, 
			 1, 
			 'EDUARDO-LOPEZ', 
			 GETDATE())

INSERT INTO [dbo].[RolByModuleBySystem] 
			([RmsIdRol], 
			 [RmsIdSystem], 
			 [RmsIdModule], 
			 [RmsRowStatus], 
			 [RmsTokenCreated], 
			 [RmsDateCreated]) 
	VALUES  (5, 
			 1, 
			 35, 
			 1, 
			 'EDUARDO-LOPEZ', 
			 GETDATE())

INSERT INTO [dbo].[RolByModuleBySystem] 
			([RmsIdRol], 
			 [RmsIdSystem], 
			 [RmsIdModule], 
			 [RmsRowStatus], 
			 [RmsTokenCreated], 
			 [RmsDateCreated]) 
	VALUES  (5, 
			 1, 
			 36, 
			 1, 
			 'EDUARDO-LOPEZ', 
			 GETDATE())

INSERT INTO [dbo].[RolByModuleBySystem] 
			([RmsIdRol], 
			 [RmsIdSystem], 
			 [RmsIdModule], 
			 [RmsRowStatus], 
			 [RmsTokenCreated], 
			 [RmsDateCreated]) 
	VALUES  (3, 
			 1, 
			 33, 
			 1, 
			 'EDUARDO-LOPEZ', 
			 GETDATE())

INSERT INTO [dbo].[RolByModuleBySystem] 
			([RmsIdRol], 
			 [RmsIdSystem], 
			 [RmsIdModule], 
			 [RmsRowStatus], 
			 [RmsTokenCreated], 
			 [RmsDateCreated]) 
	VALUES  (3, 
			 1, 
			 34, 
			 1, 
			 'EDUARDO-LOPEZ', 
			 GETDATE())

INSERT INTO [dbo].[RolByModuleBySystem] 
			([RmsIdRol], 
			 [RmsIdSystem], 
			 [RmsIdModule], 
			 [RmsRowStatus], 
			 [RmsTokenCreated], 
			 [RmsDateCreated]) 
	VALUES  (3, 
			 1, 
			 35, 
			 1, 
			 'EDUARDO-LOPEZ', 
			 GETDATE())

INSERT INTO [dbo].[RolByModuleBySystem] 
			([RmsIdRol], 
			 [RmsIdSystem], 
			 [RmsIdModule], 
			 [RmsRowStatus], 
			 [RmsTokenCreated], 
			 [RmsDateCreated]) 
	VALUES  (3, 
			 1, 
			 36, 
			 1, 
			 'EDUARDO-LOPEZ', 
			 GETDATE())

--COMMIT


SELECT *
FROM RolByModuleBySystem