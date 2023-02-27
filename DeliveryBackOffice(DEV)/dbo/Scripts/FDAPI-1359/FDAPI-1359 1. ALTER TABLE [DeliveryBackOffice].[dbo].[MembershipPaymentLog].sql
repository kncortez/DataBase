USE [DeliveryBackOffice];
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[MembershipPaymentLog]
ADD PaymentImageURL NVARCHAR(600) NULL

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Imagen de pago que se realizo, de ser posible', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipPaymentLog', @level2type = N'COLUMN', @level2name = N'PaymentImageURL';
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[SubscriptionPaymentLog]
ADD PaymentImageURL NVARCHAR(600) NULL

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Imagen de pago que se realizo, de ser posible', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SubscriptionPaymentLog', @level2type = N'COLUMN', @level2name = N'PaymentImageURL';
GO