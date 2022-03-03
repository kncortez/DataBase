USE [DeliveryBackOffice]

ALTER TABLE [dbo].[ServiceManagement]
ADD Amount DECIMAL(16,2) NULL;

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto total de un servicio.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceManagement', @level2type=N'COLUMN',@level2name=N'Amount'
GO