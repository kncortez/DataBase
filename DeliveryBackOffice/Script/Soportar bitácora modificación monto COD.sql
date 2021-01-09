-- soportar bitácora de modificación de monto COD
ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder ADD User_Collect_OnDelivery NVARCHAR(50) NULL
ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder ADD Date_Collect_OnDelivery DATETIME NULL