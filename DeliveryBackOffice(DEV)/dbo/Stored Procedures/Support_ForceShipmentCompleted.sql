/* =================================================
   SP:        dbo.Support_ForceShipmentCompleted
   Propósito: Forzar ShipmentCompleted=1 en guías pagadas que no permiten descarga.
   Autor:     IGONZALEZ
   Historia:  FDAPI-5320
   Fecha:     2026-01-03
============================================
=== CHANGELOG ================================
2026-01-03 | Historia/épica: FDAPI-5320 | Autor: IGONZALEZ |

=========================================== */

CREATE PROCEDURE dbo.Support_ForceShipmentCompleted
(
    @GuideSerie   NVARCHAR(10),
    @GuideNumber  INT,
    @TokenUpdated NVARCHAR(50),
    @DateUpdated  DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- PASO 1: Validar existencia del registro

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail WITH (NOLOCK)
            WHERE GuideSerie  = @GuideSerie
              AND GuideNumber = @GuideNumber
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'La guía no existe en DeliveryOrderPaymentDetail.' AS Mensaje,
                @GuideSerie AS GuideSerie,
                @GuideNumber AS GuideNumber;
            RETURN;
        END


        -- PASO 2: Capturar estado actual (ANTES)

        DECLARE @PrevShipmentCompleted BIT;

        SELECT 
            @PrevShipmentCompleted = ShipmentCompleted
        FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail WITH (NOLOCK)
        WHERE GuideSerie  = @GuideSerie
          AND GuideNumber = @GuideNumber;


        -- PASO 3: Validar si ya se encuentra completada

        IF @PrevShipmentCompleted = 1
        BEGIN
            SELECT
                'Sin Acción' AS Estado,
                'La guía ya se encuentra marcada como completada.' AS Mensaje,
                @GuideSerie AS GuideSerie,
                @GuideNumber AS GuideNumber,
                @PrevShipmentCompleted AS ShipmentCompleted_Actual;
            RETURN;
        END


        -- PASO 4: Ejecutar UPDATE

        UPDATE DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail
        SET 
            ShipmentCompleted = 1,
            TokenUpdated      = @TokenUpdated,
            DateUpdated       = @DateUpdated
        WHERE GuideSerie  = @GuideSerie
          AND GuideNumber = @GuideNumber;


        -- PASO 5: Respuesta final (ANTES / DESPUÉS)

        SELECT
            'Éxito' AS Estado,
            'La guía fue habilitada correctamente.' AS Mensaje,
            @GuideSerie AS GuideSerie,
            @GuideNumber AS GuideNumber,
            @PrevShipmentCompleted AS ShipmentCompleted_Anterior,
            1 AS ShipmentCompleted_Nuevo,
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