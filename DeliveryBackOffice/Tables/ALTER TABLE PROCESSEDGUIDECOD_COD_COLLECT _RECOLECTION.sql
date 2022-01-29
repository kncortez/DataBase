USE DeliveryBackOffice

ALTER TABLE ProcessedGuideCOD
ADD  CollectBatch BIT NULL


EXECUTE sp_addextendedproperty N'MS_Description', N'Identifica los lotes que son de COLLECT', N'SCHEMA', N'dbo', N'TABLE', N'ProcessedGuideCOD', N'COLUMN', N'CollectBatch'

ALTER TABLE ProcessedGuideCOD
ADD  RecolectionBatch BIT NULL


EXECUTE sp_addextendedproperty N'MS_Description', N'Identifica los lotes que son de pagos en Recolección ', N'SCHEMA', N'dbo', N'TABLE', N'ProcessedGuideCOD', N'COLUMN', N'RecolectionBatch'



ALTER TABLE ProcessedGuideCOD
ADD  CODBatch BIT NULL


EXECUTE sp_addextendedproperty N'MS_Description', N'Identifica los lotes que son de pagos de COD ', N'SCHEMA', N'dbo', N'TABLE', N'ProcessedGuideCOD', N'COLUMN', N'CODBatch'


