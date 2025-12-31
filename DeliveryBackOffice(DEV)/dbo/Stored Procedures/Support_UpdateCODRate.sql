/*
================================================================================
FECHA DE CREACIÓN: 2025-11-21
AUTOR: IGONZALEZ
================================================================================
*/

CREATE PROCEDURE dbo.Support_UpdateCODRate
    @RateId INT,
    @NewCODRate DECIMAL(10,2),
    @TokenUpdated VARCHAR(50),
    @DateUpdated DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        
        -- PASO 1: Validar existencia de RateHeader
        
        IF NOT EXISTS (
            SELECT TOP 1
            FROM dbo.RateHeader WITH (NOLOCK)
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
        FROM dbo.RateCOD rco WITH (NOLOCK)
        LEFT JOIN dbo.CatRateSegment crs WITH (NOLOCK) 
            ON crs.CrsId = rco.TypeSegmentId
        WHERE rco.RateId = @RateId
        ORDER BY rco.DateCreated DESC;

        
        -- PASO 3: Aplicar UPDATE del CODRate
        
        UPDATE dbo.RateCOD
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
        FROM dbo.RateCOD rco WITH (NOLOCK)
        LEFT JOIN dbo.CatRateSegment crs WITH (NOLOCK) 
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
HISTORIAL DE CAMBIOS:
    - 2025-11-21: Primera versión documentada y parametrizada.
================================================================================
*/