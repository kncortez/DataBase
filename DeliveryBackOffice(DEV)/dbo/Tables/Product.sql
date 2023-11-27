USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[Product]    Script Date: 11/27/2023 10:23:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Product](
	[IdProduct] [int] IDENTITY(1,1) NOT NULL,
	[CatProductId] [int] NOT NULL,
	[ProductCost] [decimal](18, 2) NOT NULL,
	[ProductPurchaseEmail] [nvarchar](100) NULL,
	[ProductGiftShippingEmail] [nvarchar](100) NULL,
	[ProductCustomerId] [int] NULL,
	[ProductAccountId] [bigint] NULL,
	[ProductCodeOfReference] [int] NULL,
	[ProductVisitPointclientByClientPortfolioId] [bigint] NULL,
	[ProductInvoiceName] [nvarchar](100) NULL,
	[ProductTaxIdNumber] [nvarchar](100) NULL,
	[ProductFiscalAddress] [nvarchar](200) NULL,
	[ProductCustomerPaymentId] [int] NULL,
	[ProductIsAutoRenewable] [bit] NULL,
	[ProductMaxServiceFixedValue] [int] NULL,
	[ProductActualServiceCount] [int] NULL,
	[ProductExpirationDate] [datetime] NOT NULL,
	[ProductDiscountValue] [decimal](18, 2) NULL,
	[ProductCatProductSupplierId] [int] NULL,
	[ProductCatPointsAccumulation] [bit] NULL,
	[ProductCatConfigPointsId] [int] NULL,
	[ProductCatSystemId] [int] NOT NULL,
	[ProductCatModuleId] [int] NOT NULL,
	[ArticleSAPId] [int] NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[IdProduct] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_Account] FOREIGN KEY([ProductAccountId])
REFERENCES [dbo].[Account] ([AccIdAccount])
GO

ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Account]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_CatArticleSAP] FOREIGN KEY([ArticleSAPId])
REFERENCES [dbo].[CatArticleSAP] ([IdCatArticleSAP])
GO

ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_CatArticleSAP]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_CatConfigPoints] FOREIGN KEY([ProductCatConfigPointsId])
REFERENCES [dbo].[CatConfigPoints] ([IdCatConfigPoints])
GO

ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_CatConfigPoints]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_CatProduct] FOREIGN KEY([CatProductId])
REFERENCES [dbo].[CatProduct] ([IdCatProduct])
GO

ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_CatProduct]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_CatProductSupplier] FOREIGN KEY([ProductCatProductSupplierId])
REFERENCES [dbo].[CatProductSupplier] ([IdCatProductSupplier])
GO

ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_CatProductSupplier]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_Customer] FOREIGN KEY([ProductCustomerId])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Customer]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_CustomerPaymentValue] FOREIGN KEY([ProductCustomerPaymentId])
REFERENCES [dbo].[CustomerPaymentValue] ([IdCustomerPaymentValue])
GO

ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_CustomerPaymentValue]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_VisitPointByClientPortfolio] FOREIGN KEY([ProductVisitPointclientByClientPortfolioId])
REFERENCES [dbo].[VisitPointByClientPortfolio] ([IdVisitPointByClientPortfolio])
GO

ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_VisitPointByClientPortfolio]
GO

ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_VisitPointClient] FOREIGN KEY([ProductCodeOfReference])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_VisitPointClient]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'IdProduct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de catálogo de producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'CatProductId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Costo del producto adquirido' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductCost'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo de la persona que compra el producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductPurchaseEmail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correo cuando se envíe como regalo el producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductGiftShippingEmail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cliente que adquirió el producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductCustomerId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cuenta del cliente que adquirió el producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductAccountId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductCodeOfReference'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de cartera del Express Center cuando aplique' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductVisitPointclientByClientPortfolioId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Datos de facturación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductInvoiceName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de documento' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductTaxIdNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Dirección fiscal' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductFiscalAddress'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de tarjeta utilizada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductCustomerPaymentId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Es autorenovable? Debe aplicar solo para membresía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductIsAutoRenewable'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de servicios contratados' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductMaxServiceFixedValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Servicios consumidos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductActualServiceCount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de expiración del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductExpirationDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Porcentaje de descuento, cuando aplique' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductDiscountValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Proveedor al que pertenece el producto, no obligatorio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductCatProductSupplierId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Acumula puntos?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductCatPointsAccumulation'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de acumulación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductCatConfigPointsId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sistema origen' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductCatSystemId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Módulo origen' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ProductCatModuleId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de facturación del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'ArticleSAPId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Productos adquiridos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Product'
GO


