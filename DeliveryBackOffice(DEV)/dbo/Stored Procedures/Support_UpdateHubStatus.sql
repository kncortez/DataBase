/* =================================================
   SP:        dbo.Support_UpdateHubStatus
   Propósito: Activar o desactivar un hub mediante HubStatus.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6271
   Fecha:     2026-05-08
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateHubStatus
(
    @IdHubLogistic INT,
    @HubStatus     BIT,          -- 1 = Activo, 0 = Inactivo
    @TokenUpdated  NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @IdHubLogistic IS NULL
        OR @HubStatus IS NULL
        OR ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT 
                'Error' AS Estado,
                'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar existencia
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.HubLogistics WITH (NOLOCK)
            WHERE IdHubLogistic = @IdHubLogistic
        )
        BEGIN
            SELECT
                'Error' AS Estado,
                'El hub logístico no existe.' AS Mensaje,
                @IdHubLogistic AS IdHubLogistic;
            RETURN;
        END

        -- PASO 3: Capturar estado ANTES
        DECLARE @PrevHubStatus BIT;

        SELECT 
            @PrevHubStatus = HubStatus
        FROM DeliveryBackOffice.dbo.HubLogistics WITH (NOLOCK)
        WHERE IdHubLogistic = @IdHubLogistic;

        -- PASO 4: Validar si ya tiene el mismo estado
        IF @PrevHubStatus = @HubStatus
        BEGIN
            SELECT
                'Error' AS Estado,
                'El hub ya cuenta con el estado solicitado.' AS Mensaje,
                @IdHubLogistic AS IdHubLogistic,
                @PrevHubStatus AS EstadoActual;
            RETURN;
        END

        -- PASO 5: UPDATE
        UPDATE DeliveryBackOffice.dbo.HubLogistics
        SET 
            HubStatus    = @HubStatus,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = GETDATE()
        WHERE IdHubLogistic = @IdHubLogistic;

        -- PASO 6: Resultado final (ANTES / DESPUÉS)
        SELECT
            'Exito' AS Estado,
            'El estado del hub fue actualizado correctamente.' AS Mensaje,
            @IdHubLogistic AS IdHubLogistic,
            @PrevHubStatus AS HubStatus_ANTES,
            @HubStatus AS HubStatus_DESPUES,

            CASE 
                WHEN @HubStatus = 1 THEN 'ACTIVO'
                ELSE 'INACTIVO'
            END AS EstadoDescripcion;

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