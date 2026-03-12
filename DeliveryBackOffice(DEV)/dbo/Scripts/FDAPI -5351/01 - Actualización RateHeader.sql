BEGIN TRY
BEGIN TRANSACTION

    ALTER TABLE [dbo].[RateHeader] ADD [InsuranceCharge] [decimal](12, 2) NULL
 
    COMMIT TRANSACTION
    PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH