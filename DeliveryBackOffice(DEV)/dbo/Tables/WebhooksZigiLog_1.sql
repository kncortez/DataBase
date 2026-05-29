CREATE TABLE [dbo].[WebhooksZigiLog] (
    [Id]                    INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [WebhookId]             NVARCHAR (50)  NOT NULL,
    [BranchId]              NVARCHAR (50)  NOT NULL,
    [DateCreated]           DATETIME       NOT NULL,
    [ZigiWebhookId]         NVARCHAR (50)  NOT NULL,
    [ZigiEventType]         NVARCHAR (50)  NOT NULL,
    [ZigiTimestamp]         DATETIME       NOT NULL,
    [ZigiPaymentId]         NVARCHAR (50)  NOT NULL,
    [ZigiAuthorizationCode] NVARCHAR (50)  NOT NULL,
    [ZigiPaymentLinkId]     NVARCHAR (50)  NOT NULL,
    [ZigiPaymentRef]        NVARCHAR (50)  NOT NULL,
    [ZigiBuyerId]           NVARCHAR (50)  NULL,
    [ZigiBankAccount]       NVARCHAR (50)  NULL,
    [ZigiPayloadWebhook]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_WebhooksZigiLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Payload cmpleto recibido desde Zigi con todos los datos en formato JSON', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'ZigiPayloadWebhook';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único proporcionado por Zigi sobre el banco donde se depositará el dinero recaudado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'ZigiBankAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del compador único proporconado por Zigi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'ZigiBuyerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del pago proporcionado por Zigi a la hora de creación del link', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'ZigiPaymentRef';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identicador único del link generado por Zigi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'ZigiPaymentLinkId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de autorización de pago asignado por Zigi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'ZigiAuthorizationCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único asignado por Zigi cuando se ha pagado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'ZigiPaymentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en que llegó la información desde Zigi al webhook', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'ZigiTimestamp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tipo de evento recibido desde Zigi (payment_link, QR)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'ZigiEventType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificdor único proporcionado por Zigi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'ZigiWebhookId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del webhook', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Conocida como sucursal en Zigi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'BranchId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador que le daremos en Forza cuando fue registrado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'WebhookId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador interno en la base de datos de Forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhooksZigiLog', @level2type = N'COLUMN', @level2name = N'Id';

