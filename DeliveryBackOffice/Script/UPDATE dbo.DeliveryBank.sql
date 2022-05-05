USE [DeliveryBackOffice]
GO

UPDATE DeliveryBank
    SET PayingBank = (SELECT Id_bank FROM DeliveryBank WHERE Acronym = 'BAM' AND Id_country = 'GT' AND Id_status = 1)
WHERE Id_bank = (SELECT Id_bank FROM DeliveryBank WHERE Acronym = 'BAM' AND Id_country = 'GT' AND Id_status = 1)