USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LAS COLUMNAS QUE CONSTRUYEN EL ARCHIVO
INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('CUENTA DEBITO','CatDebitAccountCODId','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('CUENTA CREDITO','CreditAccountId','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('FECHA','CreditDate','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('MONTO','Amount','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('REFERENCIA','Reference','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('BENEFICIARIO','Beneficiary','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('TIPO DE TRANSACCION','CatTransactionTypeCODId','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('MONEDA ACH','CatCurrencyCODId','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('CODIGO BANCO ACH','BankId','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('TIPO DE CUENTA','CatAccountTypeCODId','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('CONCEPTO','CatConceptCODId','AORTIZ')

INSERT INTO [dbo].[CatColumnCOD] 
			([ColumnName],[BatchDetailCODColumnName],[TokenCreated]) 
	VALUES  ('CONTRASEÑA','Password','AORTIZ')

--COMMIT


