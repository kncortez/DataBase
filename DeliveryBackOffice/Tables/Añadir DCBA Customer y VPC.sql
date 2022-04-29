USE [DeliveryBackOffice];
GO

ALTER TABLE dbo.Customer ADD
DCBAID INT NULL

ALTER TABLE dbo.VisitPointClient ADD
DCBAID INT NULL

ALTER TABLE dbo.Customer ADD 
CONSTRAINT FK_Customer_DCBA FOREIGN KEY (DCBAID) REFERENCES dbo.DeliveryCustomerBankAccount(DCBA_ID)

ALTER TABLE dbo.VisitPointClient ADD 
CONSTRAINT FK_VisitPointClient_DCBA FOREIGN KEY (DCBAID) REFERENCES dbo.DeliveryCustomerBankAccount(DCBA_ID)

DECLARE @v sql_variant 
SET @v = N'Referencia al identificador de la tabla DeliveryCustomerBankAccount.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Customer', N'COLUMN', N'DCBAID'
GO

DECLARE @v sql_variant 
SET @v = N'Referencia al identificador de la tabla DeliveryCustomerBankAccount.'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'VisitPointClient', N'COLUMN', N'DCBAID'
GO