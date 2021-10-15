ALTER TABLE Customer
ADD CatBatchTypeCODId [bigint] NULL	

EXECUTE sp_addextendedproperty N'MS_Description', N'Id de la tabla CatBatchTypeCOD', N'SCHEMA', N'dbo', N'TABLE', N'Customer', N'COLUMN', N'CatBatchTypeCODId'


ALTER TABLE Customer
ADD CatBatchFrequencyCODId [bigint] NULL	

EXECUTE sp_addextendedproperty N'MS_Description', N'Id para la tabla CatBatchFrequencyCOD ', N'SCHEMA', N'dbo', N'TABLE', N'Customer', N'COLUMN', N'CatBatchFrequencyCODId'

