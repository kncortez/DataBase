USE DeliveryBackOffice

ALTER TABLE BatchDetailCOD
ADD  CollectBatch BIT NULL


EXECUTE sp_addextendedproperty N'MS_Description', N'Identifica los lotes que son de COLLECT', N'SCHEMA', N'dbo', N'TABLE', N'BatchDetailCOD', N'COLUMN', N'CollectBatch'

ALTER TABLE BatchDetailCOD
ADD  RecolectionBatch BIT NULL


EXECUTE sp_addextendedproperty N'MS_Description', N'Identifica los lotes que son de pagos en Recolección ', N'SCHEMA', N'dbo', N'TABLE', N'BatchDetailCOD', N'COLUMN', N'RecolectionBatch'


ALTER TABLE BatchDetailCOD
ADD  CODBatch BIT NULL


EXECUTE sp_addextendedproperty N'MS_Description', N'Identifica los lotes que son de pagos de COD ', N'SCHEMA', N'dbo', N'TABLE', N'BatchDetailCOD', N'COLUMN', N'CODBatch'


