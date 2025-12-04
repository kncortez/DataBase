BEGIN TRY
    BEGIN TRANSACTION;

    insert ConfigParams ([Name],[Description],[Value],[Status],[CreateDate],[IdCountry])
    values('RTN', ' Registro Tributario Nacional, arreglo de sólo números de 14 caracteres','05019024041963',1,GETDATE(),'HN')

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;