-- Insertar registros de información adicional para CodeOfReference 1162393 - Seller
-- SCRIPT PARA DESARROLLO
BEGIN TRY
    BEGIN TRANSACTION;
    
    USE DeliveryBackOffice;
    -- Insertar valores iniciales
    
    SELECT   *
    FROM dbo.AddInfoByConfigSV

    DELETE
    FROM dbo.AddInfoByConfigSV
    WHERE [Name] IN (
    'UnitOfMeasure',
    'AdditionalInfo',
    'CodEstPuntoV',
    'TipoModelo',
    'TipoOperacion',
    'Secuencial',
    'nombreResponsable',
    'tipoDocumentoResponsable',
    'numDocumentoResponsable',
    'nombreSolicitante',
    'tipoDocumentoSolicitante',
    'numDocumentoSolitante'
    )

    SELECT   *
    FROM dbo.AddInfoByConfigSV


    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
