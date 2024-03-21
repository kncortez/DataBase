CREATE TABLE [dbo].[StatusOrderExternal] (
    [IdStatusOrderExternal]  INT    IDENTITY (1, 1) NOT NULL,
    [Remark]             NVARCHAR (50)  NOT NULL,
    [Description]        NVARCHAR (150) NOT NULL,
    [RowStatus]          BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [TokenCreated]       NVARCHAR (50)  NOT NULL,
    [DateUpdated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
	CONSTRAINT [PK_IdStatusOrderExternal] PRIMARY KEY CLUSTERED ([IdStatusOrderExternal] ASC)
)
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción del estado externo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderExternal',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de la tabla StatusOrderExternal',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderExternal',
    @level2type = N'COLUMN',
    @level2name = N'IdStatusOrderExternal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Abreviatura externa',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderExternal',
    @level2type = N'COLUMN',
    @level2name = N'Remark'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderExternal',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha Creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderExternal',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario Creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderExternal',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha Actualización',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderExternal',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario Actualización',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'StatusOrderExternal',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'