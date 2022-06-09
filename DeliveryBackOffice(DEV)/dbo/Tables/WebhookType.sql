CREATE TABLE [dbo].[WebhookType] (
    [WebhookTypeId] INT            IDENTITY (1, 1) NOT NULL,
    [Name]          VARCHAR (250)  NOT NULL,
    [Description]   NVARCHAR (500) NOT NULL,
    [StatusRow]     INT            NOT NULL,
    [CreatedDate]   DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([WebhookTypeId] ASC)
);

