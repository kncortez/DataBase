USE DeliveryBackOffice
ALTER TABLE Deliveryorder
ADD SystemSource INT NULL 

EXECUTE sp_addextendedproperty N'MS_Description', N'ID de la tabla CatSystem, el cual indica en que sistema se creo la guía', N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrder', N'COLUMN', N'SystemSource'

ALTER TABLE Deliveryorder
ADD ModuleSource INT NULL 

EXECUTE sp_addextendedproperty N'MS_Description', N'ID de la tabla CatModule, el cual indica en que módulo del sistema se creo la guía', N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrder', N'COLUMN', N'ModuleSource'
