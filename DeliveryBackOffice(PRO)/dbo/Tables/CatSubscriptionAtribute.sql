CREATE TABLE [dbo].[CatSubscriptionAtribute] (
    [IdCatSubscriptionAttribute]       INT            IDENTITY (1, 1) NOT NULL,
    [CatSubscriptionId]                INT            NOT NULL,
    [CatAttributeId]                   INT            NOT NULL,
    [SubscriptionAttributeValue]       NVARCHAR (50)  NOT NULL,
    [SubscriptionAttributeDescription] NVARCHAR (300) NOT NULL,
    [SubscriptionAttributePosition]    INT            NOT NULL,
    [RowStatus]                        BIT            CONSTRAINT [DF_CatSubscriptionAtribute_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                     NVARCHAR (50)  NOT NULL,
    [DateCreated]                      DATETIME       NOT NULL,
    [TokenUpdated]                     NVARCHAR (50)  NULL,
    [DateUpdated]                      DATETIME       NULL,
    CONSTRAINT [PK_CatSubscriptionAtribute] PRIMARY KEY CLUSTERED ([IdCatSubscriptionAttribute] ASC),
    CONSTRAINT [FK_CatSubscriptionAtribute_IdCatAttribute] FOREIGN KEY ([CatAttributeId]) REFERENCES [dbo].[CatAttribute] ([IdCatAttribute]) ON DELETE CASCADE,
    CONSTRAINT [FK_CatSubscriptionAtribute_IdCatSubscription] FOREIGN KEY ([CatSubscriptionId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription]) ON DELETE CASCADE
);

