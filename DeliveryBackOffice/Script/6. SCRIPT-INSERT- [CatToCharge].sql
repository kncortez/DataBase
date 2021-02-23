USE [DeliveryBackOffice]
GO
INSERT INTO [DeliveryBackOffice].[dbo].[CatToCharge] 
(Name,Description,DescriptionLabel,Value,UnitId,CountryId,CurrencyId,RowStatus,TokenCreated,DateCreated)
VALUES ('PickupRateSpecial','Costo de recolección mayor a 24 horas', 'Portal_PickupRateSpecial',12.00,6,'GT',1,1,'SYS-AJUAREZ',GETDATE())