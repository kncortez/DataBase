ALTER TABLE DeliveryBackOffice.[dbo].[invoiceDetail]
ADD SAPCode NVARCHAR(50) NULL;

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar el código SAP del artículo.', N'SCHEMA', N'dbo', N'TABLE', N'invoiceDetail', N'COLUMN', N'SAPCode'
