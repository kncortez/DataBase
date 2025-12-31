/*
================================================================================
FECHA DE CREACIÓN: 2025-10-16
AUTOR: IGONZALEZ
================================================================================
*/

CREATE PROCEDURE dbo.Support_CheckGuideInsurance
    @GuideNumber INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        
        -- PASO 1: Validar existencia de la guía
        
        IF NOT EXISTS (
            SELECT TOP 1
            FROM dbo.DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Number = @GuideNumber
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'La guía no existe.' AS Mensaje,
                @GuideNumber AS Guia;
            RETURN;
        END

        
        -- PASO 2: Obtener datos del seguro
        
        DECLARE 
            @IsInsurance BIT,
            @InsuranceAmount DECIMAL(10,2);

        SELECT TOP 1
            @IsInsurance = IsInsurance,
            @InsuranceAmount = InsuranceAmount
        FROM dbo.DeliveryOrder WITH (NOLOCK)
        WHERE Guide_Number = @GuideNumber;

        
        -- PASO 3: Respuesta según estado del seguro
        
        IF @IsInsurance = 0
        BEGIN
            SELECT
                @GuideNumber AS Guia,
                'Sin Seguro' AS Estado,
                'La guía no cuenta con seguro.' AS Mensaje,
                @InsuranceAmount AS MontoAsegurado;
            RETURN;
        END
        ELSE
        BEGIN
            SELECT
                @GuideNumber AS Guia,
                'Asegurada' AS Estado,
                'La guía se encuentra asegurada por un monto de:' AS Mensaje,
                @InsuranceAmount AS MontoAsegurado;
            RETURN;
        END

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
Ejemplo de ejecución
================================================================================
EXEC dbo.Support_CheckGuideInsurance
     @GuideNumber = 12345678;

================================================================================
HISTORIAL DE CAMBIOS:
    - 2025-10-16: Primera versión documentada.
================================================================================
*/
