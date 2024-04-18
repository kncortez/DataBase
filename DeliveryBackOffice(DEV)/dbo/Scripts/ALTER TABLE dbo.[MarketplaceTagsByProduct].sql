-- Agregar la columna  dbo.CatSubscription
ALTER TABLE dbo.[MarketplaceTagsByProduct]
ADD CatSubscriptionId INT;

ALTER TABLE [dbo].[MarketplaceTagsByProduct]  WITH CHECK ADD  CONSTRAINT [FK_MarketplaceTagsByProduct_CatSubscription] FOREIGN KEY([CatSubscriptionId])
REFERENCES [dbo].[CatSubscription] ([IdCatSubscription])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id relacion con tabla CatSubscription' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'MarketplaceTagsByProduct', @level2type=N'COLUMN',@level2name=N'CatSubscriptionId'
GO