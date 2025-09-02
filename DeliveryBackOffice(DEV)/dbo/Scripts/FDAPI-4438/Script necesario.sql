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

UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^502[3-7]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'GT';

UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^504[389]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'HN';

UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^503[79]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'SV';