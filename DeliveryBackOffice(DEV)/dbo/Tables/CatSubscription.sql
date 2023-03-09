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
    [NextSalesPackageBanner]           NVARCHAR (200)  NULL,
    [RateHeaderId]                     INT             NULL,
    [AlternativeRateHeaderId]          INT             NULL,
    [IncludedMembershipId]             INT             NULL,    
    CONSTRAINT [PK_CatSubscription] PRIMARY KEY CLUSTERED ([IdCatSubscription] ASC),
    CONSTRAINT [FK_CatSubscription_AlternativeRate] FOREIGN KEY ([AlternativeRateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FK_CatSubscription_Rate] FOREIGN KEY ([RateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId])
);










GO


GO



GO


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre de banner a desplegar cuando servicios de monto fijo esten proximos a acabarse', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'NextSalesPackageBanner';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tarifario a utilizar cuando se usa suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'RateHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tarifario alterno a utilizar cuando se usa suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'AlternativeRateHeaderId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si suscripción contiene una membresía incluida y cual membresía es de la tabla CatMembership', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'IncludedMembershipId';
