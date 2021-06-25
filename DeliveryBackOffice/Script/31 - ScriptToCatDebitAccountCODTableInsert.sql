USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA PARAMETRIZACION DE LAS CUENTAS DE DEBITO
INSERT INTO [dbo].[CatDebitAccountCOD] 
			([AccountNumber],[BankId],[TokenCreated]) 
	VALUES  ('903666113',31,'AORTIZ')

--COMMIT


