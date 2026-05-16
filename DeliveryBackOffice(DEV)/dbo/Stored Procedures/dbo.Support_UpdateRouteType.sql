/* =================================================
   SP:        dbo.Support_UpdateRouteType
   Propósito: Actualizar el tipo de una ruta validando los tipos permitidos.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6302
   Fecha:     2026-05-16
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateRouteType
(
    @IdRoute       INT,
    @IdTypeRoute   INT,
    @TokenUpdated  NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- PASO 1: Validaciones básicas
        IF @IdRoute IS NULL
        OR @IdTypeRoute IS NULL
        OR ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT 
                'Error' AS Estado,
                'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- PASO 2: Validar tipos permitidos
        IF @IdTypeRoute NOT IN (1,2,3,4,5)
        BEGIN
            SELECT 
                'Error' AS Estado,
                'El IdTypeRoute ingresado no es válido. Valores permitidos: 1,2,3,4,5.' AS Mensaje,
                @IdTypeRoute AS IdTypeRoute;
            RETURN;
        END

        -- PASO 3: Validar existencia de la ruta
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

        -- PASO 4: Validar existencia del tipo de ruta
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatTypeRoute WITH (NOLOCK)
            WHERE IdTypeRoute = @IdTypeRoute
        )
        BEGIN
            SELECT 
                'Error' AS Estado,
                'El tipo de ruta no existe en CatTypeRoute.' AS Mensaje,
                @IdTypeRoute AS IdTypeRoute;
            RETURN;
        END

        -- PASO 5: Capturar valores antes
        DECLARE
            @PrevIdTypeRoute INT,
            @PrevTypeDescription NVARCHAR(100);

        SELECT
            @PrevIdTypeRoute = CR.IdTypeRoute,
            @PrevTypeDescription = CTR.[Description]
        FROM DeliveryBackOffice.dbo.CatRoute CR WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.CatTypeRoute CTR WITH (NOLOCK)
            ON CTR.IdTypeRoute = CR.IdTypeRoute
        WHERE CR.IdRoute = @IdRoute;

        -- PASO 6: Validar si ya tiene el mismo tipo
        IF @PrevIdTypeRoute = @IdTypeRoute
        BEGIN
            SELECT
                'Error' AS Estado,
                'La ruta ya posee el tipo indicado.' AS Mensaje,
                @IdRoute AS IdRoute,
                @IdTypeRoute AS IdTypeRoute_Actual;
            RETURN;
        END

        -- PASO 7: Actualizar tipo de ruta
        UPDATE DeliveryBackOffice.dbo.CatRoute
        SET
            IdTypeRoute = @IdTypeRoute,
            TokenUpdated = @TokenUpdated,
            DateUpdated = GETDATE()
        WHERE IdRoute = @IdRoute;

        -- PASO 8: Resultado final
        SELECT
            'Exito' AS Estado,
            'El tipo de ruta fue actualizado correctamente.' AS Mensaje,
            CR.IdRoute,
            @PrevIdTypeRoute AS IdTypeRoute_Anterior,
            @PrevTypeDescription AS TipoRuta_Anterior,
            CTR.IdTypeRoute AS IdTypeRoute_Nuevo,
            CTR.[Description] AS TipoRuta_Nuevo,
            @TokenUpdated AS TokenUpdated,
            GETDATE() AS DateUpdated
        FROM DeliveryBackOffice.dbo.CatRoute CR WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.CatTypeRoute CTR WITH (NOLOCK)
            ON CTR.IdTypeRoute = CR.IdTypeRoute
        WHERE CR.IdRoute = @IdRoute;

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