
CREATE PROCEDURE [dbo].[GetRoutes] @RouteChar AS NVARCHAR,
                                   @IdCountry AS NVARCHAR(2)='GT'
AS
BEGIN


    DECLARE @RouteType INT;

    BEGIN TRY

        IF (@RouteChar = 'R')
            SET @RouteType =
        (
            SELECT TOP 1
                   CTR.IdTypeRoute
            FROM [DeliveryBackOffice].[dbo].[CatTypeRoute] CTR WITH (NOLOCK)
            WHERE CTR.[Name] = 'Recolección' COLLATE Latin1_General_CI_AI
        )   ;
        ELSE IF (@RouteChar = 'L')
            SET @RouteType =
        (
            SELECT TOP 1
                   CTR.IdTypeRoute
            FROM [DeliveryBackOffice].[dbo].[CatTypeRoute] CTR WITH (NOLOCK)
            WHERE CTR.[Name] = 'Linehaul' COLLATE Latin1_General_CI_AI
        )   ;
        ELSE IF (@RouteChar = 'D')
            SET @RouteType =
        (
            SELECT TOP 1
                   CTR.IdTypeRoute
            FROM [DeliveryBackOffice].[dbo].[CatTypeRoute] CTR WITH (NOLOCK)
            WHERE CTR.[Name] = 'Devolución' COLLATE Latin1_General_CI_AI
        )   ;
        ELSE IF (@RouteChar = 'U')
            SET @RouteType =
        (
            SELECT TOP 1
                   CTR.IdTypeRoute
            FROM [DeliveryBackOffice].[dbo].[CatTypeRoute] CTR WITH (NOLOCK)
            WHERE CTR.[Name] = 'Ultima Milla' COLLATE Latin1_General_CI_AI
        )   ;
        ELSE
            SET @RouteType = -1;

        IF (ISNULL(@RouteType, -1) > 0)
            SELECT CR.IdRoute IdRoute,
                   CR.CodeRoute CodeRoute
            FROM [DeliveryBackOffice].[dbo].CatRoute CR WITH (NOLOCK)
            WHERE CR.IdTypeRoute = @RouteType
			AND CR.RowStatus = 'TRUE'
			AND IIF(CR.CountryId IS NULL, 'GT',CR.CountryId)=@IdCountry;
        ELSE
            SELECT CR.IdRoute IdRoute,
                   CR.CodeRoute CodeRoute
            FROM [DeliveryBackOffice].[dbo].CatRoute CR WITH (NOLOCK)
            WHERE LEFT(UPPER(CR.CodeRoute), 1) = @RouteChar
			AND CR.RowStatus = 'TRUE'
			AND IIF(CR.CountryId IS NULL, 'GT',CR.CountryId)=@IdCountry;

    END TRY
    BEGIN CATCH
        SELECT CR.IdRoute IdRoute,
               CR.CodeRoute CodeRoute
        FROM [DeliveryBackOffice].[dbo].CatRoute CR WITH (NOLOCK)
        WHERE LEFT(UPPER(CR.CodeRoute), 1) = @RouteChar
		AND CR.RowStatus = 'TRUE'
		AND IIF(CR.CountryId IS NULL, 'GT',CR.CountryId)=@IdCountry;
    END CATCH;

END;



