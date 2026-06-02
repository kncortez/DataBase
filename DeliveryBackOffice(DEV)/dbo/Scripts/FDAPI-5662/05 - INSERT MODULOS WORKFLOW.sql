BEGIN TRY
    ---PASO 1

    Declare @IdRol1 INT,
            @IdModule1 INT;

    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.CatModule WITH(NOLOCK)
        WHERE [ModName] = 'Mapa de Procesos'
    )
    BEGIN

        INSERT INTO DeliveryBackOffice.dbo.CatModule
        VALUES
        ('Mapa de Procesos',
         NULL,
         '/operaciones/process-map',
         'Mapa de procesos',
         1  ,
         'bi bi-arrow-repeat',
         1  ,
         1  ,
         'SYS-BPEDROZA',
         GETDATE(),
         NULL,
         NULL,
         NULL
        );

        SET @IdModule1 = SCOPE_IDENTITY();

        IF NOT EXISTS
        (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatRol WITH(NOLOCK)
            WHERE [RolName] = 'Workflow'
        )
        BEGIN
            INSERT INTO DeliveryBackOffice.dbo.CatRol
            values
            (13, 'Workflow', 'Workflow', NULL, 0, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL, NULL);

            SET @IdRol1 = SCOPE_IDENTITY();

            INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem
            VALUES
            (@IdRol1, 13, @IdModule1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL, NULL, NULL);

        --DEFINIR USUARIO
        --INSERT INTO DeliveryBackOffice.dbo.RolByUserBySystem (RusIdRol,
        --RusIdSystem,
        --RusIdUser,
        --RusRowStatus,
        --RusTokenCreated,
        --RusDateCreated,
        --RusTokenUpdated,
        --RusDateUpdated,
        --StationId)
        --VALUES (@IdRol1,13,10861,1,'SYS-BPEDROZA',GETDATE(),null,null,285)
        END
    END



    ---PASO 2


    Declare @IdRol INT,
            @IdModule INT;

    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.CatModule WITH(NOLOCK)
        WHERE [ModName] = 'Incidencia de recolección'
    )
    BEGIN

        INSERT INTO DeliveryBackOffice.dbo.CatModule
        VALUES
        ('Incidencia de recolección',
         NULL,
         '/control-calidad/control-calidad-recoleccion',
         'Incidencia de recolección',
         1  ,
         'bi bi-exclamation-diamond',
         1  ,
         1  ,
         'SYS-BPEDROZA',
         GETDATE(),
         NULL,
         NULL,
         NULL
        );
        SET @IdModule = SCOPE_IDENTITY();

        IF NOT EXISTS
        (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatRol WITH(NOLOCK)
            WHERE [RolName] = 'Recolecciones'
        )
        BEGIN

            INSERT INTO DeliveryBackOffice.dbo.CatRol
            values
            (13, 'Recolecciones', 'Recolecciones', NULL, 0, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL, NULL);

            SET @IdRol = SCOPE_IDENTITY();

            INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem
            VALUES
            (@IdRol, 13, @IdModule, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL, NULL, NULL);

        --DEFINIR USUARIO
        --INSERT INTO DeliveryBackOffice.dbo.RolByUserBySystem (RusIdRol,
        --RusIdSystem,
        --RusIdUser,
        --RusRowStatus,
        --RusTokenCreated,
        --RusDateCreated,
        --RusTokenUpdated,
        --RusDateUpdated,
        --StationId)
        --VALUES (@IdRol,13,10861,1,'SYS-BPEDROZA',GETDATE(),null,null,285)
        END
    END
END TRY
BEGIN CATCH

    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;

END CATCH;