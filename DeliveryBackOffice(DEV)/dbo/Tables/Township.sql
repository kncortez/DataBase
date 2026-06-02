CREATE TABLE [dbo].[Township] (
    [IdTownship]          INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TownshipName]        NVARCHAR (50)  NULL,
    [TownshipDescription] NVARCHAR (50)  NULL,
    [TownshipLatitud]     DECIMAL (9, 6) NULL,
    [TownshipLongitud]    DECIMAL (9, 6) NULL,
    [PostalCode]          NVARCHAR (5)   NULL,
    [TownshipStatus]      BIT            NULL,
    [IdProvince]          INT            NULL,
    [TokenCreated]        NVARCHAR (50)  NULL,
    [DateCreated]         DATETIME       NULL,
    [TokenUpdated]        NVARCHAR (50)  NULL,
    [DatedUpdated]        DATETIME       NULL,
    [HeaderCode]          VARCHAR (10)   NULL,
    CONSTRAINT [PK_Township] PRIMARY KEY CLUSTERED ([IdTownship] ASC),
    CONSTRAINT [FK_Township_Province] FOREIGN KEY ([IdProvince]) REFERENCES [dbo].[Province] ([IdProvince])
);








GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20221216-222011]
    ON [dbo].[Township]([TownshipName] ASC);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificación de municipio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'IdTownship'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre municipio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'TownshipName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'TownshipDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Latitud',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'TownshipLatitud'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Longitud',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'TownshipLongitud'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código Postal',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'PostalCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'TownshipStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia departamento',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'IdProvince'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creo el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = N'COLUMN',
    @level2name = N'DatedUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Datos de municipios',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Township',
    @level2type = NULL,
    @level2name = NULL
GO
CREATE NONCLUSTERED INDEX [IDX_TownshipName_IdProvince]
    ON [dbo].[Township]([TownshipName] ASC, [IdProvince] ASC);

