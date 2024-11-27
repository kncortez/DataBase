
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Método para registrar dirección y punto de visita>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-08-26>
-- Description:	<Se agrega la opción de tener una única dirección favorita para Origen>
-- =============================================
-- =============================================
<<<<<<< HEAD
-- Author:		<Cristian Suazo>
-- Create date: <2024-10-24>
-- Description:	<Se agrega la opcion de editar datos desde un usuario de EXP>
-- =============================================

=======
-- Author:		<Aylinne Recinos>
-- Create date: <2024-11-27>
-- Description:	<Edición de join para almacenamiento de dirección y modificación en valor de contact name>
-- =============================================
>>>>>>> feature/FDAPI-3005-backend-aplicación-de-cliente
CREATE PROCEDURE [dbo].[spws_set_address]
	-- Add the parameters for the stored procedure here

	@IdAddress bigINT,
	@IdTownship INT = NULL,
	@IdAccount bigINT ,
	@IdCountry  nvarchar(10) = 'GT',
	@FullName  nvarchar(200) ,
	@Address1  nvarchar(600),
	@Address2  nvarchar(250),
	@NirPhone  nvarchar(10) ,
	@Phone  nvarchar(50) ,
	@AdditionalInstructions  nvarchar(250) ,
	@Status INT = 1,
	@Token nvarchar(200),
	@IdCityPlace int = 31,
	@Latitude varchar(50)=NULL,
	@Longitude varchar(50)=NULL,
	@Neighborhood varchar(50) = NULL,
	@Zone smallint = NULL,
	@ProvinceTownship NVARCHAR(100) = '', -- Posible texto con datos de municipio y/o departamento concatenados
	@IdPopulated int = NULL,
	@Predeterminated bit = NULL,
	@VisibleInGuide bit = NULL,
	@PickupsProgram bit = NULL,
	@IsOriginVisitPoint bit = 1,
	@ContactName NVARCHAR(200) = NULL,
	@IsFavorite bit = 0,
	@Email NVARCHAR(200) = NULL,
	@IsUserExp BIT = 0
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 
	DECLARE @CodeOfReference INT
	DECLARE @IdCustomer INT
	DECLARE @TownshipName NVARCHAR(200)
	DECLARE @Department NVARCHAR(100)
	DECLARE @IdKindOfVPClient INT
	DECLARE @IdKindOfVPBusiness INT
	DECLARE @IdVisitPointClient INT
	DECLARE @HeaderCode VARCHAR(10)
	DECLARE @CityName VARCHAR(50)
	DEClARE @IdDepartment INT;
	DECLARE @IdAddressFavorite bigINT;
	DECLARE @ValidUserExp INT
	DECLARE @SystemEXP INT

	DECLARE @ResponseMessages AS TABLE (
		IdResult INT,
		[Message] NVARCHAR(50),
		Id NVARCHAR(10)
	);
	
	DECLARE @UpdatedAddress AS TABLE (
		IdUpdated BIGINT
	);

	-- insertar en tabla temporal posbibles mensajes de respuesta
	
	INSERT INTO @ResponseMessages
		(IdResult, [Message], Id)
	select IdResult,Message,Id 
	from (SELECT  200 AS IdResult
			,'Registro creado correctamente' AS Message
			,'Insert' as Id 
	union
	SELECT  500 AS IdResult
			,'Usuario no asociado a cuenta' AS Message
			,'Access' as Id 
	union
	SELECT  200 AS IdResult
			,'Registro actualizado correctamente' AS Message
			,'Update' as Id 
	union
	SELECT  200 AS IdResult
			,'Registro Eliminado' AS Message
			,'Delete'  as Id
	union
	SELECT  500 AS IdResult
			,'Error al ejecutar la operación ' AS Message
			,'Error' as Id) as messagess
			
	-- Figurar municipio en caso no venga un identificador

	PRINT '@IdTownship'
	PRINT @IdTownship
	IF(@IdTownship IS NULL)
	BEGIN

		SET @IdTownship = (SELECT TOP 1 Twn.IdTownship FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE @ProvinceTownship LIKE '%'+Twn.TownshipName+'%' COLLATE Latin1_General_CI_AI);

	END

	-- obtener el id de usuarion con base al token

	declare @IdUser bigint
	
	 select top 1 @IdUser = t.TknIdUser,
				  @ValidUserExp = t.TknIdSystem
	from TokenLog t with(nolock) 
	where t.TknIdToken = @Token

	select RuaIdAccount 
	into #Access
	from dbo.RolByUserByAccount  rua
	where rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser

	BEGIN TRANSACTION
	BEGIN TRY
		
		SET @SystemEXP =
		(
			SELECT SysIdSystem
			FROM CatSystem WITH (NOLOCK)
			WHERE SysNameSystem = 'Hermes Web'
		)

		IF @IsUserExp = 1 AND @ValidUserExp = @SystemEXP
		BEGIN
			SET @IsUserExp = 1
		END
		ELSE
		BEGIN
			SET @IsUserExp = 0
		END

		if(select count(RuaIdAccount) from #Access)>0 OR @IsUserExp = 1 -- el usuario tiene acceso  a la cuenta indicada
		begin

			select uad.UadIdAddress
			into #Address
			from dbo.UserAddress uad
			where uad.UadIdAddress =  @IdAddress and uad.UadIdAccount = @IdAccount
		
				SET @IdCustomer      = (SELECT IdCustomer FROM Account with(nolock) WHERE AccIdAccount = @IdAccount)
				SELECT @Department=ProvinceName,@IdDepartment=PV.IdProvince FROM Province PV  with(nolock)
									  INNER JOIN Township TS with(nolock) ON PV.IdProvince = TS.IdProvince
									  WHERE TS.IdTownship = @IdTownship;
				SET @IdKindOfVPClient = (SELECT IdKindOfVPClient FROM KindOfVPClient with(nolock) WHERE KindOfVPName = 'HUB' AND (IdCountry = @IdCountry OR (@IdCountry = 'GT' AND IdCountry IS NULL)))
				SET @IdKindOfVPBusiness = (SELECT IdKindOfVPBusiness  FROM KindOfVPBusiness with(nolock) WHERE Shorthand = 'HUB' AND (IdCountry = @IdCountry OR (@IdCountry = 'GT' AND IdCountry IS NULL)))
				Select @HeaderCode=HeaderCode, @TownshipName=TownshipName from dbo.Township with(nolock) WHERE IdTownship = @IdTownship;
				SET @CityName=(SELECT CityPlace FROM DBO.CatCityPlace with(nolock) WHERE IdCityPlace=@IdCityPlace)


				PRINT '@Department'
				PRINT @Department

				PRINT '@HeaderCode'
				PRINT @HeaderCode
			

			if (select count(*) from #Address) >0 -- verifica que la direccion exista
			begin 
				if @Status =0  -- se infiere que, se va a desctivar el registro
				begin
					-- desactivar registro (borrado logico)
					UPDATE [dbo].[UserAddress]
					   SET [UadRowStatus] = @Status
						  ,[UadFavorite] = 0
						  ,[UadTokenUpdated] = @Token
						  ,[UadDateUpdated] = GETDATE()
					 WHERE [UadIdAddress] =  @IdAddress

					UPDATE VP
					   SET VP.[StatusClient]=@Status
						   ,VP.[TokenUpdated]=@Token
						   ,VP.[DateUpdated]=GETDATE()
					FROM [dbo].[UserAddress] UADD LEFT JOIN [dbo].[VisitPointClient] VP with(nolock)
						ON UADD.CodeOfReference=VP.CodeOfReference
					 WHERE [UadIdAddress] =  @IdAddress

					 set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"IdAddress":' + convert(varchar,@IdAddress)    +',' 
						+ '"Message":"' + Message + '"}' from @ResponseMessages where Id ='Delete'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
						)

				end
				else -- se va a actualizar el registro
				begin 
					--Es favorita la dirección?
					IF (@IsFavorite = 1 AND @IsOriginVisitPoint = 1)
					BEGIN
						--Cosultar si ya existe otra favorita
						SELECT TOP 1
							@IdAddressFavorite = ua.UadIdAddress
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
							AND conf.TownshipId = vp.IdTownship
							AND conf.[Address] = vp.[Address]
						WHERE rua.RuaIdAccount = @IdAccount
							  AND rua.RuaIdUser = @IdUser
							  AND ua.UadRowStatus = 1
							  AND ua.UadFavorite = 1 --Debe ser favorita
							  AND ISNULL(vp.IsOriginVisitPoint, 1) = 1 --Debe ser Origen

						IF (@IdAddressFavorite IS NOT NULL AND @IdAddressFavorite > 0)
						BEGIN
							IF(@IdAddressFavorite != @IdAddress)
							BEGIN
								UPDATE [dbo].[UserAddress]
							   SET [UadTokenUpdated] = @Token
								  ,[UadDateUpdated] = GETDATE()
								  ,[UadFavorite] = 0 --Se elimina la favorita actual
								WHERE [UadIdAddress] =  @IdAddressFavorite
							END;
						END;
					END;
					--Es origen la direccion
					ELSE IF (@IsFavorite = 1 AND @IsOriginVisitPoint = 0)
					BEGIN
						SET @IsFavorite = 0; --Se cambia ya que solo puede ser favorita una direccion de Origen
					END;

					-- actualizar el registro con los datos proporcionado
					UPDATE [dbo].[UserAddress]
					   SET [UadIdTownship] = @IdTownship
						  ,[UadIdAccount] =@IdAccount
						  ,[UadIdCountry] = @IdCountry
						  ,[UadFullName] =@FullName
						  ,[UadAddress1] = @Address1
						  ,[UadAddress2] = @Address2
						  ,[UadNirPhone] = @NirPhone
						  ,[UadPhone] = @Phone
						  ,[UadAdditionalInstructions] = @AdditionalInstructions
						  ,[UadTokenUpdated] = @Token
						  ,[UadDateUpdated] = GETDATE()
						  ,[IdCityPlace] = @IdCityPlace
						  ,[UadFavorite] = @IsFavorite
					 WHERE [UadIdAddress] =  @IdAddress

					UPDATE VP
					   SET VP.IdTownship = @IdTownship
						  --,VP.ACC =@IdAccount
						  ,VP.CountryId = @IdCountry
						  ,VP.DescriptionOfClient =@FullName
						  ,VP.Address = CAST((@Address1 + @Address2) AS NVARCHAR(600))
						  ,VP.Phone =@Phone
						  ,VP.TokenUpdated = @Token
						  ,VP.DateUpdated = GETDATE()
						  ,VP.Town=@TownshipName
						  ,VP.Department=@Department
						  ,VP.IdKindOfVPClient=@IdKindOfVPClient
						  ,VP.IdKindOfVPBusiness=@IdKindOfVPBusiness
						  ,VP.Latitude=@Latitude
						  ,VP.Longitude=@Longitude
						  ,VP.IsOriginVisitPoint = ISNULL(@IsOriginVisitPoint, 1)
						  ,VP.ContactName = @ContactName
						  ,VP.Email = ISNULL(@Email, VP.Email)
						  ,VP.IdSettlement = @IdPopulated
					FROM [dbo].[UserAddress] UADD LEFT JOIN [dbo].[VisitPointClient] VP with(nolock)
						ON UADD.CodeOfReference=VP.CodeOfReference
					 WHERE [UadIdAddress] =  @IdAddress

					 set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"IdAddress":' + convert(varchar,@IdAddress)    +',' 
						+ '"Message":"' + Message + '"}' from @ResponseMessages where Id ='Update'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
						)
				end
			end
			else -- la cuenta no existe, entonces se crea
			begin
				--Es favorita la dirección?
					IF (@IsFavorite = 1 AND @IsOriginVisitPoint = 1)
					BEGIN
						--Cosultar si ya existe otra favorita
						SELECT TOP 1
							@IdAddressFavorite = ua.UadIdAddress
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
							AND conf.TownshipId = vp.IdTownship
							AND conf.[Address] = vp.[Address]
						WHERE rua.RuaIdAccount = @IdAccount
							  AND rua.RuaIdUser = @IdUser
							  AND ua.UadRowStatus = 1
							  AND ua.UadFavorite = 1 --Debe ser favorita
							  AND ISNULL(vp.IsOriginVisitPoint, 1) = 1 --Debe ser Origen

						IF (@IdAddressFavorite IS NOT NULL AND @IdAddressFavorite > 0)
						BEGIN
							IF(@IdAddressFavorite != @IdAddress)
							BEGIN
								UPDATE [dbo].[UserAddress]
							   SET [UadTokenUpdated] = @Token
								  ,[UadDateUpdated] = GETDATE()
								  ,[UadFavorite] = 0 --Se elimina la favorita actual
								WHERE [UadIdAddress] =  @IdAddressFavorite
							END;
						END;
					END;
					--Es origen la direccion
					ELSE IF (@IsFavorite = 1 AND @IsOriginVisitPoint = 0)
					BEGIN
						SET @IsFavorite = 0; --Se cambia ya que solo puede ser favorita una direccion de Origen
					END;

				SET @CodeOfReference = (SELECT MAX(CodeOfReference) + 1 FROM VisitPointClient)			
						--Inserta Visit Point en la tabla VisitPointClient
				INSERT INTO [dbo].[VisitPointClient]
					   ([CodeOfReference]
					   ,[DescriptionOfClient]
					   ,[StatusClient]
					   ,[CountryId]
					   ,[VisitPointId]
					   ,[TokenCreated]
					   ,[DateCreated]
					   ,[TokenUpdated]
					   ,[DateUpdated]
					   ,[CustomerID]
					   ,[Address]
					   ,[Zone]
					   ,[Town]
					   ,[Department]
					   ,[Phone]
					   ,[ContactName]
					   ,[IdKindOfVPClient]
					   ,[IdKindOfVPBusiness]
					   ,[IdSettlement]
					   ,[Email]
					   ,[IdTownship]
					   ,[Latitude]
					   ,[Longitude]
					   ,[IsOriginVisitPoint])
				 VALUES
					   (
						@CodeOfReference
					   ,@FullName
					   ,@Status
					   ,@IdCountry
					   ,NULL
					   ,@Token
					   ,GETDATE()
					   ,NULL
					   ,NULL
					   ,@IdCustomer
					   ,CAST((@Address1 + @Address2) AS NVARCHAR(600))
					   ,NULL
					   ,@TownshipName
					   ,@Department
					   ,@Phone
					   ,@ContactName
					   ,@IdKindOfVPClient
					   ,@IdKindOfVPBusiness
					   ,@IdPopulated
					   ,@Email
					   ,@IdTownship
					   ,@Latitude
					   ,@Longitude
					   ,ISNULL(@IsOriginVisitPoint, 1)
					   )
				set @IdVisitPointClient = SCOPE_IDENTITY()


				--insertar nueva direccion
				INSERT INTO [dbo].[UserAddress]
						([UadIdTownship]
						,[UadIdAccount]
						,[UadIdCountry]
						,[UadFullName]
						,[UadAddress1]
						,[UadAddress2]
						,[UadNirPhone]
						,[UadPhone]
						,[UadAdditionalInstructions]
						,[UadRowStatus]
						,[UadTokenCreated]
						,[UadDateCreated]
						,[UadTokenUpdated]
						,[UadDateUpdated]
						,CodeOfReference
						,IdCityPlace
						,[UadFavorite])
						VALUES
						(@IdTownship
						,@IdAccount
						,@IdCountry
						,@FullName
						,CAST(@Address1 AS NVARCHAR(600))
						,@Address2
						,@NirPhone
						,@Phone
						,@AdditionalInstructions
						,1 -- se crean los registros activos por default 
						,@Token
						,getdate()
						,null
						,null
						,@CodeOfReference
						,@IdCityPlace
						,@IsFavorite)



				set @IdAddress = SCOPE_IDENTITY()
				set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"IdAddress":' + convert(varchar,@IdAddress)    +',' 
						+ '"CodeOfReference":' + convert(varchar,@CodeOfReference)    +',' 
						+ '"Province":"' + convert(varchar,@Department)    +'",' 
						+ '"Township":"' + convert(varchar,@TownshipName)    +'",' 
						+ '"HeaderCode":"' + convert(varchar,@HeaderCode)    +'",' 
						+ '"CityPlace":"' + convert(varchar,@CityName) +'",' 
						+ '"IdProvince":"' + convert(varchar,@IdDepartment) +'",' 
						+ '"Message":"' + Message + '"}' from @ResponseMessages where Id ='Insert'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
						)			
			end
			--------INICIO Homologación de campos para OAC (Tabla: ConfirmedAddres)--------
			if @Status = 0
			begin 
					UPDATE [dbo].[ConfirmedAddress] SET
							   [TokenUpdate] =@Token
							   ,[DateUpdate] =getdate()
							   ,[RowStatus] =0
					WHERE NirPhone=@NirPhone AND Phone=@Phone			
			end
			else if @Status = 1
			begin 
				--Comprobar si existe el telefono
				if EXISTS(SELECT TOP 1 1 FROM DBO.ConfirmedAddress WHERE NirPhone=@NirPhone AND Phone=@Phone AND ProvinceId = @IdDepartment AND TownshipId = @IdTownship AND [Address] = @Address1)
				begin
					UPDATE [dbo].[ConfirmedAddress] SET
							   [NirPhone] =@NirPhone
							   ,[Phone] = @Phone
							   ,[TokenUpdate] =@Token
							   ,[DateUpdate] =getdate()
							   ,[RowStatus] =1
							   ,[AccountId] = @IdAccount
							   ,[ProvinceId] = @IdDepartment
							   ,[TownshipId] = @IdTownship
							   ,[NameAddress] = @FullName
							   ,[Address] = @Address1 
							   ,[AdditionalInstructions] = @AdditionalInstructions
							   ,[CityPlaceId] = @IdCityPlace
							   ,[CodeOfReference] = @CodeOfReference
							   ,[DeliveryOptionId] = NULL
							   ,[Latitude] = @Latitude
							   ,[Longitude] = @Longitude
							   ,[Neighborhood] = @Neighborhood
							   ,[Zone] = @Zone
					OUTPUT inserted.IdConfirmedAddress INTO @UpdatedAddress (IdUpdated)
					WHERE NirPhone=@NirPhone 
							AND 
							Phone=@Phone 
							AND 
							ProvinceId = @IdDepartment
							AND 
							TownshipId = @IdTownship 
							AND 
							[Address] = @Address1;
						
					-- Asociar dirección con cliente que la reporta, siempre que esta no exista bajo el mismo cliente
					IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfirmedAddressByCustomer] CABC WITH(NOLOCK) INNER JOIN @UpdatedAddress UA ON CABC.ConfirmedAddressId = UA.IdUpdated WHERE CABC.CustomerId = @IdCustomer AND CABC.RowStatus = 1) )
					BEGIN

						INSERT INTO [DeliveryBackOffice].[dbo].[ConfirmedAddressByCustomer]
							(CustomerId, ConfirmedAddressId, TokenCreated, DateCreated)
						SELECT
							DISTINCT
								@IdCustomer, UA.IdUpdated, @Token, GETDATE()
						FROM
							@UpdatedAddress UA

					END
				end
				else
				begin
					--Si no existe, crearlo
					INSERT INTO [dbo].[ConfirmedAddress]
						([NirPhone]
						,[Phone]
						,[TokenCreated]
						,[DateCreated]
						,[TokenUpdate]
						,[DateUpdate]
						,[RowStatus]
						,[AccountId]
						,[ProvinceId]
						,[TownshipId]
						,[NameAddress]
						,[Address]
						,[AdditionalInstructions]
						,[CityPlaceId]
						,[CodeOfReference]
						,[DeliveryOptionId]
						,[Latitude]
						,[Longitude]
						,[Neighborhood]
						,[Zone]
						,[StatusAddressId])
					OUTPUT inserted.IdConfirmedAddress INTO @UpdatedAddress (IdUpdated)
					VALUES
						(@NirPhone
						,@Phone
						,@Token
						,getdate()
						,NULL
						,NULL
						,1
						,@IdAccount
						,@IdDepartment
						,@IdTownship
						,@FullName
						,@Address1 
						,@AdditionalInstructions
						,@IdCityPlace
						,@CodeOfReference
						,NULL
						,@Latitude
						,@Longitude
						,@Neighborhood
						,@Zone
						,(select top 1 IdStatus from dbo.CatStateConfirmedAddress where NameState='CONFIRMADO'));
					
					-- Asociar dirección con cliente que la reporta, siempre que esta no exista bajo el mismo cliente
					IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfirmedAddressByCustomer] CABC WITH(NOLOCK) INNER JOIN @UpdatedAddress UA ON CABC.ConfirmedAddressId = UA.IdUpdated WHERE CABC.CustomerId = @IdCustomer AND CABC.RowStatus = 1) )
					BEGIN

						INSERT INTO [DeliveryBackOffice].[dbo].[ConfirmedAddressByCustomer]
							(CustomerId, ConfirmedAddressId, TokenCreated, DateCreated)
						SELECT
							DISTINCT
								@IdCustomer, UA.IdUpdated, @Token, GETDATE()
						FROM
							@UpdatedAddress UA

					END
				end			
			end

			COMMIT TRANSACTION;

			--------FIN Homologación de campos para OAC --------
		end
		else
		begin

			ROLLBACK TRANSACTION;

			set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"IdAddress":' + convert(varchar,@IdAddress)    +',' 
						+ '"Message":"' + Message + '"}' from @ResponseMessages where Id ='Access'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
						)
		end
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
			(ErrorProcedure, ErrorDescription, TokenCreated, DateCreated, ErrorLine)
		VALUES
			('spws_set_address', ERROR_MESSAGE(), @Token, GETDATE(), ERROR_LINE())

		set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"IdAddress":' + convert(varchar,@IdAddress)    +',' 
					+ '"Message":"' + Message + '"}' from @ResponseMessages where Id ='Error'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
							) 
					)
	END CATCH

	-- destruir tablas temporales

	IF OBJECT_ID('tempdb.dbo.#Address', 'U') IS NOT NULL DROP TABLE #Address;
	IF OBJECT_ID('tempdb.dbo.#Access', 'U') IS NOT NULL DROP TABLE #Access;

	-- retornar resultado en formato json

	select ('[{' + @jsonResult +  ']') jsonResult

END



