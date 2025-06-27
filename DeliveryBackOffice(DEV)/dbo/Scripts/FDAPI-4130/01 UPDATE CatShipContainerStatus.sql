
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE CatShipContainerStatus
    SET [Name] = 'Creado', 
        [Description] = 'Contenedor creado listo para ingreso de guías',
        DateUpdated = GETDATE(),
        TokenUpdated = 'SYS-BPEDROZA'
    WHERE IdCatStatus = 1;

    UPDATE CatShipContainerStatus
    SET [Name] = 'Recolectado', 
        [Description] = 'Contenedor recolectado',
        DateUpdated = GETDATE(),
        TokenUpdated = 'SYS-BPEDROZA'
    WHERE IdCatStatus = 2;

    UPDATE CatShipContainerStatus
    SET [Name] = 'Liquidado', 
        [Description] = 'Contenedor liquidado en proceso de liquidacion de ruta',
        DateUpdated = GETDATE(),
        TokenUpdated = 'SYS-BPEDROZA'
    WHERE IdCatStatus = 3;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH
