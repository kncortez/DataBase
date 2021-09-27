USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA PARAMETRIZACION DE LOS NUEVOS STATUS (CHECKPOINTS)
INSERT INTO [dbo].[StatusOrder] 
			([OrderDescription]) 
	VALUES  ('Recibido En Express Center')

INSERT INTO [dbo].[StatusOrder] 
			([OrderDescription]) 
	VALUES  ('Entregado En Express Center')

INSERT INTO [dbo].[StatusOrder] 
			([OrderDescription]) 
	VALUES  ('Devuelto en Express Center')

--COMMIT


SELECT *
FROM StatusOrder