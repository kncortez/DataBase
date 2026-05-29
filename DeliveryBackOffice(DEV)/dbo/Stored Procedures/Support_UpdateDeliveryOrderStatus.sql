/* =================================================
   SP:        DeliveryBackOffice.dbo.Support_UpdateDeliveryOrderStatus
   Propósito: Actualizar el estado de una guía cuando no permite liquidación.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5529
   Fecha:     2026-02-06
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateDeliveryOrderStatus
(
    @GuideNumber     INT,
    @NewStatusOrderId TINYINT,
    @TokenUpdated    NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @GuideNumber IS NULL
        BEGIN
            SELECT 'Error' AS Estado, 'GuideNumber es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF @NewStatusOrderId IS NULL
        BEGIN
            SELECT 'Error' AS Estado, 'NewStatusOrderId es obligatorio.' AS Mensaje;
            RETURN;
        END

        IF @TokenUpdated IS NULL
        BEGIN
            SELECT 'Error' AS Estado, 'TokenUpdated es obligatorio.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar existencia de la guía (Guide_Serie = 'FD')

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Serie = 'FD'
              AND Guide_Number = @GuideNumber
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'La guía no existe con la serie FD.' AS Mensaje,
                @GuideNumber AS GuideNumber;
            RETURN;
        END

        -- PASO 3: Capturar estado ANTES
        DECLARE @PrevStatusOrderId TINYINT;

        SELECT 
            @PrevStatusOrderId = StatusOrderId
        FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
        WHERE Guide_Serie = 'FD'
          AND Guide_Number = @GuideNumber;

        -- PASO 4: Actualizar estado
        UPDATE DeliveryBackOffice.dbo.DeliveryOrder
        SET 
            StatusOrderId = @NewStatusOrderId,
            TokenUpdated  = @TokenUpdated,
            DateUpdated   = GETDATE()
        WHERE Guide_Serie = 'FD'
          AND Guide_Number = @GuideNumber;

        -- PASO 5: Respuesta final (ANTES / DESPUÉS)
        SELECT
            'Exito' AS Estado,
            'El estado de la guía fue actualizado correctamente.' AS Mensaje,
            'FD' AS GuideSerie,
            @GuideNumber AS GuideNumber,
            @PrevStatusOrderId AS StatusOrderId_Anterior,
            @NewStatusOrderId AS StatusOrderId_Actual;

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