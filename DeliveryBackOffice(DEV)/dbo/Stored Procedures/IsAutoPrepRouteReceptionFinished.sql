/* =================================================
   SP:        [dbo].[IsAutoPrepRouteReceptionFinished]
   Propósito: Verifica si la recepción automática de la ruta está finalizada.
   Autor:     Erick Hernandez
   Historia:  FDAPI-6249
   Fecha:     2026-06-01
   === CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[IsAutoPrepRouteReceptionFinished]
    @RouteID INT,
    @CountryID VARCHAR(2) = 'GT'
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY

		DECLARE @RouteTypeID INT = 0;
        DECLARE @IsFinished BIT = 0;
		DECLARE @LastMileRouteTypeID INT;
        DECLARE @Today DATE = CAST(GETDATE() AS DATE)
		
		DECLARE @RowStatus_Active INT = 1;

        SELECT TOP 1 @RouteTypeID = R.IdTypeRoute, @IsFinished = RP.IsAutoFinished
        FROM DeliveryBackOffice.dbo.RoutePreparation RP WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.CatRoute R WITH (NOLOCK)
			ON R.IdRoute = RP.CatRouteId
        WHERE RP.CatRouteId = @RouteID
        AND RP.DateRoutePreparation = @Today
        AND RP.RowStatus = @RowStatus_Active
        ORDER BY RP.DateRoutePreparation DESC;

		-- LAST MILE ROUTE TYPE ID = 4
		SET @LastMileRouteTypeID = (
			SELECT TOP 1 CTR.IdTypeRoute
            FROM DeliveryBackOffice.dbo.CatTypeRoute CTR WITH (NOLOCK)
            WHERE CTR.Name = 'Ultima Milla');

		IF @RouteTypeID = @LastMileRouteTypeID
		BEGIN
			SELECT @IsFinished AS IsFinished, 1 AS StatusCode;
		END
		ELSE
		BEGIN
			-- RETURN TRUE FOR OTHER TYPES OF ROUTES
			SELECT CAST(1 AS BIT) AS IsFinished, 1 AS StatusCode;
		END
    END TRY
	BEGIN CATCH
		SELECT CAST(0 AS BIT) AS IsFinished, -1 AS StatusCode;
	END CATCH	
END