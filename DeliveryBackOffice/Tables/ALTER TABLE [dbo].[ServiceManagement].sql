USE [DeliveryBackOffice]

ALTER TABLE [dbo].[ServiceManagement]
ADD CatPaymentTimeId INT NULL;

ALTER TABLE [dbo].[ServiceManagement]  WITH CHECK ADD  CONSTRAINT [FK_ServiceManagement_CatPaymentTimeId] FOREIGN KEY([CatPaymentTimeId])
REFERENCES [dbo].[CatPaymentTime] ([TimePlaId])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tiempo de pago del servicio.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagement', @level2type=N'COLUMN',@level2name=N'CatPaymentTimeId'
GO