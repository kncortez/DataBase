ALTER TABLE DeliveryBackOffice.[dbo].[CatArticleSAP]
ADD Category VARCHAR(50) NULL;

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar si es BIEN o SERVICIO.', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'Category'

ALTER TABLE DeliveryBackOffice.[dbo].[CatArticleSAP]
ADD Price DECIMAL(14,2) NULL;

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar un precio predefinido.', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'Price'

ALTER TABLE DeliveryBackOffice.[dbo].[CatArticleSAP]
ADD CardPercent DECIMAL(3,2) NULL;

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar el porcentaje de recargo que tendrá si el pago es con tarjeta.', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'CardPercent'

ALTER TABLE DeliveryBackOffice.[dbo].[CatArticleSAP]
ADD CardAmount DECIMAL(14,2) NULL;

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar el recargo que tendrá si el pago es con tarjeta.', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'CardAmount'
