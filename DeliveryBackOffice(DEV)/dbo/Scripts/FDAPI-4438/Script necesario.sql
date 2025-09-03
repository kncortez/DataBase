--  Modificación a tabla DefaultValuesPerCountry --
alter table dbo.DefaultValuesPerCountry
    add RegxMovilPhone NVARCHAR(50)
go

exec sp_addextendedproperty 'MS_Description', N'Expresión regular para tléfonos móviles del país', 'SCHEMA', 'dbo',
     'TABLE', 'DefaultValuesPerCountry', 'COLUMN', 'RegxMovilPhone'
go

alter table dbo.DefaultValuesPerCountry
    add WhatsappNumber NVARCHAR(15)
go

exec sp_addextendedproperty 'MS_Description',
     N'Número asignado de Forza al país para enviar mensajes, debe estar registrado en META', 'SCHEMA', 'dbo', 'TABLE',
     'DefaultValuesPerCountry', 'COLUMN', 'WhatsappNumber'
go


-- Modificación a tabla PaymentZigi --

alter table dbo.PaymentZigi
    add PhoneNumber NVARCHAR(20)
go

exec sp_addextendedproperty 'MS_Description',
     N'En cao que se requira enviar a otro númer de tléfono y no necesariamente asignado a la Guía, sirve mucho pra multiguía',
     'SCHEMA', 'dbo', 'TABLE', 'PaymentZigi', 'COLUMN', 'PhoneNumber'
go



-- Modificación a tabla DefaultValuesPerCountry --


UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^502[3-7]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'GT';

UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^504[389]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'HN';

UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^503[79]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'SV';