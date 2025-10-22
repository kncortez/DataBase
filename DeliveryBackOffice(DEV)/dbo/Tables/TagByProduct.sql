CREATE TABLE [dbo].[TagByProduct] (
    [Id]          INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TagId]       INT           NOT NULL,
    [ProductId]   INT           NOT NULL,
    [RowStatus]   BIT           NOT NULL,
    [UserCreated] NVARCHAR (50) NOT NULL,
    [DateCreated] DATETIME      NOT NULL,
    [UserUpdated] NVARCHAR (50) NULL,
    [DateUpdated] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TagByProduct_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([IdProduct]),
    CONSTRAINT [FK_TagByProduct_TagId] FOREIGN KEY ([TagId]) REFERENCES [dbo].[CatProductTag] ([IdCatProductTag])
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de la tabla',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TagByProduct',
    @level2type = N'COLUMN',
    @level2name = N'Id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tag asociado (FK a CatProductTag)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TagByProduct',
    @level2type = N'COLUMN',
    @level2name = N'TagId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Producto asociado (FK a Product)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TagByProduct',
    @level2type = N'COLUMN',
    @level2name = N'ProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado lógico',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TagByProduct',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TagByProduct',
    @level2type = N'COLUMN',
    @level2name = N'UserCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TagByProduct',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TagByProduct',
    @level2type = N'COLUMN',
    @level2name = N'UserUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TagByProduct',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'