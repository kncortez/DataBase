USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatPromo]    Script Date: 1/24/2023 08:49:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatPointPromo](
	[IdPointPromo] BIGINT IDENTITY(1,1) NOT NULL,

	[PointPromoDescription] [nvarchar](200) NOT NULL,
	[PointPromoWeight] [int] NOT NULL,

	[StartPromoDate] [datetime] NOT NULL,
	[FinishPromoDate] [datetime] NOT NULL,

	[Monday] [bit] NOT NULL,
	[Tuesday] [bit] NOT NULL,
	[Wednesday] [bit] NOT NULL,
	[Thursday] [bit] NOT NULL,
	[Friday] [bit] NOT NULL,
	[Saturday] [bit] NOT NULL,
	[Sunday] [bit] NOT NULL,

	[InPointExchange] [bit] NOT NULL DEFAULT 0,
	[InPointGeneration] [bit] NOT NULL DEFAULT 0,

	[PointPromoFactor] [decimal](5,2) DEFAULT 1,

	[RowStatus] [bit] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateUpdated] [datetime] NULL,
	[TokenUpdated] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdPointPromo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'IdPointPromo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'PointPromoDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor que determina que promoción toma precedencia (Mayor peso implica que se genera sobre los que tienen menor peso).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'PointPromoWeight'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de inicio de valides de la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'StartPromoDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha final de valides de la promoción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'FinishPromoDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si promoción aplica día lunes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'Monday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si promoción aplica día martes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'Tuesday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si promoción aplica día miercoles.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'Wednesday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si promoción aplica día jueves.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'Thursday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si promoción aplica día viernes.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'Friday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si promoción aplica día sabado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'Saturday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indica si promoción aplica día domingo.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'Sunday'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador si la promoción aplica en el canjeo de puntos.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'InPointExchange'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador si la promoción aplica en la generación de puntos.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'InPointGeneration'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Factor a aplicar en los puntos,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'PointPromoFactor'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última fecha de actualización.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Último token de actualziación.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Catálogo de promociones de puntos forza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatPointPromo'
GO


