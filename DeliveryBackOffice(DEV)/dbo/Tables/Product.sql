CREATE TABLE [dbo].[Product] (
    [IdProduct]                                  INT             IDENTITY (1, 1) NOT NULL,
    [CatProductId]                               INT             NOT NULL,
    [ProductCost]                                DECIMAL (18, 2) NOT NULL,
    [ProductPurchaseEmail]                       NVARCHAR (100)  NULL,
    [ProductGiftShippingEmail]                   NVARCHAR (100)  NULL,
    [ProductCustomerId]                          INT             NULL,
    [ProductAccountId]                           BIGINT          NULL,
    [ProductCodeOfReference]                     INT             NULL,
    [ProductVisitPointclientByClientPortfolioId] BIGINT          NULL,
    [ProductInvoiceName]                         NVARCHAR (100)  NULL,
    [ProductTaxIdNumber]                         NVARCHAR (100)  NULL,
    [ProductFiscalAddress]                       NVARCHAR (200)  NULL,
    [ProductCustomerPaymentId]                   INT             NULL,
    [ProductIsAutoRenewable]                     BIT             NULL,
    [ProductMaxServiceFixedValue]                INT             NULL,
    [ProductActualServiceCount]                  INT             NULL,
    [ProductExpirationDate]                      DATETIME        NOT NULL,
    [ProductDiscountValue]                       DECIMAL (18, 2) NULL,
    [ProductCatProductSupplierId]                INT             NULL,
    [ProductCatPointsAccumulation]               BIT             NULL,
    [ProductCatConfigPointsId]                   INT             NULL,
    [ProductCatSystemId]                         INT             NOT NULL,
    [ProductCatModuleId]                         INT             NOT NULL,
    [ArticleSAPId]                               INT             NULL,
    [RowStatus]                                  BIT             NOT NULL,
    [TokenCreated]                               NVARCHAR (50)   NOT NULL,
    [DateCreated]                                DATETIME        NOT NULL,
    [TokenUpdated]                               NVARCHAR (50)   NULL,
    [DateUpdated]                                DATETIME        NULL,
    [ActivationCode]                             NVARCHAR (50)   NULL,
    CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED ([IdProduct] ASC),
    CONSTRAINT [FK_Product_Account] FOREIGN KEY ([ProductAccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_Product_CatArticleSAP] FOREIGN KEY ([ArticleSAPId]) REFERENCES [dbo].[CatArticleSAP] ([IdCatArticleSAP]),
    CONSTRAINT [FK_Product_CatConfigPoints] FOREIGN KEY ([ProductCatConfigPointsId]) REFERENCES [dbo].[CatConfigPoints] ([IdCatConfigPoints]),
    CONSTRAINT [FK_Product_CatProduct] FOREIGN KEY ([CatProductId]) REFERENCES [dbo].[CatProduct] ([IdCatProduct]),
    CONSTRAINT [FK_Product_CatProductSupplier] FOREIGN KEY ([ProductCatProductSupplierId]) REFERENCES [dbo].[CatProductSupplier] ([IdCatProductSupplier]),
    CONSTRAINT [FK_Product_Customer] FOREIGN KEY ([ProductCustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_Product_CustomerPaymentValue] FOREIGN KEY ([ProductCustomerPaymentId]) REFERENCES [dbo].[CustomerPaymentValue] ([IdCustomerPaymentValue]),
    CONSTRAINT [FK_Product_VisitPointByClientPortfolio] FOREIGN KEY ([ProductVisitPointclientByClientPortfolioId]) REFERENCES [dbo].[VisitPointByClientPortfolio] ([IdVisitPointByClientPortfolio]),
    CONSTRAINT [FK_Product_VisitPointClient] FOREIGN KEY ([ProductCodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de facturación del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ArticleSAPId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Módulo origen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductCatModuleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sistema origen', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductCatSystemId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de acumulación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductCatConfigPointsId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Acumula puntos?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductCatPointsAccumulation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Proveedor al que pertenece el producto, no obligatorio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductCatProductSupplierId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de descuento, cuando aplique', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductDiscountValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de expiración del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductExpirationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Servicios consumidos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductActualServiceCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de servicios contratados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductMaxServiceFixedValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es autorenovable? Debe aplicar solo para membresía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductIsAutoRenewable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de tarjeta utilizada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductCustomerPaymentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección fiscal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductFiscalAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de documento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductTaxIdNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datos de facturación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductInvoiceName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de cartera del Express Center cuando aplique', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductVisitPointclientByClientPortfolioId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductCodeOfReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cuenta del cliente que adquirió el producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductAccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cliente que adquirió el producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductCustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Correo cuando se envíe como regalo el producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductGiftShippingEmail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Correo de la persona que compra el producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductPurchaseEmail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Costo del producto adquirido', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ProductCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de catálogo de producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'CatProductId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'IdProduct';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Productos adquiridos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de activación del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Product', @level2type = N'COLUMN', @level2name = N'ActivationCode';

