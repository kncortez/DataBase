/* =================================================
   SP:        dbo.Support_CheckGuideInsurance
   Propósito: Validar si una guía cuenta con seguro y retornar su monto asegurado.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5209
   Fecha:     2025-10-16
============================================
=== CHANGELOG ============================
2025-10-16 | Historia/épica: FDAPI-5209 | Autor: IRVIN GONZALEZ |

=========================================== */

CREATE PROCEDURE dbo.Support_CheckGuideInsurance
    @GuideNumber INT,
    @GuideSerie  VARCHAR(10) = 'FD'
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validar existencia de la guía

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Number = @GuideNumber
              AND Guide_Serie  = @GuideSerie
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'La guía no existe.' AS Mensaje,
                @GuideSerie + CAST(@GuideNumber AS VARCHAR(20)) AS Guia;
            RETURN;
        END

        -- PASO 2: Obtener datos del seguro

        DECLARE
            @IsInsurance BIT,
            @InsuranceAmount DECIMAL(10,2);

        SELECT TOP 1
            @IsInsurance     = IsInsuarance,
            @InsuranceAmount = InsuranceAmount
        FROM dbo.DeliveryOrder WITH (NOLOCK)
        WHERE Guide_Number = @GuideNumber
          AND Guide_Serie  = @GuideSerie;

        -- PASO 3: Respuesta según estado del seguro

        IF @IsInsurance = 0
        BEGIN
            SELECT
                @GuideSerie + CAST(@GuideNumber AS VARCHAR(20)) AS Guia,
                'Sin Seguro' AS Estado,
                'La guía no cuenta con seguro.' AS Mensaje,
                @InsuranceAmount AS MontoAsegurado;
            RETURN;
        END
        ELSE
        BEGIN
            SELECT
                @GuideSerie + CAST(@GuideNumber AS VARCHAR(20)) AS Guia,
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
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;

        THROW;

    END CATCH
END
GO

/*
================================================================================
EJEMPLO DE EJECUCIÓN
================================================================================
EXEC dbo.Support_CheckGuideInsurance
     @GuideNumber = 12345678,
     @GuideSerie  = 'FD';
================================================================================
*/
