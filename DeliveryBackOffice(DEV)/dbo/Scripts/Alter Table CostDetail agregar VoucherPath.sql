-- Agregar la columna VoucherPath
ALTER TABLE [dbo].[CostDetail]
ADD VoucherPath VARCHAR(500) NULL;

-- Agregar descripción a la columna
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Ruta de almacenamiento del comprobante de transacción de entrega',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'CostDetail',
    @level2type = N'COLUMN', @level2name = N'VoucherPath';