USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CorporateManifestDetail](
	[IdManifestDetail] [BIGINT] IDENTITY(1,1) NOT NULL,
	[ManifestId] [BIGINT] NOT NULL,
	[GuideSerie] [NVARCHAR](100) NOT NULL,
	[GuideNumber] [NVARCHAR](100) NOT NULL,
	[OrderStatusId] [TINYINT] NOT NULL,
	[TokenCreated] [VARCHAR](50) NOT NULL,
	[DateCreated] [DATETIME] NOT NULL,
	[RowStatus] [BIT] NOT NULL,
 CONSTRAINT [PKCorporateManifestDetail] PRIMARY KEY CLUSTERED 
(
	[IdManifestDetail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CorporateManifestDetail]  WITH CHECK ADD  CONSTRAINT [FKManifestId] FOREIGN KEY([ManifestId])
REFERENCES [dbo].[CorporateManifest] ([IdManifest])
GO

ALTER TABLE [dbo].[CorporateManifestDetail] CHECK CONSTRAINT [FKManifestId]
GO

ALTER TABLE [dbo].[CorporateManifestDetail]  WITH CHECK ADD  CONSTRAINT [FKOrderStatusId] FOREIGN KEY([OrderStatusId])
REFERENCES [dbo].[StatusOrder] ([StatusOrderId])
GO

ALTER TABLE [dbo].[CorporateManifestDetail] CHECK CONSTRAINT [FKOrderStatusId]
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'ID de la tabla CorporateManifestDetail', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifestDetail', N'COLUMN', N'IdManifestDetail'
EXECUTE sp_addextendedproperty N'MS_Description', N'ID de referencia a tabla CorporateManifest', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifestDetail', N'COLUMN', N'ManifestId'
EXECUTE sp_addextendedproperty N'MS_Description', N'Serie de guia', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifestDetail', N'COLUMN', N'GuideSerie'
EXECUTE sp_addextendedproperty N'MS_Description', N'Numero de guia', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifestDetail', N'COLUMN', N'GuideNumber'
EXECUTE sp_addextendedproperty N'MS_Description', N'ID de referencia a tabla StatusOrder', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifestDetail', N'COLUMN', N'OrderStatusId'
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creacion', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifestDetail', N'COLUMN', N'TokenCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creacion', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifestDetail', N'COLUMN', N'DateCreated'
EXECUTE sp_addextendedproperty N'MS_Description', N'Estado de fila si esta activa o no', N'SCHEMA', N'dbo', N'TABLE', N'CorporateManifestDetail', N'COLUMN', N'RowStatus'


