/* =================================================
   SP:        dbo.Support_UpdateRouteStatus
   Propósito: Activar o desactivar una ruta mediante su RowStatus.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6041
   Fecha:     2026-04-10
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateRouteStatus
(
    @IdRoute      INT,
    @RowStatus    BIT,       
    @TokenUpdated NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- VALIDACIONES
        IF @IdRoute IS NULL 
        OR @RowStatus IS NULL
        OR ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- VALIDAR EXISTENCIA
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatRoute WITH(NOLOCK)
            WHERE IdRoute = @IdRoute
        )
        BEGIN
            SELECT 'Error' AS Estado, 'La ruta no existe.' AS Mensaje;
            RETURN;
        END

        -- CAPTURA ANTES
        DECLARE @PrevRowStatus BIT;

        SELECT @PrevRowStatus = RowStatus
        FROM DeliveryBackOffice.dbo.CatRoute WITH(NOLOCK)
        WHERE IdRoute = @IdRoute;

        -- VALIDACIÓN: EVITAR UPDATE REDUNDANTE
        IF @PrevRowStatus = @RowStatus
        BEGIN
            SELECT 
                'Info' AS Estado,
                @IdRoute AS IdRoute,
                @PrevRowStatus AS RowStatus_ACTUAL,
                CASE 
                    WHEN @RowStatus = 1 THEN 'La ruta ya se encuentra ACTIVA.'
                    ELSE 'La ruta ya se encuentra INACTIVA.'
                END AS Mensaje;
            RETURN;
        END

        -- UPDATE
        UPDATE DeliveryBackOffice.dbo.CatRoute
        SET 
            RowStatus    = @RowStatus,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = GETDATE()
        WHERE IdRoute = @IdRoute;

        -- RESULTADO FINAL
        SELECT
            'Exito' AS Estado,
            @IdRoute AS IdRoute,
            @PrevRowStatus AS RowStatus_ANTES,
            @RowStatus     AS RowStatus_DESPUES,
            CASE WHEN @RowStatus = 1 THEN 'ACTIVA' ELSE 'INACTIVA' END AS EstadoRuta;

    END TRY
    BEGIN CATCH

        SELECT 
            'Error' AS Estado,
            ERROR_NUMBER()  AS ErrorNumero,
            ERROR_MESSAGE() AS ErrorDescripcion,
            ERROR_LINE()    AS ErrorLinea;

        THROW;

    END CATCH

END
GO