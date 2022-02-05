USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[GeofencePoint]    Script Date: 2/4/2022 4:49:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GeofencePoint](
	[IdGeofencePoint] [int] IDENTITY(1,1) NOT NULL,
	[IdGeofence] [int] NOT NULL,
	[IdPoint] [int] NOT NULL,
	[GeofencePointOrder] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdGeofencePoint] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GeofencePoint]  WITH CHECK ADD  CONSTRAINT [FK_GeofencePoint_Geofence] FOREIGN KEY([IdGeofence])
REFERENCES [dbo].[Geofence] ([IdGeofence])
GO

ALTER TABLE [dbo].[GeofencePoint] CHECK CONSTRAINT [FK_GeofencePoint_Geofence]
GO

ALTER TABLE [dbo].[GeofencePoint]  WITH CHECK ADD  CONSTRAINT [FK_GeofencePoint_Point] FOREIGN KEY([IdPoint])
REFERENCES [dbo].[Point] ([IdPoint])
GO

ALTER TABLE [dbo].[GeofencePoint] CHECK CONSTRAINT [FK_GeofencePoint_Point]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeofencePoint', @level2type=N'COLUMN',@level2name=N'IdGeofencePoint'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la tabla Geofence' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeofencePoint', @level2type=N'COLUMN',@level2name=N'IdGeofence'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la tabla Point' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeofencePoint', @level2type=N'COLUMN',@level2name=N'IdPoint'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Orden de referencia del punto en la geocerca, para poder generar el polígono de forma correcta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeofencePoint', @level2type=N'COLUMN',@level2name=N'GeofencePointOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeofencePoint', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeofencePoint', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeofencePoint', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeofencePoint', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeofencePoint', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para relacionar geocercas con puntos (ubicaciones)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'GeofencePoint'
GO


