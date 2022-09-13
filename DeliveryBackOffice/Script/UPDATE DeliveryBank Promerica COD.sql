USE [DeliveryBackOffice]
GO

UPDATE DeliveryBank
SET PayingBank = Id_bank
WHERE Name = 'BANCO PROMERICA'
AND Id_country = 'GT'
AND Id_status = 1