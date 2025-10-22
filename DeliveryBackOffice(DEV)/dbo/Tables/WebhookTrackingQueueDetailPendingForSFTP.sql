CREATE TABLE [dbo].[WebhookTrackingQueueDetailPendingForSFTP] (
    [IdWebhookTrackingQueueDetailPendingForSFTP] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [WebhookTrackingQueueForSFTPId]              INT           NULL,
    [RowStatus]                                  BIT           NOT NULL,
    [DateCreated]                                DATETIME      NOT NULL,
    [TokenCreated]                               NVARCHAR (50) NOT NULL,
    [DateUpdated]                                DATETIME      NULL,
    [TokenUpdated]                               NCHAR (50)    NULL,
    CONSTRAINT [PK_IdWebhookTrackingQueueDetailPendingForSFTP] PRIMARY KEY CLUSTERED ([IdWebhookTrackingQueueDetailPendingForSFTP] ASC),
    CONSTRAINT [FK_WebhookTrackingQueueDetailPendingForSFTP_WebhookTrackingQueueForSFTP] FOREIGN KEY ([WebhookTrackingQueueForSFTPId]) REFERENCES [dbo].[WebhookTrackingQueueForSFTP] ([IdWebhookTrackingQueueForSFTP])
);


GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla WebhookTrackingQueueDetailPendingForSFTP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'IdWebhookTrackingQueueDetailPendingForSFTP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla WebhookTrackingQueueForSFTP' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'WebhookTrackingQueueForSFTPId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creaci�n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha que actualiza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario que actualiza' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'WebhookTrackingQueueDetailPendingForSFTP', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
