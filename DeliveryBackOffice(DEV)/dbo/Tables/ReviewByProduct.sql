CREATE TABLE [dbo].[ReviewByProduct] (
    [Id]          INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ProductId]   INT            NOT NULL,
    [Rating]      TINYINT        NOT NULL,
    [Comment]     NVARCHAR (500) NULL,
    [RowStatus]   BIT            NOT NULL,
    [UserCreated] NVARCHAR (50)  NOT NULL,
    [DateCreated] DATETIME       NOT NULL,
    [UserUpdated] NVARCHAR (50)  NULL,
    [DateUpdated] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CHECK ([Rating]>=(1) AND [Rating]<=(5)),
    CONSTRAINT [FK_ReviewByProduct_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([IdProduct])
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de la calificación de productos',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ReviewByProduct',
    @level2type = N'COLUMN',
    @level2name = N'Id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del producto (FK a Product)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ReviewByProduct',
    @level2type = N'COLUMN',
    @level2name = N'ProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calificación del producto (valores del 1 al 5)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ReviewByProduct',
    @level2type = N'COLUMN',
    @level2name = N'Rating'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Comentario del usuario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ReviewByProduct',
    @level2type = N'COLUMN',
    @level2name = N'Comment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado lógico',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ReviewByProduct',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ReviewByProduct',
    @level2type = N'COLUMN',
    @level2name = N'UserCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ReviewByProduct',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ReviewByProduct',
    @level2type = N'COLUMN',
    @level2name = N'UserUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ReviewByProduct',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'