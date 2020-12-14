USE DeliveryBackOffice
GO
ALTER TABLE dbo.DeliveryOrder ADD
IsCollect bit NULL,
PriceShippment decimal(14, 2) NULL