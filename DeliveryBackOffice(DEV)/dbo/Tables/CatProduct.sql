USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatProduct]    Script Date: 11/24/2023 3:37:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CatProduct](
	[IdCatProduct] [int] IDENTITY(1,1) NOT NULL,
	[CatProductName] [nvarchar](50) NOT NULL,
	[CatProductDescription] [nvarchar](100) NULL,
	[CatProductCategoryId] [int] NOT NULL,
	[CatProductCost] [decimal](18, 2) NOT NULL,
	[ProductStock] [int] NULL,
	[CatProductMaxServiceFixedValue] [int] NULL,
	[CatProductVality] [int] NOT NULL,
	[CatProductDiscountValue] [decimal](18, 2) NULL,
	[CatProductOrder] [int] NOT NULL,
	[CatProductSupplierId] [int] NULL,
	[PointsAccumulation] [bit] NULL,
	[CatConfigPointsId] [int] NULL,
	[IsAutoRenewable] [bit] NULL,
	[ArticleSAPId] [int] NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatProduct] PRIMARY KEY CLUSTERED 
(
	[IdCatProduct] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatProduct]  WITH CHECK ADD  CONSTRAINT [FK_CatProduct_CatArticleSAP] FOREIGN KEY([ArticleSAPId])
REFERENCES [dbo].[CatArticleSAP] ([IdCatArticleSAP])
GO

ALTER TABLE [dbo].[CatProduct] CHECK CONSTRAINT [FK_CatProduct_CatArticleSAP]
GO

ALTER TABLE [dbo].[CatProduct]  WITH CHECK ADD  CONSTRAINT [FK_CatProduct_CatConfigPoints] FOREIGN KEY([CatConfigPointsId])
REFERENCES [dbo].[CatConfigPoints] ([IdCatConfigPoints])
GO

ALTER TABLE [dbo].[CatProduct] CHECK CONSTRAINT [FK_CatProduct_CatConfigPoints]
GO

ALTER TABLE [dbo].[CatProduct]  WITH CHECK ADD  CONSTRAINT [FK_CatProduct_CatProductCategory] FOREIGN KEY([CatProductCategoryId])
REFERENCES [dbo].[CatProductCategory] ([IdCatProductCategory])
GO

ALTER TABLE [dbo].[CatProduct] CHECK CONSTRAINT [FK_CatProduct_CatProductCategory]
GO

ALTER TABLE [dbo].[CatProduct]  WITH CHECK ADD  CONSTRAINT [FK_CatProduct_CatProductSupplier] FOREIGN KEY([CatProductSupplierId])
REFERENCES [dbo].[CatProductSupplier] ([IdCatProductSupplier])
GO

ALTER TABLE [dbo].[CatProduct] CHECK CONSTRAINT [FK_CatProduct_CatProductSupplier]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de catálogo de producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'IdCatProduct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del catálogo producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'CatProductName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'CatProductDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de categoría' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'CatProductCategoryId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Costo del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'CatProductCost'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de artículos por producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'ProductStock'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de servicios incluidos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'CatProductMaxServiceFixedValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vencimiento en meses' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'CatProductVality'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Porcentaje de descuento, cuando aplique' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'CatProductDiscountValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Orden de aparición de información' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'CatProductOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Proveedor al que pertenece el producto, no obligatorio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'CatProductSupplierId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Acumula puntos?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'PointsAccumulation'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de acumulación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'CatConfigPointsId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'El producto aplica a autorenovación?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'IsAutoRenewable'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de facturación del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'ArticleSAPId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Listado de productos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProduct'
GO


