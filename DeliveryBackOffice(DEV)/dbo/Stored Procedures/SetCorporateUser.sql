-- =============================================
-- Author:	<Tito García>
-- Created: <2024-12-11>
-- Description:	<Setup Usuario no existente en Portal Web Corporativo tomando en cuenta el pais de origen>
-- =============================================
ALTER PROCEDURE [dbo].[SetCorporateUser]
    @Code BIGINT
  , @UserName VARCHAR(50)
  , @Email NVARCHAR(200)
  , @UserPassword VARCHAR(200)
  , @IdVisitPointClient BIGINT
  , @Token NVARCHAR(MAX)
  , @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN

	IF OBJECT_ID('tempdb.dbo.#errormessage_SCU', 'U') IS NOT NULL DROP TABLE #errormessage_SCU;
		SELECT * INTO #errormessage_SCU FROM (SELECT  500 AS IdResult
				,'Código de usuario ya fue asignado a otro usuario' AS Message
				,'ExistCode' as Id 
		UNION
		SELECT  500 AS IdResult
				,'El nombre de usuario ya existe en el sistema'  AS Message
				,'ExistUser' as Id 
		UNION
		SELECT  500 AS IdResult
				,'Error fatal intente de nuevo mas tarde'  AS Message
				,'Transaction' as Id 
		UNION
		SELECT  200 AS IdResult
				,'Cuenta creada correctamente' AS Message
				,'Ok' as Id )  as errror

	DECLARE @gender VARCHAR(1) = '';
    DECLARE @firstName VARCHAR(50) = '';
    DECLARE @lastName VARCHAR(50) = '';
	DECLARE @Cui VARCHAR(50) = ''
    DECLARE @idCustomer BIGINT;
	DECLARE @IdRol BIGINT
    DECLARE @nationality VARCHAR(50);
	DECLARE @CodeISOCurrency NVARCHAR(3);
	DECLARE @jsonResult NVARCHAR(MAX) 

	SET @IdRol = 7;  -- Admin Corp
    SELECT  @nationality = cu.CountryID
         , @firstName   = vpc.DescriptionOfClient
         , @idCustomer  = vpc.CustomerID
    FROM DeliveryBackOffice.dbo.Customer             cu WITH (NOLOCK)
        JOIN DeliveryBackOffice.dbo.VisitPointClient vpc
            ON vpc.CustomerID = cu.IdCustomer
    WHERE vpc.IdVisitPointClient = @IdVisitPointClient;

	SELECT TOP 1
		@CodeISOCurrency = cuCOD.CodeISO 
	FROM CatCurrencyCOD cuCOD WITH (NOLOCK)
		INNER JOIN DeliveryCurrency  cu WITH (NOLOCK)
			ON cu.IdCurrencyCOD = cuCOD.IdCatCurrencyCOD
	WHERE cu.DefaultPerCountry = 1
	AND cu.Currency_IdCountry= @IdCountry

	DECLARE @CodeMatch BIT = 0;
	DECLARE @UserNameMatch BIT = 0;

	SELECT 
		@CodeMatch = CASE WHEN IdUser = @Code THEN 1 ELSE 0 END,
		@UserNameMatch = CASE WHEN Username = @UserName THEN 1 ELSE 0 END
	FROM DeliveryBackOffice.dbo.InternalUser
	WHERE IdUser = @Code OR Username = @UserName;

	IF @CodeMatch = 1
	BEGIN
		SET @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
				+ '"Message":"' + Message  + '"}' from #errormessage_SCU where Id ='ExistCode'
		
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
			) 
		)
	END
	ELSE IF @UserNameMatch = 1
	BEGIN
		SET @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
				+ '"Message":"' + Message  + '"}' from #errormessage_SCU where Id ='ExistUser'
		
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
			) 
		)
	END;
    ELSE
    BEGIN
        BEGIN TRANSACTION;
		BEGIN TRY

            -- Makes an insert into table person once the user was found on Denarius
            INSERT INTO DeliveryBackOffice.dbo.Person
            (
                PerFirstName
              , PerLastName
              , PerGender
              , PerIdentification
              , PerNationality
              , PerRowStatus
              , PerTokenCreated
              , PerDateCreated
			  , PerCountryOrigin
            )
            VALUES
            (ISNULL(@firstName, ''), ISNULL(@lastName, ''), @gender, @Cui, @nationality, 1, @Token, GETDATE(), @IdCountry);

            DECLARE @IdPerson AS BIGINT = SCOPE_IDENTITY();

            --Makes an insert into table RegisterUser once person was created
            DECLARE @ExpirationDate AS DATE =
                    (
                        SELECT DATEADD(DAY, 90, GETDATE())
                    );

            INSERT INTO DeliveryBackOffice.dbo.RegisterUser
            (
                UsrIdPerson
              , UsrNickName
              , UsrEmail
              , UsrAvatar
              , UsrLastPassword
              , UsrPasswordExpiration
              , UsrLang
              , UsrDeviceType
              , UsrCurrency
              , UsrEnable2FA
              , UsrRestrictionAddressIp
              , UsrRowStatus
              , UsrTokenCreated
              , UsrDateCreated
            )
            VALUES
            (@IdPerson, ISNULL(@firstName, ''), ISNULL(@Email, ''), NULL, @UserPassword, @ExpirationDate, 'ES', 'WEB'
           , @CodeISOCurrency, NULL, NULL, 1, @Token, GETDATE());
            DECLARE @IdUser AS BIGINT = SCOPE_IDENTITY();
			
            -- Makes an insert into table UserSystemRestriction once the user was registered
            INSERT INTO DeliveryBackOffice.dbo.UserSystemRestriction
            (
                UstIdUser
              , UstIdSystem      -- System 1 equals to Hermes Web Portal
              , UstAccessRetries -- 10 attemps by default
              , UstRetries       -- Counter needs to start in 0
              , UstStatus        --- When is being created set up in ACTIVE
              , UstRowStatus
              , UstTokenCreated
              , UstDateCreated
              , UstOperationDate
            )
            VALUES
            (@IdUser, 1, 10, 0, 'ACTIVE', 1, @Token, GETDATE(), GETDATE());

            -- Makes an insert into table RolByUserBySystem once the user was registered
            INSERT INTO DeliveryBackOffice.dbo.RolByUserBySystem
            (
                RusIdRol
              , RusIdSystem
              , RusIdUser
              , RusRowStatus
              , RusTokenCreated
              , RusDateCreated
            )
            VALUES
            (@IdRol, 1, @IdUser, 1, @Token, GETDATE());

            -- Makes an insert into table InternalUser once the user was registered

            INSERT INTO DeliveryBackOffice.dbo.InternalUser
            (
                IdUser
              , Username
              , RegisterUserID
              , RowStatus
              , TokenCreated
              , DateCreated
            )
            VALUES
            (@Code, @UserName, @IdUser, 1, @Token, GETDATE());

            --Makes an insert into table Account once the internal user was created

            INSERT INTO DeliveryBackOffice.dbo.Account
            (
                AccName
              , AccIdTypeAccount
              , AccRowStatus
              , AccTokenCreated
              , AccDateCreated
              , IdCustomer
              , AccConfirm
            )
            VALUES
            (CAST(CONCAT('Corporativo ', ISNULL(@firstName, '')) AS VARCHAR(100)), 2, 1, @Token, GETDATE()
           , @idCustomer, 'C');

            DECLARE @IdAccount AS BIGINT = SCOPE_IDENTITY();

            --Makes an insert into table RolByUserByAccount onse the account was created

            INSERT INTO DeliveryBackOffice.dbo.RolByUserByAccount
            (
                RuaIdRol
              , RuaIdUser
              , RuaIdAccount
              , RuaRowStatus
              , RuaTokenCreated
              , RuaDateCreated
            )
            VALUES
            (@IdRol, @IdUser, @IdAccount, 1, @Token, GETDATE());

            -- Makes an inser into table VisitPointByUser, so the user can add clients to the corporate portfolio

            INSERT INTO DeliveryBackOffice.dbo.VisitPointByUser
            (
                IdVisitPointClient
              , RegisterUserID
              , RowStatus
              , TokenCreated
              , DateCreated
            )
            VALUES
            (@IdVisitPointClient, @IdUser, 1, @Token, GETDATE());

        END TRY
        BEGIN CATCH

            set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"Message":"' + Message +'"}' from #errormessage_SCU where Id ='Transaction'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
				) 
			)

            ROLLBACK TRANSACTION;

        END CATCH;

        IF @@TRANCOUNT > 0
        BEGIN

            COMMIT TRANSACTION;

            SET @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"Message":"' + Message  + '"}' from #errormessage_SCU where Id ='Ok'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
				) 
			)

        END;

    END;

		IF OBJECT_ID('tempdb.dbo.#errormessage_SCU', 'U') IS NOT NULL DROP TABLE #errormessage_SCU;

		SELECT ('[{' + @jsonResult +  ']') jsonResult

END;
