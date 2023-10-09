CREATE TABLE [dbo].[Subscription] (
    [IdSubscription]                   INT             IDENTITY (1, 1) NOT NULL,
    [MembershipId]                     INT             NULL,
    [CatSubscriptionId]                INT             NOT NULL,
    [CatSubscriptionStatusId]          INT             NOT NULL,
    [SubscriptionCode]                 NVARCHAR (50)   NULL,
    [SubscriptionCost]                 DECIMAL (18, 2) NOT NULL,
    [CustomerId]                       INT             NULL,
    [AccountId]                        BIGINT          NULL,
    [VisitPointClientId]               INT             NULL,
    [CustomerPaymentId]                INT             NULL,
    [IsAutoRenewable]                  BIT             CONSTRAINT [DF_Subscription_IsAutoRenewable] DEFAULT ((0)) NOT NULL,
    [SubscriptionFixedValue]           INT             NOT NULL,
    [SubscriptionMaxServiceFixedValue] INT             NOT NULL,
    [ActualServiceCount]               INT             NOT NULL,
    [ExpirationDate]                   DATETIME        NOT NULL,
    [RowStatus]                        BIT             CONSTRAINT [DF_Subscription_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                     NVARCHAR (50)   NOT NULL,
    [DateCreated]                      DATETIME        NOT NULL,
    [TokenUpdated]                     NVARCHAR (50)   NULL,
    [DateUpdated]                      DATETIME        NULL,
    [LastPaymentDate]                  DATETIME        NULL,
    [RenewalFixedDay]                  INT             NULL,
    [RateHeaderId]                     INT             NULL,
    [AlternativeRateHeaderId]          INT             NULL,
    [CatTypeSubscriptionId]            INT             NULL,
    CONSTRAINT [PK_Subscription] PRIMARY KEY CLUSTERED ([IdSubscription] ASC),
    CONSTRAINT [FK_Subscription_AlternativeRate] FOREIGN KEY ([AlternativeRateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FK_Subscription_CatTypeSubscription] FOREIGN KEY ([CatTypeSubscriptionId]) REFERENCES [dbo].[CatTypeSubscription] ([IdCatTypeSubscription]),
    CONSTRAINT [FK_Subscription_Rate] FOREIGN KEY ([RateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId])
);














GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Día  el cual se desea poder renovar la suscripción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'RenewalFixedDay';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tarifario a utilizar cuando se usa suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'RateHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tarifario alterno a utilizar cuando se usa suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'AlternativeRateHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id relacion con tabla CatTypeSubscription', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'CatTypeSubscriptionId';


GO
CREATE NONCLUSTERED INDEX [idx_CatSubscriptionId]
    ON [dbo].[Subscription]([CatSubscriptionId] ASC);

