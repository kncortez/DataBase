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


------------------ SUGERENCIA IMPORTANTE ----------------------
-- Revisar la estructura de la tabla DefaultValuesPerCountry --
-- parece no estar actualizada en el entorno de desarrollo   --
-- el archivo tables/DefaultValuesPerCountry.sql no contiene --
-- la estructura correcta a lo que está en la base de datos  --
-- revisar y actualizar el archivo según sea necesario.      --
-- no se incluye el cambio, no es parte del alcance.         --
---------------------------------------------------------------


-- Modificación a tabla PaymentZigi --

alter table dbo.PaymentZigi
    add PhoneNumber NVARCHAR(20)
go

exec sp_addextendedproperty 'MS_Description',
    N'En cao que se requira enviar a otro númer de tléfono y no necesariamente asignado a la Guía, sirve mucho pra multiguía',
    'SCHEMA', 'dbo', 'TABLE', 'PaymentZigi', 'COLUMN', 'PhoneNumber'
go

alter table dbo.PaymentZigi
    add IsGroup BIT DEFAULT 0 NOT NULL
go

exec sp_addextendedproperty 'MS_Description',
    N'Indica si el pago es parte de un grupo de pagos.',
    'SCHEMA', 'dbo', 'TABLE', 'PaymentZigi', 'COLUMN', 'IsGroup'
go

alter table dbo.PaymentZigi
    add GeneratedMethod NVARCHAR(100)
go

exec sp_addextendedproperty 'MS_Description', N'Método de generación del link', 'SCHEMA', 'dbo', 'TABLE', 'PaymentZigi',
    'COLUMN', 'GeneratedMethod'
go


-- Modificación a tabla DefaultValuesPerCountry --


UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^502[3-7]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'GT';
UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^504[389]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'HN';
UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^503[79]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'SV';


--- Modificación de tabla AccountingClosuresHeader
ALTER TABLE dbo.AccountingClosuresHeader
ADD TotalAmountZigi DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    TotalAmountZigiDeclared DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    TotalAmountCODZigi DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    TotalAmountCODZigiDeclared DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    TotalAmountFacturaZigi DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    InvoiceAmountZigi INT NOT NULL DEFAULT 0,
    TotalAmountFacturaZigiDeclared DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    InvoiceAmountFacturaZigi INT NOT NULL DEFAULT 0;

ALTER TABLE dbo.AccountingClosuresHeaderVisitPoint
ADD TotalAmountZigi DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    TotalAmountZigiDeclared DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    TotalAmountCODZigi DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    TotalAmountCODZigiDeclared DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    TotalAmountFacturaZigi DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    InvoiceAmountZigi INT NOT NULL DEFAULT 0,
    TotalAmountFacturaZigiDeclared DECIMAL(18, 5) NOT NULL DEFAULT 0.00,
    InvoiceAmountFacturaZigi INT NOT NULL DEFAULT 0;

INSERT INTO DeliveryBackOffice.dbo.ClosureAccount 
    (AccountNumber, Name, Description, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, IdCountry) VALUES
    (N'749', N'Cuenta Zigi', N'Cuenta Zigi', 1, N'SYS-BMORATAYA', N'2025-10-19 18:46:26.000', null, null, N'GT');

