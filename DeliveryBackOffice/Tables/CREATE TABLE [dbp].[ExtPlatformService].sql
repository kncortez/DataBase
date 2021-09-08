USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ExtPlatformService]    Script Date: 25/08/2021 8:55:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ExtPlatformService](
	[IdExtPlatformService] [int] IDENTITY(1,1) NOT NULL,
	[ExtPlatformId] [int] NOT NULL,
	[IdService] [int] NOT NULL,
	[Reference] [nvarchar](10) NULL,
	[TrackingData] [nvarchar](150) NULL,
	[Plan] [nvarchar](50) NULL,
	[Route] [nvarchar](50) NULL,
	[Order] [int] NULL,
	[Address] [nvarchar](200) NOT NULL,
	[Latitude] [decimal](18, 15) NOT NULL,
	[Longitude] [decimal](18, 15) NOT NULL,
	[Driver] [nvarchar](50) NULL,
	[Vehicle] [nvarchar](50) NULL,
	[Observation] [nvarchar](200) NULL,
	[IsIncluded] [bit] NOT NULL,
	[IsDelivery] [bit] NOT NULL,
	[ServiceStatus] [nvarchar](30) NULL,
	[EstimatedTimeArrival] [datetime] NULL,
	[StartServiceDateTime] [datetime] NULL,
	[EndServiceDateTime] [datetime] NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdExtPlatformService] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ExtPlatformService]  WITH CHECK ADD  CONSTRAINT [ExtPlatformService_PlatformId_FK] FOREIGN KEY([ExtPlatformId])
REFERENCES [dbo].[CatExternalPlatform] ([IdExternalPlatform])
GO

ALTER TABLE [dbo].[ExtPlatformService] CHECK CONSTRAINT [ExtPlatformService_PlatformId_FK]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'IdExtPlatformService'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la plataforma a la que pertenece el servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'ExtPlatformId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del servicio dentro de la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'IdService'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referencia asignada por nosotros dentro de la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'Reference'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Información de rastreo que provee la plataforma externa relacionado al servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'TrackingData'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del plan asociado al servicio, visto desde la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'Plan'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la ruta asociada al servicio, visto desde la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'Route'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Orden en el que fue asignado el servicio en la ruta vista desde la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'Order'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Direccion que fue ingresada en la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'Address'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Latitud del servicio registrada en la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'Latitude'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Longitud del servicio registrada en la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'Longitude'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre identificador del usuario o courierman dentro de la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'Driver'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre identificador del vehículo dentro de la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'Vehicle'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Observacion respecto al servicio generado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'Observation'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a si el servicio fue incluido dentro de la ruta/plan (1 representando su inclusión)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'IsIncluded'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referente a si es un servicio de entrega o de recoleccion (1 representando entrega)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'IsDelivery'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado asignado dentro de la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'ServiceStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se genera el servicio del lado de la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'StartServiceDateTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se completa el servicio del lado de la plataforma externa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'EndServiceDateTime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ExtPlatformService', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO


