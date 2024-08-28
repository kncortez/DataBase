CREATE TABLE [dbo].[CatVehicleCategories] (
    [IdCatVehicleCategories] INT             IDENTITY (1, 1) NOT NULL,
    [Name]                   NVARCHAR (200)  NULL,
    [RowStatus]              BIT             NOT NULL,
    [TokenCreated]           VARCHAR (50)    NOT NULL,
    [DateCreated]            DATETIME        NOT NULL,
    [TokenUpdated]           VARCHAR (50)    NULL,
    [DateUpdated]            DATETIME        NULL,
    [Length]                 DECIMAL (14, 2) NULL,
    [Width]                  DECIMAL (14, 2) NULL,
    [High]                   DECIMAL (14, 2) NULL,
    [UnitType]               INT             NULL,
    [IdCountry]              VARCHAR(2)      NULL,
    PRIMARY KEY CLUSTERED ([IdCatVehicleCategories] ASC),
    CONSTRAINT [FK_CatVehicleCategories_Unit] FOREIGN KEY ([UnitType]) REFERENCES [dbo].[Unit] ([IdUnit]),
    CONSTRAINT [FK_IdCountry_Cat_Region] FOREIGN KEY (IdCountry) REFERENCES [dbo].[CatCountry] (IdCountry)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'IdCatVehicleCategories'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de la categoria del vehiculo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Largo(metros)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'Length'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ancho(metros)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'Width'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Alto(metros)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'High'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tipo de unidad(Referencia a IdUnit de la tabla Unit)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'UnitType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Relación con el pais de origen (CatCountry)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = N'COLUMN',
    @level2name = N'IdCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catálogo de categorías de vehículos',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicleCategories',
    @level2type = NULL,
    @level2name = NULL