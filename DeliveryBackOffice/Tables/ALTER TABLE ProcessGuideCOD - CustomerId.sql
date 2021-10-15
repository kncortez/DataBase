ALTER TABLE ProcessedGuideCOD
ADD CustomerId INT NULL 


EXECUTE sp_addextendedproperty N'MS_Description', N'Id del Cliente al que le pertenece la guía', N'SCHEMA', N'dbo', N'TABLE', N'ProcessedGuideCOD', N'COLUMN', N'CustomerId'

