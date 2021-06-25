USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA PARAMETRIZACION DE LOS TIPOS DE CUENTA
INSERT INTO [dbo].[CatAccountTypeCOD] 
			([AccountType],[Description],[TokenCreated]) 
	VALUES  ('MONETARIA','DM','AORTIZ')

INSERT INTO [dbo].[CatAccountTypeCOD] 
			([AccountType],[Description],[TokenCreated]) 
	VALUES  ('AHORRO','DA','AORTIZ')

INSERT INTO [dbo].[CatAccountTypeCOD] 
			([AccountType],[TokenCreated]) 
	VALUES  ('AHORRO BANCO DEL NIÑO','AORTIZ')

INSERT INTO [dbo].[CatAccountTypeCOD] 
			([AccountType],[TokenCreated]) 
	VALUES  ('PRESTAMO','AORTIZ')

INSERT INTO [dbo].[CatAccountTypeCOD] 
			([AccountType],[TokenCreated]) 
	VALUES  ('TARJETA DE CREDITO','AORTIZ')

INSERT INTO [dbo].[CatAccountTypeCOD] 
			([AccountType],[TokenCreated]) 
	VALUES  ('TARJETA DE DEBITO','AORTIZ')

--COMMIT


