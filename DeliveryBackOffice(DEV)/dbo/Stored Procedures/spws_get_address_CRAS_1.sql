
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_address_CRAS]
    -- Add the parameters for the stored procedure here
    @Token VARCHAR(200)
  , @IdAccount BIGINT
  , @IdAddress BIGINT = -1
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




    SELECT CONVERT(VARCHAR, ua.UadIdAccount)
         , CONVERT(VARCHAR, ua.UadIdAddress)
         , REPLACE(dbo.fnt_String_Escape(ua.UadFullName, 'json'), '"', '')
         , REPLACE(dbo.fnt_String_Escape(ISNULL(ua.UadFullName, ''), 'json'), '"', '')
         , REPLACE(dbo.fnt_String_Escape(ua.UadAddress1, 'json'), '"', '')
         , REPLACE(dbo.fnt_String_Escape(ua.UadAddress2, 'json'), '"', '')
         , REPLACE(dbo.fnt_String_Escape(ua.UadNirPhone, 'json'), '"', '')
         , REPLACE(dbo.fnt_String_Escape(ua.UadAdditionalInstructions, 'json'), '"', '')
         , prv.ProvinceName
         , CONVERT(VARCHAR, ua.UadIdTownship)
         , twn.HeaderCode
         , CONVERT(VARCHAR, ua.CodeOfReference)
         , CONVERT(VARCHAR, ISNULL(ua.IdCityPlace, 31))
         , CONVERT(VARCHAR, ctp.CityPlace)
         , CONVERT(VARCHAR, prv.IdProvince)
         , ISNULL(vp.Latitude, '')
         , ISNULL(vp.Longitude, '')
         , ISNULL(CAST(conf.Zone AS VARCHAR(2)), '')
         , ISNULL(dbo.fn_ReplaceSpecialCharsForJSON(conf.Neighborhood), '')
         , CAST(ISNULL(vp.IsOriginVisitPoint, 1) AS NVARCHAR)
    FROM dbo.RolByUserByAccount        rua WITH (NOLOCK)
        INNER JOIN dbo.UserAddress     ua WITH (NOLOCK)
            ON ua.UadIdAccount = rua.RuaIdAccount
        INNER JOIN dbo.Township        twn WITH (NOLOCK)
            ON twn.IdTownship = ua.UadIdTownship
        INNER JOIN dbo.Province        prv WITH (NOLOCK)
            ON prv.IdProvince = twn.IdProvince
        INNER JOIN dbo.CatCityPlace    ctp WITH (NOLOCK)
            ON ua.IdCityPlace = ctp.IdCityPlace
               AND ctp.CityPlaceRowStatus = 'true'
        LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
            ON vp.CodeOfReference = ua.CodeOfReference
        LEFT JOIN dbo.ConfirmedAddress conf WITH (NOLOCK)
            ON conf.NirPhone = ua.UadNirPhone
               AND conf.Phone = ua.UadPhone
               AND conf.TownshipId = vp.IdTownship
               AND conf.[Address] = vp.Address
    WHERE rua.RuaIdAccount = @IdAccount
          AND rua.RuaIdUser = @IdUser
          AND ua.UadRowStatus = 1
          AND
          (
              ua.UadIdAddress = @IdAddress
              OR @IdAddress = -1
          );

    -- retornar resultado en formato json
    IF @jsonResult IS NULL
    BEGIN


        SET @jsonResult =
        (
            SELECT STUFF((
                             SELECT '{{"IdResult":500,' + '"Message":" No se econtraron registros"}'
                             FOR XML PATH(''), TYPE
                         ).value('.', 'varchar(max)')
                       , 1
                       , 1
                       , ''
                        )
        );
    END;

    SELECT ('[' + @jsonResult + ']') jsonResult;



END;