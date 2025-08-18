/***
-- INSERCION DE VALORES EN LA TABLA DEFAULTVALUESPERCOUNTRY
***/

BEGIN TRANSACTION;
BEGIN TRY

    INSERT INTO DefaultValuesPerCountry
    (
     [IdCountry], 
     [UseMultiCountry],
     [DNIShortName],
     [DNIDescription],
     [RegxDNI],
     [DNIMaxLength],
     [TaxShortName],
     [TaxDescription],
     [RegxPayerTaxNumber],
     [PrefixNumber],
     [IconFlag],
     [CultureInfo],
     [RowStatus],
     [TokenCreated],
     [DateCreated]
    )
    VALUES
    (
     'GT',
     1,
     'DPI',
     'Documento Personal de Identificación',
     '^[0-9]{13}$',
     13,
     'NIT',
     'Número de Identificación Tributaria',
     '^([0-9]{4,})(K|[0-9]{1})$',
     '502',
     'GT.png',
     'es-GT',
     1,
     'SYS-CAZURDIA',
     GETDATE()
    )

    INSERT INTO DefaultValuesPerCountry 
    (
     [IdCountry], 
     [UseMultiCountry],
     [DNIShortName],
     [DNIDescription],
     [RegxDNI],
     [DNIMaxLength],
     [TaxShortName],
     [TaxDescription],
     [RegxPayerTaxNumber],
     [PrefixNumber],
     [IconFlag],
     [CultureInfo],
     [RowStatus],
     [TokenCreated],
     [DateCreated]
    )
    VALUES
    (
     'HN',
     1,
     'DNI',
     'Documento Nacional de Identificación',
     '^[0-9]{13}$',
     13,
     'RTN',
     'Registro Tributario Nacional',
     '^[0-9]{14}$',
     '504',
     'HN.png',
     'es-HN',
     1,
     'SYS-CAZURDIA',
     GETDATE()
    )

    INSERT INTO DefaultValuesPerCountry 
    (
     [IdCountry], 
     [UseMultiCountry],
     [DNIShortName],
     [DNIDescription],
     [RegxDNI],
     [DNIMaxLength],
     [TaxShortName],
     [TaxDescription],
     [RegxPayerTaxNumber],
     [PrefixNumber],
     [IconFlag],
     [CultureInfo],
     [RowStatus],
     [TokenCreated],
     [DateCreated]
    )
    VALUES
    (
     'SV',
     1,
     'DUI',
     'Documento Único de Identidad',
     '^[0-9]{8}[0-9]$',
     9,
     'NIT',
     'Número de Identificación Tributaria',
     '^[0-9]{4}[0-9]{6}[0-9]{3}[0-9]$',
     '503',
     'SV.png',
     'en-US',
     1,
     'SYS-CAZURDIA',
     GETDATE()
    )

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH