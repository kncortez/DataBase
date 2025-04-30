--SELECT * FROM CatTypeVehicle
BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO CatTypeVehicle (
        [Name]
        ,[Description]
        ,RowStatus
        ,TokenCreated
        ,DateCreated
        ,TokenUpdated
        ,DateUpdated
        ,PackageSize
        ,IdCountry
    )
    VALUES 
    ('Camión', 'Camión', 1, 'SYS-JRAMIREZ', GETDATE(), NULL, NULL, 'Paquete grande', 'SV'),
    ('Panel', 'Panel', 1, 'SYS-JRAMIREZ', GETDATE(), NULL, NULL, 'Paquete mediano', 'SV'),
    ('Motocicleta', 'Motocicleta', 1, 'SYS-JRAMIREZ', GETDATE(), NULL, NULL, 'Paquete pequeño', 'SV');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
