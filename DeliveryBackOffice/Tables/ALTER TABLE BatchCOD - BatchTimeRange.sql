ALTER TABLE BatchCOD
ADD BatchTimeRange VARCHAR(300) 





EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar el rango de hora en que se ejecutó la generación de lotes', N'SCHEMA', N'dbo', N'TABLE', N'BatchCOD', N'COLUMN', N'BatchTimeRange'

