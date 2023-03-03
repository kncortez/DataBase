CREATE TABLE [dbo].[WebhookEndpointHeader] (
    [IdWebhookEndpointHeader] BIGINT         IDENTITY (1, 1) NOT NULL,
    [WebhookEndpointId]       BIGINT         NOT NULL,
    [WebhookHeaderName]       NVARCHAR (100) NOT NULL,
    [WebhookHeaderValue]      NVARCHAR (600) NOT NULL,
    [RowStatus]               BIT            CONSTRAINT [DF_WebhookEndpointHeader_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]             DATETIME       NOT NULL,
    [TokenCreated]            NVARCHAR (50)  NOT NULL,
    [DateUpdated]             DATETIME       NULL,
    [TokenUpdated]            NVARCHAR (50)  NULL,
    CONSTRAINT [PK_WebhookEndpointHeader] PRIMARY KEY CLUSTERED ([IdWebhookEndpointHeader] ASC),
    CONSTRAINT [FK_WebhookEndpointHeader_WebhookEndpoint] FOREIGN KEY ([WebhookEndpointId]) REFERENCES [dbo].[WebhookEndpoint] ([IdWebhookEndpoint])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpointHeader', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpointHeader', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpointHeader', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpointHeader', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado de cabecera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpointHeader', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'valor de cabecera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpointHeader', @level2type = N'COLUMN', @level2name = N'WebhookHeaderValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nombre de cabecera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpointHeader', @level2type = N'COLUMN', @level2name = N'WebhookHeaderName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de endpoint', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpointHeader', @level2type = N'COLUMN', @level2name = N'WebhookEndpointId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de cabecera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WebhookEndpointHeader', @level2type = N'COLUMN', @level2name = N'IdWebhookEndpointHeader';

