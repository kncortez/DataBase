ALTER TABLE DeliveryBackOffice.[dbo].[DeliverySettlementDetail]
ADD RowStatus BIT NULL;

ALTER TABLE DeliveryBackOffice.[dbo].[DeliverySettlementDetail]
ADD TokenCreated [nvarchar](50) NULL;

ALTER TABLE DeliveryBackOffice.[dbo].[DeliverySettlementDetail]
ADD DateCreated [datetime] NULL;

ALTER TABLE DeliveryBackOffice.[dbo].[DeliverySettlementDetail]
ADD TokenUpdated [nvarchar](50) NULL;

ALTER TABLE DeliveryBackOffice.[dbo].[DeliverySettlementDetail]
ADD DateUpdated [datetime] NULL;

ALTER TABLE DeliveryBackOffice.[dbo].[DeliverySettlementDetail]
ADD CONSTRAINT df_RowStatus DEFAULT 'TRUE' FOR RowStatus;

EXECUTE sp_addextendedproperty N'MS_Description', N'Estado de la fila, TRUE o FALSE.', N'SCHEMA', N'dbo', N'TABLE', N'DeliverySettlementDetail', N'COLUMN', N'RowSatus'
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creación de la fila.', N'SCHEMA', N'dbo', N'TABLE', N'DeliverySettlementDetail', N'COLUMN', N'TokenCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha y hora de creación de la fila', N'SCHEMA', N'dbo', N'TABLE', N'DeliverySettlementDetail', N'COLUMN', N'DateCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de actualización de la fila', N'SCHEMA', N'dbo', N'TABLE', N'DeliverySettlementDetail', N'COLUMN', N'TokenUpdated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha y hora de actualización de la fila', N'SCHEMA', N'dbo', N'TABLE', N'DeliverySettlementDetail', N'COLUMN', N'DateUpdated'