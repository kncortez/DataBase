CREATE TABLE [dbo].[WebhookRestrinctionByUser] (
    [WebhookRestrinctionByUserId] INT            IDENTITY (1, 1) NOT NULL,
    [IdCustomer]                  INT            NOT NULL,
    [IdEcommerce]                 INT            NULL,
    [WebhookTypeId]               INT            NOT NULL,
    [Name]                        VARCHAR (250)  NOT NULL,
    [Description]                 NVARCHAR (500) NOT NULL,
    [StatusOrderId]               NVARCHAR (MAX) NOT NULL,
    [StatusInternalName]          NVARCHAR (MAX) NULL,
    [StatusExternalName]          NVARCHAR (MAX) NULL,
    [StatusRow]                   INT            NOT NULL,
    [CreatedToken]                NVARCHAR (MAX) NULL,
    [CreatedDate]                 DATETIME       NULL,
    [UpdatedToken]                NVARCHAR (MAX) NULL,
    [UpdatedDate]                 DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([WebhookRestrinctionByUserId] ASC),
    CONSTRAINT [FK_WebhookRestrinctionByUser_IdCustomer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_WebhookRestrinctionByUser_WebhookTypeId] FOREIGN KEY ([WebhookTypeId]) REFERENCES [dbo].[WebhookType] ([WebhookTypeId])
);

