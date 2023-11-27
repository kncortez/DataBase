USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatProductAttribute]    Script Date: 11/27/2023 10:17:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatProductAttribute](
	[IdCatProductAttribute] [int] IDENTITY(1,1) NOT NULL,
	[CatProductId] [int] NOT NULL,
	[CatProductAttributeDescription] [nvarchar](50) NOT NULL,
	[CatProductAttributeDescriptionLong] [nvarchar](100) NULL,
	[CatProductAttributeIcon] [nvarchar](50) NULL,
	[CatProductAtributeOrder] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatProductAttribute] PRIMARY KEY CLUSTERED 
(
	[IdCatProductAttribute] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatProductAttribute]  WITH CHECK ADD  CONSTRAINT [FK_CatProductAttribute_CatProduct] FOREIGN KEY([CatProductId])
REFERENCES [dbo].[CatProduct] ([IdCatProduct])
GO

ALTER TABLE [dbo].[CatProductAttribute] CHECK CONSTRAINT [FK_CatProductAttribute_CatProduct]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del atributo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'IdCatProductAttribute'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Producto al que pertenece el atributo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'CatProductId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del atributo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'CatProductAttributeDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre largo del atributo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'CatProductAttributeDescriptionLong'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ícono del atributo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'CatProductAttributeIcon'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Orden de aparición del atributo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'CatProductAtributeOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Atributos por producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductAttribute'
GO


