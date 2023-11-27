USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatProductImage]    Script Date: 11/24/2023 3:51:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatProductImage](
	[IdCatProductImage] [int] IDENTITY(1,1) NOT NULL,
	[CatProductId] [int] NOT NULL,
	[CatProductImageSmallImageURL] [nvarchar](200) NULL,
	[CatProductImageLargeImageURL] [nvarchar](200) NULL,
	[CatProductImageOrder] [int] NOT NULL,	
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatProductImage] PRIMARY KEY CLUSTERED 
(
	[IdCatProductImage] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatProductImage]  WITH CHECK ADD  CONSTRAINT [FK_CatProductImage_CatProduct] FOREIGN KEY([CatProductId])
REFERENCES [dbo].[CatProduct] ([IdCatProduct])
GO

ALTER TABLE [dbo].[CatProductImage] CHECK CONSTRAINT [FK_CatProductImage_CatProduct]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la imagen' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'IdCatProductImage'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Producto al que pertenece la imagen' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage', @level2type=N'COLUMN',@level2name=N'CatProductId'
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

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Listado de imágenes por producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductImage'
GO


