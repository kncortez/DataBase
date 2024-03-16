CREATE TABLE [dbo].[CatProductImage](
	[IdCatProductImage] [int] IDENTITY(1,1) NOT NULL,
	[CatProductImageSmallImageURL] [nvarchar](200) NULL,
	[CatProductImageLargeImageURL] [nvarchar](200) NULL,
	[CatProductImageOrder] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[CatSubscriptionId] [int] NULL,
	[CatMembershipId] [int] NULL,
	[CatProductImageBigImageURL] [nvarchar](200) NULL,
 	CONSTRAINT [PK_CatProductImage] PRIMARY KEY CLUSTERED ([IdCatProductImage] ASC)
)
GO

ALTER TABLE [dbo].[CatProductImage]  WITH CHECK ADD  CONSTRAINT [FK_CatProductImage_CatMembership] FOREIGN KEY([CatMembershipId])
REFERENCES [dbo].[CatMembership] ([IdCatMembership])
GO

ALTER TABLE [dbo].[CatProductImage] CHECK CONSTRAINT [FK_CatProductImage_CatMembership]
GO

ALTER TABLE [dbo].[CatProductImage]  WITH CHECK ADD  CONSTRAINT [FK_CatProductImage_CatSubscription] FOREIGN KEY([CatSubscriptionId])
REFERENCES [dbo].[CatSubscription] ([IdCatSubscription])
GO

ALTER TABLE [dbo].[CatProductImage] CHECK CONSTRAINT [FK_CatProductImage_CatSubscription]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la imagen' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'IdCatProductImage'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Imagen en miniatura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'CatProductImageSmallImageURL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Imagen grande' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'CatProductImageLargeImageURL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Orden de aparición de las imágenes' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'CatProductImageOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id relacion con tabla CatSubscription' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'CatSubscriptionId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Imagen grande para marketplace' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'CatProductImageBigImageURL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Listado de imágenes por producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage'
GO


