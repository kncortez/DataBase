BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE ConfigParams
    SET IdCountry = 'GT' 
    WHERE [Name] = 'MinimumCODAmount' AND IdCountry IS NULL

    COMMIT TRANSACTION;
    PRINT 'Actualización realizada exitosamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Ocurrió un error durante la actualización.';
    PRINT ERROR_MESSAGE();
END CATCH;