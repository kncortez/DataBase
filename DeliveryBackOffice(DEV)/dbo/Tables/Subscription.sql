CREATE TABLE [dbo].[Subscription](
	[IdSubscription] [int] IDENTITY(1,1) NOT NULL,
	[MembershipId] [int] NULL,
	[CatSubscriptionId] [int] NOT NULL,
	[CatSubscriptionStatusId] [int] NOT NULL,
	[SubscriptionCode] [nvarchar](50) NULL,
	[SubscriptionCost] [decimal](18, 2) NOT NULL,
	[CustomerId] [int] NULL,
	[AccountId] [bigint] NULL,
	[VisitPointClientId] [int] NULL,
	[CustomerPaymentId] [int] NULL,
	[IsAutoRenewable] [bit] NOT NULL DEFAULT ((0)),
	[SubscriptionFixedValue] [int] NOT NULL,
	[SubscriptionMaxServiceFixedValue] [int] NOT NULL,
	[ActualServiceCount] [int] NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
	[RowStatus] [bit] NOT NULL DEFAULT ((1)),
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[LastPaymentDate] [datetime] NULL,
	[RenewalFixedDay] [int] NULL,
	[RateHeaderId] [int] NULL,
	[AlternativeRateHeaderId] [int] NULL,
	[CatTypeSubscriptionId] [int] NULL,
	[ActivationCode] [nvarchar](50) NULL,
	[ProductGiftShippingEmail] [nvarchar](100) NULL,
	[ActivationDate] [datetime] NULL,
    CONSTRAINT [PK_Subscription] PRIMARY KEY CLUSTERED ([IdSubscription] ASC),
    CONSTRAINT [FK_Subscription_AlternativeRate] FOREIGN KEY ([AlternativeRateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FK_Subscription_CatTypeSubscription] FOREIGN KEY ([CatTypeSubscriptionId]) REFERENCES [dbo].[CatTypeSubscription] ([IdCatTypeSubscription]),
    CONSTRAINT [FK_Subscription_Rate] FOREIGN KEY ([RateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId])
)
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Día  el cual se desea poder renovar la suscripción.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'RenewalFixedDay'
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de activación del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'ActivationDate'
GO


EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tarifario a utilizar cuando se usa suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'RateHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tarifario alterno a utilizar cuando se usa suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'AlternativeRateHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id relacion con tabla CatTypeSubscription', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Subscription', @level2type = N'COLUMN', @level2name = N'CatTypeSubscriptionId';

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'código de activación del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'ActivationCode'

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'correo al cual se envía el regalo del producto' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Subscription', @level2type=N'COLUMN',@level2name=N'ProductGiftShippingEmail'

GO
CREATE NONCLUSTERED INDEX [idx_CatSubscriptionId]
    ON [dbo].[Subscription]([CatSubscriptionId] ASC);

