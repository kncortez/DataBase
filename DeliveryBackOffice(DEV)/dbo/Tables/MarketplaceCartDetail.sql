CREATE TABLE [dbo].[MarketplaceCartDetail](
	[IdMarketplaceCartDetail] [int] IDENTITY(1,1) NOT NULL,
	[MarketplaceCartId] [int] NOT NULL,
	[CatProductId] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[TypeProduct] [nvarchar](300) NULL,
 	CONSTRAINT [PK_MarketplaceCartDetail] PRIMARY KEY CLUSTERED ([IdMarketplaceCartDetail] ASC)ON [PRIMARY],
	CONSTRAINT [FK_MarketplaceCartDetail_CatSubscription] FOREIGN KEY([CatProductId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription]),
	CONSTRAINT [FK_MarketplaceCartDetail_MarketplaceCart] FOREIGN KEY([MarketplaceCartId]) REFERENCES [dbo].[MarketplaceCart] ([IdMarketplaceCart])
) 
GO



EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceCartDetail', @level2type=N'COLUMN',@level2name=N'IdMarketplaceCartDetail'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Encabezado del carrito' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceCartDetail', @level2type=N'COLUMN',@level2name=N'MarketplaceCartId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceCartDetail', @level2type=N'COLUMN',@level2name=N'CatProductId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceCartDetail', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceCartDetail', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceCartDetail', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceCartDetail', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceCartDetail', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Detalle de carrito de productos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceCartDetail'
GO


