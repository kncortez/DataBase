
CREATE TABLE [dbo].[DefaultValuesPerCountry] (
    [IdCountry]                     VARCHAR (2)    NOT NULL,
    [UseMultiCountry]               BIT            NOT NULL,
    [DNIShortName]                  NVARCHAR (100) NULL,
    [DNIDescription]                NVARCHAR (255) NULL,
    [RegxDNI]                       NVARCHAR (255) NULL,
    [DNIMaxLength]                  INT            NULL,
    [TaxShortName]                  NVARCHAR (100) NULL,
    [TaxDescription]                NVARCHAR (255) NULL,
    [RegxPayerTaxNumber]            NVARCHAR (255) NULL,
    [PrefixNumber]                  NVARCHAR (5)   NULL,
    [IconFlag]                      NVARCHAR (50)  NULL,
    [CultureInfo]                   NVARCHAR (10)  NULL,
    [RowStatus]                     BIT            NOT NULL,
    [TokenCreated]                  VARCHAR (50)   NOT NULL,
    [DateCreated]                   DATETIME       NOT NULL,
    [TokenUpdated]                  VARCHAR (50)   NULL,
    [DateUpdated]                   DATETIME       NULL,
    [Latitude]                      DECIMAL (9, 6) NULL,
    [Longitude]                     DECIMAL (9, 6) NULL,
    [LimitHourPickupByApi]          NVARCHAR (5)   NULL,
    [VATShortName]                  VARCHAR (10)   NULL,
    [CodeOfReferenceCorpForInvoice] NVARCHAR (10)  NULL,
    [RegxNRC]                       NVARCHAR (200) NULL,
    [NRCShortDescription]           NVARCHAR (500) NULL,
    [RegxPassport]                  NVARCHAR (200) NULL,
    [PassportShortDescription]      NVARCHAR (500) NULL,
    [TaxPercentage]                 NVARCHAR (20)  NULL,
    [RegxMovilPhone]                NVARCHAR (50)  NULL,
    [WhatsappNumber]                NVARCHAR (15)  NULL,
    PRIMARY KEY CLUSTERED ([IdCountry] ASC),
    CONSTRAINT [CHK_DefaultValuesPerCountry_Latitude_ValidRange] CHECK ([Latitude]>=(-90) AND [Latitude]<=(90)),
    CONSTRAINT [CHK_DefaultValuesPerCountry_Longitude_ValidRange] CHECK ([Longitude]>=(-180) AND [Longitude]<=(180)),
    CONSTRAINT [FK_DefaultValuesPerCountry_CatCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de país ingresado a multipais', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'IdCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para determinar si el país esta activo o no para multipais', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'UseMultiCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',@value = N'Nombre corto del documento de identidad nacional (DNI)',@level0type = N'SCHEMA', @level0name = N'dbo',@level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry',@level2type = N'COLUMN', @level2name = N'DNIShortName';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',@value = N'Descripción del documento nacional de identidad',@level0type = N'SCHEMA', @level0name = N'dbo',@level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry',@level2type = N'COLUMN', @level2name = N'DNIDescription';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',@value = N'Expresión regular para validar el formato del DNI',@level0type = N'SCHEMA', @level0name = N'dbo',@level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry',@level2type = N'COLUMN', @level2name = N'RegxDNI';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',@value = N'Nombre corto del número de identificación fiscal',@level0type = N'SCHEMA', @level0name = N'dbo',@level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry',@level2type = N'COLUMN', @level2name = N'TaxShortName';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',@value = N'Descripción del número de identificación fiscal',@level0type = N'SCHEMA', @level0name = N'dbo',@level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry',@level2type = N'COLUMN', @level2name = N'TaxDescription';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',@value = N'Expresión regular para validar el número fiscal del contribuyente',@level0type = N'SCHEMA', @level0name = N'dbo',@level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry',@level2type = N'COLUMN', @level2name = N'RegxPayerTaxNumber';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',@value = N'Cantidad máxima de caracteres permitidos en el DNI',@level0type = N'SCHEMA', @level0name = N'dbo',@level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry',@level2type = N'COLUMN', @level2name = N'DNIMaxLength';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',@value = N'Prefijo común utilizado en documentos o números regionales',@level0type = N'SCHEMA', @level0name = N'dbo',@level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry',@level2type = N'COLUMN', @level2name = N'PrefixNumber';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',@value = N'Nombre o ruta del ícono de la bandera del país',@level0type = N'SCHEMA', @level0name = N'dbo',@level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry',@level2type = N'COLUMN', @level2name = N'IconFlag';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description',@value = N'Código de cultura regional para formateo (ej: es-PE, en-US)',@level0type = N'SCHEMA', @level0name = N'dbo',@level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry',@level2type = N'COLUMN', @level2name = N'CultureInfo';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Almacena los valores predeterminados y configuraciones por país para funcionalidades multipaís del sistema.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Coordenada geográfica que especifica la posición este-oeste.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'Longitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Coordenada geográfica que especifica la posición norte-sur.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'Latitude';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Abreviación del Impuesto al Valor Agregado por país (VAT: Value Added Tax)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'VATShortName';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número asignado de Forza al país para enviar mensajes, debe estar registrado en META', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'WhatsappNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Expresión regular para teléfonos móviles del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'RegxMovilPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code Of Reference que se usa por defecto para facturas corporativas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'CodeOfReferenceCorpForInvoice';

