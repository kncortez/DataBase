USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LOS EMAIL A LOS QUE SE ENVIARAN LOS ARCHIVOS GENERADOS
INSERT INTO [dbo].[CatReceiverEmailCOD] 
			([Email],[TokenCreated])
	VALUES	('alvaro.ortiz@forzalatam.com','AORTIZ')

INSERT INTO [dbo].[CatReceiverEmailCOD] 
			([Email],[TokenCreated])
	VALUES	('oscar.morales@forzalatam.com','AORTIZ')

--COMMIT


