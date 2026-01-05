-- Variables para mayor mantenibilidad
DECLARE @GuatemalaSubscriptionId INT = 12;
DECLARE @HondurasSubscriptionId INT = 19;
DECLARE @RowsAffectedTotal INT = 0;

BEGIN TRY
    -- Logging inicial
    PRINT 'Iniciando desactivación de suscripciones PRO...';
    PRINT CONCAT('Timestamp: ', GETDATE());
    
    BEGIN TRANSACTION
    
    -- Verificar que los registros existen y están activos antes de actualizar
    IF NOT EXISTS (SELECT 1 FROM CatSubscription WHERE IdCatSubscription IN (@GuatemalaSubscriptionId, @HondurasSubscriptionId) AND RowStatus = 1)
    BEGIN
        RAISERROR('Una o ambas suscripciones ya están desactivadas o no existen', 16, 1);
        RETURN;
    END
    
    -- DESACTIVAR SUSCRIPCIONES PRO PARA GUATEMALA Y HONDURAS
    UPDATE CatSubscription 
    SET RowStatus = 0
    WHERE IdCatSubscription IN (@GuatemalaSubscriptionId, @HondurasSubscriptionId) 
      AND RowStatus = 1;
    
    SET @RowsAffectedTotal = @@ROWCOUNT;
    
    -- Validar que se actualizaron registros
    IF @RowsAffectedTotal = 0
    BEGIN
        RAISERROR('No se actualizó ningún registro', 16, 1);
        RETURN;
    END
    
    COMMIT TRANSACTION;
    
    PRINT 'Transacción completada exitosamente';
    SELECT CONCAT('DATOS ACTUALIZADOS CORRECTAMENTE - Registros afectados: ', @RowsAffectedTotal) AS MESSAGE;
    
END TRY
BEGIN CATCH
    -- Rollback solo si hay una transacción activa
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
        
    -- Información detallada del error
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState;
        
    PRINT 'Error durante la ejecución del script';
END CATCH