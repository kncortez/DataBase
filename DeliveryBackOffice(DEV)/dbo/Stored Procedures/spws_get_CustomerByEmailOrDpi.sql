-- =============================================
-- Author:		<Michael, Espinoza>
-- Create date: <2021-08-02>
-- Description:	<Devuelve el nombre de un cliente individual asi como su IdCustomer>
-- =============================================
-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <2024-06-27>
-- Description:	<Devuelve el nombre de un cliente individual asi como su IdCustomer filtrado por país>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_CustomerByEmailOrDpi]
    -- Add the parameters for the stored procedure here
    --@StartDate DATETIME,
    --@EndDate DATETIME ,
    @Token VARCHAR(200) = ''
  , @Email VARCHAR(50) = ''
  , @DPI VARCHAR(50) = ''
  , @IdMembership INT = 0
  , @IdCountry VARCHAR(2) = 'GT'
AS
BEGIN

    DECLARE @IdAccount INT;
    DECLARE @IdUser INT;
    DECLARE @jsonResult NVARCHAR(MAX);

    DECLARE @ActiveSalesPackageId INT =
            (
                SELECT TOP 1
                       CSPS.IdCatSalesPackageStatus
                FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK)
                WHERE CSPS.SalesPackageStatusName = 'Activa' 
            );


    IF (@Email = '' AND @DPI = '')
    BEGIN

        SELECT TOP 1
               @IdAccount = rub.RuaIdAccount
             , @IdUser    = UsrIdUser
        FROM dbo.Person
            INNER JOIN dbo.RegisterUser       ru
                ON ru.UsrIdPerson = PerIdPerson
            INNER JOIN dbo.RolByUserByAccount rub
                ON rub.RuaIdUser = UsrIdUser
            INNER JOIN dbo.Membership         M
                ON rub.RuaIdAccount = M.AccountId
        WHERE M.IdMembership = @IdMembership;

    END;

    ELSE IF (@Email = '' AND @IdMembership = 0)
    BEGIN

        SELECT TOP 1
               @IdAccount = rub.RuaIdAccount
             , @IdUser    = UsrIdUser
        FROM dbo.Person
            INNER JOIN dbo.RegisterUser       ru
                ON ru.UsrIdPerson = PerIdPerson
            INNER JOIN dbo.RolByUserByAccount rub
                ON rub.RuaIdUser = UsrIdUser
        WHERE PerIdentification = @DPI;

    END;

    ELSE
    BEGIN

        SELECT @IdAccount = rub.RuaIdAccount
             , @IdUser    = UsrIdUser
        FROM dbo.RegisterUser
            INNER JOIN dbo.RolByUserByAccount rub
                ON rub.RuaIdUser = UsrIdUser
        WHERE UsrEmail = @Email;

    END;

    SET @jsonResult =
    (
        SELECT STUFF(
                        (
                            SELECT ',{"IdAccount":"' + CONVERT(NVARCHAR, ISNULL(@IdAccount, '')) + '",' + '"IdUser":"'
                                   + CONVERT(NVARCHAR, ISNULL(@IdUser, '')) + '",' + '"IdCustomer":"'
                                   + CONVERT(NVARCHAR, ISNULL(cu.[IdCustomer], '')) + '",' + '"Name":"'
                                   + ISNULL(cu.[Name], '') + '",' + '"Email":"' + ISNULL(ru.[UsrEmail], '') + '",'
                                   + '"Phone":"' + ISNULL(ru.[Phone], '') + '",'
								   + '"NirPhone":"' + ISNULL(ru.[PrefixCallingCode], '+502')
								   + '",' + '"HasMembership":'
                                   + CONVERT(NVARCHAR
                                           , ISNULL(   (CASE
                                                            WHEN mmbrshp.IdMembership IS NOT NULL THEN
                                                                1
                                                            ELSE
                                                                0
                                                        END
                                                       )
                                                     , 0
                                                   )
                                            ) + ',' + '"Addresses":['
                                   + ISNULL(
                                     (
                                         SELECT STUFF(
                                                         (
                                                             SELECT ',{' + '"FullName":"' + ua.UadFullName + '",'
                                                                    + '"Address1":"'
                                                                    + REPLACE(
                                                                                 REPLACE(
                                                                                            dbo.fnt_String_Escape(
                                                                                                                     ISNULL(
                                                                                                                               ua.UadAddress1
                                                                                                                             , ''
                                                                                                                           )
                                                                                                                   , 'json'
                                                                                                                 )
                                                                                          , '\'
                                                                                          , ' '
                                                                                        )
                                                                               , '"'
                                                                               , ''
                                                                             ) + '",' + '"Address2":"'
                                                                    + REPLACE(
                                                                                 REPLACE(
                                                                                            dbo.fnt_String_Escape(
                                                                                                                     ISNULL(
                                                                                                                               ua.UadAddress2
                                                                                                                             , ''
                                                                                                                           )
                                                                                                                   , 'json'
                                                                                                                 )
                                                                                          , '\'
                                                                                          , ' '
                                                                                        )
                                                                               , '"'
                                                                               , ''
                                                                             ) + '",' + '"NirPhone":"' + ua.UadNirPhone
                                                                    + '",' + '"Phone":"' + ua.UadPhone + '",'
                                                                    + '"AdditionalInstructions":"'
                                                                    + REPLACE(
                                                                                 REPLACE(
                                                                                            dbo.fnt_String_Escape(
                                                                                                                     ISNULL(
                                                                                                                               ua.UadAdditionalInstructions
                                                                                                                             , ''
                                                                                                                           )
                                                                                                                   , 'json'
                                                                                                                 )
                                                                                          , '\'
                                                                                          , ' '
                                                                                        )
                                                                               , '"'
                                                                               , ''
                                                                             ) + '",' + '"IdCountry":"'
                                                                    + ua.UadIdCountry + '",' + '"Province":"'
                                                                    + prv.ProvinceName + '",' + '"Township":"'
                                                                    + twn.TownshipName + '",' + '"IdTownship":"'
                                                                    + CONVERT(VARCHAR, ua.UadIdTownship) + '",'
                                                                    + '"HeaderCode":"' + twn.HeaderCode + '",'
                                                                    + '"CodeOfReference":"'
                                                                    + CONVERT(VARCHAR, ua.CodeOfReference) + '",'
                                                                    + '"IdCityPlace":"'
                                                                    + CONVERT(VARCHAR, ISNULL(ua.IdCityPlace, 31))
                                                                    + '",' + '"CityPlace":"'
                                                                    + CONVERT(VARCHAR, ctp.CityPlace) + '",'
                                                                    + '"IdProvince":"'
                                                                    + CONVERT(VARCHAR, prv.IdProvince) + +'"}'
                                                             FROM dbo.RolByUserByAccount     rua
                                                                 INNER JOIN dbo.UserAddress  ua
                                                                     ON ua.UadIdAccount = rua.RuaIdAccount
                                                                 INNER JOIN dbo.Township     twn
                                                                     ON twn.IdTownship = ua.UadIdTownship
                                                                 INNER JOIN dbo.Province     prv
                                                                     ON prv.IdProvince = twn.IdProvince
                                                                 INNER JOIN dbo.CatCityPlace ctp
                                                                     ON ua.IdCityPlace = ctp.IdCityPlace
                                                                        AND ctp.CityPlaceRowStatus = 'true'
                                                             WHERE rua.RuaIdAccount = @IdAccount
                                                                   AND rua.RuaIdUser = @IdUser
                                                                   AND ua.UadRowStatus = 1
                                                             FOR XML PATH(''), TYPE
                                                         ).value('.', 'varchar(max)')
                                                       , 1
                                                       , 1
                                                       , ''
                                                     )
                                     )
                                   , '{"Message": "No se encontraron resultados", "Code": 400}'
                                           ) + ']' + '}'
                            FROM DeliveryBackOffice.dbo.Account                ac
                                INNER JOIN DeliveryBackOffice.dbo.Customer     cu
                                    ON cu.IdCustomer = ac.IdCustomer
                                INNER JOIN DeliveryBackOffice.dbo.RegisterUser ru
                                    ON ru.UsrIdUser = @IdUser
                                LEFT JOIN DeliveryBackOffice.dbo.Membership    mmbrshp WITH (NOLOCK)
                                    ON cu.IdCustomer = mmbrshp.CustomerId
                                       AND mmbrshp.RowStatus = 1
                                       AND mmbrshp.ExpirationDate >= GETDATE()
                                       AND mmbrshp.CatMembershipStatusId IN ( @ActiveSalesPackageId )
                            WHERE ac.AccIdAccount = @IdAccount
                            AND (cu.CountryID = @IdCountry OR (@IdCountry = 'GT' AND cu.CountryID IS NULL))
                            FOR XML PATH(''), TYPE
                        ).value('.', 'varchar(max)')
                      , 1
                      , 1
                      , ''
                    )
    );

    SELECT ('[' + @jsonResult + ']') jsonResult;

END;
