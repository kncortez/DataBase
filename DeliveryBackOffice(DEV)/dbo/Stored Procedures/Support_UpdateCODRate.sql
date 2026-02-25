/* =================================================
   SP:        dbo.Support_UpdateCODRate
   Propósito: Modificar porcentaje COD.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5095
   Fecha:     2025-11-21
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateCODRate
    @IdRateCOD     INT,
    @NewCODRate    DECIMAL(12,2),
    @TokenUpdated  NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- PASO 1: Validar existencia de RateCOD

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.RateCOD WITH (NOLOCK)
            WHERE IdRateCOD = @IdRateCOD
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'El IdRateCOD consultado no existe. No se aplicó el cambio.' AS Mensaje,
                @IdRateCOD AS IdRateCOD;
            RETURN;
        END


        -- PASO 2: Consultar valor actual de CODRate

        SELECT
            crs.CrsName,
            rco.IdRateCOD,
            rco.CODRate AS PorcentajeCODAnterior
        FROM DeliveryBackOffice.dbo.RateCOD rco WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.CatRateSegment crs WITH (NOLOCK) 
            ON crs.CrsId = rco.TypeSegmentId
        WHERE rco.IdRateCOD = @IdRateCOD;


        -- PASO 3: Aplicar UPDATE del CODRate

        UPDATE DeliveryBackOffice.dbo.RateCOD
        SET 
            CODRate      = @NewCODRate,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = GETDATE()
        WHERE IdRateCOD = @IdRateCOD;


        -- PASO 4: Mostrar valor actualizado

        SELECT 
            crs.CrsName,
            rco.IdRateCOD,
            rco.CODRate AS PorcentajeCODActualizado
        FROM DeliveryBackOffice.dbo.RateCOD rco WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.CatRateSegment crs WITH (NOLOCK) 
            ON crs.CrsId = rco.TypeSegmentId
        WHERE rco.IdRateCOD = @IdRateCOD;

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
