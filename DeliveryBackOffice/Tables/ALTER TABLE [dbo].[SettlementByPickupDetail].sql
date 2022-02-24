USE [DeliveryBackOffice]

ALTER TABLE [dbo].[SettlementByPickupDetail]
ADD Price [decimal](14, 2) NULL;


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Precio de envío a pagar.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SettlementByPickupDetail', @level2type=N'COLUMN',@level2name=N'Price'
GO