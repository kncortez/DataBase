
CREATE TABLE [dbo].[CatProductCategory] (
    [IdCatProductCategory]          INT            IDENTITY (1, 1) NOT NULL,
    [CatProductCategoryName]        NVARCHAR (100) NOT NULL,
    [CatProductCategoryDescription] NVARCHAR (200) NULL,
    [CatProductCategoryOrder]       INT            NOT NULL,
    [RowStatus]                     BIT            NOT NULL,
    [TokenCreated]                  NVARCHAR (50)  NOT NULL,
    [DateCreated]                   DATETIME       NOT NULL,
    [TokenUpdated]                  NVARCHAR (50)  NULL,
    [DateUpdated]                   DATETIME       NULL,
    [TechnicalDescription]          NVARCHAR (50)  NULL,
    [IdCountry]                     VARCHAR (2)    NULL,
    [ImageURL]                      NVARCHAR (255) NULL,
    CONSTRAINT [PK_CatProductCategory] PRIMARY KEY CLUSTERED ([IdCatProductCategory] ASC),
    CONSTRAINT [FK_CatProductCategory_CatCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);


GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de categoría' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory', @level2type=N'COLUMN',@level2name=N'IdCatProductCategory'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Título de la categoría' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory', @level2type=N'COLUMN',@level2name=N'CatProductCategoryName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de categoría' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory', @level2type=N'COLUMN',@level2name=N'CatProductCategoryDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Order de aparición' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory', @level2type=N'COLUMN',@level2name=N'CatProductCategoryOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Categoría de productos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'País de los productos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductCategory', @level2type=N'COLUMN',@level2name=N'IdCountry'
GO



EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre técnico de categoria para validaciones.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductCategory',
    @level2type = N'COLUMN',
    @level2name = N'TechnicalDescription'