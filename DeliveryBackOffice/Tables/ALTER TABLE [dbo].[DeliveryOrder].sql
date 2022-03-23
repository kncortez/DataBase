ALTER TABLE DeliveryOrder ADD Segment nvarchar(10)
EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para almacenar dato de guía si es local, foranea o metropolitana.', N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrder', N'COLUMN', N'Segment'

