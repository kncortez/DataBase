/* =================================================
   SP:        dbo.Support_UpdateSettlementName
   Propósito: Cambio de nombre a poblado.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5321
   Fecha:     2026-01-02
============================================
=== CHANGELOG ================================

=========================================== */

CREATE PROCEDURE dbo.Support_UpdateSettlementName
(
    @IdSettlement     INT,
    @NewSettlement    NVARCHAR(100),
    @TokenUpdated     NVARCHAR(100),
    @DateUpdated      DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validar existencia del IdSettlement
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.Settlement WITH (NOLOCK)
            WHERE IdSettlement = @IdSettlement
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El IdSettlement especificado no existe.' AS Mensaje,
                @IdSettlement AS IdSettlement;
            RETURN;
        END

        -- PASO 2: Capturar valor actual (ANTES)
        DECLARE @OldSettlement NVARCHAR(100);

        SELECT 
            @OldSettlement = Settlement
        FROM DeliveryBackOffice.dbo.Settlement WITH (NOLOCK)
        WHERE IdSettlement = @IdSettlement;

        -- PASO 3: Validar si el nombre ya es el mismo
        IF @OldSettlement = @NewSettlement
        BEGIN
            SELECT
                'Sin Acción' AS Estado,
                'El nombre del poblado ya coincide con el valor proporcionado.' AS Mensaje,
                @IdSettlement AS IdSettlement,
                @OldSettlement AS SettlementActual;
            RETURN;
        END

        -- PASO 4: Ejecutar UPDATE
        UPDATE DeliveryBackOffice.dbo.Settlement
        SET 
            Settlement   = @NewSettlement,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = @DateUpdated
        WHERE IdSettlement = @IdSettlement;

        -- PASO 5: Respuesta final (ANTES / DESPUÉS)
        SELECT
            'Éxito' AS Estado,
            'El nombre del poblado fue actualizado correctamente.' AS Mensaje,
            @IdSettlement AS IdSettlement,
            @OldSettlement AS Settlement_Anterior,
            @NewSettlement AS Settlement_Nuevo,
            @TokenUpdated AS UsuarioActualizacion,
            @DateUpdated AS FechaActualizacion;

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
