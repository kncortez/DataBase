BEGIN TRY
    BEGIN TRANSACTION;
    
INSERT INTO dbo.CatShipContainerStatus ([Name], [Description], [UserCreated], [DateCreated], [TokenCreated])
 VALUES('Creado','Contenedor creado listo para ingreso de guías','SYS-ARECINOS', GETDATE(), 'SYS-ARECINOS')

INSERT INTO dbo.CatShipContainerStatus ([Name], [Description], [UserCreated], [DateCreated], [TokenCreated])
 VALUES('Recolectado','Contenedor recolectado','SYS-ARECINOS', GETDATE(), 'SYS-ARECINOS')

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;