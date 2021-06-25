USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LAS COLUMNAS QUE CONSTRUYEN EL ARCHIVO
INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('CUENTA DEBITO','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('CUENTA CREDITO','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('FECHA','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('MONTO','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('REFERENCIA','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('BENEFICIARIO','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('TIPO DE TRANSACCION','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('MONEDA ACH','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('CODIGO BANCO ACH','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('TIPO DE CUENTA','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('CONCEPTO','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[TokenCreated]) 
	VALUES  ('CONTRASEÑA','AORTIZ')

--COMMIT


