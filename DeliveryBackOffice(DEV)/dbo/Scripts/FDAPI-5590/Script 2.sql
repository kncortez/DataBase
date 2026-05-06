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
    VALUES (N'Mi inventario', null, N'/inventario', N'Módulo de Inventario de EXC y CNC', 20, null, 1, 1, N'SYS-BILKAR', GETDATE(), null, null, 0);

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


