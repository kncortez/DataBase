BEGIN TRY
BEGIN TRANSACTION

    UPDATE RateHeader 
       SET InsuranceCharge = 3
    WHERE CountryId = 'GT'
    AND InsuranceRate = 1.5 
    AND RheRowStatus = 1
 
    COMMIT TRANSACTION
    PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH