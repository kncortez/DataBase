USE [DeliveryBackOffice]
GO

-- Catálogo de suscripciones
ALTER TABLE [DeliveryBackOffice].[dbo].[CatSubscription]
ADD RateHeaderId INT NULL

EXECUTE sp_addextendedproperty N'MS_Description', 'Tarifario a utilizar cuando se usa suscripción', N'SCHEMA', N'dbo', N'TABLE', N'CatSubscription', N'COLUMN', N'RateHeaderId'


ALTER TABLE [DeliveryBackOffice].[dbo].[CatSubscription]
ADD AlternativeRateHeaderId INT NULL

EXECUTE sp_addextendedproperty N'MS_Description', 'Tarifario alterno a utilizar cuando se usa suscripción', N'SCHEMA', N'dbo', N'TABLE', N'CatSubscription', N'COLUMN', N'AlternativeRateHeaderId'


ALTER TABLE [DeliveryBackOffice].[dbo].[CatSubscription]
ADD CONSTRAINT FK_CatSubscription_Rate FOREIGN KEY (RateHeaderId) REFERENCES [DeliveryBackOffice].[dbo].[RateHeader](RheId)


ALTER TABLE [DeliveryBackOffice].[dbo].[CatSubscription]
ADD CONSTRAINT FK_CatSubscription_AlternativeRate FOREIGN KEY (AlternativeRateHeaderId) REFERENCES [DeliveryBackOffice].[dbo].[RateHeader](RheId)

-- Suscripciones

ALTER TABLE [DeliveryBackOffice].[dbo].[Subscription]
ADD RateHeaderId INT NULL

EXECUTE sp_addextendedproperty N'MS_Description', 'Tarifario a utilizar cuando se usa suscripción', N'SCHEMA', N'dbo', N'TABLE', N'Subscription', N'COLUMN', N'RateHeaderId'


ALTER TABLE [DeliveryBackOffice].[dbo].[Subscription]
ADD AlternativeRateHeaderId INT NULL

EXECUTE sp_addextendedproperty N'MS_Description', 'Tarifario alterno a utilizar cuando se usa suscripción', N'SCHEMA', N'dbo', N'TABLE', N'Subscription', N'COLUMN', N'AlternativeRateHeaderId'


ALTER TABLE [DeliveryBackOffice].[dbo].[Subscription]
ADD CONSTRAINT FK_Subscription_Rate FOREIGN KEY (RateHeaderId) REFERENCES [DeliveryBackOffice].[dbo].[RateHeader](RheId)


ALTER TABLE [DeliveryBackOffice].[dbo].[Subscription]
ADD CONSTRAINT FK_Subscription_AlternativeRate FOREIGN KEY (AlternativeRateHeaderId) REFERENCES [DeliveryBackOffice].[dbo].[RateHeader](RheId)
