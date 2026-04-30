/* =================================================
   SP:        dbo.Support_UpdatePersonStatus
   Propósito: Activar o desactivar una persona mediante PerRowStatus.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6214
   Fecha:     2026-04-29
=========================================== */

CREATE PROCEDURE dbo.Support_UpdatePersonStatus
(
    @PerIdPerson   BIGINT,
    @PerRowStatus  BIT,         
    @TokenUpdated  NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @PerIdPerson IS NULL
        OR @PerRowStatus IS NULL
        OR ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar existencia
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.Person WITH (NOLOCK)
            WHERE PerIdPerson = @PerIdPerson
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'La persona no existe.' AS Mensaje,
                @PerIdPerson AS PerIdPerson;
            RETURN;
        END

        -- PASO 3: Capturar estado ANTES
        DECLARE @PrevStatus BIT;

        SELECT 
            @PrevStatus = PerRowStatus
        FROM DeliveryBackOffice.dbo.Person WITH (NOLOCK)
        WHERE PerIdPerson = @PerIdPerson;

        -- PASO 4: Validar si ya tiene el mismo estado
        IF @PrevStatus = @PerRowStatus
        BEGIN
            SELECT
                'Error' AS Estado,
                'La persona ya cuenta con el estado solicitado.' AS Mensaje,
                @PerIdPerson AS PerIdPerson,
                @PrevStatus AS EstadoActual;
            RETURN;
        END

        -- PASO 5: UPDATE
        UPDATE DeliveryBackOffice.dbo.Person
        SET 
            PerRowStatus   = @PerRowStatus,
            PerTokenUpdated = @TokenUpdated,
            PerDateUpdated  = GETDATE()
        WHERE PerIdPerson = @PerIdPerson;

        -- PASO 6: Resultado final (ANTES / DESPUÉS)
        SELECT
            'Exito' AS Estado,
            'El estado de la persona fue actualizado correctamente.' AS Mensaje,
            @PerIdPerson AS PerIdPerson,

            -- Antes
            @PrevStatus AS Estado_ANTES,

            -- Después
            @PerRowStatus AS Estado_DESPUES,

            CASE 
                WHEN @PerRowStatus = 1 THEN 'ACTIVO'
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