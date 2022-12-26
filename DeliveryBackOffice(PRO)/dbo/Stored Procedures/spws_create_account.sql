-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-30>
-- Description:	<Login Portal Web>
-- =============================================


CREATE PROCEDURE [dbo].[spws_create_account]
	-- Add the parameters for the stored procedure here
	@FirstName NVARCHAR(100),
	@LastName  NVARCHAR(100) ,
	@Gender  VARCHAR(200),
	@Birthdate  DATE,
	@Identification  VARCHAR(200),
	@Nationality  VARCHAR(200),
	@Email  VARCHAR(200),
	@Password  VARCHAR(200),
	@NickName VARCHAR(100),
	@Language  VARCHAR(2) = 'ES', -- ESPAÑOL
	@DeviceType VARCHAR(200),
	@Currency VARCHAR(10),
	@IdSystem INT = 1,
	@TypeAccount  AS CHAR(3),
	@BusinessName AS VARCHAR(200),
	@URL AS NVARCHAR(MAX),
	@NIT AS VARCHAR(18),
	@PhoneNumber AS VARCHAR(30)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
	DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);

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
			SELECT  200 AS IdResult
					,'Cuenta creada correctamente' AS Message
					,'Ok' as Id )  as errror

		-- validar que el correo no exite

		if (select count(*) from RegisterUser usr where usr.UsrEmail = @Email) =0  -- no existe usuario, por lo tanto lo crea
			begin
				IF @TypeAccount = 'IND' 
				BEGIN
				SET @IdentificationValue = @Identification;
				END
				ELSE IF @TypeAccount = 'EMP'
				BEGIN
				SET @IdentificationValue = @NIT;
				END
				BEGIN TRANSACTION
				BEGIN TRY
				-- insertar registro en la tabla persona
					insert into DeliveryBackOffice.dbo.Person  
					(PerFirstName
					,PerLastName
					,PerGender
					,PerBirthdate
					,PerIdentification
					,PerNationality
					,PerRowStatus
					,PerTokenCreated
					,PerDateCreated)
					Values(@FirstName,@LastName, @Gender,@Birthdate,@IdentificationValue, @Nationality, 1,'SYS-ADMIN',GETDATE())
					
					DECLARE @IdPerson as bigint =  SCOPE_IDENTITY();

				-- 90 dias para cambio de contraseña
					declare @ExpirationDate as date = (SELECT DATEADD(DAY,90,GETDATE()));

				-- insertar registro en tabla RegisterUser 
					
					Insert into  DeliveryBackOffice.dbo.RegisterUser  
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
						,Phone
						)
					Values(@IdPerson, @NickName,@Email,null,@Password,@ExpirationDate,@Language,@DeviceType,@Currency,null,null, 1,'SYS-ADMIN',GETDATE(),@PhoneNumber)
					DECLARE @IdUser as bigint =  SCOPE_IDENTITY();


				--- Insertar tupla de restricciones
					insert into DeliveryBackOffice.dbo.UserSystemRestriction  
						(UstIdUser
						,UstIdSystem
						,UstAccessRetries -- 10 intentos por default
						,UstRetries      -- inicia el contador en 0
						,UstStatus		--- Insertar siempre como ACTIVE
						,UstRowStatus
						,UstTokenCreated
						,UstDateCreated
						,UstOperationDate)
					values (@IdUser,@IdSystem,10,0,'ACTIVE', 1,'SYS-ADMIN',GETDATE(),GETDATE())

				-- CREAR CUSTOMER					
					INSERT INTO [dbo].[Customer]
					   ([Name]
					   ,[Description]
					   ,[Domain]
					   ,[RegexSubject]
					   ,[RegexEmail]
					   ,[RegexFilename]
					   ,[Abbreviation]
					   ,[IdCustomerType]
					   ,BusinessSegmentID 
					   
					--   ,[COD]
					   , SaleAdvisorID
					   ,TypeOfBusinessID
					   ,BusinessActivityID
					   ,CommercialSegmentID
					)
				    VALUES
					   (
					     CAST((@FirstName + ' ' + @LastName) AS NVARCHAR(100))
						,CAST((@FirstName + ' ' + @LastName) AS NVARCHAR(100))
						,CAST(SUBSTRING (@Email, CHARINDEX( '@', @Email ), LEN(@Email)  ) AS nvarchar(50))
						,'^.*solicitud.*$'
						,CAST(('^' + @Email + '$') AS NVARCHAR(100))
						,'^envios_.*\.xls$'
						,CAST((@FirstName + ' ' + @LastName) AS NVARCHAR(25))
						,3
						--,CAST(( select cty.IdCustomerType from dbo.CustomerType cty join dbo.CatTypeAccount city on(upper(city.TacName) = cty.Description) where city.TacShortName = @TypeAccount ) AS INT)
						--,NULL
						,10
						,72
						,16
						,28
						,2
					   )
					    SET @IdCustomer =  SCOPE_IDENTITY();

				--- ASIGNAR TARIFARIO PARA CLIENTES INDIVIDUALES 
					
					INSERT INTO [dbo].[RatebyCustomer]
						(
							[RbcIdRate]
							,[RbcIdCustomer]
							,[RbcRowStatus]
							,[RbcTokenCreated]
							,[RbcDateCreated]
						)
					VALUES
						(
							@NewMainRates
							,@IdCustomer
							,1
							,'SYS-ADMIN'
							,GETDATE()
						)

				-- ASIGNAR TARIFARIO ALTERNO PARA CLIENTES INDIVIDUALES
					INSERT INTO [dbo].[AlternativeRateByCustomer]
						(
							[RateId]
							,[CustomerId]
							,[RowStatus]
							,[TokenCreated]
							,[DateCreated]
						)
					VALUES
						(
							@NewAlternativeRates
							,@IdCustomer
							,1
							,'SYS-ADMIN'
							,GETDATE()
						)
						

				-- CREAR CUENTA
					-- Tipo de cuenta individual
					DECLARE @TypeAccounnt as int =(SELECT tac.TacIdTypeAccount FROM  DeliveryBackOffice.dbo.CatTypeAccount tac where tac.TacShortName = @TypeAccount)
					
					INSERT INTO [dbo].[Account]
					   ([AccName]
					   ,[AccIdTypeAccount]
					   ,[AccRowStatus]
					   ,[AccTokenCreated]
					   ,[AccDateCreated]
					   ,[AccTokenUpdated]
					   ,[AccDateUpdated]
					   ,[IdCustomer]  
					   ,[AccConfirm] -- P = Pendiente de Confirmar / C = Correo Confirmado
					   )
					 VALUES(CAST(concat('Envíos de ',@FirstName) AS VARCHAR(100)),@TypeAccounnt,1,'SYS-ADMIN',GETDATE(),NULL,NULL,@IdCustomer,'P')

					 DECLARE @IdAccount as bigint =  SCOPE_IDENTITY();

					-- MODIFICACIÓN 01/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
					-- Insertar en la tabla de TermnsAndConditionsByUser
					INSERT INTO [dbo].[TermsAndConditionsByUser]
						(TACId
						,IdAccount
						,TAC
						,RowStatus
						,TokenCreated
						,DateCreated
						,TokenUpdated
						,DateUpdated
						)
					VALUES((SELECT TOP 1 IdTAC FROM [dbo].[TermsAndConditions] WHERE RowStatus = 1 AND Name = 'New Termns And Conditions' ORDER BY DateCreated DESC)
							,@IdAccount
							,1
							,1
							,'SYS-ADMIN'
							,GETDATE()
							,NULL
							,NULL
							)
					-- FIN MODIFICACIÓN

				---- Asignar rol por cuenta
					-- rol estadar
					DECLARE @IdRol as int =(select rol.RolIdRol from dbo.CatRol rol where rol.RolIdSystem =@IdSystem and rol.RolName = 'Estandar')

					insert into DeliveryBackOffice.dbo.RolByUserByAccount  
						(RuaIdRol,
						RuaIdUser
						,RuaIdAccount
						,RuaRowStatus
						,RuaTokenCreated
						,RuaDateCreated)
					values (@IdRol,@IdUser,@IdAccount,1,'SYS-ADMIN',GETDATE())

					--inserta los wizards por deafult
					insert into DeliveryBackOffice.dbo.DeliveryWizardAccount
					(AccIdAccount,
					Idwiz,
					StatusAccountWiz,
					DateCreate,
					TokenCreate 
					)
					values(CAST(@IdAccount AS INT),1,1,GETDATE(),'SYS-ADMIN')
					
					insert into DeliveryBackOffice.dbo.DeliveryWizardAccount
					(AccIdAccount,
					Idwiz,
					StatusAccountWiz,
					DateCreate,
					TokenCreate 
					)
					values(CAST(@IdAccount AS INT),2,1,GETDATE(),'SYS-ADMIN')

					insert into DeliveryBackOffice.dbo.DeliveryWizardAccount
					(AccIdAccount,
					Idwiz,
					StatusAccountWiz,
					DateCreate,
					TokenCreate 
					)
					values(CAST(@IdAccount AS INT),3,1,GETDATE(),'SYS-ADMIN')

					-----





				---- Asignar rol por systema
					insert into DeliveryBackOffice.dbo.RolByUserBySystem  
						(RusIdRol
						,RusIdSystem
						,RusIdUser
						,RusRowStatus
						,RusTokenCreated
						,RusDateCreated)
					values (@IdRol,@IdSystem,@IdUser,1,'SYS-CAQUINO',GETDATE())
					
				
				END TRY
				BEGIN CATCH				
					set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"Message":"' + Message +'"}' from #errormessage where Id ='Transaction'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
					ROLLBACK TRANSACTION
				END CATCH;
				IF @@TRANCOUNT > 0 BEGIN
					COMMIT TRANSACTION;
					set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"Message":"' + Message  + '"}' from #errormessage where Id ='Ok'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
				END

				
			end
			else -- el usuario ya esta registrado
			begin
				set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"Message":"' + Message + '"}' from #errormessage where Id ='Exist'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)

			end

		-- destruir tablas temporales

		IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;

		-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult

END
