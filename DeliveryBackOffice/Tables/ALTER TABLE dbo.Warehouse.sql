USE [DeliveryBackOffice]
GO

ALTER TABLE Warehouse
ADD IsReturn BIT NULL


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si pertenece al inventario de devoluciones.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Warehouse', @level2type=N'COLUMN',@level2name=N'IsReturn'

