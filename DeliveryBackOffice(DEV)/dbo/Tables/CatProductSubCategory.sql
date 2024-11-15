CREATE TABLE [dbo].[CatProductSubCategory]
(
	[IdCatProductSubCategory] INT IDENTITY (1, 1) NOT NULL,
    [ProductCategoryId] INT NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(200) NULL,
    [Icon] NVARCHAR(50) NULL, 
    [ProductSubCategoryParentId] INT NULL,
    [RowStatus] BIT NOT NULL,
    [UserCreated] NVARCHAR(50) NOT NULL,
    [DateCreated] DATETIME NOT NULL,
    [UserUpdated] NVARCHAR(50) NULL,
    [DateUpdated] DATETIME NULL,
    PRIMARY KEY CLUSTERED ([IdCatProductSubCategory] ASC),
    CONSTRAINT FK_CatProductCategory_ProductCategoryId FOREIGN KEY (ProductCategoryId) REFERENCES CatProductCategory(IdCatProductCategory),
    CONSTRAINT FK_ProductSubCategory_ProductSubCategoryParentId FOREIGN KEY (ProductSubCategoryParentId) REFERENCES [CatProductSubCategory](IdCatProductSubCategory)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de la categoría (FK a CatProductCategory)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'ProductCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de la subcategoría',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción de subcategoría',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Icono de la categoría',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'Icon'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Subcategoría de producto padre (FK a ProductSubCategory)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'ProductSubCategoryParentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado logico',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de creacion ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'UserCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'UserUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de la subcategoría',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatProductSubCategory',
    @level2type = N'COLUMN',
    @level2name = N'IdCatProductSubCategory'