CREATE TABLE [dbo].[WebhookTrackingQueue] (
    [IdWebhookTrackingQueue] BIGINT        IDENTITY (1, 1) NOT NULL,
    [WebhookEndpointId]      BIGINT        NOT NULL,
    [CustomerId]             INT           NULL,
    [GuideSerie]             NVARCHAR (2)  NULL,
    [GuideNumber]            INT           NULL,
    [StatusOrderId]          TINYINT       NULL,
    [HasNotified]            BIT           CONSTRAINT [DF_WebhookTrackingQueue_HasNotified] DEFAULT ((0)) NOT NULL,
    [NotificationDate]       DATETIME      NULL,
    [RowStatus]              BIT           CONSTRAINT [DF_WebhookTrackingQueue_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [DateUpdated]            DATETIME      NULL,
    [TokenUpdated]           NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdWebhookTrackingQueue] ASC),
    CONSTRAINT [FK_WebhookEndpointId_WebhookEndpoint] FOREIGN KEY ([WebhookEndpointId]) REFERENCES [dbo].[WebhookEndpoint] ([IdWebhookEndpoint]),
    CONSTRAINT [FK_WebhookTrackingQueue_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_WebhookTrackingQueue_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_WebhookTrackingQueue_Status] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de envio de webhook.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'NotificationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el webhook ha sido enviado exitosamente (Sin importar respuesta del endpoint).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'HasNotified';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del estado de la tabla StatusOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente de la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de endpoint para enviar webhook de la tabla WebhookEndpoint.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'WebhookEndpointId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue', @level2type = N'COLUMN', @level2name = N'IdWebhookTrackingQueue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de cola de webhooks por enviar.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueue';

GO
CREATE NONCLUSTERED INDEX IDX_RowStatus_GuideSerie_GuideNumber_StatusOrderId
ON [dbo].[WebhookTrackingQueue] ([GuideSerie],[GuideNumber],[StatusOrderId],[RowStatus])