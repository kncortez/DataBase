CREATE TABLE [dbo].[WebhookEndpoint] (
    [IdWebhookEndpoint]  BIGINT         IDENTITY (1, 1) NOT NULL,
    [WebhookTypeId]      INT            NOT NULL,
    [CustomerId]         INT            NOT NULL,
    [WebhookEndpointURI] NVARCHAR (MAX) NOT NULL,
    [RowStatus]          BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [TokenCreated]       NVARCHAR (50)  NOT NULL,
    [DateUpdated]        DATETIME       NULL,
    [TokenUpdated]       NVARCHAR (50)  NULL,
    [TypeConnectionId] INT NOT NULL, 
    [Hostname] NVARCHAR(50) NULL, 
    [UserName] NVARCHAR(50) NULL, 
    [Password] NVARCHAR(50) NULL, 
    [Port] INT NULL, 
    [RemoteRoute] NVARCHAR(50) NULL, 
    PRIMARY KEY CLUSTERED ([IdWebhookEndpoint] ASC),
    CONSTRAINT [FK_WebhookEndpoint_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_WebhookEndpoint_WebhookType] FOREIGN KEY ([WebhookTypeId]) REFERENCES [dbo].[WebhookType] ([IdWebhookType])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpoint', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpoint', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpoint', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpoint', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpoint', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL para envio de petición de webhook.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpoint', @level2type = N'COLUMN', @level2name = N'WebhookEndpointURI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente de la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpoint', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de webhook de la tabla WebhookType.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpoint', @level2type = N'COLUMN', @level2name = N'WebhookTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpoint', @level2type = N'COLUMN', @level2name = N'IdWebhookEndpoint';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de endpoints para envio de webhook basado en tipo de webhook.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpoint';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tipo de notificación al cliente, api o SFTP u otra valor.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'WebhookEndpoint',
    @level2type = N'COLUMN',
    @level2name = N'TypeConnectionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dirección SFTP del cliente.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'WebhookEndpoint',
    @level2type = N'COLUMN',
    @level2name = N'Hostname'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario cliente SFTP cifrado.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'WebhookEndpoint',
    @level2type = N'COLUMN',
    @level2name = N'UserName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Password SFTP cifrado.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'WebhookEndpoint',
    @level2type = N'COLUMN',
    @level2name = N'Password'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Puerto de conexión SFTP.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'WebhookEndpoint',
    @level2type = N'COLUMN',
    @level2name = N'Port'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N' path donde almacenara la información en el servidor SFTP',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'WebhookEndpoint',
    @level2type = N'COLUMN',
    @level2name = N'RemoteRoute'