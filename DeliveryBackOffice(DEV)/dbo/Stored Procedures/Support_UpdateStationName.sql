/* =================================================
   SP:        dbo.Support_UpdateStationName
   Propósito: Actualizar el nombre de una estación con normalización a mayúsculas.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-6039
   Fecha:     2026-04-10
=========================================== */

CREATE PROCEDURE dbo.Support_UpdateStationName
(
    @IdStation    INT,
    @StationName  NVARCHAR(100),
    @TokenUpdated NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- VALIDACIONES
        IF @IdStation IS NULL 
        OR ISNULL(@StationName,'') = ''
        OR ISNULL(@TokenUpdated,'') = ''
        BEGIN
            SELECT 'Error' AS Estado, 'Todos los parámetros son obligatorios.' AS Mensaje;
            RETURN;
        END

        -- NORMALIZACIÓN (MAYÚSCULAS + TRIM)
        DECLARE @StationNameNormalized NVARCHAR(100);
        SET @StationNameNormalized = UPPER(LTRIM(RTRIM(@StationName)));

        -- VALIDAR LONGITUD
        IF LEN(@StationNameNormalized) > 100
        BEGIN
            SELECT 'Error' AS Estado, 'El nombre excede la longitud máxima permitida (100).' AS Mensaje;
            RETURN;
        END

        -- VALIDAR EXISTENCIA
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.CatStation WITH(NOLOCK)
            WHERE IdStation = @IdStation
        )
        BEGIN
            SELECT 'Error' AS Estado, 'La estación no existe.' AS Mensaje;
            RETURN;
        END

        -- CAPTURA ANTES
        DECLARE @PrevName NVARCHAR(100);

        SELECT @PrevName = StationName
        FROM DeliveryBackOffice.dbo.CatStation WITH(NOLOCK)
        WHERE IdStation = @IdStation;

        -- UPDATE
        UPDATE DeliveryBackOffice.dbo.CatStation
        SET 
            StationName = @StationNameNormalized,
            TokenUpdated = @TokenUpdated,
            DateUpdated  = GETDATE()
        WHERE IdStation = @IdStation;

        -- RESULTADO FINAL
        SELECT
            'Exito' AS Estado,
            @IdStation AS IdStation,
            @PrevName AS Nombre_ANTES,
            @StationNameNormalized AS Nombre_DESPUES;

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