CREATE TABLE [dbo].[CatProductCategory_bkp] (
    [IdCatProductCategory]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [CatProductCategoryName]        NVARCHAR (50)  NOT NULL,
    [CatProductCategoryDescription] NVARCHAR (200) NOT NULL,
    [CategoryOrder]                 INT            NOT NULL,
    [RowStatus]                     BIT            NOT NULL,
    [DateCreated]                   NCHAR (10)     NOT NULL,
    [TokenCreated]                  NCHAR (10)     NOT NULL,
    [DateUpdated]                   NCHAR (10)     NULL,
    [TokenUpdated]                  NCHAR (10)     NULL,
    CONSTRAINT [PK_[CatProductCategory_bkp] PRIMARY KEY CLUSTERED ([IdCatProductCategory] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory_bkp', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory_bkp', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory_bkp', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory_bkp', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory_bkp', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden en que se mostrara la categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory_bkp', @level2type = N'COLUMN', @level2name = N'CategoryOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory_bkp', @level2type = N'COLUMN', @level2name = N'CatProductCategoryDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory_bkp', @level2type = N'COLUMN', @level2name = N'CatProductCategoryName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatProductCategory', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProductCategory_bkp', @level2type = N'COLUMN', @level2name = N'IdCatProductCategory';

