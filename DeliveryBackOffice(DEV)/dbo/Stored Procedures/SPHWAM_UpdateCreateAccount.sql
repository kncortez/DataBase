
-- =============================================
-- Author:		<Edelman>
-- Create date: <2024-11-11>
-- Description:	<Actualizar datos de cuenta creada desde APP movil>
-- =============================================

CREATE PROCEDURE [dbo].[SPHWAM_UpdateCreateAccount]
	-- Add the parameters for the stored procedure here
	@FirstName  VARCHAR(200),  
	@LastName  VARCHAR(200),  	
	@Gender  VARCHAR(200),
	@Birthdate  DATE,
	@Identification  VARCHAR(200),
	@Nationality  VARCHAR(200),
	@Email  VARCHAR(200),
	@NickName VARCHAR(100),
	@Language  VARCHAR(2) = 'ES', -- ESPAÑOL
	@DeviceType VARCHAR(200),
	@Currency VARCHAR(10),
	@IdSystem INT = 1,
	@TypeAccount AS CHAR(3) = 'IND',
	@PhoneNumber AS VARCHAR(30),
	@CountryId AS NVARCHAR(2) ='GT'
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @PrefixCallingCode VARCHAR(4) = LEFT(@PhoneNumber, 4)
	SET  @PhoneNumber = RIGHT(@PhoneNumber,8)

	DECLARE @NewMainUserRol INT = (SELECT TOP 1 CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Nuevo estandar' );

	DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI AND CountryId= @CountryId);
	DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI AND CountryId = @CountryId);
	DECLARE @IdentificationValue NVARCHAR(200)
	DECLARE @jsonResult NVARCHAR(MAX) 
	DECLARE @IdCustomer as INT        --IdCustomer que se inserta en la tabla dbo.Customer

		-- insertar en tabla temporal posbibles mensajes de error

		IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;
			select * INTO #errormessage from (SELECT  500 AS IdResult
					,'Este correo ya fue registrado anteriormente' AS Message
					,'Exist' as Id 
			union
			SELECT  500 AS IdResult
					,'Error fatal intente de nuevo mas tarde'  AS Message
					,'Transaction' as Id 
			union
			SELECT  1 AS IdResult
					,'Cuenta modificada correctamente' AS Message
					,'Ok' as Id )  as errror

		-- validar que el correo no exite

		IF EXISTS(SELECT top 1  1 FROM RegisterUser usr where usr.UsrEmail = @Email)   -- no existe usuario, por lo tanto lo crea
			BEGIN
				IF @TypeAccount = 'IND' 
				BEGIN
				SET @IdentificationValue = @Identification;
				END
				ELSE IF @TypeAccount = 'EMP'
				BEGIN
				SET @IdentificationValue = '';
				END
				BEGIN TRANSACTION
				BEGIN TRY
				
				-- insertar registro en la tabla persona
					UPDATE  DeliveryBackOffice.dbo.Person  
					SET 
					 PerFirstName = @FirstName,
                	 PerLastName = @LastName,					
					 PerGender = @Gender,
					 PerBirthdate = @Birthdate,
					 PerIdentification = @IdentificationValue,
					 PerNationality = @Nationality,
					 PerRowStatus =  1,
					 PerTokenUpdated = 'SYS-ADMIN-MOVILAPP',
					 PerDateCreated =GETDATE()
					WHERE  PerIdPerson = (Select top 1 UsrIdPerson  From dbo.RegisterUser WHERE UsrEmail= @Email)
				

				-- insertar registro en tabla RegisterUser 
				
					UPDATE  DeliveryBackOffice.dbo.RegisterUser  
						SET UsrIdPerson = (Select top 1 UsrIdPerson  From dbo.RegisterUser WHERE UsrEmail= @Email)
						,UsrNickName = @NickName
						,UsrLang = @Language
						,UsrDeviceType = @DeviceType
						,UsrCurrency=@Currency
						,UsrTokenUpdated = 'SYS-ADMIN-MOVILAPP'
						,UsrDateUpdated =GETDATE()
						,PrefixCallingCode = @PrefixCallingCode
						,Phone = @PhoneNumber
						WHERE UsrIdUser =  (Select top 1 UsrIdUser From dbo.RegisterUser WHERE UsrEmail= @Email)

			
		

				END TRY
				BEGIN CATCH				
				   
				   	SELECT  IdResult 'IdResul' ,
					  [Message] AS 'Message' FROM #errormessage WHERE Id = 'Transaction'

					ROLLBACK TRANSACTION
				END CATCH;
				IF @@TRANCOUNT > 0 BEGIN
					COMMIT TRANSACTION;
				
					SELECT  IdResult 'IdResul' ,
					  [Message] AS 'Message' FROM #errormessage WHERE Id ='Ok'
				END

				
			end
			else -- el usuario ya esta registrado
			BEGIN
			
					SELECT  IdResult AS 'IdResul' ,
					  [Message] AS 'Message' FROM #errormessage WHERE Id ='Exist'
		

			END

		-- destruir tablas temporales

		IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;

END
