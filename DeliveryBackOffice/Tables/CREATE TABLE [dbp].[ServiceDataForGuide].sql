USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ServiceDataForGuide]    Script Date: 16/08/2021 13:56:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ServiceDataForGuide](
	[IdServiceDataForGuide] [bigint] IDENTITY(1,1) NOT NULL,
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
	[GuideToken] [nvarchar](50) NOT NULL,
	[Latitude] [decimal](18, 15) NULL,
	[Longitude] [decimal](18, 15) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[DateUsed] [datetime] NULL,
	[IsDelivery] [bit] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdServiceDataForGuide] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ServiceDataForGuide]  WITH CHECK ADD  CONSTRAINT [ServiceDataForGuide_Guide_FK] FOREIGN KEY([GuideSerie], [GuideNumber])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[ServiceDataForGuide] CHECK CONSTRAINT [ServiceDataForGuide_Guide_FK]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'IdServiceDataForGuide'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de la guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'GuideSerie'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de la guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'GuideNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de acceso para landing page de captura de datos de guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'GuideToken'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Latitud donde se realizara el servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'Latitude'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Longitud donde se realizara el servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'Longitude'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inicio de ventana horaria para realizar el servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'StartTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fin de ventana horaria para realizar el servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'EndTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en el que se registro la ultima asignacion de datos' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'DateUsed'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a si es un servicio de entrega o de recoleccion (1 siendo entrega)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'IsDelivery'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceDataForGuide', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO


