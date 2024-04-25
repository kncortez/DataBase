CREATE TABLE [dbo].[WebhookTrackingQueueDetailForSFTP] (
    [IdWebhookTrackingQueueDetailForSFTP] INT           IDENTITY (1, 1) NOT NULL,
    [WebhookTrackingQueueForSFTPId]       INT           NULL,
    [CustomerId]                          INT           NOT NULL,
    [GuideSerie]                          NVARCHAR (2)  NOT NULL,
    [GuideNumber]                         INT           NOT NULL,
    [GuidePiece]                          BIGINT        NOT NULL,
    [ExternalNumber]                      NVARCHAR (50) NULL,
    [ExternalPieceId]                     NVARCHAR (50) NOT NULL,
    [StatusOrderId]                       TINYINT       NOT NULL,
    [RowStatus]                           BIT           NOT NULL,
    [DateCreated]                         DATETIME      NOT NULL,
    [TokenCreated]                        NVARCHAR (50) NOT NULL,
    [DateUpdated]                         DATETIME      NULL,
    [TokenUpdated]                        NVARCHAR (50) NULL,
    [DeliveryAttemptId]                   BIGINT        NULL,
    [NewDeliveryDate]                     DATETIME      NULL,
    CONSTRAINT [PK_IdWebhookTrackingQueueDetailForSFTP] PRIMARY KEY CLUSTERED ([IdWebhookTrackingQueueDetailForSFTP] ASC),
    CONSTRAINT [FK_WebhookTrackingQueueDetailForSFTP_DeliveryAttempt] FOREIGN KEY ([DeliveryAttemptId]) REFERENCES [dbo].[DeliveryAttempt] ([ID]),
    CONSTRAINT [FK1_WebhookTrackingQueueDetailForSFTP_WebhookTrackingQueueForSFTP] FOREIGN KEY ([WebhookTrackingQueueForSFTPId]) REFERENCES [dbo].[WebhookTrackingQueueForSFTP] ([IdWebhookTrackingQueueForSFTP]),
    CONSTRAINT [FK2_WebhookTrackingQueueDetailForSFTP_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK3_WebhookTrackingQueueDetailForSFTP_DeliveryOrderPiece] FOREIGN KEY ([GuideSerie], [GuideNumber], [GuidePiece]) REFERENCES [dbo].[DeliveryOrderPiece] ([GuideSerie], [GuideNumber], [GuidePiece]),
    CONSTRAINT [FK4_WebhookTrackingQueueDetailForSFTP_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nueva fecha de entrega, Incidencia (destino solicita cambio de fecha de entrega)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'NewDeliveryDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si es un estado de incidencia registrar el detalle de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'DeliveryAttemptId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de pieza externo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'ExternalPieceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía externo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'ExternalNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de pieza Forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'GuidePiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía Forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de Forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla WebhookTrackingQueueForSFTP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'WebhookTrackingQueueForSFTPId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla WebhookTrackingQueueDetailForSFTP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookTrackingQueueDetailForSFTP', @level2type = N'COLUMN', @level2name = N'IdWebhookTrackingQueueDetailForSFTP';

