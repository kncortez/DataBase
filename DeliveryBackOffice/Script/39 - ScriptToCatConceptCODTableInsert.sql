USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA PARAMETRIZACION DE LOS CONCEPTOS
INSERT INTO [dbo].[CatConceptCOD] 
			([Concept],[TokenCreated]) 
	VALUES  ('COMISION Y ENVIOS','AORTIZ')

INSERT INTO [dbo].[CatConceptCOD] 
			([Concept],[TokenCreated]) 
	VALUES  ('PAGO POR ENTREGAS','AORTIZ')

--COMMIT


