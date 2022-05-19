USE [DeliveryBackOffice]
GO


ALTER TABLE [dbo].[InvoiceHeader]
ADD CatInvoiceTypeId INT;

ALTER TABLE [dbo].[InvoiceHeader]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceHeader_CatInvoiceTypeId] FOREIGN KEY([CatInvoiceTypeId])
REFERENCES [dbo].[CatInvoiceType] ([IdCatInvoiceType])
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar el tipo de factura.', N'SCHEMA', N'dbo', N'TABLE', N'InvoiceHeader', N'COLUMN', N'CatInvoiceTypeId'

ALTER TABLE [dbo].[InvoiceHeader]
ADD IsPaid BIT;

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar si la factura debe ser pagada en el servicio de SAP.', N'SCHEMA', N'dbo', N'TABLE', N'InvoiceHeader', N'COLUMN', N'IsPaid'
