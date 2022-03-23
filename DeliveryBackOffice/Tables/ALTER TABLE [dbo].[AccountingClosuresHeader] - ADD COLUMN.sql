USE [DeliveryBackOffice]
GO

ALTER TABLE [AccountingClosuresHeader]
ADD TotalAmountCODCashDeclared DECIMAL(18, 5) NOT NULL 
CONSTRAINT [ACH_TotalAmountCODCashDeclared] DEFAULT 0
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Monto total de COD en efectivo declarado', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'TotalAmountCODCashDeclared'
GO

ALTER TABLE [AccountingClosuresHeader]
ADD TotalAmountCODCreditDeclared DECIMAL(18, 5) NOT NULL 
CONSTRAINT [ACH_TotalAmountCODCreditDeclared] DEFAULT 0
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Monto total de COD con tarjeta declarado', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'TotalAmountCODCreditDeclared'
GO



ALTER TABLE [AccountingClosuresHeader]
ADD TotalAmountFacturaCash DECIMAL(18, 5) NOT NULL 
CONSTRAINT [ACH_TotalAmountFacturaCash] DEFAULT 0
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Monto total de facturas en efectivo para COD', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'TotalAmountFacturaCash'
GO

ALTER TABLE [AccountingClosuresHeader]
ADD InvoiceAmountFacturaCash INT NOT NULL 
CONSTRAINT [ACH_InvoiceAmountFacturaCash] DEFAULT 0
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Cantidad de facturas efectivo para COD', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'InvoiceAmountFacturaCash'
GO

ALTER TABLE [AccountingClosuresHeader]
ADD TotalAmountFacturaCard DECIMAL(18, 5) NOT NULL 
CONSTRAINT [ACH_TotalAmountFacturaCard] DEFAULT 0
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Monto total de facturas con tarjeta para COD', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'TotalAmountFacturaCard'
GO

ALTER TABLE [AccountingClosuresHeader]
ADD InvoiceAmountFacturaCard INT NOT NULL 
CONSTRAINT [ACH_InvoiceAmountFacturaCard] DEFAULT 0
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Cantidad de facturas tarjeta para COD', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'InvoiceAmountFacturaCard'
GO

ALTER TABLE [AccountingClosuresHeader]
ADD TotalAmountFacturaCashDeclared DECIMAL(18, 5) NOT NULL 
CONSTRAINT [ACH_TotalAmountFacturaCashDeclared] DEFAULT 0
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Monto total de facturas en efectivo para COD declarado', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'TotalAmountFacturaCashDeclared'
GO

ALTER TABLE [AccountingClosuresHeader]
ADD TotalAmountFacturaCardDeclared DECIMAL(18, 5) NOT NULL 
CONSTRAINT [ACH_TotalAmountFacturaCardDeclared] DEFAULT 0
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Monto total de facturas con tarjeta para COD declarado', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'TotalAmountFacturaCardDeclared'
GO

ALTER TABLE [AccountingClosuresHeader]
ADD InvoiceAmountCOD INT NOT NULL 
CONSTRAINT [ACH_InvoiceAmountCOD] DEFAULT 0
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Cantidad de cobros de COD', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'InvoiceAmountCOD'
GO