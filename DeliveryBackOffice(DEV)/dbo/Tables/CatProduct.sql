CREATE TABLE [dbo].[CatProduct] (
    [IdCatProduct]                   INT             IDENTITY (1, 1) NOT NULL,
    [CatProductName]                 NVARCHAR (50)   NOT NULL,
    [CatProductDescription]          NVARCHAR (100)  NULL,
    [CatProductCategoryId]           INT             NOT NULL,
    [CatProductCost]                 DECIMAL (18, 2) NOT NULL,
    [ProductStock]                   INT             NULL,
    [CatProductMaxServiceFixedValue] INT             NULL,
    [CatProductVality]               INT             NOT NULL,
    [CatProductDiscountValue]        DECIMAL (18, 2) NULL,
    [CatProductOrder]                INT             NOT NULL,
    [CatProductSupplierId]           INT             NULL,
    [PointsAccumulation]             BIT             NULL,
    [CatConfigPointsId]              INT             NULL,
    [IsAutoRenewable]                BIT             NULL,
    [ArticleSAPId]                   INT             NULL,
    [RowStatus]                      BIT             NOT NULL,
    [TokenCreated]                   NVARCHAR (50)   NOT NULL,
    [DateCreated]                    DATETIME        NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    [DateUpdated]                    DATETIME        NULL,
    CONSTRAINT [PK_CatProduct] PRIMARY KEY CLUSTERED ([IdCatProduct] ASC),
    CONSTRAINT [FK_CatProduct_CatArticleSAP] FOREIGN KEY ([ArticleSAPId]) REFERENCES [dbo].[CatArticleSAP] ([IdCatArticleSAP]),
    CONSTRAINT [FK_CatProduct_CatConfigPoints] FOREIGN KEY ([CatConfigPointsId]) REFERENCES [dbo].[CatConfigPoints] ([IdCatConfigPoints]),
    CONSTRAINT [FK_CatProduct_CatProductCategory] FOREIGN KEY ([CatProductCategoryId]) REFERENCES [dbo].[CatProductCategory] ([IdCatProductCategory]),
    CONSTRAINT [FK_CatProduct_CatProductSupplier] FOREIGN KEY ([CatProductSupplierId]) REFERENCES [dbo].[CatProductSupplier] ([IdCatProductSupplier])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de facturación del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'ArticleSAPId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'El producto aplica a autorenovación?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'IsAutoRenewable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de acumulación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'CatConfigPointsId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Acumula puntos?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'PointsAccumulation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Proveedor al que pertenece el producto, no obligatorio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'CatProductSupplierId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden de aparición de información', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'CatProductOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de descuento, cuando aplique', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'CatProductDiscountValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Vencimiento en meses', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'CatProductVality';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de servicios incluidos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'CatProductMaxServiceFixedValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de artículos por producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'ProductStock';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Costo del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'CatProductCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de categoría', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'CatProductCategoryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'CatProductDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del catálogo producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'CatProductName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de catálogo de producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct', @level2type = N'COLUMN', @level2name = N'IdCatProduct';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Listado de productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProduct';

