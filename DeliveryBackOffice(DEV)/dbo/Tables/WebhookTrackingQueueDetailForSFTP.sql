CREATE TABLE [dbo].[WebhookTrackingQueueDetailForSFTP](
	[IdWebhookTrackingQueueDetailForSFTP] [INT] IDENTITY(1,1) NOT NULL,
	[WebhookTrackingQueueForSFTPId] [INT] NULL,
	[CustomerId] [INT] NOT NULL,
	[GuideSerie] [NVARCHAR](2) NOT NULL,
	[GuideNumber] [INT] NOT NULL,
	[GuidePiece] [BIGINT] NOT NULL,
	[ExternalNumber] [NVARCHAR] (50) NOT NULL,
	[ExternalPieceId] [NVARCHAR] (50) NOT NULL,
	[StatusOrderId] [TINYINT] NOT NULL,
	[RowStatus] [BIT] NOT NULL,
	[DateCreated] [DATETIME] NOT NULL,
	[TokenCreated] [NVARCHAR](50) NOT NULL,
	[DateUpdated] [DATETIME] NULL,
	[TokenUpdated] [NVARCHAR](50) NULL,
	[DeliveryAttemptId] [bigint] NULL,
	[NewDeliveryDate] [datetime] NULL,
 CONSTRAINT [PK_IdWebhookTrackingQueueDetailForSFTP] PRIMARY KEY CLUSTERED 
(
	[IdWebhookTrackingQueueDetailForSFTP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebhookTrackingQueueDetailForSFTP]  WITH CHECK ADD  CONSTRAINT [FK1_WebhookTrackingQueueDetailForSFTP_WebhookTrackingQueueForSFTP] FOREIGN KEY([WebhookTrackingQueueForSFTPId])
REFERENCES [dbo].[WebhookTrackingQueueForSFTP] ([IdWebhookTrackingQueueForSFTP])
GO
ALTER TABLE [dbo].[WebhookTrackingQueueDetailForSFTP]  WITH CHECK ADD  CONSTRAINT [FK2_WebhookTrackingQueueDetailForSFTP_Customer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customer] ([IdCustomer])
GO
ALTER TABLE [dbo].[WebhookTrackingQueueDetailForSFTP]  WITH CHECK ADD  CONSTRAINT [FK4_WebhookTrackingQueueDetailForSFTP_StatusOrder] FOREIGN KEY([StatusOrderId])
REFERENCES [dbo].[StatusOrder] ([StatusOrderId])
GO
ALTER TABLE [dbo].[WebhookTrackingQueueDetailForSFTP] ADD CONSTRAINT UQ_1 UNIQUE ([CustomerId],[ExternalNumber],[ExternalPieceId])
GO
ALTER TABLE [dbo].[WebhookTrackingQueueDetailForSFTP]  WITH CHECK ADD  CONSTRAINT [FK_WebhookTrackingQueueDetailForSFTP_DeliveryAttempt] FOREIGN KEY([DeliveryAttemptId])
REFERENCES [dbo].[DeliveryAttempt] ([ID])
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla WebhookTrackingQueueDetailForSFTP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'IdWebhookTrackingQueueDetailForSFTP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla WebhookTrackingQueueForSFTP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'WebhookTrackingQueueForSFTPId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id de cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'CustomerId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de Forza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'GuideSerie'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de guía Forza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'GuideNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de pieza Forza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'GuidePiece'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de guía externo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'ExternalNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de pieza externo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'ExternalPieceId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'StatusOrderId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que actualiza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha que actualiza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Si es un estado de incidencia registrar el detalle de incidencia' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'DeliveryAttemptId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nueva fecha de entrega, Incidencia (destino solicita cambio de fecha de entrega)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailForSFTP', @level2type=N'COLUMN',@level2name=N'NewDeliveryDate'

