CREATE TABLE [dbo].[SubscriptionByMembership] (
    [IdSubscriptionByMembership] INT           IDENTITY (1, 1) NOT NULL,
    [CatMembershipId]            INT           NOT NULL,
    [CatSubscriptionId]          INT           NOT NULL,
    [RowStatus]                  BIT           CONSTRAINT [DF_SubscriptionByMembership_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]               VARCHAR (50)  NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenUpdated]               NVARCHAR (50) NULL,
    [DateUpdated]                DATETIME      NULL,
    CONSTRAINT [PK_SubscriptionByMembership] PRIMARY KEY CLUSTERED ([IdSubscriptionByMembership] ASC),
    CONSTRAINT [FK_SubscriptionByMembership_Membership] FOREIGN KEY ([CatMembershipId]) REFERENCES [dbo].[CatMembership] ([IdCatMembership]),
    CONSTRAINT [FK_SubscriptionByMembership_Subscription] FOREIGN KEY ([CatSubscriptionId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription])
);

