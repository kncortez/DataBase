--SCRIPT PARA CAMBIO DE NOMBRE DE MODULO DE MIS LINKS
BEGIN TRY
    BEGIN TRANSACTION;
    
	UPDATE DeliveryBackOffice.dbo.CatModule
	SET ModName = 'Mis links'
	WHERE ModName = 'Mis link'
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
