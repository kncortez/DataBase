
ALTER TABLE DeliveryProof ADD Path_Dry nvarchar(300)
EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para almacenar url imagen dry evidencia de entrega en courierApp.', N'SCHEMA', N'dbo', N'TABLE', N'DeliveryProof', N'COLUMN', N'Path_Dry'

ALTER TABLE DeliveryProof ADD Path_Cold nvarchar(300)
EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para almacenar url imagen cold evidencia de entrega en courierApp.', N'SCHEMA', N'dbo', N'TABLE', N'DeliveryProof', N'COLUMN', N'Path_Cold'