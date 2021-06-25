USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA PARAMETRIZACION DE LOS EMAIL A LOS PROCESOS
INSERT INTO [dbo].[CatEmailProcessCOD] 
			([CatProcessCODId],[CatReceiverEmailCODId],[TokenCreated])
	VALUES	(1,1,'AORTIZ')

INSERT INTO [dbo].[CatEmailProcessCOD] 
			([CatProcessCODId],[CatReceiverEmailCODId],[TokenCreated])
	VALUES	(1,2,'AORTIZ')

--COMMIT


