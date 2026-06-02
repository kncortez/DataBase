CREATE TABLE [dbo].[WebhookLogWithDates] (
    [IdWebhookLog]           BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [WebhookTrackingQueueId] BIGINT         NOT NULL,
    [DataSent]               NVARCHAR (MAX) NULL,
    [DataReceived]           NVARCHAR (MAX) NULL,
    [RowStatus]              BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenCreated]           NVARCHAR (50)  NOT NULL,
    [DateUpdated]            DATETIME       NULL,
    [TokenUpdated]           NVARCHAR (50)  NULL,
    [DateIni]                DATETIME       NULL,
    [DateBeforeClient]       DATETIME       NULL,
    [DateAfterClient]        DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdWebhookLog] ASC),
    CONSTRAINT [FK_WebhookLogWithDates_WebhookTrackingQueue] FOREIGN KEY ([WebhookTrackingQueueId]) REFERENCES [dbo].[WebhookTrackingQueue] ([IdWebhookTrackingQueue])
);

