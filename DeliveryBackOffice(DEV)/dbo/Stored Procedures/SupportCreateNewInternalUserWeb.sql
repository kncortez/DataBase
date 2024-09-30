-- =============================================
-- Author:        <Brandon, Pedroza>
-- Create date:   <2024-08-07>
-- Description:   <Crear un nuevo usuario para ingresar a portal interno,debe estar previamente creado en Denarius considerando multipais>
-- =============================================
-- Author:        <Brandon, Pedroza>
-- Create date:   <2024-08-14>
-- Description:   <Se agrega validacion para usuarios de telemercadeo>
-- =============================================
CREATE PROCEDURE [dbo].[SupportCreateNewInternalUserWeb]
  @Code INT
 ,@User NVARCHAR(50)
 ,@Token NVARCHAR(50)
 ,@IdStation INT
 ,@IdRol INT
 ,@IdSystem INT
 ,@IdCountry NVARCHAR(2)
AS
BEGIN

    BEGIN TRY
        BEGIN TRANSACTION;

		DECLARE @IDPerson INT = 0,
				@CodeISOCurrency NVARCHAR(10),
				@IdRegisterUser INT = 0,
				@IdRolTelemercadeo INT = 0,
				@FirstName NVARCHAR(100),
				@LastName NVARCHAR(100);
		SELECT TOP 1
				@CodeISOCurrency = cuCOD.CodeISO 
				FROM CatCurrencyCOD cuCOD WITH (NOLOCK)
				INNER JOIN DeliveryCurrency  cu WITH (NOLOCK)
					ON cu.IdCurrencyCOD = cuCOD.IdCatCurrencyCOD
				WHERE cu.DefaultPerCountry = 1
				AND cu.Currency_IdCountry= @IdCountry
                
        SELECT TOP 1 
				@IdRolTelemercadeo = RolIdRol 
				FROM CatRol WHERE RolName = 'Ventas telemercadeo'

        INSERT INTO DeliveryBackOffice.dbo.Person
        (
           PerFirstName
         , PerLastName
         , PerGender
         , PerBirthdate
         , PerIdentification
         , PerNationality
         , PerRowStatus
         , PerTokenCreated
         , PerDateCreated
         , PerTokenUpdated
         , PerDateUpdated
         , PerCountryOrigin
        )
        SELECT TOP 1
               TRIM(CONCAT(ISNULL(emp.FirstName, ''), ' ', ISNULL(emp.SecondName, '')))
             , TRIM(CONCAT(ISNULL(emp.LastName1, ''), ' ', ISNULL(emp.LastName2, '')))
             , emp.Sex
             , CONVERT(DATE, emp.DateBrith)
             , ISNULL(emp.DPI, '')
             , IIF(@IdCountry = 'HN','Hondureño','Guatemalteco')
             , 1
             , @Token
             , GETDATE()
             , NULL
             , NULL
             , @IdCountry
          FROM DenariusDesktop_Dev.dbo.LGT_INF_Employee emp
         WHERE emp.CodeEmployee =  CONVERT(NVARCHAR(20), @Code);

        SELECT @IDPerson = SCOPE_IDENTITY();

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
          , UsrTokenUpdated
          , UsrDateUpdated
          , PrefixCallingCode
          , Phone
          , UrlFacebook
          , UrlInstagram
          , UrlEcommerce
          , UrlWebsite
          , IdentificationImageA
          , IdentificationImageB
          , VerifiedPhone
          , ChangePassword
        )
        SELECT @IDPerson
             , usr.USR_Username
             , usr.USR_Email
             , NULL
             , usr.USR_Password
             , GETDATE() + 100
             , 'ES'
             , 'WEB'
             , @CodeISOCurrency
             , NULL
             , NULL
             , 1
             , @Token
             , GETDATE()
             , NULL
             , NULL
             , IIF(@IdCountry='GT','+502','+504')
             , ''
             , NULL --UrlFacebook
             , NULL --UrlInstagram
             , NULL --UrlEcommerce
             , NULL --UrlWebsite
             , NULL --IdentificationImageA
             , NULL --IdentificationImageB
             , NULL --VerifiedPhone
             , NULL --ChangePassword
        FROM DenariusUser_Dev.dbo.LGN_User usr
       WHERE usr.USR_IdUser = @Code
         AND usr.USR_Username = @User;

         SET @IdRegisterUser = SCOPE_IDENTITY();

      INSERT INTO DeliveryBackOffice.dbo.InternalUser
      (
          IdUser
        , Username
        , IdEmployee
        , RegisterUserID
        , RowStatus
        , TokenCreated
        , DateCreated
        , TokenUpdated
        , DateUpdated
      )
      SELECT usr.USR_IdUser
             , usr.USR_Username
             , usr.USR_IdEmployee
             , @IdRegisterUser
             , 1
             , @Token
             , GETDATE()
             , NULL
             , NULL
        FROM DenariusUser_Dev.dbo.LGN_User usr
       WHERE usr.USR_IdUser = @Code
         AND usr.USR_Username = @User;

      INSERT INTO DeliveryBackOffice.dbo.UserSystemRestriction
      (
         UstIdUser
       , UstIdSystem
       , UstAccessRetries
       , UstRetries
       , UstStatus
       , UstRowStatus
       , UstTokenCreated
       , UstDateCreated
       , UstOperationDate
      )
      VALUES
      (
       @IdRegisterUser -- UstIdUser - bigint
       , @IdSystem	   -- UstIdSystem - int 13= Hermes web operaciones CatSystem
       , 10            -- UstAccessRetries - int
       , 0             -- UstRetries - int
       , 'ACTIVE'      -- UstStatus - varchar(10)
       , 1             -- UstRowStatus - bit
       , @Token        -- UstTokenCreated - varchar(50)
       , GETDATE()     -- UstDateCreated - datetime
       , GETDATE()     -- UstOperationDate - datetime
      );

      INSERT INTO DeliveryBackOffice.dbo.RolByUserBySystem
      (
         RusIdRol
       , RusIdSystem
       , RusIdUser
       , RusRowStatus
       , RusTokenCreated
       , RusDateCreated
       , RusTokenUpdated
       , RusDateUpdated
       , StationId
      )
      VALUES
      (
       @IdRol            -- RusIdRol - int
       , @IdSystem       -- RusIdSystem - int 13= Hermes web operaciones CatSystem
       , @IdRegisterUser -- RusIdUser - bigint
       , 1               -- RusRowStatus - bit
       , @Token          -- RusTokenCreated - varchar(50)
       , GETDATE()       -- RusDateCreated - datetime
       , NULL            -- RusTokenUpdated - varchar(50)
       , NULL            -- RusDateUpdated - datetime
       , @idStation      -- StationId - int
      );

      IF(@IdRol = @IdRolTelemercadeo)
	  BEGIN
		SELECT TOP 1
              @FirstName =  dbo.CapitalizeFirstLetter(ISNULL(emp.FirstName, ''))
             , @LastName =  dbo.CapitalizeFirstLetter(ISNULL(emp.LastName1, ''))
			FROM DenariusDesktop_Dev.dbo.LGT_INF_Employee emp
			WHERE emp.CodeEmployee =  CONVERT(NVARCHAR(20), @Code);

			INSERT INTO [dbo].[CatTMSalesPerson]
				([Code]
				,[FirstName]
				,[LastName]
				,[Country]
				,[RegisterUserId]
				,[RowStatus]
				,[DateCreated]
				,[TokenCreated]
				,[DateUpdated]
				,[TokenUpdated]
				,[CatSaleAdvisorId])
			VALUES
				(''
				,@FirstName
				,@LastName
				,@IdCountry
				,@IdRegisterUser
				,1
				,GETDATE()
				,@Token
				,NULL
				,NULL
				,NULL)
	  END;

      COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;

        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER()
             , ERROR_PROCEDURE()
             , ERROR_STATE();
    END CATCH;
END;