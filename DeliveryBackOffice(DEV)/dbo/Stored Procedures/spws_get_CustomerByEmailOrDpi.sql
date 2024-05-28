-- =============================================
-- Author:		<Michael, Espinoza>
-- Create date: <2021-08-02>
-- Description:	<Devuelve el nombre de un cliente individual asi como su IdCustomer>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_CustomerByEmailOrDpi]
    -- Add the parameters for the stored procedure here
    --@StartDate DATETIME,
    --@EndDate DATETIME ,
    @Token VARCHAR(200) = ''
  , @Email VARCHAR(50) = ''
  , @DPI VARCHAR(50) = ''
  , @IdMembership INT = 0
AS
BEGIN

    DECLARE @IdAccount INT;
    DECLARE @IdUser INT;

    DECLARE @ActiveSalesPackageId INT =
            (
                SELECT TOP 1
                       CSPS.IdCatSalesPackageStatus
                FROM [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK)
                WHERE CSPS.SalesPackageStatusName = 'Activa' COLLATE Latin1_General_CI_AI
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

    SELECT 
		CONVERT(NVARCHAR, ISNULL(@IdAccount, '')) [IdAccount],
		CONVERT(NVARCHAR, ISNULL(@IdUser, '')) [IdUser],
		CONVERT(NVARCHAR, ISNULL(cu.[IdCustomer], '')) [IdCustomer],
		ISNULL(cu.[Name], '') [Name],
		ISNULL(ru.[UsrEmail], '') [Email],
		ISNULL(ru.[Phone], '') [Phone],
		CONVERT(NVARCHAR, ISNULL(
			(CASE
				WHEN mmbrshp.IdMembership IS NOT NULL THEN 1
				ELSE 0
			 END), 0)) [HasMembership]
	FROM DeliveryBackOffice.dbo.Account                ac
		INNER JOIN DeliveryBackOffice.dbo.Customer     cu
			ON cu.IdCustomer = ac.IdCustomer
		INNER JOIN DeliveryBackOffice.dbo.RegisterUser ru
			ON ru.UsrIdUser = @IdUser
		LEFT JOIN DeliveryBackOffice.dbo.Membership    mmbrshp WITH (NOLOCK)
			ON cu.IdCustomer = mmbrshp.CustomerId
	WHERE ac.AccIdAccount = @IdAccount AND mmbrshp.RowStatus = 1
		AND mmbrshp.ExpirationDate >= GETDATE()
		AND mmbrshp.CatMembershipStatusId IN ( @ActiveSalesPackageId )


	SELECT
		ua.UadFullName [FullName],
		REPLACE( 
			REPLACE( dbo.fnt_String_Escape
				( ISNULL( ua.UadAddress1, ''), 'json'), '\', ' ')
			, '"', '') [Address1],
		REPLACE(
			REPLACE( dbo.fnt_String_Escape
				( ISNULL( ua.UadAddress2, ''), 'json'), '\', ' ')
			, '"', '') [Address2],
		ua.UadNirPhone [NirPhone],
		ua.UadPhone [Phone],
		REPLACE(
			REPLACE( dbo.fnt_String_Escape
				( ISNULL( ua.UadAdditionalInstructions, ''), 'json'), '\', ' ')
			, '"', '') [AdditionalInstructions],
		ua.UadIdCountry [IdCountry],
		prv.ProvinceName [Province],
		twn.TownshipName [Township],
		CONVERT(VARCHAR, ua.UadIdTownship) [IdTownship],
		twn.HeaderCode [HeaderCode],
		CONVERT(VARCHAR, ua.CodeOfReference) [CodeOfReference],
		CONVERT(VARCHAR, ISNULL(ua.IdCityPlace, 31)) [IdCityPlace],
		CONVERT(VARCHAR, ctp.CityPlace) [CityPlace],
		CONVERT(VARCHAR, prv.IdProvince) [IdProvince],
		CONVERT(VARCHAR, ua.UadIdAddress) [IdAddress],
		CONVERT(VARCHAR, ua.UadFullName) [ContactName],
		ISNULL(vp.Latitude,'') [Latitude],
		ISNULL(vp.Longitude,'') [Longitude],
		ISNULL(CAST(conf.Zone as varchar(2)),'') [Zone],
		ISNULL(dbo.fn_ReplaceSpecialCharsForJSON(conf.Neighborhood),'') [Neighborhood],
		CAST(ISNULL(vp.IsOriginVisitPoint,1) AS NVARCHAR) [IsOrigin]
	FROM dbo.RolByUserByAccount     rua WITH(NOLOCK)
		INNER JOIN dbo.UserAddress  ua WITH(NOLOCK)
			ON ua.UadIdAccount = rua.RuaIdAccount
		INNER JOIN dbo.Township     twn WITH(NOLOCK)
			ON twn.IdTownship = ua.UadIdTownship 
		INNER JOIN dbo.Province     prv WITH(NOLOCK)
			ON prv.IdProvince = twn.IdProvince
		INNER JOIN dbo.CatCityPlace ctp WITH(NOLOCK)
			ON ua.IdCityPlace = ctp.IdCityPlace
			AND ctp.CityPlaceRowStatus = 'true'
		LEFT JOIN dbo.VisitPointClient vp WITH(NOLOCK) 
			ON vp.CodeOfReference = ua.CodeOfReference
		LEFT JOIN  dbo.ConfirmedAddress conf WITH(NOLOCK) 
			ON conf.NirPhone=ua.UadNirPhone
			AND conf.Phone=ua.UadPhone
			AND conf.TownshipId = VP.IdTownship
			AND conf.[Address] = VP.[Address]
	WHERE rua.RuaIdAccount = @IdAccount
		AND rua.RuaIdUser = @IdUser
		AND ua.UadRowStatus = 1

END;
