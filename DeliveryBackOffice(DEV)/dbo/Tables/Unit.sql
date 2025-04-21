CREATE TABLE [dbo].[Unit] (
    [IdUnit]       INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [UnitName]     NVARCHAR (50) NULL,
    [Prefix]       NVARCHAR (5)  NULL,
    [TypeUnit]     NVARCHAR (10) NULL,
    [UnitStatus]   BIT           CONSTRAINT [DF_Unit_UnitStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated] NVARCHAR (50) NULL,
    [DateCreated]  DATETIME      NULL,
    [TokenUpdated] NVARCHAR (50) NULL,
    [DateUpdated]  DATETIME      NULL,
    CONSTRAINT [PK_Unit] PRIMARY KEY CLUSTERED ([IdUnit] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Unit',
    @level2type = N'COLUMN',
    @level2name = N'IdUnit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catálogo de unidades de medidas(peso, longitud, unidades)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Unit',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de unidad',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Unit',
    @level2type = N'COLUMN',
    @level2name = N'UnitName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Prefijo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Unit',
    @level2type = N'COLUMN',
    @level2name = N'Prefix'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tipo de unidad',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Unit',
    @level2type = N'COLUMN',
    @level2name = N'TypeUnit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Unit',
    @level2type = N'COLUMN',
    @level2name = N'UnitStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Unit',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Unit',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Unit',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Unit',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'