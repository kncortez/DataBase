-- =====================================================
-- SCRIPT FDAPI-5590: Creación de Módulo y Permisos
-- =====================================================
-- Propósito: Crear módulo "Mi inventario" y asignar permisos
-- Fecha: 2026-03-18
-- Autor: Bilkar Morataya
-- =====================================================

BEGIN TRANSACTION;

BEGIN TRY
    PRINT '========================================';
    PRINT 'Iniciando creación de módulo...';
    PRINT '========================================';

    -- Variable para almacenar el ID del módulo generado
    DECLARE @NewModuleId INT;

    -- Insertar el nuevo módulo (sin especificar ModIdModule para que lo asigne la BBDD)
    INSERT INTO DeliveryBackOffice.dbo.CatModule (ModName, ModIdModuleParent, ModPath, ModDescription, ModOrder, ModMetadata, ModVisible, ModRowStatus, ModTokenCreated, ModDateCreated, ModTokenUpdated, ModDateUpdated, ModGroup) 
    VALUES (N'Mi inventario', null, N'/historico', N'Módulo de Inventario de EXC y CNC', 20, null, 1, 1, N'SYS-BILKAR', GETDATE(), null, null, 0);

    -- Capturar el ID generado automáticamente
    SET @NewModuleId = SCOPE_IDENTITY();

    PRINT 'Módulo creado con ID: ' + CAST(@NewModuleId AS NVARCHAR(10));

    -- Insertar la relación Rol-Módulo-Sistema usando el ID generado
    INSERT INTO DeliveryBackOffice.dbo.RolByModuleBySystem (RmsIdRol, RmsIdSystem, RmsIdModule, RmsRowStatus, RmsTokenCreated, RmsDateCreated, RmsTokenUpdated, RmsDateUpdated, RmsModuleMenu, RmsHasNewFunction) 
    VALUES (5, 1, @NewModuleId, 1, N'SYS-BILKAR', GETDATE(), null, null, null, null);

    PRINT 'Relación Rol-Módulo-Sistema creada para ModuleId: ' + CAST(@NewModuleId AS NVARCHAR(10));

    PRINT '';
    PRINT '========================================';
    PRINT '✓ Módulo y permisos creados exitosamente.';
    PRINT '========================================';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '❌ ERROR al crear módulo: ' + ERROR_MESSAGE();
    PRINT '❌ LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    THROW;
END CATCH;
GO


-- =====================================================
-- SCRIPT FDAPI-5590: Actualización de Tabla Warehouse
-- =====================================================
-- Propósito: Agregar campos y optimizar tabla Warehouse
-- Fecha: 2026-03-17
-- Cambios FDAPI-4784 por Bilkar Morataya
-- 
-- Este script agrega:
--   1. 4 nuevas columnas a la tabla Warehouse
--   2. 6 índices optimizados para mejorar rendimiento
--
-- NOTA: Al terminar, ejecutar:
--   * Agregar_Indices_StationId.sql (si aún no se ejecutó)
--   * Mantenimiento_Warehouse_Inteligente.sql (para optimizar)
-- =====================================================





BEGIN TRANSACTION;

BEGIN TRY
    PRINT '========================================';
    PRINT 'Iniciando actualización de Warehouse...';
    PRINT '========================================';

    -- 1. Agregar HubExc si no existe
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_NAME = 'Warehouse' AND COLUMN_NAME = 'HubExc')
    BEGIN
        ALTER TABLE [dbo].[Warehouse]
        ADD HubExc NVARCHAR(10) NULL;
        PRINT 'Campo HubExc agregado.';
    END
    ELSE
        PRINT 'Campo HubExc ya existe.';

    -- 2. Agregar IdHubExc si no existe
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_NAME = 'Warehouse' AND COLUMN_NAME = 'IdHubExc')
    BEGIN
        ALTER TABLE [dbo].[Warehouse]
        ADD IdHubExc INT NOT NULL DEFAULT 0;
        PRINT 'Campo IdHubExc agregado con DEFAULT 0.';
    END
    ELSE
        PRINT 'Campo IdHubExc ya existe.';

    -- 3. Agregar StatusOrderId si no existe
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_NAME = 'Warehouse' AND COLUMN_NAME = 'StatusOrderId')
    BEGIN
        ALTER TABLE [dbo].[Warehouse]
        ADD StatusOrderId INT NOT NULL DEFAULT 0;
        PRINT 'Campo StatusOrderId agregado con DEFAULT 0.';
    END
    ELSE
        PRINT 'Campo StatusOrderId ya existe.';

    -- 4. Crear índice 1 si no existe
    IF NOT EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'idx_warehouse_active_hubexc_date' 
                   AND object_id = OBJECT_ID('[dbo].[Warehouse]'))
    BEGIN
        CREATE INDEX idx_warehouse_active_hubexc_date
            ON [dbo].[Warehouse] (HubExc, IdHubExc, Active, DateCreated, Rack_Position, Guide_Serie, Guide_Number, StatusOrderId)
            WHERE Active = 1 AND HubExc IS NOT NULL;
        PRINT 'Índice idx_warehouse_active_hubexc_date creado.';
    END
    ELSE
        PRINT 'Índice idx_warehouse_active_hubexc_date ya existe.';

    -- 5. Crear índice 2 si no existe
    IF NOT EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'idx_warehouse_statusorder_guide' 
                   AND object_id = OBJECT_ID('[dbo].[Warehouse]'))
    BEGIN
        CREATE INDEX idx_warehouse_statusorder_guide
            ON [dbo].[Warehouse] (StatusOrderId, Guide_Serie, Guide_Number, Rack_Position, Active);
        PRINT 'Índice idx_warehouse_statusorder_guide creado.';
    END
    ELSE
        PRINT 'Índice idx_warehouse_statusorder_guide ya existe.';

    -- 6. Crear índice 3 si no existe
    IF NOT EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'idx_warehouse_idhubexc_active' 
                   AND object_id = OBJECT_ID('[dbo].[Warehouse]'))
    BEGIN
        CREATE INDEX idx_warehouse_idhubexc_active
            ON [dbo].[Warehouse] (IdHubExc, Active, Guide_Serie, Guide_Number)
            WHERE Active = 1 AND IdHubExc IS NOT NULL;
        PRINT 'Índice idx_warehouse_idhubexc_active creado.';
    END
    ELSE
        PRINT 'Índice idx_warehouse_idhubexc_active ya existe.';

    -- 7. Agregar StationId si no existe
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_NAME = 'Warehouse' AND COLUMN_NAME = 'StationId')
    BEGIN
        ALTER TABLE [dbo].[Warehouse]
        ADD StationId INT NULL;
        PRINT 'Campo StationId agregado.';
        
        EXECUTE sp_addextendedproperty @name = N'MS_Description', 
            @value = N'Identificador de la estación desde donde se radicó el inventario', 
            @level0type = N'SCHEMA', @level0name = N'dbo', 
            @level1type = N'TABLE', @level1name = N'Warehouse', 
            @level2type = N'COLUMN', @level2name = N'StationId';
    END
    ELSE
        PRINT 'Campo StationId ya existe.';

    -- 8. Crear índices para StationId si no existen
    PRINT '';
    PRINT '8. Creando índices para StationId...';
    
    -- Índice simple en StationId
    IF NOT EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'idx_warehouse_stationid' 
                   AND object_id = OBJECT_ID('[dbo].[Warehouse]'))
    BEGIN
        CREATE NONCLUSTERED INDEX [idx_warehouse_stationid]
            ON [dbo].[Warehouse] (StationId ASC)
            INCLUDE (Guide_Serie, Guide_Number, Rack_Position, Active, DateCreated);
        PRINT '   Índice idx_warehouse_stationid creado.';
    END
    ELSE
        PRINT '   Índice idx_warehouse_stationid ya existe.';

    -- Índice compuesto: StationId + Active (FILTERED)
    IF NOT EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'idx_warehouse_stationid_active' 
                   AND object_id = OBJECT_ID('[dbo].[Warehouse]'))
    BEGIN
        CREATE NONCLUSTERED INDEX [idx_warehouse_stationid_active]
            ON [dbo].[Warehouse] (StationId ASC, Active ASC)
            WHERE Active = 1;
        PRINT '   Índice idx_warehouse_stationid_active creado (FILTERED).';
    END
    ELSE
        PRINT '   Índice idx_warehouse_stationid_active ya existe.';

    -- Índice compuesto: StationId + DateCreated
    IF NOT EXISTS (SELECT 1 FROM sys.indexes 
                   WHERE name = 'idx_warehouse_stationid_datecreated' 
                   AND object_id = OBJECT_ID('[dbo].[Warehouse]'))
    BEGIN
        CREATE NONCLUSTERED INDEX [idx_warehouse_stationid_datecreated]
            ON [dbo].[Warehouse] (StationId ASC, DateCreated DESC)
            INCLUDE (Guide_Serie, Guide_Number, Rack_Position);
        PRINT '   Índice idx_warehouse_stationid_datecreated creado.';
    END
    ELSE
        PRINT '   Índice idx_warehouse_stationid_datecreated ya existe.';

    PRINT '';
    PRINT '========================================';
    PRINT '✓ Actualización completada exitosamente.';
    PRINT '========================================';
    PRINT 'Campos agregados:';
    PRINT '  • HubExc (NVARCHAR(10), NULL)';
    PRINT '  • IdHubExc (INT, DEFAULT 0)';
    PRINT '  • StatusOrderId (INT, DEFAULT 0)';
    PRINT '  • StationId (INT, NULL) - Identificador de estación';
    PRINT '';
    PRINT 'Índices creados en Warehouse:';
    PRINT '  • idx_warehouse_active_hubexc_date';
    PRINT '  • idx_warehouse_statusorder_guide';
    PRINT '  • idx_warehouse_idhubexc_active';
    PRINT '  • idx_warehouse_stationid (Búsquedas por estación)';
    PRINT '  • idx_warehouse_stationid_active (Estación + activo)';
    PRINT '  • idx_warehouse_stationid_datecreated (Estación + fecha)';
    PRINT '';
    PRINT 'Total: 6 índices creados';
    PRINT '========================================';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '❌ ERROR: ' + ERROR_MESSAGE();
    PRINT '❌ LÍNEA: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    THROW;
END CATCH;








