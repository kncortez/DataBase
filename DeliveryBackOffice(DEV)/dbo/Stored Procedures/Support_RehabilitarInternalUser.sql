/* =================================================
   SP:        dbo.Support_RehabilitarInternalUser
   Propósito: Rehabilitar una ficha corrigiendo el IdUser.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5353
   Fecha:     2026-01-10
============================================
=== CHANGELOG ================================

=========================================== */
CREATE PROCEDURE dbo.Support_RehabilitarInternalUser
(
    @IdUserActual INT,  
    @IdUserNuevo INT,     
    @TokenUpdated NVARCHAR(100),
    @DateUpdated DATETIME,
    @Comment NVARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @IdUserActual IS NULL OR @IdUserNuevo IS NULL
        BEGIN
            SELECT
                'Error' AS Estado,
                'Ambos valores de IdUser son obligatorios.' AS Mensaje;
            RETURN;
        END

        IF @IdUserActual = @IdUserNuevo
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
            WHERE IdUser = @IdUserNuevo
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdUser correcto ya existe y no puede ser reutilizado.' AS Mensaje,
                @IdUserNuevo AS IdUser;
            RETURN;
        END

        -- PASO 4: Actualización del IdUser
        UPDATE DeliveryBackOffice.dbo.InternalUser
        SET 
            IdUser = @IdUserNuevo,
            TokenUpdated = @TokenUpdated,
            DateUpdated = @DateUpdated,
            Comment = @Comment
        WHERE IdUser = @IdUserActual;

        -- PASO 5: Respuesta final
        SELECT
            'Exito' AS Estado,
            'La ficha fue rehabilitada correctamente.' AS Mensaje,
            @IdUserActual   AS IdUserAnterior,
            @IdUserNuevo AS IdUserActualizado;

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