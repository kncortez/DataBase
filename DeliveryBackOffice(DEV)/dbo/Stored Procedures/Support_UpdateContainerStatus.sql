/* =================================================
   SP:        dbo.Support_UpdateContainerStatus
   Propósito: Activar o desactivar un contenedor.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6171
   Fecha:     2026-04-23
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateContainerStatus
(
    @IdContainer  INT,
    @RowStatus    BIT,          -- 1 = Activo, 0 = Inactivo
    @TokenUpdated NVARCHAR(50),
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @IdContainer IS NULL
        OR @RowStatus IS NULL
        OR ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar existencia
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.Container WITH (NOLOCK)
            WHERE IdContainer = @IdContainer
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'El contenedor no existe.' AS Mensaje,
                @IdContainer AS IdContainer;
            RETURN;
        END

        -- PASO 3: Capturar valor actual
        DECLARE @PrevRowStatus BIT;

        SELECT 
            @PrevRowStatus = RowStatus
        FROM DeliveryBackOffice.dbo.Container WITH (NOLOCK)
        WHERE IdContainer = @IdContainer;

        -- PASO 4: Validar si ya tiene el mismo estado
        IF @PrevRowStatus = @RowStatus
        BEGIN
            SELECT
                'Error' AS Estado,
                'El contenedor ya cuenta con el estado solicitado.' AS Mensaje,
                @IdContainer AS IdContainer,
                @PrevRowStatus AS RowStatusActual;
            RETURN;
        END

        -- PASO 5: UPDATE
        UPDATE DeliveryBackOffice.dbo.Container
        SET 
            RowStatus    = @RowStatus,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = GETDATE()
        WHERE IdContainer = @IdContainer;

        -- PASO 6: Resultado final (ANTES / DESPUÉS)
        SELECT
            'Exito' AS Estado,
            'El estado del contenedor fue actualizado correctamente.' AS Mensaje,
            @IdContainer AS IdContainer,

            -- Antes
            @PrevRowStatus AS RowStatus_ANTES,

            -- Después
            @RowStatus AS RowStatus_DESPUES,

            CASE 
                WHEN @RowStatus = 1 THEN 'ACTIVO'
                ELSE 'INACTIVO'
            END AS EstadoContenedor;

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