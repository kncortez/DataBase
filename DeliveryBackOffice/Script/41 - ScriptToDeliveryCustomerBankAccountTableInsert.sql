USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA PARAMETRIZACION DE LA CUENTA DE BAC DE FORZA
--EN DONDE SE DEPOSITAN LAS COMISIONES Y ENVIOS
DECLARE @MaxId INT;

SELECT @MaxId = MAX([DCBA_Id])
FROM [dbo].[DeliveryCustomerBankAccount];

INSERT INTO [dbo].[DeliveryCustomerBankAccount] 
			([DCBA_Id],[DCBA_Bank_Id],[DCBA_Num_account],[DCBA_Nom_account],[DCBA_Id_currency],
			 [DCBA_TokenCreated],[DCBA_DateCreated],[DCBA_Id_estado],[DCBA_BankAccountType],[DCBA_Customer_Id]) 
	VALUES  ((@MaxId + 1),31,'903666261','DELIVERY EXPRESS',1,
			 'AORTIZ',GETDATE(),1,'Monetaria',-1)

--COMMIT


