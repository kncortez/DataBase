USE [DeliveryBackOffice]
GO

ALTER TABLE [DEliveryBackOffice].[dbo].[RateData]
ADD RateIdUpdated INT NULL

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para identificar modificaciones en tarifarios por rango de peso.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RateData', @level2type = N'COLUMN', @level2name = N'RateIdUpdated';
