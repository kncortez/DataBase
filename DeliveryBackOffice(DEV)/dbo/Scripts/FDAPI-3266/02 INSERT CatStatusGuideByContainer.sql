BEGIN TRY
    BEGIN TRANSACTION;

INSERT INTO CatShipContainerStatus 
VALUES('Liquidado','Contenedor liquidado en proceso de liquidacion de ruta',1,'SYS-BPEDROZA',GETDATE(),'SYS-BPEDROZA',NULL,NULL,NULL)

INSERT INTO [CatStatusGuideByContainer]
VALUES ('Pendiente', 'Indica que la guia esta lista para ser escaneada',1,'SYS-BPEDROZA',GETDATE(),NULL,NULL)

INSERT INTO [CatStatusGuideByContainer]
VALUES ('Escaneada', 'La guia esta preparada para ser liquidada',1,'SYS-BPEDROZA',GETDATE(),NULL,NULL)

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;