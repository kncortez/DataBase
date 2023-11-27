USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatProductDescription]    Script Date: 11/27/2023 10:20:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatProductDescription](
	[IdCatProductDescription] [int] IDENTITY(1,1) NOT NULL,
	[CatProductId] [int] NOT NULL,
	[CatProductDescriptionTitle] [nvarchar](50) NOT NULL,
	[CatProductDescription] [nvarchar](100) NULL,
	[CatProductDescriptionOrder] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatProductDescription] PRIMARY KEY CLUSTERED 
(
	[IdCatProductDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatProductDescription]  WITH CHECK ADD  CONSTRAINT [FK_CatProductDescription_CatProduct] FOREIGN KEY([CatProductId])
REFERENCES [dbo].[CatProduct] ([IdCatProduct])
GO

ALTER TABLE [dbo].[CatProductDescription] CHECK CONSTRAINT [FK_CatProductDescription_CatProduct]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del atributo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription', @level2type=N'COLUMN',@level2name=N'IdCatProductDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Producto al que pertenece el la descripción' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription', @level2type=N'COLUMN',@level2name=N'CatProductId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Título de la descripción del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription', @level2type=N'COLUMN',@level2name=N'CatProductDescriptionTitle'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de cada descripción por producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription', @level2type=N'COLUMN',@level2name=N'CatProductDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Orden' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription', @level2type=N'COLUMN',@level2name=N'CatProductDescriptionOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Lista de descripciones por producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatProductDescription'
GO


