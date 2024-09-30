CREATE TABLE [dbo].[CatSystem] (
    [SysIdSystem]     INT           IDENTITY (1, 1) NOT NULL,
    [SysNameSystem]   VARCHAR (100) NOT NULL,
    [SysPlataform]    VARCHAR (50)  NOT NULL,
    [SysDescription]  VARCHAR (50)  NULL,
    [SysRowStatus]    BIT           NOT NULL,
    [SysTokenCreated] VARCHAR (50)  NOT NULL,
    [SysDateCreated]  DATETIME      NOT NULL,
    [SysTokenUpdated] VARCHAR (50)  NULL,
    [SysDateUpdated]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([SysIdSystem] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Representa los sistemas que existen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSystem',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Id del sistema',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSystem',
    @level2type = N'COLUMN',
    @level2name = N'SysIdSystem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre del sistema',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSystem',
    @level2type = N'COLUMN',
    @level2name = N'SysNameSystem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Describe donde se ejecuta el sistema',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSystem',
    @level2type = N'COLUMN',
    @level2name = N'SysPlataform'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción del sistema',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSystem',
    @level2type = N'COLUMN',
    @level2name = N'SysDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado del sistema(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSystem',
    @level2type = N'COLUMN',
    @level2name = N'SysRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSystem',
    @level2type = N'COLUMN',
    @level2name = N'SysTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha en que se creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSystem',
    @level2type = N'COLUMN',
    @level2name = N'SysDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSystem',
    @level2type = N'COLUMN',
    @level2name = N'SysTokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha en que se modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatSystem',
    @level2type = N'COLUMN',
    @level2name = N'SysDateUpdated'