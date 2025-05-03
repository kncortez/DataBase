
CREATE TABLE [dbo].[DefaultValuesPerCountry](
    [IdCountry]             [nvarchar](4)   NOT NULL,
    [UseMultiCountry]       [bit]           NOT NULL,
    [RowStatus]             [bit]           NOT NULL,
    [TokenCreated]          [varchar](50)   NOT NULL,
    [DateCreated]           [datetime]      NOT NULL,
    [TokenUpdated]          [varchar](50)   NULL,
    [DateUpdated]           [datetime]      NULL,
    [DNIShortName]          [nvarchar](100) NULL,
	[DNIDescription]        [nvarchar](255) NULL,
	[RegxDNI]               [nvarchar](255) NULL,
	[TaxShortName]          [nvarchar](100) NULL,
	[TaxDescription]        [nvarchar](255) NULL,
	[RegxPayerTaxNumber]    [nvarchar](255) NULL,
	[DNIMaxLength]          [int]           NULL,
	[PrefixNumber]          [nvarchar](5)   NULL,
	[IconFlag]              [nvarchar](50)  NULL,
	[CultureInfo]           [nvarchar](10)  NULL
) ON [PRIMARY];


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