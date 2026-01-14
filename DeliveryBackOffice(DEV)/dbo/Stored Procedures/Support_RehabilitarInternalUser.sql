/* =================================================
   SP:        dbo.Support_RehabilitarInternalUser
   Propósito: Rehabilitar una ficha corrigiendo el IdUser.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5353
   Fecha:     2026-01-10
============================================
=== CHANGELOG ================================
2026-01-10 | Historia: FDAPI-5353 | Autor: IRVIN GONZALEZ |
=========================================== */

CREATE PROCEDURE dbo.Support_RehabilitarInternalUser
(
    @IdUserActual   INT,    -- IdUser actualmente incorrecto
    @IdUserCorrecto INT     -- IdUser correcto a asignar
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @IdUserActual IS NULL OR @IdUserCorrecto IS NULL
        BEGIN
            SELECT
                'Error' AS Estado,
                'Ambos valores de IdUser son obligatorios.' AS Mensaje;
            RETURN;
        END

        IF @IdUserActual = @IdUserCorrecto
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdUser actual y el IdUser correcto no pueden ser iguales.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar existencia del IdUser actual
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.InternalUser WITH (NOLOCK)
            WHERE IdUser = @IdUserActual
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdUser actual no existe.' AS Mensaje,
                @IdUserActual AS IdUser;
            RETURN;
        END

        -- PASO 3: Validar no existencia previa del IdUser correcto
        IF EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.InternalUser WITH (NOLOCK)
            WHERE IdUser = @IdUserCorrecto
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdUser correcto ya existe y no puede ser reutilizado.' AS Mensaje,
                @IdUserCorrecto AS IdUser;
            RETURN;
        END

        -- PASO 4: Actualización del IdUser
        UPDATE DeliveryBackOffice.dbo.InternalUser
        SET IdUser = @IdUserCorrecto
        WHERE IdUser = @IdUserActual;

        -- PASO 5: Respuesta final
        SELECT
            'Exito' AS Estado,
            'La ficha fue rehabilitada correctamente.' AS Mensaje,
            @IdUserActual   AS IdUserAnterior,
            @IdUserCorrecto AS IdUserActualizado;

    END TRY


    BEGIN CATCH

        SELECT 
            'Error' AS Estado,
            'Ocurrio un error durante la ejecucion del procedimiento.' AS Mensaje,
            ERROR_NUMBER() AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE() AS ErrorLinea;

        THROW;

    END CATCH

END
GO


/* =================================================
EJEMPLO DE EJECUCIÓN
====================================================
EXEC dbo.Support_RehabilitarInternalUser
     @IdUserActual   = 180144,
     @IdUserCorrecto = 00180144;
==================================================== */
