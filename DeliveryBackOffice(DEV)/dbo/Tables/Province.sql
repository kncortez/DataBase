CREATE TABLE [dbo].[Province] (
    [IdProvince]           INT            IDENTITY (1, 1) NOT NULL,
    [ProvinceName]         NVARCHAR (50)  NULL,
    [ProvinceDescription]  NVARCHAR (100) NULL,
    [ProvinceStatus]       BIT            NULL,
    [ProvinceLatitud]      DECIMAL (9, 6) NULL,
    [ProvinceLongitud]     DECIMAL (9, 6) NULL,
    [PostalCode]           NVARCHAR (5)   NULL,
    [IdCountry]            NVARCHAR (2)   NULL,
    [TokenCreated]         NVARCHAR (50)  NULL,
    [DateCreated]          DATETIME       NULL,
    [TokenUpdated]         NVARCHAR (50)  NULL,
    [DateUpdated]          DATETIME       NULL,
    [ProvinceAbbreviation] NVARCHAR (3)   NULL,
    [LocalCode]            VARCHAR (10)   NULL,
    CONSTRAINT [PK_Province] PRIMARY KEY CLUSTERED ([IdProvince] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Datos de Departamentos',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificación de departamento',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'IdProvince'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre departemento',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'ProvinceName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'ProvinceDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'ProvinceStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Latitud',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'ProvinceLatitud'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Longitud',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'ProvinceLongitud'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código postal',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'PostalCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia país',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'IdCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creo el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Abreviatura departemento',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'ProvinceAbbreviation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código local',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Province',
    @level2type = N'COLUMN',
    @level2name = N'LocalCode'