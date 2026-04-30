/* =================================================
   SP:        dbo.Support_UpdatePersonName
   Propósito: Actualizar el nombre (PerFirstName) de una persona.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6210
   Fecha:     2026-04-29
=========================================== */

CREATE PROCEDURE dbo.Support_UpdatePersonName
(
    @PerIdPerson     BIGINT,
    @NewFirstName    NVARCHAR(100),
    @TokenUpdated    NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @PerIdPerson IS NULL
        OR ISNULL(@NewFirstName,'') = ''
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

        -- PASO 3: Normalizar longitud
        DECLARE @NormalizedName NVARCHAR(100);
        SET @NormalizedName = LEFT(@NewFirstName, 100);

        -- PASO 4: Capturar valor ANTES
        DECLARE @PrevName NVARCHAR(100);

        SELECT 
            @PrevName = PerFirstName
        FROM DeliveryBackOffice.dbo.Person WITH (NOLOCK)
        WHERE PerIdPerson = @PerIdPerson;

        -- PASO 5: Validar si ya tiene el mismo valor
        IF @PrevName = @NormalizedName
        BEGIN
            SELECT
                'Error' AS Estado,
                'El nombre ya se encuentra con el mismo valor.' AS Mensaje,
                @PrevName AS NombreActual;
            RETURN;
        END

        -- PASO 6: UPDATE
        UPDATE DeliveryBackOffice.dbo.Person
        SET 
            PerFirstName   = @NormalizedName,
            PerTokenUpdated = @TokenUpdated,
            PerDateUpdated  = GETDATE()
        WHERE PerIdPerson = @PerIdPerson;

        -- PASO 7: Resultado final (ANTES / DESPUÉS)
        SELECT
            'Exito' AS Estado,
            'El nombre de la persona fue actualizado correctamente.' AS Mensaje,
            @PerIdPerson AS PerIdPerson,

            -- Antes
            @PrevName AS Nombre_Anterior,

            -- Después
            @NormalizedName AS Nombre_Nuevo;

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