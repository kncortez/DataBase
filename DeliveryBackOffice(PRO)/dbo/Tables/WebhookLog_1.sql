CREATE TABLE [dbo].[WebhookLog] (
    [IdWebhookLog]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [WebhookTrackingQueueId] BIGINT         NOT NULL,
    [DataSent]               NVARCHAR (MAX) NULL,
    [DataReceived]           NVARCHAR (MAX) NULL,
    [RowStatus]              BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenCreated]           NVARCHAR (50)  NOT NULL,
    [DateUpdated]            DATETIME       NULL,
    [TokenUpdated]           NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdWebhookLog] ASC),
    CONSTRAINT [FK_WebhookLog_WebhookTrackingQueue] FOREIGN KEY ([WebhookTrackingQueueId]) REFERENCES [dbo].[WebhookTrackingQueue] ([IdWebhookTrackingQueue])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Respuesta del endpoint del cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookLog', @level2type = N'COLUMN', @level2name = N'DataReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Información enviada al endpoint de cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookLog', @level2type = N'COLUMN', @level2name = N'DataSent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro de envio de webhook de la tabla WebhookTrackingQueue.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookLog', @level2type = N'COLUMN', @level2name = N'WebhookTrackingQueueId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookLog', @level2type = N'COLUMN', @level2name = N'IdWebhookLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de bitácora de envios de webhook.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookLog';

