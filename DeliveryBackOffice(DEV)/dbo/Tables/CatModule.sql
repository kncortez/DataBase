CREATE TABLE [dbo].[CatModule] (
    [ModIdModule]       INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ModName]           VARCHAR (100) NOT NULL,
    [ModIdModuleParent] INT           NULL,
    [ModPath]           VARCHAR (200) NOT NULL,
    [ModDescription]    VARCHAR (150) NULL,
    [ModOrder]          INT           NOT NULL,
    [ModMetadata]       VARCHAR (50)  NULL,
    [ModVisible]        BIT           NOT NULL,
    [ModRowStatus]      BIT           NOT NULL,
    [ModTokenCreated]   VARCHAR (50)  NOT NULL,
    [ModDateCreated]    DATETIME      NOT NULL,
    [ModTokenUpdated]   VARCHAR (50)  NULL,
    [ModDateUpdated]    DATETIME      NULL,
    [ModGroup]          INT           CONSTRAINT [DF_CatModule_ModGroup] DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([ModIdModule] ASC),
    FOREIGN KEY ([ModIdModuleParent]) REFERENCES [dbo].[CatModule] ([ModIdModule])
);








GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificador del modulo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModIdModule'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'nombre del modulo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia al modulo padre(CatModule)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModIdModuleParent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ruta o nombre de formulario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModPath'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'descripción',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Posición en que se mostrara visualmente',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModOrder'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'nombre de archivo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModMetadata'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 True, 0 False',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModVisible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificiación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModDateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grupo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = N'COLUMN',
    @level2name = N'ModGroup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contiene información de los modulos presentes en los diferentes sistemas Forza Delivery',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatModule',
    @level2type = NULL,
    @level2name = NULL