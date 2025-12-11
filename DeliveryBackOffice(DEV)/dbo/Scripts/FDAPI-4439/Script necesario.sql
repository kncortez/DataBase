--  Modificación a tabla DefaultValuesPerCountry --
alter table dbo.DefaultValuesPerCountry
    add RegxMovilPhone NVARCHAR(50)
go

exec sp_addextendedproperty 'MS_Description', N'Expresión regular para teléfonos móviles del país', 'SCHEMA', 'dbo',
    'TABLE', 'DefaultValuesPerCountry', 'COLUMN', 'RegxMovilPhone'
go

alter table dbo.DefaultValuesPerCountry
    add WhatsappNumber NVARCHAR(15)
go

exec sp_addextendedproperty 'MS_Description',
    N'Número asignado de Forza al país para enviar mensajes, debe estar registrado en META', 'SCHEMA', 'dbo', 'TABLE',
    'DefaultValuesPerCountry', 'COLUMN', 'WhatsappNumber'
go


-- Modificación a tabla DefaultValuesPerCountry --
UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^502[3-7]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'GT';
UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^504[389]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'HN';
UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry SET RegxMovilPhone = N'^503[79]\d{7}$', WhatsappNumber = N'50223775302' WHERE IdCountry = N'SV';


-- Modificación a tabla PaymentZigi --

alter table dbo.PaymentZigi
    add PhoneNumber NVARCHAR(20)
go

exec sp_addextendedproperty 'MS_Description',
    N'En caso que se requira enviar a otro número de teléfono y no necesariamente asignado a la Guía, sirve mucho para multiguía',
    'SCHEMA', 'dbo', 'TABLE', 'PaymentZigi', 'COLUMN', 'PhoneNumber'
go

alter table dbo.PaymentZigi
    add IsGroup BIT DEFAULT 0 NOT NULL
go

exec sp_addextendedproperty 'MS_Description', N'Define si este link define el pago de un grupo de guías', 'SCHEMA',
     'dbo', 'TABLE', 'PaymentZigi', 'COLUMN', 'IsGroup'
go

alter table dbo.PaymentZigi
    add GeneratedMethod NVARCHAR(100)
go

exec sp_addextendedproperty 'MS_Description', N'Método de generación del link', 'SCHEMA', 'dbo', 'TABLE', 'PaymentZigi',
    'COLUMN', 'GeneratedMethod'
go

-- Creación y Modificación a tabla PaymentZigiMulti --
create table PaymentZigiMulti
(
    Id             int identity
        primary key,
    Id_PaymentZigi int                      not null
        constraint FK_PaymentZigi
            references PaymentZigi,
    GuideSerie     nvarchar(50)             not null,
    GuideNumber    nvarchar(50)             not null,
    Amount         decimal(10, 2) default 0.00,
    exclude_COD    bit            default 0,
    IsPay          bit            default 0,
    CODValue       decimal(10, 2),
    CollectValue   decimal(10, 2),
    RowStatus      bit            default 1 not null
)
go

exec sp_addextendedproperty 'MS_Description', N'Identificador único del registro en la tabla', 'SCHEMA', 'dbo', 'TABLE',
     'PaymentZigiMulti', 'COLUMN', 'Id'
go

exec sp_addextendedproperty 'MS_Description', N'Id de relación con la tabla PaymentZigi ', 'SCHEMA', 'dbo', 'TABLE',
     'PaymentZigiMulti', 'COLUMN', 'Id_PaymentZigi'
go

exec sp_addextendedproperty 'MS_Description', N'Serie de la guía', 'SCHEMA', 'dbo', 'TABLE', 'PaymentZigiMulti',
     'COLUMN', 'GuideSerie'
go

exec sp_addextendedproperty 'MS_Description', N'Número d Guía', 'SCHEMA', 'dbo', 'TABLE', 'PaymentZigiMulti', 'COLUMN',
     'GuideNumber'
go

exec sp_addextendedproperty 'MS_Description', 'Monto a pagar completo', 'SCHEMA', 'dbo', 'TABLE', 'PaymentZigiMulti',
     'COLUMN', 'Amount'
go

exec sp_addextendedproperty 'MS_Description', N'Exclusión de COD', 'SCHEMA', 'dbo', 'TABLE', 'PaymentZigiMulti',
     'COLUMN', 'exclude_COD'
go

exec sp_addextendedproperty 'MS_Description', N'Indicador si desde portal EXC se indica que está pagado', 'SCHEMA',
     'dbo', 'TABLE', 'PaymentZigiMulti', 'COLUMN', 'IsPay'
go

exec sp_addextendedproperty 'MS_Description', 'Valor de pago correspondiente a COD', 'SCHEMA', 'dbo', 'TABLE',
     'PaymentZigiMulti', 'COLUMN', 'CODValue'
go

exec sp_addextendedproperty 'MS_Description', 'Valor correspondiente al servicio Collect', 'SCHEMA', 'dbo', 'TABLE',
     'PaymentZigiMulti', 'COLUMN', 'CollectValue'
go

exec sp_addextendedproperty 'MS_Description', N'Indicador si el registro está vigente', 'SCHEMA', 'dbo', 'TABLE',
     'PaymentZigiMulti', 'COLUMN', 'RowStatus'
go


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

------------------ SUGERENCIA IMPORTANTE ----------------------
-- Revisar la estructura de la tabla DefaultValuesPerCountry --
-- parece no estar actualizada en el entorno de desarrollo   --
-- el archivo tables/DefaultValuesPerCountry.sql no contiene --
-- la estructura correcta a lo que está en la base de datos  --
-- revisar y actualizar el archivo según sea necesario.      --
-- no se incluye el cambio, no es parte del alcance.         --
---------------------------------------------------------------



------------------ SUGERENCIA IMPORTANTE ----------------------
-- Revisar el SP GetDataForClosure, tiene variaciones        --
-- a lo versionado y la BBDD de DEV, revisar y actualizar    --
---------------------------------------------------------------


------------------ SUGERENCIA IMPORTANTE ----------------------
-- Revisar el SP ReportClosureDesktop, tiene variaciones     --
-- a lo versionado y la BBDD de DEV, revisar y actualizar    --
-- es posible que ya esté actualizado con los cambios        --
-- en la Base de datos de DEV, es necesario cambiar este bloque --
--
--            WHEN DOPD.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name) --
--            WHEN DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name) --
--            WHEN DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name) --
--            WHEN DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name) --
--            WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta') --
--            WHEN DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name) --
--            ELSE '' END 'PaymentType'
--
-- por este otro bloque modificado:
--
--            -- Modificación 21/10/2025
--            WHEN DOPD.TypeofInOutMoneyId IN (1, 2, 3, 4, 7, 10) THEN UPPER(ctgmon.tio_pk_name)
--            WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
--            ELSE '' END 'PaymentType'
--            -- Fin de modificación                               --
--
-- Se recomienda revisar todo el SP para asegurar que todos los cambios
-- estén aplicados correctamente. Se sabe que hay más bloques similares.
-- y arreglos que no estaban en la rama develop por arreglos en otras épicas
---------------------------------------------------------------