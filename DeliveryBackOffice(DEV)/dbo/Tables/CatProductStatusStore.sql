CREATE TABLE [dbo].[CatProductStatusStore] (
    [IdCatProductStatusStore] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                    NVARCHAR (100) NOT NULL,
    [RowStatus]               BIT            NOT NULL,
    [UserCreated]             NVARCHAR (50)  NOT NULL,
    [DateCreated]             DATETIME       NOT NULL,
    [UserUpdated]             NVARCHAR (50)  NULL,
    [DateUpdated]             DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatProductStatusStore] ASC)
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductStatusStore',
    @level2type = N'COLUMN',
    @level2name = N'IdCatProductStatusStore'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre del estado del producto',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductStatusStore',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado lógico',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductStatusStore',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductStatusStore',
    @level2type = N'COLUMN',
    @level2name = N'UserCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductStatusStore',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductStatusStore',
    @level2type = N'COLUMN',
    @level2name = N'UserUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductStatusStore',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'