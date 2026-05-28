SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    -- Validación FUERA de la transacción
    IF NOT EXISTS (
        SELECT 1
        FROM DefaultValuesPerCountry
        WHERE IdCountry = 'SV'
    )
    BEGIN
        THROW 50001, 'No existe configuración para el país SV.', 1;
    END

    --  Auditoría del valor actual FUERA de la transacción
    PRINT 'Valor actual:';
    SELECT 
        IdCountry,
        RegxPayerTaxNumber AS CurrentRegxPayerTaxNumber
    FROM DefaultValuesPerCountry
    WHERE IdCountry = 'SV';

    BEGIN TRANSACTION;
    PRINT 'Inicio de actualización de RegxPayerTaxNumber para SV';

    UPDATE DefaultValuesPerCountry
       SET RegxPayerTaxNumber = '^(\d{9}|\d{14})$'
    WHERE IdCountry = 'SV';

    
    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50002, 'La actualización no afectó registros.', 1;
    END

    PRINT 'Valor actualizado:';
    SELECT 
        IdCountry,
        RegxPayerTaxNumber AS UpdatedRegxPayerTaxNumber
    FROM DefaultValuesPerCountry
    WHERE IdCountry = 'SV';

    COMMIT TRANSACTION;
    PRINT 'Actualización realizada correctamente.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Ocurrió un error durante la actualización.';
    PRINT 'Error Number   : ' + CAST(ERROR_NUMBER()    AS VARCHAR(20));
    PRINT 'Error Message  : ' + ERROR_MESSAGE();
    PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
    PRINT 'Error Line     : ' + CAST(ERROR_LINE()      AS VARCHAR(20));

    THROW; 
END CATCH;