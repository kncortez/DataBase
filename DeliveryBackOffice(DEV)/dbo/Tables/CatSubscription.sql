CREATE TABLE [dbo].[CatSubscription] (
    [IdCatSubscription]                INT             IDENTITY (1, 1) NOT NULL,
    [SubscriptionName]                 NVARCHAR (50)   NOT NULL,
    [SubscriptionDescription]          NVARCHAR (300)  NULL,
    [SubscriptionCost]                 DECIMAL (18, 2) NULL,
    [SubscriptionFixedValue]           INT             NOT NULL,
    [SubscriptionMaxServiceFixedValue] INT             NOT NULL,
    [SubscriptionValidity]             INT             NOT NULL,
    [SubscriptionWeight]               INT             NOT NULL,
    [RowStatus]                        BIT             CONSTRAINT [DF_CatSubscription_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                     NVARCHAR (50)   NOT NULL,
    [DateCreated]                      DATETIME        NOT NULL,
    [TokenUpdated]                     NVARCHAR (50)   NULL,
    [DateUpdated]                      DATETIME        NULL,
    [Icon]                             NVARCHAR (50)   NULL,
    CONSTRAINT [PK_CatSubscription] PRIMARY KEY CLUSTERED ([IdCatSubscription] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo de ícono configurable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'Icon';

