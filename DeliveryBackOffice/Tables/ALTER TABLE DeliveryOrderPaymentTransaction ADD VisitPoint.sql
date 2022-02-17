
USE DeliveryBackOffice
ALTER TABLE DeliveryOrderPaymentTransaction
ADD VisitPoint INT NULL

ALTER TABLE [dbo].[DeliveryOrderPaymentTransaction]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrderPaymentTransaction_VisitPointClient] FOREIGN KEY([VisitPoint])
REFERENCES [dbo].[VisitPointClientParser] ([CodeOfReference])
GO

ALTER TABLE [dbo].[DeliveryOrderPaymentTransaction] CHECK CONSTRAINT [FK_DeliveryOrderPaymentTransaction_VisitPointClient]
GO