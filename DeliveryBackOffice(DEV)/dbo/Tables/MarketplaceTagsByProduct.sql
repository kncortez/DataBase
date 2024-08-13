CREATE TABLE [dbo].[MarketplaceTagsByProduct](
	[IdMarketplaceTagsByProduct] [int] IDENTITY(1,1) NOT NULL,
	[MarketplaceProductTagsId] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[CatSubscriptionId] [int] NULL,
	[CatMembershipId] [int] NULL,
	[Position] [int] NOT NULL,
	CONSTRAINT [PK_MarketplaceTagsByProduct] PRIMARY KEY ([IdMarketplaceTagsByProduct] ASC),
	CONSTRAINT [FK_MarketplaceTagsByProduct_CatSubscription] FOREIGN KEY([CatSubscriptionId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription]),
	CONSTRAINT [FK_MarketplaceTagsByProduct_MarketplaceProductTags] FOREIGN KEY([MarketplaceProductTagsId]) REFERENCES [dbo].[MarketplaceProductTags] ([IdMarketplaceProductTags])
)
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la tabla' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct', @level2type=N'COLUMN',@level2name=N'IdMarketplaceTagsByProduct'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identicador de la etiqueta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct', @level2type=N'COLUMN',@level2name=N'MarketplaceProductTagsId'
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id relacion con tabla CatSubscription' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct', @level2type=N'COLUMN',@level2name=N'CatSubscriptionId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Varias etiquetas para varios productos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct'
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Posición de etiqueta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct', @level2type=N'COLUMN',@level2name=N'Position'
GO