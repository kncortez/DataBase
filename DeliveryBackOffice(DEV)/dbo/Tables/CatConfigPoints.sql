USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatConfigPoints]    Script Date: 11/24/2023 3:29:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatConfigPoints](
	[IdCatConfigPoints] [int] IDENTITY(1,1) NOT NULL,
	[CatConfigPointsExpirationDays] [int] NOT NULL,
	[CatConfigPointsExchangeValue] [int] NOT NULL,
	[CatConfigPointsGenerationValue] [int] NOT NULL,
	[CatConfigPointsExchangeType] [nvarchar](50) NOT NULL,
	[CatConfigPointsGenerationType] [nvarchar](50) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatConfigPoints] PRIMARY KEY CLUSTERED 
(
	[IdCatConfigPoints] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la tabla' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'IdCatConfigPoints'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Días adicionales para la expiración de puntos forza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'CatConfigPointsExpirationDays'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor de puntos en proceso de intercambio de puntos forza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'CatConfigPointsExchangeValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor de puntos a generar en proceso de acreditación de puntos forza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'CatConfigPointsGenerationValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Forma de utilizar puntos en intercambio de puntos forza (Monto o Servicio)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'CatConfigPointsExchangeType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Forma de generar puntos forza (Monto o Servicio)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'CatConfigPointsGenerationType'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de modificación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Acumulación de puntos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatConfigPoints'
GO


