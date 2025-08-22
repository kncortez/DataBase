
-- =============================================
-- Author:        <Bidcar Herrera>
-- Create date:   <2024-05-15>
-- Description:   <Crear un nuevo usuario en Hermes Desktop, debe estar previamente creado en Denarius considerando multipais>
-- =============================================
-- Author:      <Cristian Azurdia>
-- Create date: <2025-04-22>
-- Description: <Actualizacion para manejo de multipais en roles y estaciones>
-- =============================================

CREATE PROCEDURE [dbo].[SupportCreatNewDesktopUserV2]
(
  @Code NVARCHAR(20)
 ,@User NVARCHAR(50)
 ,@Token NVARCHAR(50)
 ,@rol INT
 ,@idStation INT
)
AS
BEGIN
    DECLARE @IdCountry NVARCHAR(2) = 'GT',
            @IDPerson INT = 0,
            @IdRegisterUser INT = 0,
            @Demonym NVARCHAR(20),
            @CodeArea NVARCHAR(4),
            @Currency NVARCHAR(4);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @IdCountry= CountryId 
        FROM dbo.CatStation
        WHERE IdStation = @idStation

        SELECT @Demonym = CountryNationality
        FROM dbo.CatCountry
        WHERE IdCountry= @IdCountry

        SELECT @Currency = ccc.CodeISO
         FROM DeliveryCurrency dc
        INNER JOIN CatCurrencyCOD ccc
        ON ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
        WHERE Currency_IdCountry = @IdCountry
          and DefaultPerCountry = 1

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
             , @Demonym 
             , 1
             , @Token
             , GETDATE()
             , NULL
             , NULL
             , @IdCountry
          FROM DenariusDesktop_Dev.dbo.LGT_INF_Employee emp
         WHERE emp.CodeEmployee =  @Code;

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
             , 'DESKTOP'
             , @Currency
             , NULL
             , NULL
             , 1
             , @Token
             , GETDATE()
             , NULL
             , NULL
             , @CodeArea
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
       WHERE usr.USR_IdUser =   @Code
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
       , 2             -- UstIdSystem - int 2= Hermes Desktop CatSystem
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
       @rol            -- RusIdRol - int
       , 2               -- RusIdSystem - int 2= Hermes Desktop
       , @IdRegisterUser -- RusIdUser - bigint
       , 1               -- RusRowStatus - bit
       , @Token          -- RusTokenCreated - varchar(50)
       , GETDATE()       -- RusDateCreated - datetime
       , NULL            -- RusTokenUpdated - varchar(50)
       , NULL            -- RusDateUpdated - datetime
       , @idStation      -- StationId - int
      );

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