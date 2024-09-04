CREATE TABLE [dbo].[CatSalePipelines] (
    [IdSalePipeLine] INT           IDENTITY (1, 1) NOT NULL,
    [Name]           VARCHAR (50)  NOT NULL,
    [ShortName]      VARCHAR (10)  NOT NULL,
    [Description]    VARCHAR (100) NULL,
    [RowStatus]      BIT           NOT NULL,
    [TokenCreated]   VARCHAR (50)  NOT NULL,
    [DateCreated]    DATETIME      NOT NULL,
    [TokenUpdated]   VARCHAR (50)  NULL,
    [DateUpdated]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdSalePipeLine] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalogo de canales de ventas',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSalePipelines',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSalePipelines',
    @level2type = N'COLUMN',
    @level2name = N'IdSalePipeLine'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre del canal',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSalePipelines',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre a mostrar',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSalePipelines',
    @level2type = N'COLUMN',
    @level2name = N'ShortName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción del canal',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSalePipelines',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSalePipelines',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSalePipelines',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSalePipelines',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSalePipelines',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de moficicación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSalePipelines',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'