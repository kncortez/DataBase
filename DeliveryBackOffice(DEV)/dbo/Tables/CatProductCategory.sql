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
    CONSTRAINT [PK_CatProductCategory] PRIMARY KEY CLUSTERED ([IdCatProductCategory] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Order de aparición', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory', @level2type = N'COLUMN', @level2name = N'CatProductCategoryOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory', @level2type = N'COLUMN', @level2name = N'CatProductCategoryDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Título de la categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory', @level2type = N'COLUMN', @level2name = N'CatProductCategoryName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory', @level2type = N'COLUMN', @level2name = N'IdCatProductCategory';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Categoría de productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory';

