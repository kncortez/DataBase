


--EMAIL GT
INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate])
VALUES
    ('VoucherEmailGT'
    ,'Valor de correo electrónico para el comprobante en Guatemala'
    ,'info@forzadelivery.com' --VALOR
    ,1
    ,GETDATE())

--EMAIL HN
INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate])
VALUES
    ('VoucherEmailHN'
    ,'Valor de correo electrónico para el comprobante en Honduras'
    ,'infohn@forzadelivery.com' --VALOR
    ,1
    ,GETDATE())

--PHONE GT
INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate])
VALUES
    ('VoucherPhoneGT'
    ,'Valor del teléfono para el comprobante en Guatemala'
    ,'(+502) 2377-5300' --VALOR
    ,1
    ,GETDATE())

--PHONE HN
INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate])
VALUES
    ('VoucherPhoneHN'
    ,'Valor del teléfono para el comprobante en Honduras'
    ,'(+504) 2377-5300' --VALOR
    ,1
    ,GETDATE())

--UPDATE CON CAMBIO DE AGREGAR PAIS

SELECT * FROM DeliveryBackOffice.dbo.ConfigParams

UPDATE DeliveryBackOffice.dbo.ConfigParams
SET Name = 'VoucherEmail' , IdCountry = 'GT'
WHERE Name = 'VoucherEmailGT'

UPDATE DeliveryBackOffice.dbo.ConfigParams
SET Name = 'VoucherPhone' , IdCountry = 'GT'
WHERE Name = 'VoucherPhoneGT'

UPDATE DeliveryBackOffice.dbo.ConfigParams
SET Name = 'VoucherEmail' , IdCountry = 'HN'
WHERE Name = 'VoucherEmailHN'

UPDATE DeliveryBackOffice.dbo.ConfigParams
SET Name = 'VoucherPhone' , IdCountry = 'HN'
WHERE Name = 'VoucherPhoneHN'
