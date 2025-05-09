/***
-- UPDATE DE VALORES CORREGIDOS
***/

BEGIN TRANSACTION;
BEGIN TRY

UPDATE DefaultValuesPerCountry
SET DNIMaxLength = 9,
	RegxPayerTaxNumber = '^[0-9]{4}[0-9]{6}[0-9]{3}[0-9]$'
WHERE IdCountry = 'SV'

UPDATE DefaultValuesPerCountry
SET DNIMaxLength = 13
WHERE IdCountry = 'HN'

UPDATE DefaultValuesPerCountry
SET RegxPayerTaxNumber = '^([0-9]{4,})(K|[0-9]{1})$'
WHERE IdCountry = 'GT'

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH