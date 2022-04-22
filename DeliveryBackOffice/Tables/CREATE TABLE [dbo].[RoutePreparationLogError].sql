USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RoutePreparationLogError](
	[IdRoutePreparationLogError] [int] IDENTITY(1,1) NOT NULL,
	[ErrorDescription] [varchar](300),
	[ErrorNumber] [int],
	[ErrorProcedure] [varchar](100),
	[ErrorLine] [int],
	[GuideSerie] [nvarchar](2),
	[GuideNumber] [int],
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	IdRoutePreparationLogError ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[RoutePreparationLogError] ON 
GO
SET IDENTITY_INSERT [dbo].[RoutePreparationLogError] OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador único del log.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationLogError', @level2type=N'COLUMN',@level2name=N'IdRoutePreparationLogError'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción del error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationLogError', @level2type=N'COLUMN',@level2name=N'ErrorDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número del error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationLogError', @level2type=N'COLUMN',@level2name=N'ErrorNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'StoreProcedure donde se originó el error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationLogError', @level2type=N'COLUMN',@level2name=N'ErrorProcedure'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Línea del error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationLogError', @level2type=N'COLUMN',@level2name=N'ErrorLine'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de la guía con error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationLogError', @level2type=N'COLUMN',@level2name=N'GuideSerie'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de la guía con error.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationLogError', @level2type=N'COLUMN',@level2name=N'GuideNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationLogError', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RoutePreparationLogError', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO