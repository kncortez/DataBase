USE DeliveryBackOffice
ALTER TABLE AccountingClosuresDetail
ADD Fel NVARCHAR(MAX) NULL

EXECUTE sp_addextendedproperty N'MS_Description', N'Número de factura de la transacción para los servicios sin guías', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresDetail', N'COLUMN', N'Fel'