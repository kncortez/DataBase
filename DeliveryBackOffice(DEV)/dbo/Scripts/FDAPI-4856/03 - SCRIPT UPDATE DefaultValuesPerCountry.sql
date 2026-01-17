/************************************************************************************
*****SCRIPT PARA ELMINAR EXPRESIÓN REGULAR DE PASAPORTES EN EL PAIS EL SALVADOR******
************************REGEX: ^[A-Z]{3}[0-9]{6}$************************************
*************************************************************************************/

BEGIN TRY
    BEGIN TRANSACTION;

    --SCRIPT PARA ELMINAR EXPRESION REGULAR PASAPORTE
	UPDATE DefaultValuesPerCountry SET RegxPassport = '' WHERE IdCountry = 'SV'

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;