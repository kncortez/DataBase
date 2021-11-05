ALTER TABLE DeliveryBackOffice.[dbo].[invoiceDetail]
ADD SendToInvoice BIT NULL;

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar si el artículo se enviará al detalle de factura cliente.', N'SCHEMA', N'dbo', N'TABLE', N'invoiceDetail', N'COLUMN', N'SendToInvoice'
