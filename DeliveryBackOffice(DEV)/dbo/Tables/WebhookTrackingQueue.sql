CREATE TABLE [dbo].[WebhookTrackingQueue] (
    [WebhookTrackingQueueId] BIGINT      IDENTITY (1, 1) NOT NULL,
    [Guide_Serie]            VARCHAR (5) NULL,
    [Guide_Number]           BIGINT      NULL,
    [IdCustomer]             INT         NULL,
    [Status]                 INT         NULL,
    [WebhookEndpointId]      BIGINT      NOT NULL,
    [HasNotified]            BIT         NULL,
    [ChangedDate]            DATETIME    NULL,
    PRIMARY KEY CLUSTERED ([WebhookTrackingQueueId] ASC),
    CONSTRAINT [FK_WebhookEndpointId_WebhookEndpointId] FOREIGN KEY ([WebhookEndpointId]) REFERENCES [dbo].[WebhookEndpoint] ([WebhookEndpointId]),
    CONSTRAINT [FK_WebhookTrackingQueue_IdCustomer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer])
);

