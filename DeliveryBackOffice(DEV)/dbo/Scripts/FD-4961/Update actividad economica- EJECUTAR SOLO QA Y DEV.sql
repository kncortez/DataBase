BEGIN TRY
    BEGIN TRANSACTION;

    update AddInfoByCodeOfReference
    set Value = '52219'
    where Name = 'CodigoActividad'
    
    update AddInfoByCodeOfReference
    set Value = 'Servicios para el transporte por vía terrestre n.c.p.'
    where Name = 'DescActividad'

    COMMIT TRANSACTION;
    PRINT 'Actualización completada exitosamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Severidad: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
    PRINT 'Estado: ' + CAST(ERROR_STATE() AS VARCHAR(10));
    PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), '-');
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;