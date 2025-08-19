BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO CatTypeIdentifationDocument
    VALUES
        ('03', 'Pasaporte', 'Documento de viaje emitido por autoridades extranjeras', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
        ('13', 'DUI', 'Documento Único de Identidad', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
        ('36', 'NIT', 'Número de Identificación Tributaria', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);

    COMMIT TRANSACTION;
    PRINT 'Inserción completada correctamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Ocurrió un error durante la inserción.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH;