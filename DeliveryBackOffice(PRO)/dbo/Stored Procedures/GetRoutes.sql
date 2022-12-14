
CREATE PROCEDURE [dbo].[GetRoutes] @RouteChar AS NVARCHAR
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
            SELECT IdRoute IdRoute,
                   CodeRoute
            FROM [DeliveryBackOffice].[dbo].CatRoute CR WITH (NOLOCK)
            WHERE CR.IdTypeRoute = @RouteType;
        ELSE
            SELECT IdRoute IdRoute,
                   CodeRoute
            FROM [DeliveryBackOffice].[dbo].CatRoute
            WHERE LEFT(UPPER(CodeRoute), 1) = @RouteChar;

    END TRY
    BEGIN CATCH
        SELECT IdRoute IdRoute,
               CodeRoute
        FROM [DeliveryBackOffice].[dbo].CatRoute
        WHERE LEFT(UPPER(CodeRoute), 1) = @RouteChar;
    END CATCH;

END;


