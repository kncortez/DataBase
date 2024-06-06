-- =============================================
-- Modified:	<Brandon Pedroza>
-- Create date: <2024-06-04>
-- Description:	<Se agregar parametro para filtrar por pais>
-- =============================================
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
            LEFT JOIN [DeliveryBackOffice].[dbo].Township TW WITH(NOLOCK)
				ON CR.IdTownship = TW.IdTownship
			LEFT JOIN [DeliveryBackOffice].[dbo].Province PR WITH(NOLOCK)
				ON PR.IdProvince = TW.IdProvince
            WHERE CR.IdTypeRoute = @RouteType
            AND CR.RowStatus = 'TRUE'
			AND IIF(PR.IdCountry IS NULL, 'GT',PR.IdCountry)=@IdCountry;
        ELSE
            SELECT CR.IdRoute IdRoute,
                   CR.CodeRoute CodeRoute
            FROM [DeliveryBackOffice].[dbo].CatRoute CR WITH (NOLOCK)
			LEFT JOIN [DeliveryBackOffice].[dbo].Township TW WITH(NOLOCK)
				ON CR.IdTownship = TW.IdTownship
			LEFT JOIN [DeliveryBackOffice].[dbo].Province PR WITH(NOLOCK)
				ON PR.IdProvince = TW.IdProvince
            WHERE LEFT(UPPER(CodeRoute), 1) = @RouteChar
			AND CR.RowStatus = 'TRUE'
			AND IIF(PR.IdCountry IS NULL, 'GT',PR.IdCountry)=@IdCountry;

    END TRY
    BEGIN CATCH
        SELECT CR.IdRoute IdRoute,
               CR.CodeRoute CodeRoute
        FROM [DeliveryBackOffice].[dbo].CatRoute CR WITH (NOLOCK)
			LEFT JOIN [DeliveryBackOffice].[dbo].Township TW WITH(NOLOCK)
				ON CR.IdTownship = TW.IdTownship
			LEFT JOIN [DeliveryBackOffice].[dbo].Province PR WITH(NOLOCK)
				ON PR.IdProvince = TW.IdProvince
        WHERE LEFT(UPPER(CodeRoute), 1) = @RouteChar
        AND CR.RowStatus = 'TRUE'
		AND IIF(PR.IdCountry IS NULL, 'GT',PR.IdCountry)=@IdCountry;
    END CATCH;

END;


