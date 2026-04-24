/* =================================================
   SP:        dbo.Support_UpdateContainerName
   Propósito: Actualizar el nombre de un contenedor.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6170
   Fecha:     2026-04-23
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateContainerName
(
    @IdContainer        INT,
    @NewDescription     NVARCHAR(200),
    @TokenUpdated       NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @IdContainer IS NULL
        OR ISNULL(@NewDescription,'') = ''
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

        -- PASO 3: Normalizar longitud
        DECLARE @NormalizedDescription NVARCHAR(200);
        SET @NormalizedDescription = LEFT(@NewDescription, 200);

        -- PASO 4: Capturar valor ANTES
        DECLARE @PrevDescription NVARCHAR(200);

        SELECT 
            @PrevDescription = ContainerDescription
        FROM DeliveryBackOffice.dbo.Container WITH (NOLOCK)
        WHERE IdContainer = @IdContainer;

        -- PASO 5: Validar si ya tiene el mismo valor
        IF @PrevDescription = @NormalizedDescription
        BEGIN
            SELECT
                'Error' AS Estado,
                'El contenedor ya cuenta con la misma descripción.' AS Mensaje,
                @PrevDescription AS DescripcionActual;
            RETURN;
        END

        -- PASO 6: UPDATE
        UPDATE DeliveryBackOffice.dbo.Container
        SET 
            ContainerDescription = @NormalizedDescription,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = GETDATE()
        WHERE IdContainer = @IdContainer;

        -- PASO 7: Resultado final (ANTES / DESPUÉS)
        SELECT
            'Exito' AS Estado,
            'El contenedor fue actualizado correctamente.' AS Mensaje,
            @IdContainer AS IdContainer,

            -- Antes
            @PrevDescription AS Descripcion_Anterior,

            -- Después
            @NormalizedDescription AS Descripcion_Nueva;

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