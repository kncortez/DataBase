USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[Account] (AccName, AccIdTypeAccount, AccRowStatus, AccTokenCreated, AccDateCreated, AccTokenUpdated, AccDateUpdated, IdCustomer, AccConfirm)
	VALUES ('Envíos de Cliente Referenciado', 1, 1, 'SYS-OMORALES', GETDATE(), NULL, NULL, (SELECT c.IdCustomer FROM Customer c WHERE c.Name = 'Cliente Referenciado' AND c.Domain = '@forzadelivery'), 'C');
