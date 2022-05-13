USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CourierPickupManifest]    Script Date: 4/05/2022 15:49:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CourierPickupManifest](
	[IdManifest] [bigint] IDENTITY(1000,1) NOT NULL,
	[ManifestSerie] [nvarchar](50) NOT NULL,
	[SenderReceiverId] [int] NOT NULL,
	[ManifestURL] [nvarchar](max) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](100) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](100) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PKCourierPickupManifest] PRIMARY KEY CLUSTERED 
(
	[IdManifest] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[CourierPickupManifest]  WITH CHECK ADD  CONSTRAINT [FKCourierPickupManifestSenderReceiverId] FOREIGN KEY([SenderReceiverId])
REFERENCES [dbo].[SenderReceiver] ([ID])
GO

ALTER TABLE [dbo].[CourierPickupManifest] CHECK CONSTRAINT [FKCourierPickupManifestSenderReceiverId]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla CourierPickupManifest y Numero de manifiesto de recoleccion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CourierPickupManifest', @level2type=N'COLUMN',@level2name=N'IdManifest'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de manifiesto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CourierPickupManifest', @level2type=N'COLUMN',@level2name=N'ManifestSerie'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id de referencia a tabla SenderReceiver' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CourierPickupManifest', @level2type=N'COLUMN',@level2name=N'SenderReceiverId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'URL de descarga de manifiesto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CourierPickupManifest', @level2type=N'COLUMN',@level2name=N'ManifestURL'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stado de fila 1 activa 0 inactiva' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CourierPickupManifest', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creacion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CourierPickupManifest', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CourierPickupManifest', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CourierPickupManifest', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CourierPickupManifest', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO


