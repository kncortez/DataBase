-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2021-09-22>
-- Update date: <2021-09-22>
-- Description:	<Setup Usuario no existente en Portal Web Corporativo>
-- =============================================


CREATE PROCEDURE [dbo].[spws_SetHwNewCorporateUser]
@UserCode BIGINT,
@UserName VARCHAR(50),
@UserPassword VARCHAR(200),
@gender VARCHAR(1)='',-- M Male / F Female
@Cui VARCHAR(50) = '',
@IdRol BIGINT = 6,
@IdVisitPointClient BIGINT

AS

BEGIN


DECLARE @firstName VARCHAR(50)='';
DECLARE @lastName VARCHAR (50)='';
DECLARE @idCustomer BIGINT;
DECLARE @nationality VARCHAR(50);
DECLARE @email NVARCHAR(MAX);

SELECT  @email = cu.ContactEmail, @nationality = cu.CountryID, @firstName = vpc.DescriptionOfClient, @idCustomer = vpc.CustomerID 
FROM DeliveryBackOffice.dbo.Customer cu WITH (NOLOCK)
JOIN DeliveryBackOffice.dbo.VisitPointClient vpc ON vpc.CustomerID = cu.IdCustomer
WHERE vpc.IdVisitPointClient=@IdVisitPointClient


IF EXISTS (SELECT * FROM DeliveryBackOffice.dbo.InternalUser WHERE IdUser = @UserCode )
BEGIN

SELECT 'Codigo de usuario ya fue asignado a otro usuario ingresar uno nuevo'

END

ELSE

BEGIN

BEGIN TRANSACTION

BEGIN TRY

-- Makes an insert into table person once the user was found on Denarius
INSERT INTO DeliveryBackOffice.dbo.Person  
					(PerFirstName
					,PerLastName
					,PerGender
					,PerIdentification
					,PerNationality
					,PerRowStatus
					,PerTokenCreated
					,PerDateCreated)
					VALUES(ISNULL(@firstName,''),ISNULL(@lastName,''), @gender,@Cui,@nationality, 1,'SYS-ADMIN',GETDATE())
					
					DECLARE @IdPerson AS BIGINT =  SCOPE_IDENTITY();

--Makes an insert into table RegisterUser once person was created
DECLARE @ExpirationDate AS DATE = (SELECT DATEADD(DAY,90,GETDATE()));
					
INSERT INTO DeliveryBackOffice.dbo.RegisterUser  
						(UsrIdPerson
						,UsrNickName
						,UsrEmail
						,UsrAvatar
						,UsrLastPassword
						,UsrPasswordExpiration
						,UsrLang
						,UsrDeviceType
						,UsrCurrency
						,UsrEnable2FA
						,UsrRestrictionAddressIp
						,UsrRowStatus
						,UsrTokenCreated
						,UsrDateCreated
						)
					VALUES(@IdPerson, ISNULL(@firstName,''),ISNULL(@email,''),null,@UserPassword,@ExpirationDate,'ES','WEB','GTZ',null,null, 1,'SYS-ADMIN',GETDATE())
					DECLARE @IdUser AS BIGINT =  SCOPE_IDENTITY();

-- Makes an insert into table UserSystemRestriction once the user was registered
INSERT INTO DeliveryBackOffice.dbo.UserSystemRestriction  
						(UstIdUser
						,UstIdSystem	-- System 1 equals to Hermes Web Portal
						,UstAccessRetries -- 10 attemps by default
						,UstRetries      -- Counter needs to start in 0
						,UstStatus		--- When is being created set up in ACTIVE
						,UstRowStatus
						,UstTokenCreated
						,UstDateCreated
						,UstOperationDate)
					VALUES (@IdUser,1,10,0,'ACTIVE', 1,'SYS-ADMIN',GETDATE(),GETDATE())

-- Makes an insert into table RolByUserBySystem once the user was registered
INSERT INTO DeliveryBackOffice.dbo.RolByUserBySystem
						(RusIdRol
						,RusIdSystem
						,RusIdUser
						,RusRowStatus
						,RusTokenCreated
						,RusDateCreated)
						VALUES(@IdRol,1,@IdUser,1,'SYS-ADMIN', GETDATE())

-- Makes an insert into table InternalUser once the user was registered

INSERT INTO DeliveryBackOffice.dbo.InternalUser
						(IdUser
						,Username
						,RegisterUserID
						,RowStatus
						,TokenCreated
						,DateCreated
						)
						VALUES(@UserCode,@UserName,@IdUser,1,'SYS-ADMIN',GETDATE())

--Makes an insert into table Account once the internal user was created

INSERT INTO DeliveryBackOffice.dbo.Account
						(AccName
						,AccIdTypeAccount
						,AccRowStatus
						,AccTokenCreated
						,AccDateCreated
						,IdCustomer
						,AccConfirm
						)
						VALUES(CAST(concat('Corporativo ',ISNULL(@firstName,'')) AS VARCHAR(100)),2,1,'SYS-ADMIN',GETDATE(),@idCustomer,'C')

						DECLARE @IdAccount AS BIGINT =  SCOPE_IDENTITY();

--Makes an insert into table RolByUserByAccount onse the account was created

INSERT INTO DeliveryBackOffice.dbo.RolByUserByAccount
						(RuaIdRol
						,RuaIdUser
						,RuaIdAccount
						,RuaRowStatus
						,RuaTokenCreated
						,RuaDateCreated
						)
						VALUES(@IdRol,@IdUser,@IdAccount,1,'SYS-ADMIN', GETDATE())

-- Makes an inser into table VisitPointByUser, so the user can add clients to the corporate portfolio

INSERT INTO DeliveryBackOffice.dbo.VisitPointByUser
(IdVisitPointClient
,RegisterUserID
,RowStatus
,TokenCreated
,DateCreated)
VALUES(@IdVisitPointClient,@IdUser,1,'SYS-ADMIN', GETDATE())

END TRY

BEGIN CATCH	


SELECT 'Error al Crear usuario' AS message,
				'FALSE'	blnResult,
				CAST(-1 AS VARCHAR(5)) IdResult,
				CAST(500 AS VARCHAR(5)) StatusResult,
				CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
				CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
				CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
				CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
				CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
				CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage;

ROLLBACK TRANSACTION

END CATCH;

IF @@TRANCOUNT > 0 BEGIN

COMMIT TRANSACTION;

SELECT 'Usuario Creado exitosamente'

END

END

END;
