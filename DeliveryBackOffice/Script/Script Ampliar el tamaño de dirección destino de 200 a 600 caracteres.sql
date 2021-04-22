Use DeliveryBackOffice
GO
ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder 
ALTER COLUMN Receiver_Address nvarchar(600) NULL