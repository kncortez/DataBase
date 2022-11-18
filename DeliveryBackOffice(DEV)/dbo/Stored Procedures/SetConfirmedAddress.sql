-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <05-09-2022>
-- Description:	<Crea una nuevo registro en la tabla de direcciones confirmadas>
-- =============================================
CREATE PROCEDURE [dbo].[SetConfirmedAddress]
	-- Add the parameters for the stored procedure here
	@IdTownship INT = NULL,
	@IdAccount bigINT ,
	@IdCountry  nvarchar(10) = 'GT',
	@FullName  nvarchar(200) ,
	@Address1  nvarchar(600),
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
	@ProvinceTownship NVARCHAR(100) = '' -- Posible texto con datos de municipio y/o departamento concatenados
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX); 
	DECLARE @CodeOfReference INT;

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
			,'Delete' as Id) as messagess

	-- Figurar municipio en caso no venga un identificador
	IF(@IdTownship IS NULL)
	BEGIN

		SET @IdTownship = (SELECT TOP 1 Twn.IdTownship FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE @ProvinceTownship LIKE '%'+Twn.TownshipName+'%' COLLATE Latin1_General_CI_AI);

	END
	
	-- obtener el id de usuarion con base al token
	DECLARE @CustomerId INT = (SELECT TOP 1 Acc.IdCustomer FROM [DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK) WHERE Acc.AccIdAccount = @IdAccount);
	declare @IdUser bigint  = (select top 1 t.TknIdUser from TokenLog t WITH(NOLOCK) where t.TknIdToken = @Token);

	select 
		RuaIdAccount  
	into 
		#Access
	from 
		dbo.RolByUserByAccount  rua WITH(NOLOCK)
	where 
		rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser

	BEGIN TRANSACTION
	BEGIN TRY

		if ((select count(RuaIdAccount) from #Access)>0) -- el usuario tiene acceso  a la cuenta indicada
		begin

			DECLARE @ProvinceId INT = (SELECT TOP 1 Twn.IdProvince FROM [DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK) WHERE Twn.IdTownship = @IdTownship );

			if (@Status = 0)
			begin 
					UPDATE [dbo].[ConfirmedAddress] SET
							   [TokenUpdate] =@Token
							   ,[DateUpdate] =getdate()
							   ,[RowStatus] =0
					WHERE NirPhone=@NirPhone AND Phone=@Phone			
			end
			else if (@Status = 1)
			begin 
				--Comprobar si existe el telefono y dirección "exacta"
				if EXISTS(SELECT TOP 1 1 FROM DBO.ConfirmedAddress WHERE NirPhone=@NirPhone AND Phone=@Phone AND ProvinceId = @ProvinceId AND TownshipId = @IdTownship AND [Address] = @Address1)
				begin

					UPDATE [DeliveryBackOffice].[dbo].[ConfirmedAddress] 
					SET
							   [NirPhone] =@NirPhone
							   ,[Phone] = @Phone
							   ,[TokenUpdate] =@Token
							   ,[DateUpdate] =getdate()
							   ,[RowStatus] =1
							   ,[AccountId] = @IdAccount
							   ,[TownshipId] = @IdTownship
							   ,[ProvinceId] = @ProvinceId
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
					WHERE 
						NirPhone=@NirPhone 
						AND 
						Phone=@Phone 
						AND 
						ProvinceId = @ProvinceId
						AND 
						TownshipId = @IdTownship 
						AND 
						[Address] = @Address1;
						
					-- Asociar dirección con cliente que la reporta, siempre que esta no exista bajo el mismo cliente
					IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfirmedAddressByCustomer] CABC WITH(NOLOCK) INNER JOIN @UpdatedAddress UA ON CABC.ConfirmedAddressId = UA.IdUpdated WHERE CABC.CustomerId = @CustomerId AND CABC.RowStatus = 1) )
					BEGIN

						INSERT INTO [DeliveryBackOffice].[dbo].[ConfirmedAddressByCustomer]
							(CustomerId, ConfirmedAddressId, TokenCreated, DateCreated)
						SELECT
							DISTINCT
								@CustomerId, UA.IdUpdated, @Token, GETDATE()
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
						,[TownshipId]
						,[ProvinceId]
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
						,@IdTownship
						,@ProvinceId
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
						,(select TOP 1 IdStatus from dbo.CatStateConfirmedAddress where NameState='CONFIRMADO'));

					-- Asociar dirección con cliente que la reporta, siempre que esta no exista bajo el mismo cliente
					IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfirmedAddressByCustomer] CABC WITH(NOLOCK) INNER JOIN @UpdatedAddress UA ON CABC.ConfirmedAddressId = UA.IdUpdated WHERE CABC.CustomerId = @CustomerId AND CABC.RowStatus = 1) )
					BEGIN

						INSERT INTO [DeliveryBackOffice].[dbo].[ConfirmedAddressByCustomer]
							(CustomerId, ConfirmedAddressId, TokenCreated, DateCreated)
						SELECT
							DISTINCT
								@CustomerId, UA.IdUpdated, @Token, GETDATE()
						FROM
							@UpdatedAddress UA

					END
				end			
			end	

			-- Si pudo actualizar o insertar dato de dirección confirmada
			IF ( EXISTS (SELECT TOP 1 1 FROM @UpdatedAddress) )
			BEGIN

				COMMIT TRANSACTION;

				set @jsonResult =(
							SELECT STUFF(( 
							SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
							+ '"NirPhone":' + @NirPhone    +',' 
							+ '"Phone":' + @Phone +',' 
							+ '"Message":"' + Message + '"}' from @ResponseMessages where Id ='Insert'
		
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
								  ) 
							)

			END
			ELSE
			BEGIN

				ROLLBACK TRANSACTION;

				set @jsonResult =(
							SELECT STUFF(( 
							SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
							+ '"NirPhone":' + @NirPhone    +',' 
							+ '"Phone":' + @Phone +',' 
							+ '"Message":"' + Message + '"}' from @ResponseMessages where Id ='Access'
		
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
								  ) 
							)

			END

		end
		else
		begin

			ROLLBACK TRANSACTION;

			set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"NirPhone":' + @NirPhone    +',' 
						+ '"Phone":' + @Phone +',' 
						+ '"Message":"' + Message + '"}' from @ResponseMessages where Id ='Access'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
						)
		end
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"NirPhone":' + @NirPhone    +',' 
					+ '"Phone":' + @Phone +',' 
					+ '"Message":"' + Message + '"}' from @ResponseMessages where Id ='Access'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
							) 
					)

	END CATCH

	-- destruir tablas temporales

	IF OBJECT_ID('tempdb.dbo.#Access', 'U') IS NOT NULL DROP TABLE #Access;

	-- retornar resultado en formato json

	select ('[{' + @jsonResult +  ']') jsonResult

END