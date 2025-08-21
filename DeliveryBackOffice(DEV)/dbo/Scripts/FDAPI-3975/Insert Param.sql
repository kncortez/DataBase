USE [DeliveryBackOffice]
GO

BEGIN TRY
    BEGIN TRANSACTION
    
    IF NOT EXISTS (
        SELECT 1 
        FROM [dbo].[ConfigParams] 
        WHERE [Name] = 'BaseURL'
        AND [Value] = 'https://tracking.forzadelivery.com'
    )
    BEGIN
        INSERT INTO [dbo].[ConfigParams]
                   ([Name]
                   ,[Description]
                   ,[Value]
                   ,[Status]
                   ,[CreateDate]
                   ,[IdCountry]
                   ,[IdCurrencyCOD])
             VALUES
                   ('BaseURL'
                   ,'Base para URL que muestra el comprobante de entrega escaneado'
                   ,'https://tracking.forzadelivery.com'
                   ,1
                   ,GETDATE()
                   ,NULL
                   ,NULL)
        
        PRINT 'Registro insertado exitosamente.'
    END
    ELSE
    BEGIN
        PRINT 'El registro ya existe. No se realizó la inserción.'
    END
    
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
GO