USE DeliveryBackOffice
GO
CREATE TABLE dbo.CodBankAccount
	(
	CodBankAccountId int NOT NULL,
	CustomerId int NOT NULL,
	BankId int NOT NULL,
	BankAccountId nvarchar(50) NOT NULL,
	BankAccountName nvarchar(200) NULL,
	BankAccountType nvarchar(40) NOT NULL,
	CurrencyId int NOT NULL,
	RowStatus bit NOT NULL,
	TokenCreated nvarchar(50) NOT NULL,
	DateCreated datetime NOT NULL,
	TokenUpdated nvarchar(50) NULL,
	DateUpdated datetime NULL
	)  ON [PRIMARY]
GO
DECLARE @v sql_variant 
SET @v = N'Cuentas bancarias de clientes por COD'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', NULL, NULL
GO
DECLARE @v sql_variant 
SET @v = N'Identificador de cuenta bancaria'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'CodBankAccountId'
GO
DECLARE @v sql_variant 
SET @v = N'Identificador del cliente'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'CustomerId'
GO
DECLARE @v sql_variant 
SET @v = N'Identificador del banco'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'BankId'
GO
DECLARE @v sql_variant 
SET @v = N'Número de cuenta'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'BankAccountId'
GO
DECLARE @v sql_variant 
SET @v = N'Nombre de la cuenta'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'BankAccountName'
GO
DECLARE @v sql_variant 
SET @v = N'Tipo de cuenta

Monetaria, ahorros'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'BankAccountType'
GO
DECLARE @v sql_variant 
SET @v = N'Tipo de moneda'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'CurrencyId'
GO
DECLARE @v sql_variant 
SET @v = N'Estado de la cuenta'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'RowStatus'
GO
DECLARE @v sql_variant 
SET @v = N'Token de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'TokenCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de creación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'DateCreated'
GO
DECLARE @v sql_variant 
SET @v = N'Token de actualización'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'TokenUpdated'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de actualización'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'CodBankAccount', N'COLUMN', N'DateUpdated'
GO
ALTER TABLE dbo.CodBankAccount ADD CONSTRAINT
	PK_CodBankAccount PRIMARY KEY CLUSTERED 
	(
	CodBankAccountId
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.CodBankAccount ADD CONSTRAINT
	FK_CodBankAccount_Customer FOREIGN KEY
	(
	CustomerId
	) REFERENCES dbo.Customer
	(
	IdCustomer
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.CodBankAccount ADD CONSTRAINT
	FK_CodBankAccount_DeliveryBank FOREIGN KEY
	(
	BankId
	) REFERENCES dbo.DeliveryBank
	(
	Id_bank
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.CodBankAccount ADD CONSTRAINT
	FK_CodBankAccount_DeliveryCurrency FOREIGN KEY
	(
	CurrencyId
	) REFERENCES dbo.DeliveryCurrency
	(
	Currency_Id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
