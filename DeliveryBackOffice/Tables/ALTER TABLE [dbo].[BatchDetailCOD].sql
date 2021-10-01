/*
Script ALTER BatchDetailCOD
ALTER PARA AGREGAR campo para almacenar el grupo de comisión
*/
​
ALTER TABLE DeliveryBackOffice.[dbo].[BatchDetailCOD]
ADD CommissionId INT NULL;

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar el Id de comisión al que pertenece.', N'SCHEMA', N'dbo', N'TABLE', N'BatchDetailCOD', N'COLUMN', N'CommissionId'

ALTER TABLE DeliveryBackOffice.[dbo].[BatchDetailCOD]
ADD CommissionDate DATETIME NULL;

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar la fecha en la que se genera la comisión.', N'SCHEMA', N'dbo', N'TABLE', N'BatchDetailCOD', N'COLUMN', N'CommissionDate'

ALTER TABLE DeliveryBackOffice.[dbo].[BatchDetailCOD]
ADD DiscountPrice DECIMAL(18,2) NULL;

EXECUTE sp_addextendedproperty N'MS_Description', N'Campo para poder registrar el precio que se descuenta al cálcular comisiones COD.', N'SCHEMA', N'dbo', N'TABLE', N'BatchDetailCOD', N'COLUMN', N'DiscountPrice'
