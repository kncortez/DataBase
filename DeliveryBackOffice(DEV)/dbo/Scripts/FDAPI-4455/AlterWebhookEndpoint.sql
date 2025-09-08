USE [DeliveryBackOffice]
GO

BEGIN TRY
    BEGIN TRANSACTION
    
    IF NOT EXISTS (
        SELECT 1 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = 'WebhookEndpoint' 
        AND COLUMN_NAME = 'RestrictValidatedIncidents'
    )
    BEGIN
        ALTER TABLE [DeliveryBackOffice].[dbo].[WebhookEndpoint]
        ADD RestrictValidatedIncidents BIT NOT NULL DEFAULT 0
        
        PRINT 'Columna RestrictValidatedIncidents agregada exitosamente'
        
        EXECUTE sp_addextendedproperty 
            @name = N'MS_Description', 
            @value = N'Restricción de notificación de estado 50 (Incidencia validada) si es real o no, 0: envia notificacion si es real o no, 1 envia notificacion solo si es real', 
            @level0type = N'SCHEMA', 
            @level0name = N'dbo', 
            @level1type = N'TABLE', 
            @level1name = N'WebhookEndpoint', 
            @level2type = N'COLUMN', 
            @level2name = N'RestrictValidatedIncidents'
            
        PRINT 'Propiedad extendida agregada exitosamente'
    END
    ELSE
    BEGIN
        PRINT 'La columna RestrictValidatedIncidents ya existe en la tabla WebhookEndpoint'
    END
    GO
    
    COMMIT TRANSACTION
    
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION
    
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
    DECLARE @ErrorState INT = ERROR_STATE()
    
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
