BEGIN TRY
    BEGIN TRANSACTION;

	UPDATE InvoiceBatchDetail
    SET IsCompleted = 1
    WHERE IsCompleted IS NULL;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;