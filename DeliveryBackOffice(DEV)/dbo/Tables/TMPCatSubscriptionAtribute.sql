CREATE TABLE [dbo].[TMPCatSubscriptionAtribute] (
    [IdCatSubscriptionAttribute]           INT            NOT NULL,
    [CatSubscriptionId]                    INT            NOT NULL,
    [CatAttributeId]                       INT            NOT NULL,
    [SubscriptionAttributeValue]           NVARCHAR (50)  NOT NULL,
    [SubscriptionAttributeDescription]     NVARCHAR (300) NOT NULL,
    [SubscriptionAttributePosition]        INT            NOT NULL,
    [RowStatus]                            BIT            NOT NULL,
    [TokenCreated]                         NVARCHAR (50)  NOT NULL,
    [DateCreated]                          DATETIME       NOT NULL,
    [TokenUpdated]                         NVARCHAR (50)  NULL,
    [DateUpdated]                          DATETIME       NULL,
    [SubscriptionAttributeDescriptionLong] NVARCHAR (500) NULL
);

