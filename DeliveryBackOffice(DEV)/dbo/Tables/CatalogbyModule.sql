CREATE TABLE [dbo].[CatalogbyModule] (
    [IdCatModule]  INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [NameCatalog]  NVARCHAR (50) NULL,
    [ModuleID]     INT           NULL,
    [SystemID]     INT           NULL,
    [RowStatus]    BIT           CONSTRAINT [DF_CatalogbyModule_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated] NVARCHAR (50) NULL,
    [DateCreated]  DATETIME      NULL,
    [TokenUpdated] NVARCHAR (50) NULL,
    [DateUpdated]  DATETIME      NULL,
    CONSTRAINT [PK_CatalogbyModule] PRIMARY KEY CLUSTERED ([IdCatModule] ASC),
    CONSTRAINT [FK_CatalogbyModule_CatModule] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FK_CatalogbyModule_CatSystem] FOREIGN KEY ([SystemID]) REFERENCES [dbo].[CatSystem] ([SysIdSystem])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del catalogo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatalogbyModule',
    @level2type = N'COLUMN',
    @level2name = N'IdCatModule'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'nombre del catalogo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatalogbyModule',
    @level2type = N'COLUMN',
    @level2name = N'NameCatalog'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del modulo(Referencia tabla CatModulo )',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatalogbyModule',
    @level2type = N'COLUMN',
    @level2name = N'ModuleID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del sistema (Referencia tabla CatSystem) ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatalogbyModule',
    @level2type = N'COLUMN',
    @level2name = N'SystemID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatalogbyModule',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatalogbyModule',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatalogbyModule',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatalogbyModule',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatalogbyModule',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla de catalogos por modulos disponibles por sistema',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatalogbyModule',
    @level2type = NULL,
    @level2name = NULL