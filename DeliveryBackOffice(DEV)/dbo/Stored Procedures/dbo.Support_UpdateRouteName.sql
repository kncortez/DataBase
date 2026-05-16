/* =================================================
   SP:        dbo.Support_UpdateRouteName
   Propósito: Actualizar el nombre y descripción de una ruta.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6303
   Fecha:     2026-05-16
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateRouteName
(
    @IdRoute       INT,
    @RouteName     NVARCHAR(100),
    @TokenUpdated  NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @IdRoute IS NULL
        OR ISNULL(@RouteName,'') = ''
        OR ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT 
                'Error' AS Estado,
                'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar existencia de la ruta
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatRoute WITH (NOLOCK)
            WHERE IdRoute = @IdRoute
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'La ruta indicada no existe.' AS Mensaje,
                @IdRoute AS IdRoute;
            RETURN;
        END

        -- PASO 3: Capturar valores anteriores
        DECLARE
            @PrevCodeRoute NVARCHAR(100),
            @PrevDescription NVARCHAR(200);

        SELECT
            @PrevCodeRoute = CodeRoute,
            @PrevDescription = [Description]
        FROM DeliveryBackOffice.dbo.CatRoute WITH (NOLOCK)
        WHERE IdRoute = @IdRoute;

        -- PASO 4: Validar si el nombre ya existe
        IF EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatRoute WITH (NOLOCK)
            WHERE CodeRoute = @RouteName
            AND IdRoute <> @IdRoute
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'Ya existe otra ruta con el mismo nombre.' AS Mensaje,
                @RouteName AS RouteName;
            RETURN;
        END

        -- PASO 5: Actualizar ruta
        UPDATE DeliveryBackOffice.dbo.CatRoute
        SET
            CodeRoute = @RouteName,
            [Description] = @RouteName,
            TokenUpdated = @TokenUpdated,
            DateUpdated = GETDATE()
        WHERE IdRoute = @IdRoute;

        -- PASO 6: Resultado final
        SELECT
            'Exito' AS Estado,
            'La ruta fue actualizada correctamente.' AS Mensaje,
            @IdRoute AS IdRoute,

            -- Antes
            @PrevCodeRoute AS CodeRoute_Anterior,
            @PrevDescription AS Description_Anterior,

            -- Después
            @RouteName AS CodeRoute_Nuevo,
            @RouteName AS Description_Nuevo,

            @TokenUpdated AS TokenUpdated,
            GETDATE() AS DateUpdated;

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