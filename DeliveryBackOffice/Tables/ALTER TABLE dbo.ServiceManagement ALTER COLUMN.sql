USE [DeliveryBackOffice]
GO

ALTER TABLE ServiceManagement ALTER COLUMN CiPuDate DATETIME
ALTER TABLE ServiceManagement ALTER COLUMN CoPuDate DATETIME


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que inicia un proceso de recolección en Courier.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagement', @level2type=N'COLUMN',@level2name=N'CiPuDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que finaliza un proceso de recolección en Courier.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagement', @level2type=N'COLUMN',@level2name=N'CoPuDate'
GO