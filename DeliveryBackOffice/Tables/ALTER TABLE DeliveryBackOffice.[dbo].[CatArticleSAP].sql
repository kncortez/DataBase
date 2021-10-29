ALTER TABLE DeliveryBackOffice.[dbo].[CatArticleSAP]
ADD IsSurcharge BIT NULL;

EXECUTE sp_addextendedproperty N'MS_Description', N'Si es artículo para recargos por tarjeta.', N'SCHEMA', N'dbo', N'TABLE', N'CatArticleSAP', N'COLUMN', N'IsSurcharge'
