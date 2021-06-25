USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA PARAMETRIZACION DE LOS MODULOS QUE SERAN NUESTROS ORIGENES DE DATOS
INSERT INTO [dbo].[CatModule] 
			([ModName],[ModPath],[ModOrder],[ModVisible],[ModRowStatus],[ModTokenCreated],[ModDateCreated]) 
	VALUES  ('Courier App','Courier App',1,0,1,'AORTIZ',GETDATE())

INSERT INTO [dbo].[CatModule] 
			([ModName],[ModPath],[ModOrder],[ModVisible],[ModRowStatus],[ModTokenCreated],[ModDateCreated]) 
	VALUES  ('Liquidación COD','Liquidación COD',1,0,1,'AORTIZ',GETDATE())

/*INSERT INTO [dbo].[CatModule] 
			([ModName],[ModPath],[ModOrder],[ModVisible],[ModRowStatus],[ModTokenCreated],[ModDateCreated]) 
	VALUES  ('Express Center','Express Center',1,0,1,'AORTIZ',GETDATE())*/

--COMMIT


