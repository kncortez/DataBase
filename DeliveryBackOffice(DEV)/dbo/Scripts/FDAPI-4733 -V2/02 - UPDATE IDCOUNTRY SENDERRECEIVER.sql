BEGIN TRY
    BEGIN TRANSACTION;
/***********ACTUALIZACION DE PAIS, POR DEFAULT GT PARA LOS NULL*************************/
    UPDATE SenderReceiver SET IdCountry = 'GT' 
    WHERE IdCountry IS NULL 
    AND Estatus = 1;

    COMMIT TRANSACTION;
    PRINT 'Registros actualizados exitosamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;