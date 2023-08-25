CREATE TABLE [dbo].[TMPCatSubscription] (
    [IdCatSubscription]                INT             NOT NULL,
    [SubscriptionName]                 NVARCHAR (50)   NOT NULL,
    [SubscriptionDescription]          NVARCHAR (300)  NULL,
    [SubscriptionCost]                 DECIMAL (18, 2) NULL,
    [SubscriptionFixedValue]           INT             NOT NULL,
    [SubscriptionMaxServiceFixedValue] INT             NOT NULL,
    [SubscriptionValidity]             INT             NOT NULL,
    [SubscriptionWeight]               INT             NOT NULL,
    [RowStatus]                        BIT             NOT NULL,
    [TokenCreated]                     NVARCHAR (50)   NOT NULL,
    [DateCreated]                      DATETIME        NOT NULL,
    [TokenUpdated]                     NVARCHAR (50)   NULL,
    [DateUpdated]                      DATETIME        NULL,
    [Icon]                             NVARCHAR (50)   NULL,
    [NextSalesPackageBanner]           NVARCHAR (200)  NULL,
    [RateHeaderId]                     INT             NULL,
    [AlternativeRateHeaderId]          INT             NULL,
    [IncludedMembershipId]             INT             NULL,
    [TermsandConditions]               NVARCHAR (MAX)  NULL,
    [CatTypeSubscriptionId]            INT             NULL
);

