USE [DeliveryBackOffice]

BEGIN TRAN

--MODIFICACION DE LOS BANCOS PAGADEROS
UPDATE [dbo].[DeliveryBank]
SET [PayingBank] = 31
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] = 3

--COMMIT




