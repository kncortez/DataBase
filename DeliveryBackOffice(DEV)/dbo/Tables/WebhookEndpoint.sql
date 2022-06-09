CREATE TABLE [dbo].[WebhookEndpoint] (
    [WebhookEndpointId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [IdCustomer]        INT            NOT NULL,
    [URI]               NVARCHAR (MAX) NOT NULL,
    [RowStatus]         INT            NOT NULL,
    [IdEcommerce]       INT            NULL,
    [CreatedDate]       DATETIME       NULL,
    [WebhookTypeId]     INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([WebhookEndpointId] ASC),
    CONSTRAINT [FK_WebhookEndpoint_IdCustomer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_WebhookEndpoint_WebhookTypeId] FOREIGN KEY ([WebhookTypeId]) REFERENCES [dbo].[WebhookType] ([WebhookTypeId])
);

