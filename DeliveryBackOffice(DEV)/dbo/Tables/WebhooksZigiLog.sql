create table WebhooksZigiLog
(
    Id                    int identity
        constraint PK_WebhooksZigiLog
            primary key,
    WebhookId             nvarchar(50)  not null,
    BranchId              nvarchar(50)  not null,
    DateCreated           datetime      not null,
    ZigiWebhookId         nvarchar(50)  not null,
    ZigiEventType         nvarchar(500) not null,
    ZigiTimestamp         datetime      not null,
    ZigiPaymentId         nvarchar(50)  not null,
    ZigiAuthorizationCode nvarchar(50)  not null,
    ZigiPaymentLinkId     nvarchar(50)  not null,
    ZigiPaymentRef        nvarchar(50)  not null,
    ZigiBuyerId           nvarchar(50),
    ZigiBankAccount       nvarchar(50),
    ZigiPayloadWebhook    nvarchar(max)
)
go

exec sp_addextendedproperty 'MS_Description', 'Identificador interno en la base de datos de Forza', 'SCHEMA', 'dbo',
     'TABLE', 'WebhooksZigiLog', 'COLUMN', 'Id'
go

exec sp_addextendedproperty 'MS_Description', 'Identificador que le daremos en Forza cuando fue registrado', 'SCHEMA',
     'dbo', 'TABLE', 'WebhooksZigiLog', 'COLUMN', 'WebhookId'
go

exec sp_addextendedproperty 'MS_Description', 'Conocida como sucursal en Zigi', 'SCHEMA', 'dbo', 'TABLE',
     'WebhooksZigiLog', 'COLUMN', 'BranchId'
go

exec sp_addextendedproperty 'MS_Description', N'Fecha de creación del webhook', 'SCHEMA', 'dbo', 'TABLE',
     'WebhooksZigiLog', 'COLUMN', 'DateCreated'
go

exec sp_addextendedproperty 'MS_Description', N'Identificdor único proporcionado por Zigi', 'SCHEMA', 'dbo', 'TABLE',
     'WebhooksZigiLog', 'COLUMN', 'ZigiWebhookId'
go

exec sp_addextendedproperty 'MS_Description', 'Tipo de evento recibido desde Zigi (payment_link, QR)', 'SCHEMA', 'dbo',
     'TABLE', 'WebhooksZigiLog', 'COLUMN', 'ZigiEventType'
go

exec sp_addextendedproperty 'MS_Description', N'Fecha y hora en que llegó la información desde Zigi al webhook',
     'SCHEMA', 'dbo', 'TABLE', 'WebhooksZigiLog', 'COLUMN', 'ZigiTimestamp'
go

exec sp_addextendedproperty 'MS_Description', N'Identificador único asignado por Zigi cuando se ha pagado', 'SCHEMA',
     'dbo', 'TABLE', 'WebhooksZigiLog', 'COLUMN', 'ZigiPaymentId'
go

exec sp_addextendedproperty 'MS_Description', N'Código de autorización de pago asignado por Zigi', 'SCHEMA', 'dbo',
     'TABLE', 'WebhooksZigiLog', 'COLUMN', 'ZigiAuthorizationCode'
go

exec sp_addextendedproperty 'MS_Description', N'Identicador único del link generado por Zigi', 'SCHEMA', 'dbo', 'TABLE',
     'WebhooksZigiLog', 'COLUMN', 'ZigiPaymentLinkId'
go

exec sp_addextendedproperty 'MS_Description',
     N'Identificador del pago proporcionado por Zigi a la hora de creación del link', 'SCHEMA', 'dbo', 'TABLE',
     'WebhooksZigiLog', 'COLUMN', 'ZigiPaymentRef'
go

exec sp_addextendedproperty 'MS_Description', N'Identificador del compador único proporconado por Zigi', 'SCHEMA',
     'dbo', 'TABLE', 'WebhooksZigiLog', 'COLUMN', 'ZigiBuyerId'
go

exec sp_addextendedproperty 'MS_Description',
     N'Identificador único proporcionado por Zigi sobre el banco donde se depositará el dinero recaudado', 'SCHEMA',
     'dbo', 'TABLE', 'WebhooksZigiLog', 'COLUMN', 'ZigiBankAccount'
go

exec sp_addextendedproperty 'MS_Description', 'Payload cmpleto recibido desde Zigi con todos los datos en formato JSON',
     'SCHEMA', 'dbo', 'TABLE', 'WebhooksZigiLog', 'COLUMN', 'ZigiPayloadWebhook'
go

