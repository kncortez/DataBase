-- Agregar columna con valor por defecto
ALTER TABLE [dbo].[Customer]
ADD [IsInternationalCustomer] BIT NOT NULL 
    CONSTRAINT DF_Customer_IsInternationalCustomer DEFAULT (0);
GO

-- Agregar descripción a la columna
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Campo para identificar clientes internacionales',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = 'Customer',
    @level2type = N'COLUMN', @level2name = 'IsInternationalCustomer';
GO
