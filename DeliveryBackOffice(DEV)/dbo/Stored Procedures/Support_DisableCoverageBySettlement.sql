/* =================================================
   SP:        dbo.Support_DisableCoverageBySettlement
   Propósito: Deshabilitar la cobertura de un poblado y su relación asociada.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5240
   Fecha:     2025-12-04
=========================================== */

CREATE PROCEDURE dbo.Support_DisableCoverageBySettlement
(
    @IdSettlement INT,
    @TokenUpdated NVARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validar existencia del Settlement

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Settlement WITH (NOLOCK)
            WHERE IdSettlement = @IdSettlement
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El poblado no existe.' AS Mensaje,
                @IdSettlement AS IdSettlement;
            RETURN;
        END

        -- PASO 2: Validar relación existente en DumpServiceCoverage

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.DumpServiceCoverage WITH (NOLOCK)
            WHERE IdSettlement = @IdSettlement
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'No existe relación con DumpServiceCoverage.' AS Mensaje,
                @IdSettlement AS IdSettlement;
            RETURN;
        END

        -- PASO 3: Aplicar el bloqueo en Settlement

        UPDATE dbo.Settlement
        SET
            SettlementSatus = 0,
            TokenUpdated    = @TokenUpdated,
            DateUpdated     = GETDATE()
        WHERE IdSettlement = @IdSettlement;

        -- PASO 4: Aplicar el bloqueo en DumpServiceCoverage

        UPDATE dbo.DumpServiceCoverage
        SET
            RowStatus    = 0,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = GETDATE()
        WHERE IdSettlement = @IdSettlement;

        -- PASO 5: Mensaje final de éxito

        SELECT
            'Éxito' AS Estado,
            'El bloqueo de cobertura fue efectuado con éxito.' AS Mensaje,
            @IdSettlement AS IdSettlement;

    END TRY
    BEGIN CATCH

        SELECT
            'Error' AS Estado,
            'Ocurrió un error durante la ejecución del procedimiento.' AS Mensaje,
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;

        THROW;

    END CATCH
END
GO