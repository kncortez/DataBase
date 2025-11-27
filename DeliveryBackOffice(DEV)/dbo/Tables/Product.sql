CREATE TABLE [dbo].[Product] (
    [IdProduct]               INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Token]                   NVARCHAR (200)  NULL,
    [Name]                    NVARCHAR (100)  NOT NULL,
    [Description]             NVARCHAR (200)  NULL,
    [AccountId]               BIGINT          NOT NULL,
    [CatProductSubCategoryId] INT             NOT NULL,
    [IsPublic]                BIT             NOT NULL,
    [CatStatusStoreId]        INT             NOT NULL,
    [CatProductConditionId]   INT             NOT NULL,
    [Sku]                     NVARCHAR (50)   NULL,
    [Stock]                   INT             NULL,
    [StockRequired]           BIT             NOT NULL,
    [Price]                   DECIMAL (14, 2) NOT NULL,
    [CatCurrencyCODId]        INT             NOT NULL,
    [Brand]                   NVARCHAR (200)  NULL,
    [AverageRating]           DECIMAL (14, 2) NULL,
    [NameSale]                NVARCHAR (100)  NULL,
    [StartDateSale]           DATE            NULL,
    [EndDateSale]             DATE            NULL,
    [PercentageSale]          DECIMAL (14, 2) NULL,
    [RowStatus]               BIT             NOT NULL,
    [UserCreated]             NVARCHAR (50)   NOT NULL,
    [DateCreated]             DATETIME        NOT NULL,
    [UserUpdated]             NVARCHAR (50)   NULL,
    [DateUpdated]             DATETIME        NULL,
    [IdOriginAddress]         BIGINT          NOT NULL,
    PRIMARY KEY CLUSTERED ([IdProduct] ASC),
    CONSTRAINT [FK_Product_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_Product_CatCurrencyCODId] FOREIGN KEY ([CatCurrencyCODId]) REFERENCES [dbo].[CatCurrencyCOD] ([IdCatCurrencyCOD]),
    CONSTRAINT [FK_Product_CatProductCondition] FOREIGN KEY ([CatProductConditionId]) REFERENCES [dbo].[CatProductCondition] ([IdCatProductCondition]),
    CONSTRAINT [FK_Product_CatProductSubCategory] FOREIGN KEY ([CatProductSubCategoryId]) REFERENCES [dbo].[CatProductSubCategory] ([IdCatProductSubCategory]),
    CONSTRAINT [FK_Product_CatStatusStoreId] FOREIGN KEY ([CatStatusStoreId]) REFERENCES [dbo].[CatProductStatusStore] ([IdCatProductStatusStore]),
    CONSTRAINT [FK_Product_OriginAddressId] FOREIGN KEY ([IdOriginAddress]) REFERENCES [dbo].[UserAddress] ([UadIdAddress])
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del producto',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'IdProduct'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'HMAC256(IdProduct + Name)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'Token'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre del producto',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción del producto',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dueño del producto (FK a Account)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'AccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de subcategoría (FK a CatProductSubCategory)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'CatProductSubCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica si se publicar en tienda',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'IsPublic'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado en tienda (FK a CatStatusStore)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'CatStatusStoreId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Condición (FK a CatProductCondition)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'CatProductConditionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de inventario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'Sku'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cantidad de productos',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'Stock'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica si requiere stock',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'StockRequired'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Precio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'Price'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Moneda (FK a CatCurrencyCOD)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'CatCurrencyCODId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Marca',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'Brand'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calificación promedio del producto',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'AverageRating'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de la oferta',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'NameSale'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha inicio oferta',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'StartDateSale'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de fin oferta',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'EndDateSale'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Porcentaje de descuento',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'PercentageSale'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado lógico',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'UserCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'UserUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Id Direccion origen (FK a UserAddress)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'Product',
    @level2type = N'COLUMN',
    @level2name = N'IdOriginAddress'