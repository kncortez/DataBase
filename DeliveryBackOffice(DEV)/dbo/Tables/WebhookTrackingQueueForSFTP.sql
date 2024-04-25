CREATE TABLE [dbo].[WebhookTrackingQueueForSFTP] (
    [IdWebhookTrackingQueueForSFTP] INT            IDENTITY (1, 1) NOT NULL,
    [FileName]                      NVARCHAR (100) NOT NULL,
    [Hostname]                      NVARCHAR (50)  NOT NULL,
    [ShippingDate]                  DATETIME       NULL,
    [RegistrationDate]              DATETIME       NULL,
    [SenderResponse]                NVARCHAR (200) NULL,
    [HasNotified]                   BIT            NULL,
    [RowStatus]                     BIT            NOT NULL,
    [TokenCreated]                  NVARCHAR (50)  NOT NULL,
    [DateCreated]                   DATETIME       NOT NULL,
    [TokenUpdated]                  NVARCHAR (50)  NULL,
    [DateUpdated]                   DATETIME       NULL,
    CONSTRAINT [PK_IdWebhookTrackingQueueForSFTP] PRIMARY KEY CLUSTERED ([IdWebhookTrackingQueueForSFTP] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si el envío fue válido o no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'HasNotified';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Respuesta del remitente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'SenderResponse';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de registros en servidor SFTP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'RegistrationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de envío del lote', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'ShippingDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección del hostname para enviar información', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'Hostname';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de archivo generado para el lote', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'FileName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatProductMKP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueForSFTP', @level2type = N'COLUMN', @level2name = N'IdWebhookTrackingQueueForSFTP';

