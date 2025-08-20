BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO CatTypeDocument
    VALUES (-1, 'Comprobante Crédito Fiscal', 
            'Documento que representa venta a clientes corporativos en El Salvador', 
            1, 'SYS-DRAMIREZ', GETDATE(), NULL, NULL);

    INSERT INTO CatTypeDocument
    VALUES (-1, 'Anulación DTE', 
            'Indica que un documento triburario fue anulado para El Salvador', 
            1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);

    COMMIT TRANSACTION;
    PRINT 'Inserciones realizadas correctamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Ocurrió un error:';
    PRINT ERROR_MESSAGE();
    PRINT 'Número de error:';
    PRINT ERROR_NUMBER();
    PRINT 'Procedimiento:';
    PRINT ERROR_PROCEDURE();
    PRINT 'Línea:';
    PRINT ERROR_LINE();
END CATCH;
