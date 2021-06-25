USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA PARAMETRIZACION DE LOS TIPOS DE TRANSACCION
INSERT INTO [dbo].[CatTransactionTypeCOD] 
			([TransactionType],[Description],[BankId],[TokenCreated]) 
	VALUES  ('CR','CUENTAS INTERNAS BAC O BANCOR',31,'AORTIZ')

INSERT INTO [dbo].[CatTransactionTypeCOD] 
			([TransactionType],[Description],[BankId],[TokenCreated]) 
	VALUES  ('RT','CREDITOS ENVIAR FONDOS A OTROS BANCOS',31,'AORTIZ')

INSERT INTO [dbo].[CatTransactionTypeCOD] 
			([TransactionType],[Description],[BankId],[TokenCreated]) 
	VALUES  ('DP','DEBITOS ACH TRAER FONDOS DE OTROS BANCOS',31,'AORTIZ')

INSERT INTO [dbo].[CatTransactionTypeCOD] 
			([TransactionType],[Description],[BankId],[TokenCreated]) 
	VALUES  ('CG','CHEQUES DE GERENCIA',31,'AORTIZ')

INSERT INTO [dbo].[CatTransactionTypeCOD] 
			([TransactionType],[Description],[BankId],[TokenCreated]) 
	VALUES  ('OP','ORDENES DE PAGO',31,'AORTIZ')

--COMMIT


