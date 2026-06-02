BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @ModIdModule INT;
    DECLARE @RolIdRol INT;
    DECLARE @RolIdSystem INT = 13; -- IdSystem (Hermes web operaciones)
    DECLARE @TokenCreated NVARCHAR(50) = 'SYS-DEVELOP';
    DECLARE @ModOrder INT;

        -- Obtener último ModOrder y sumarle 1
    SELECT @ModOrder = ISNULL(MAX(ModOrder), 0) + 1
    FROM [dbo].[CatModule] WITH (NOLOCK);


    -- Crear nuevo módulo
    INSERT INTO [dbo].[CatModule] 
    (
        [ModName],
        [ModIdModuleParent],
        [ModPath],
        [ModDescription],
        [ModOrder],
        [ModMetadata],
        [ModVisible],
        [ModRowStatus],
        [ModTokenCreated],
        [ModDateCreated]
    )
    VALUES 
    (
        'Gestión usuarios EXC/CNC',
        NULL,
        '/gestion-usuarios-exc-cnc',
        'Administración de usuarios EXC/CNC',
        @ModOrder,
        'file.png',
        1,
        1,
        @TokenCreated,
        GETDATE()
    );

    SET @ModIdModule = CAST(SCOPE_IDENTITY() AS INT);

    -- Crear nuevo rol
    INSERT INTO [dbo].[CatRol] 
    (
        [RolIdSystem],
        [RolName],
        [RolDescription],
        [RolAdminBrothers],
        [RolAdminClient],
        [RolRowStatus],
        [RolTokenCreated],
        [RolDateCreated],
        [RolAdminInternal],
        [RolAdminSystem]
    )
    VALUES 
    (
        @RolIdSystem,
        'Gestión usuarios EXC/CNC',
        'Rol para gestión de usuarios EXC/CNC en portal interno',
        0,
        0,
        1,
        @TokenCreated,
        GETDATE(),
        0,
        0
    );

   SET @RolIdRol = CAST(SCOPE_IDENTITY() AS INT);

    -- Asignar módulo al rol
    INSERT INTO [dbo].[RolByModuleBySystem] 
    (
        [RmsIdRol],
        [RmsIdModule],
        [RmsIdSystem],
        [RmsRowStatus],
        [RmsTokenCreated],
        [RmsDateCreated]
    )
    VALUES 
    (
        @RolIdRol,
        @ModIdModule,
        @RolIdSystem,
        1,
        @TokenCreated,
        GETDATE()
    );

    COMMIT TRANSACTION;

    PRINT 'Proceso completado correctamente.';
    PRINT 'ModOrder asignado: ' + CAST(@ModOrder AS NVARCHAR(20));
    PRINT 'RolIdRol creado: ' + CAST(@RolIdRol AS NVARCHAR(20));
    PRINT 'ModIdModule creado: ' + CAST(@ModIdModule AS NVARCHAR(20));

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();

    PRINT 'Error: ' + @ErrorMessage;
END CATCH;