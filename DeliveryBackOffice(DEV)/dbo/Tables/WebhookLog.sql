CREATE TABLE [dbo].[WebhookLog] (
    [WebhookLogId]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [Guide_Serie]            VARCHAR (5)    NULL,
    [Guide_Number]           BIGINT         NULL,
    [WebhookTrackingQueueId] BIGINT         NULL,
    [DataSent]               NVARCHAR (MAX) NULL,
    [DataReceived]           NVARCHAR (MAX) NULL,
    [ErrorDesc]              NVARCHAR (MAX) NULL,
    [ErrorModule]            NVARCHAR (MAX) NULL,
    [Date]                   DATETIME       NOT NULL,
    [RowStatus]              INT            NULL,
    PRIMARY KEY CLUSTERED ([WebhookLogId] ASC)
);

