USE [DeliveryBackOffice]

BEGIN TRAN

--PARAMETRIZAR A BAC COMO BANCO PAGADOR
UPDATE [dbo].[DeliveryBank]
SET [PayingBank] = 31
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (1,2,4,28,31,32,93)

--PARAMETRIZAR A BI COMO BANCO PAGADOR
UPDATE [dbo].[DeliveryBank]
SET [PayingBank] = 33
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (33)

--PARAMETRIZAR A GYT COMO BANCO PAGADOR
UPDATE [dbo].[DeliveryBank]
SET [PayingBank] = 3
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (3)

--PARAMETRIZAR A BANRURAL COMO BANCO PAGADOR
UPDATE [dbo].[DeliveryBank]
SET [PayingBank] = 5
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (5)

--PARAMETRIZAR CODIGO ACH A CADA BANCO
UPDATE [dbo].[DeliveryBank]
SET [ACHCode] = 44
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (1)

UPDATE [dbo].[DeliveryBank]
SET [ACHCode] = 12
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (2)

UPDATE [dbo].[DeliveryBank]
SET [ACHCode] = 45
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (3)

UPDATE [dbo].[DeliveryBank]
SET [ACHCode] = 19
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (4)

UPDATE [dbo].[DeliveryBank]
SET [ACHCode] = 16
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (5)

UPDATE [dbo].[DeliveryBank]
SET [ACHCode] = 43
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (28)

UPDATE [dbo].[DeliveryBank]
SET [ACHCode] = 42
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (31)

UPDATE [dbo].[DeliveryBank]
SET [ACHCode] = 47
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (32)

UPDATE [dbo].[DeliveryBank]
SET [ACHCode] = 15
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (33)

UPDATE [dbo].[DeliveryBank]
SET [ACHCode] = 40
WHERE [Id_status] = 1
AND [Id_country] = 'GT'
AND [Id_bank] IN (93)

--COMMIT




