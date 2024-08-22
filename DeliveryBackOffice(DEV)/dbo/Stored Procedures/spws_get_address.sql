
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-07-31>
-- Description: <Obtiene le listado de direcciones asignadas en forma de datatable>
-- =============================================
-- =============================================
-- Author:      <Walter Orozco>
-- Create date: <2024-08-21>
-- Description: <Optimización de la consulta>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_address]
	-- Add the parameters for the stored procedure here
	@Token VARCHAR(200),
	@IdAccount bigint,
	@IdAddress bigint = -1
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @jsonResult NVARCHAR(MAX);

    DECLARE @IdUser BIGINT =
            (
                SELECT TOP 1
                       RuaIdUser
                FROM dbo.RolByUserByAccount
                WHERE RuaIdAccount = @IdAccount
            );

    SELECT CONVERT(VARCHAR(20), ua.UadIdAccount) AS IdAccount
		 , CONVERT(VARCHAR(20), ua.UadIdAddress) AS IdAddress
		 , ua.UadFullName AS FullName
		 , ISNULL(ua.UadFullName, '') AS ContactName
		 , ua.UadAddress1 AS Address1
		 , ua.UadAddress2 AS Address2
		 , ua.UadNirPhone AS NirPhone
		 , ua.UadPhone AS Phone
		 , ua.UadAdditionalInstructions AS AdditionalInstructions
		 , ua.UadIdCountry AS IdCountry
		 , prv.ProvinceName AS Province
		 , twn.TownshipName AS TownshipName
		 , CONVERT(VARCHAR(11), ua.UadIdTownship) AS IdTownship
		 , twn.HeaderCode AS HeaderCode
		 , CONVERT(VARCHAR(11), ua.CodeOfReference) AS CodeOfReference
		 , CONVERT(VARCHAR(11), ISNULL(ua.IdCityPlace, 31)) AS IdCityPlace
		 , ctp.CityPlace AS CityPlace
		 , CONVERT(VARCHAR(11), prv.IdProvince) AS IdProvince
		 , ISNULL(vp.Latitude, '') AS Latitude
		 , ISNULL(vp.Longitude, '') AS Longitude
		 , ISNULL(CAST(conf.[Zone] AS VARCHAR(2)), '') AS [Zone]
		 , ISNULL(dbo.fn_ReplaceSpecialCharsForJSON(conf.Neighborhood), '') AS Neighborhood
		 , CAST(ISNULL(vp.IsOriginVisitPoint, 1) AS NVARCHAR(1)) AS IsOrigin
	FROM dbo.RolByUserByAccount rua WITH (NOLOCK)
	INNER JOIN dbo.UserAddress ua WITH (NOLOCK)
		ON ua.UadIdAccount = rua.RuaIdAccount
	INNER JOIN dbo.Township twn WITH (NOLOCK)
		ON twn.IdTownship = ua.UadIdTownship
	INNER JOIN dbo.Province prv WITH (NOLOCK)
		ON prv.IdProvince = twn.IdProvince
	INNER JOIN dbo.CatCityPlace ctp WITH (NOLOCK)
		ON ua.IdCityPlace = ctp.IdCityPlace
		   AND ctp.CityPlaceRowStatus = 'true'
	LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
		ON vp.CodeOfReference = ua.CodeOfReference
	LEFT JOIN dbo.ConfirmedAddress conf WITH (NOLOCK)
		ON conf.NirPhone = ua.UadNirPhone
		AND conf.Phone = ua.UadPhone
	WHERE rua.RuaIdAccount = @IdAccount
		  AND rua.RuaIdUser = @IdUser
		  AND ua.UadRowStatus = 1
		  AND conf.TownshipId = vp.IdTownship
		  AND conf.[Address] = vp.[Address]
          AND
          (
              ua.UadIdAddress = @IdAddress
              OR @IdAddress = -1
          );
END


