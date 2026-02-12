/* =================================================
   SP:        [dbo].[GetStationsByType]
   Propósito: Se obtienen las estaciones por tipo 
   Autor:     Tito García
   Historia:  <FDAPI-5486>
   Fecha:     <12/02/2026>
   === CHANGELOG ============================
=========================================== */
CREATE PROCEDURE GetStationsByType
    @TypeStation NVARCHAR(10),
    @CountryId   NVARCHAR(2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StationType INT;

    BEGIN TRY

        SET @TypeStation = UPPER(LTRIM(RTRIM(@TypeStation)));

        IF @TypeStation = 'ALL'
        BEGIN
            SELECT IdStation,
                   StationName
            FROM DeliveryBackOffice.dbo.CatStation
            WHERE RowStatus = 1
              AND CountryId = @CountryId;
        END
        ELSE IF @TypeStation = 'HUB'
        BEGIN
            SET @StationType = 1;

            SELECT IdStation,
                   StationName
            FROM DeliveryBackOffice.dbo.CatStation
            WHERE RowStatus = 1
              AND CountryId = @CountryId
              AND StationType = @StationType;
        END
        ELSE IF @TypeStation = 'EXC'
        BEGIN
            SET @StationType = 2;

            SELECT IdStation,
                   StationName
            FROM DeliveryBackOffice.dbo.CatStation
            WHERE RowStatus = 1
              AND CountryId = @CountryId
              AND StationType = @StationType;
        END
        ELSE
        BEGIN
            SELECT 
                CONVERT(INT, NULL) AS IdStation,
                CONVERT(NVARCHAR(50), NULL) AS StationName
            WHERE 1 = 0;

            SELECT 3 AS StatusCode,
                   'Tipo de estación inválido' AS Description;
            RETURN;
        END;

        IF @@ROWCOUNT > 0
        BEGIN
            SELECT 1 AS StatusCode,
                   'Estaciones obtenidas correctamente' AS Description;
        END
        ELSE
        BEGIN
            SELECT 2 AS StatusCode,
                   'No existen estaciones' AS Description;
        END;

    END TRY
    BEGIN CATCH
        SELECT 
            CONVERT(INT, NULL) AS IdStation,
            CONVERT(NVARCHAR(50), NULL) AS StationName
        WHERE 1 = 0;

        SELECT 0 AS StatusCode,
               ERROR_MESSAGE() AS Description;
    END CATCH;
END;
