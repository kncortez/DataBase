/***
-- UPDATE DE VALORES EN LA TABLA DEFAULTVALUESPERCOUNTRY
***/

BEGIN TRANSACTION;
BEGIN TRY

-- Guatemala
UPDATE DefaultValuesPerCountry
SET 
    DNIShortName = 'DPI',
    DNIDescription = 'Documento Personal de Identificación',
    regxDNI = '^[0-9]{13}$',
    TaxShortName = 'NIT',
    TaxDescription = 'Número de Identificación Tributaria',
    regxPayerTaxNumber = '^[0-9]+(-?[0-9Kk])?$',
	DNIMaxLength = 13,
	PrefixNumber ='502' ,
	IconFlag = 'GT.png',
	CultureInfo= 'es-GT'
WHERE IdCountry = 'GT';

-- Honduras
UPDATE DefaultValuesPerCountry
SET 
    DNIShortName = 'DNI',
    DNIDescription = 'Documento Nacional de Identificación',
    regxDNI = '^[0-9]{13}$',
    TaxShortName = 'RTN',
    TaxDescription = 'Registro Tributario Nacional',
    regxPayerTaxNumber = '^[0-9]{14}$',
	DNIMaxLength = 14,
	PrefixNumber = '504',
	IconFlag = 'HN.png',
	CultureInfo= 'es-HN'
WHERE IdCountry = 'HN';

-- El Salvador
UPDATE DefaultValuesPerCountry
SET 
    DNIShortName = 'DUI',
    DNIDescription = 'Documento Único de Identidad',
    regxDNI = '^[0-9]{8}[0-9]$',
    TaxShortName = 'NIT',
    TaxDescription = 'Número de Identificación Tributaria',
    regxPayerTaxNumber = '^[0-9]{4}-[0-9]{6}-[0-9]{3}-[0-9]$',
	DNIMaxLength = 10,
	PrefixNumber = '503',
	IconFlag = 'SV.png',
	CultureInfo= 'en-US'
WHERE IdCountry = 'SV';

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH