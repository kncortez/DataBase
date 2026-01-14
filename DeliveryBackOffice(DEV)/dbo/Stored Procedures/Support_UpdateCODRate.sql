/* =================================================
   SP:        dbo.Support_UpdateCODRate
   Propósito: Modificar porcentaje COD.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5095
   Fecha:     2025-11-21
============================================
=== CHANGELOG ================================
2025-11-21 | Historia: FDAPI-5095 | Autor: IRVIN GONZALEZ |
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateCODRate
    @RateId INT,
    @NewCODRate DECIMAL(10,2),
    @TokenUpdated VARCHAR(100),
    @DateUpdated DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        
        -- PASO 1: Validar existencia de RateHeader
        
        IF NOT EXISTS (
            SELECT TOP 1
            FROM DeliveryBackOffice.dbo.RateHeader WITH (NOLOCK)
            WHERE RHEId = @RateId
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'El RateHeader consultado no existe. No se aplicó el cambio.' AS Mensaje,
                @RateId AS RateId;
            RETURN;
        END

        
        -- PASO 2: Consultar valor actual de CODRate
        
        SELECT TOP 10
            crs.CrsName,
            rco.RateId,
            rco.CODRate AS PorcentajeCODAnterior
        FROM DeliveryBackOffice.dbo.RateCOD rco WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.CatRateSegment crs WITH (NOLOCK) 
            ON crs.CrsId = rco.TypeSegmentId
        WHERE rco.RateId = @RateId
        ORDER BY rco.DateCreated DESC;

        
        -- PASO 3: Aplicar UPDATE del CODRate
        
        UPDATE DeliveryBackOffice.dbo.RateCOD
        SET 
            CODRate = @NewCODRate,
            TokenUpdated = @TokenUpdated,
            DateUpdated = @DateUpdated
        WHERE RateId = @RateId;

        
        -- PASO 4: Mostrar valor actualizado
        
        SELECT TOP 10
            crs.CrsName,
            rco.RateId,
            rco.CODRate AS PorcentajeCODActualizado
        FROM DeliveryBackOffice.dbo.RateCOD rco WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.CatRateSegment crs WITH (NOLOCK) 
            ON crs.CrsId = rco.TypeSegmentId
        WHERE rco.RateId = @RateId
        ORDER BY rco.DateUpdated DESC;

    END TRY

    BEGIN CATCH
        SELECT 
            'Error' AS Estado,
            'Ocurrió un error durante la ejecución del procedimiento.' AS Mensaje,
            ERROR_NUMBER() AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE() AS ErrorLinea;
            
        THROW;

    END CATCH
END
GO

/*
================================================================================
EJEMPLO DE EJECUCIÓN
================================================================================
EXEC dbo.Support_UpdateCODRate
     @RateId = 5309,
     @NewCODRate = 2.00,
     @TokenUpdated = 'SYS-IGONZALEZ',
     @DateUpdated = GETDATE();
================================================================================
*/