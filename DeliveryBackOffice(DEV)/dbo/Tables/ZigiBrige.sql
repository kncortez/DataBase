create table ZigiBridge
(
    Id                 int identity
        primary key,
    WebhookName        nvarchar(50)  not null,
    WebhookDescription nvarchar(500) not null,
    RowStatus          bit default 1 not null,
    DateCreated        datetime      not null,
    TokenCreated       nvarchar(50)  not null,
    DateUpdated        datetime,
    TokenUpdated       nvarchar(50),
    Url                nvarchar(500) not null,
    TokenPass          nvarchar(50)  not null,
    BranchId           nvarchar(50)  not null,
    ZigiWebhookId      nvarchar(500)
)
go

exec sp_addextendedproperty 'MS_Description',
     'Esta tabla almacena los webhooks registrados en la infraestructura de Zigi', 'SCHEMA', 'dbo', 'TABLE',
     'ZigiBridge'
go

exec sp_addextendedproperty 'MS_Description', N'Identificador único de registro', 'SCHEMA', 'dbo', 'TABLE',
     'ZigiBridge', 'COLUMN', 'Id'
go

exec sp_addextendedproperty 'MS_Description', 'Nombre identificador del Webhook en Zigi', 'SCHEMA', 'dbo', 'TABLE',
     'ZigiBridge', 'COLUMN', 'WebhookName'
go

exec sp_addextendedproperty 'MS_Description', N'Descripción del objetivo del webhook', 'SCHEMA', 'dbo', 'TABLE',
     'ZigiBridge', 'COLUMN', 'WebhookDescription'
go

exec sp_addextendedproperty 'MS_Description', 'Estado activo del webhook', 'SCHEMA', 'dbo', 'TABLE', 'ZigiBridge',
     'COLUMN', 'RowStatus'
go

exec sp_addextendedproperty 'MS_Description', N'Fecha de creación', 'SCHEMA', 'dbo', 'TABLE', 'ZigiBridge', 'COLUMN',
     'DateCreated'
go

exec sp_addextendedproperty 'MS_Description', N'Fecha de creación del Webhook', 'SCHEMA', 'dbo', 'TABLE', 'ZigiBridge',
     'COLUMN', 'TokenCreated'
go

exec sp_addextendedproperty 'MS_Description', N'Fecha de la última modificación del registro del webhook', 'SCHEMA',
     'dbo', 'TABLE', 'ZigiBridge', 'COLUMN', 'DateUpdated'
go

exec sp_addextendedproperty 'MS_Description', 'Registro del cambio del Token', 'SCHEMA', 'dbo', 'TABLE', 'ZigiBridge',
     'COLUMN', 'TokenUpdated'
go

exec sp_addextendedproperty 'MS_Description', N'Direccón Url del webhook registrado en Zigi', 'SCHEMA', 'dbo', 'TABLE',
     'ZigiBridge', 'COLUMN', 'Url'
go

exec sp_addextendedproperty 'MS_Description',
     N'Password de autorización que requerirá enviar Zigi para hacer uso del token', 'SCHEMA', 'dbo', 'TABLE',
     'ZigiBridge', 'COLUMN', 'TokenPass'
go

exec sp_addextendedproperty 'MS_Description',
     N'Zigi reconoce este parámetro como la Sucursal que querramos registrar para fines de monitoreo', 'SCHEMA', 'dbo',
     'TABLE', 'ZigiBridge', 'COLUMN', 'BranchId'
go

exec sp_addextendedproperty 'MS_Description', 'Identificador con el ue se guarda en Zigi', 'SCHEMA', 'dbo', 'TABLE',
     'ZigiBridge', 'COLUMN', 'ZigiWebhookId'
go

