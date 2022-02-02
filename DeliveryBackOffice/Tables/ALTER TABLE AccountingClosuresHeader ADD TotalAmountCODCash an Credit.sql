USE DeliveryBackOffice
ALTER TABLE AccountingClosuresHeader
ADD TotalAmountCODCash DECIMAL(18,5) NOT NULL DEFAULT 0

EXECUTE sp_addextendedproperty N'MS_Description', N'Monto total de COD en efectivo', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'TotalAmountCODCash'

ALTER TABLE AccountingClosuresHeader
ADD TotalAmountCODCredit DECIMAL(18,5) NOT NULL DEFAULT 0

EXECUTE sp_addextendedproperty N'MS_Description', N'Monto total de COD con tarjeta', N'SCHEMA', N'dbo', N'TABLE', N'AccountingClosuresHeader', N'COLUMN', N'TotalAmountCODCredit'