CREATE TABLE [dbo].[Package] (
    [Package_Type] TINYINT       NOT NULL,
    [Package_Name] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Package] PRIMARY KEY CLUSTERED ([Package_Type] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Package',
    @level2type = N'COLUMN',
    @level2name = N'Package_Type'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre del tipo de paquete',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Package',
    @level2type = N'COLUMN',
    @level2name = N'Package_Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalogo de tipos de paquete al que puede pertenercer una guia',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Package',
    @level2type = NULL,
    @level2name = NULL