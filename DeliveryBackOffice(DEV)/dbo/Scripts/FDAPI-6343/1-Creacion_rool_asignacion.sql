/***************************************************************************************************
* TICKET:        FDAPI-6343  
* DESCRIPCIÓN:   Creación de Rol, Módulo y vinculación Rol → Módulo → Sistema para la
*                funcionalidad "Reasignación de Rutas Web" en Hermes Web Operaciones (ID 13)
* AUTOR:         Pedro Macajol
* FECHA:         2026-06-03
*
* TABLAS AFECTADAS:
*   - CatRol
*   - CatModule
*   - RolByModuleBySystem
*
* SISTEMA AFECTADO:
*   - ID 13 → Hermes Web Operaciones
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* ⚠  INSTRUCCIONES OBLIGATORIAS PARA EL DBA
*
*   1. Leer el script COMPLETO antes de ejecutar cualquier sentencia.
*   2. Ejecutar cada PASO en el ORDEN indicado. No saltarse pasos.
*   3. Verificar el resultado de cada PASO antes de continuar con el siguiente.
*   4. PASO 1 es de solo lectura. Si retorna datos existentes → DETENER y notificar al equipo
*      de desarrollo. NO continuar.
*   5. PASO 2 contiene los cambios reales. Incluye transacción con ROLLBACK automático.
*   6. PASO 3 son las post-validaciones. Ejecutar siempre para confirmar integridad.
*   7. En caso de cualquier duda o comportamiento inesperado, NO ejecutar y escalar.
*
* ROLLBACK:
*   El bloque de ejecución maneja transacción explícita. Ante cualquier error,
*   los cambios se revertirán automáticamente sin afectar el ambiente.
***************************************************************************************************/


-- ═══════════════════════════════════════════════════════════════════════════════════════════════
-- PASO 1 — PRE-VALIDACIONES  (Solo lectura | Sin cambios en BD)
--
--   Propósito : Confirmar que los registros NO existen antes de continuar.
--   Acción    : Ejecutar las tres consultas y revisar que retornen 0 filas.
--   Si alguna retorna datos → DETENER ejecución y notificar al equipo de desarrollo.
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

-- 1A. Verificar que el Rol NO exista en CatRol
--     Resultado esperado: 0 filas
SELECT
    RolIdRol,
    RolIdSystem,
    RolName,
    RolDescription,
    RolRowStatus
FROM CatRol
WHERE RolName LIKE '%Reasignacion%'
  AND RolIdSystem = 13;

-- 1B. Verificar que el Módulo NO exista en CatModule
--     Resultado esperado: 0 filas
SELECT
    ModIdModule,
    ModName,
    ModPath,
    ModRowStatus
FROM CatModule
WHERE ModPath = '/operaciones/reasignacion-rutas';

-- 1C. Vista previa del último RolIdRol y ModIdModule actuales (referencia de secuencia)
--     Útil para confirmar los IDs que se generarán tras la inserción.
SELECT TOP 1 RolIdRol   AS UltimoRolIdActual   FROM CatRol    ORDER BY RolIdRol    DESC;
SELECT TOP 1 ModIdModule AS UltimoModIdActual   FROM CatModule ORDER BY ModIdModule DESC;

GO


-- ═══════════════════════════════════════════════════════════════════════════════════════════════
-- PASO 2 — EJECUCIÓN DE CAMBIOS  (DML con transacción | Requiere que PASO 1 esté limpio)
--
--   Propósito : Crear el Rol, el Módulo y la vinculación Rol → Módulo → Sistema.
--   Acción    : Ejecutar el bloque completo de una sola vez.
--               La transacción hará ROLLBACK automático si ocurre cualquier error.
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

BEGIN TRY
    BEGIN TRANSACTION;

    -- ─────────────────────────────────────────────────────────────────────────
    -- 2A. Crear Rol en CatRol
    -- ─────────────────────────────────────────────────────────────────────────
    IF NOT EXISTS (
        SELECT 1 FROM CatRol
        WHERE RolName LIKE '%Reasignacion%'
          AND RolIdSystem = 13
    )
    BEGIN
        INSERT INTO CatRol (
            RolIdSystem,
            RolName,
            RolDescription,
            RolAdminBrothers,
            RolAdminClient,
            RolRowStatus,
            RolTokenCreated,
            RolDateCreated,
            RolAdminInternal
        )
        VALUES (
            13,                             -- Hermes Web Operaciones
            'Reasignación de rutas web',    -- Nombre del Rol
            'Reasignación de rutas web',    -- Descripción
            0,
            0,
            1,                              -- Activo
            'SYS-DEVELOP',                  -- ← Sustituir con el token del DBA que aplica
            GETDATE(),
            0
        );
        PRINT '[OK] PASO 2A: Rol "Reasignación de rutas web" creado correctamente.';
    END
    ELSE
    BEGIN
        PRINT '[WARN] PASO 2A: El Rol ya existe. Se cancela la transacción.';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Capturar ID generado mediante SCOPE_IDENTITY (seguro dentro de la misma transacción)
    DECLARE @NuevoRolId INT = SCOPE_IDENTITY();
    PRINT CONCAT('[INFO] PASO 2A: RolIdRol generado → ', CAST(@NuevoRolId AS VARCHAR(10)));


    -- ─────────────────────────────────────────────────────────────────────────
    -- 2B. Crear Módulo en CatModule
    -- ─────────────────────────────────────────────────────────────────────────
    IF NOT EXISTS (
        SELECT 1 FROM CatModule
        WHERE ModPath = '/operaciones/reasignacion-rutas'
    )
    BEGIN
        INSERT INTO CatModule (
            ModName,
            ModPath,
            ModMetadata,
            ModIdModuleParent,
            ModOrder,
            ModVisible,
            ModRowStatus,
            ModTokenCreated,
            ModDateCreated
        )
        VALUES (
            'Reasignación de rutas',
            '/operaciones/reasignacion-rutas',
            'bi bi-shuffle',        -- Clase de icono
            NULL,                   -- Sin módulo padre (es raíz)
            1,
            1,                      -- Visible
            1,                      -- Activo
            'SYS-DEVELOP',          -- ← Sustituir con el token del DBA que aplica
            GETDATE()
        );
        PRINT '[OK] PASO 2B: Módulo "Reasignación de rutas" creado correctamente.';
    END
    ELSE
    BEGIN
        PRINT '[WARN] PASO 2B: El Módulo ya existe. Se cancela la transacción.';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Capturar ID generado
    DECLARE @NuevoModId INT = SCOPE_IDENTITY();
    PRINT CONCAT('[INFO] PASO 2B: ModIdModule generado → ', CAST(@NuevoModId AS VARCHAR(10)));


    -- ─────────────────────────────────────────────────────────────────────────
    -- 2C. Vincular Rol → Módulo → Sistema en RolByModuleBySystem
    -- ─────────────────────────────────────────────────────────────────────────
    DECLARE @IdSistema INT = 13; -- Hermes Web Operaciones

    IF NOT EXISTS (
        SELECT 1 FROM RolByModuleBySystem
        WHERE RmsIdRol    = @NuevoRolId
          AND RmsIdModule = @NuevoModId
          AND RmsIdSystem = @IdSistema
    )
    BEGIN
        INSERT INTO RolByModuleBySystem (
            RmsIdRol,
            RmsIdModule,
            RmsIdSystem,
            RmsRowStatus,
            RmsTokenCreated,
            RmsDateCreated
        )
        VALUES (
            @NuevoRolId,
            @NuevoModId,
            @IdSistema,
            1,              -- Activo
            'SYS-DEVELOP',  -- ← Sustituir con el token del DBA que aplica
            GETDATE()
        );
        PRINT '[OK] PASO 2C: Vínculo Rol → Módulo → Sistema registrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT '[WARN] PASO 2C: El vínculo ya existe. Se cancela la transacción.';
        ROLLBACK TRANSACTION;
        RETURN;
    END


    -- ─────────────────────────────────────────────────────────────────────────
    -- Confirmar todos los cambios
    -- ─────────────────────────────────────────────────────────────────────────
    COMMIT TRANSACTION;
    PRINT '══════════════════════════════════════════════════════════════════';
    PRINT '[SUCCESS] PASO 2: Todos los cambios fueron aplicados correctamente.';
    PRINT CONCAT('          RolIdRol    → ', CAST(@NuevoRolId  AS VARCHAR(10)));
    PRINT CONCAT('          ModIdModule → ', CAST(@NuevoModId  AS VARCHAR(10)));
    PRINT CONCAT('          Sistema     → ', CAST(@IdSistema   AS VARCHAR(10)));
    PRINT '══════════════════════════════════════════════════════════════════';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '══════════════════════════════════════════════════════════════════';
    PRINT '[ERROR] PASO 2: Se detectó un error. Todos los cambios fueron REVERTIDOS.';
    PRINT CONCAT('  Mensaje   : ', ERROR_MESSAGE());
    PRINT CONCAT('  Línea     : ', CAST(ERROR_LINE()     AS VARCHAR(10)));
    PRINT CONCAT('  Severidad : ', CAST(ERROR_SEVERITY() AS VARCHAR(10)));
    PRINT CONCAT('  Estado    : ', CAST(ERROR_STATE()    AS VARCHAR(10)));
    PRINT '══════════════════════════════════════════════════════════════════';
END CATCH;

GO


-- ═══════════════════════════════════════════════════════════════════════════════════════════════
-- PASO 3 — POST-VALIDACIONES  (Solo lectura | Confirmar integridad de los cambios aplicados)
--
--   Propósito : Verificar que los tres registros fueron insertados correctamente
--               y que el vínculo entre ellos es consistente.
--   Acción    : Ejecutar las tres consultas y confirmar que retornan exactamente 1 fila cada una.
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

-- 3A. Confirmar Rol creado
--     Resultado esperado: 1 fila con RolRowStatus = 1
SELECT
    RolIdRol,
    RolIdSystem,
    RolName,
    RolDescription,
    RolRowStatus,
    RolTokenCreated,
    RolDateCreated
FROM CatRol
WHERE RolName LIKE '%Reasignacion%'
  AND RolIdSystem = 13;

-- 3B. Confirmar Módulo creado
--     Resultado esperado: 1 fila con ModRowStatus = 1
SELECT
    ModIdModule,
    ModName,
    ModPath,
    ModMetadata,
    ModIdModuleParent,
    ModVisible,
    ModRowStatus,
    ModTokenCreated,
    ModDateCreated
FROM CatModule
WHERE ModPath = '/operaciones/reasignacion-rutas';

-- 3C. Confirmar vínculo Rol → Módulo → Sistema (con JOIN para validación visual completa)
--     Resultado esperado: 1 fila mostrando Rol, Módulo y Sistema correctamente enlazados
SELECT
    r.RolIdRol,
    r.RolName,
    m.ModIdModule,
    m.ModName,
    m.ModPath,
    rms.RmsIdSystem,
    rms.RmsRowStatus,
    rms.RmsTokenCreated,
    rms.RmsDateCreated
FROM RolByModuleBySystem rms
INNER JOIN CatRol    r ON r.RolIdRol    = rms.RmsIdRol
INNER JOIN CatModule m ON m.ModIdModule = rms.RmsIdModule
WHERE rms.RmsIdSystem = 13
  AND r.RolName LIKE '%Reasignacion%'
  AND m.ModPath = '/operaciones/reasignacion-rutas';

GO

