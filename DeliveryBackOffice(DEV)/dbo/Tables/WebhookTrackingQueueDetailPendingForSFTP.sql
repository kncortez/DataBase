CREATE TABLE [dbo].[WebhookTrackingQueueDetailPendingForSFTP](
	[IdWebhookTrackingQueueDetailPendingForSFTP] [INT] NOT NULL,
	[WebhookTrackingQueueForSFTPId] [INT] NULL,
	[RowStatus] [BIT] NOT NULL,
	[DateCreated] [DATETIME] NOT NULL,
	[TokenCreated] [NVARCHAR](50) NOT NULL,
	[DateUpdated] [DATETIME] NULL,
	[TokenUpdated] [NCHAR](50) NULL,
 CONSTRAINT [PK_IdWebhookTrackingQueueDetailPendingForSFTP] PRIMARY KEY CLUSTERED 
(
	[IdWebhookTrackingQueueDetailPendingForSFTP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebhookTrackingQueueDetailPendingForSFTP]  WITH CHECK ADD  CONSTRAINT [FK_WebhookTrackingQueueDetailPendingForSFTP_WebhookTrackingQueueForSFTP] FOREIGN KEY([WebhookTrackingQueueForSFTPId])
REFERENCES [dbo].[WebhookTrackingQueueForSFTP] ([IdWebhookTrackingQueueForSFTP])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla WebhookTrackingQueueDetailPendingForSFTP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'IdWebhookTrackingQueueDetailPendingForSFTP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla WebhookTrackingQueueForSFTP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'WebhookTrackingQueueForSFTPId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha que actualiza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que actualiza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
