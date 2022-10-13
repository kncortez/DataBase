-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-09-20>
-- Description:	<Guarda/Modifica/Elimina un punto de visita para cliente referenciado y clientes existentes>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_SetVisitPointClient]
	-- Add the parameters for the stored procedure here
	
	@IdAddress BIGINT,
	@IdTownship INT = NULL,
	@IdAccount BIGINT,
	@IdCountry NVARCHAR(10),
	@FullName NVARCHAR(200),
	@Address1 NVARCHAR(600),
	@Address2 NVARCHAR(250),
	@NirPhone  NVARCHAR(10) ,
	@Phone  NVARCHAR(50) ,
	@AdditionalInstructions  NVARCHAR(250) ,
	@Status BIT = 1,
	@Token NVARCHAR(50),
	@IdCityPlace INT = 31,
	@Latitude VARCHAR(50)=NULL,
	@Longitude VARCHAR(50)=NULL,
	@Neighborhood VARCHAR(50) = NULL,
	@Zone SMALLINT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CodeOfReference INT
	DECLARE @IdCustomer INT 
	DECLARE @TownshipName NVARCHAR(200)
	DECLARE @Department NVARCHAR(100)
	DECLARE @IdKindOfVPBusiness INT
	DECLARE @IdVisitPointClient INT
	DECLARE @HeaderCode VARCHAR(10)
	DECLARE @CityName VARCHAR(50)
	DEClARE @IdDepartment INT;
	DECLARE @IsReferredCustomer BIT = 0;
	DECLARE @UpdatedAddress AS TABLE (
		IdUpdated BIGINT
	);

    -- Insert statements for procedure here
	BEGIN TRANSACTION
	BEGIN TRY

		SET @IdKindOfVPBusiness = (SELECT
				IdKindOfVPBusiness
			FROM KindOfVPBusiness WITH (NOLOCK)
			WHERE Shorthand = 'HUB')


		SELECT
			@Department = ProvinceName
			,@IdDepartment = PV.IdProvince
		FROM Province PV WITH (NOLOCK)
		INNER JOIN Township TS WITH (NOLOCK)
			ON PV.IdProvince = TS.IdProvince
		WHERE TS.IdTownship = @IdTownship

		SELECT
			@HeaderCode = HeaderCode
			,@TownshipName = TownshipName
		FROM dbo.Township WITH (NOLOCK);

		SET @CityName = (SELECT
				CityPlace
			FROM DBO.CatCityPlace WITH (NOLOCK)
			WHERE IdCityPlace = @IdCityPlace)

		-- Buscar cliente referenciado en caso no venga un Account
		IF (@IdAccount IS NULL)
		BEGIN 
			SELECT
				@IdAccount = AccIdAccount
			   ,@IdCustomer = IdCustomer
			FROM Account WITH (NOLOCK)
			WHERE IdCustomer = (SELECT
					IdCustomer
				FROM Customer
				WHERE Name = 'Cliente Referenciado'
				AND Domain = '@forzadelivery')

			SET @IsReferredCustomer = 1
		END
		ELSE
		BEGIN
			-- Buscar IdCustomer
			SELECT
				@IdCustomer = IdCustomer
			FROM Account WITH (NOLOCK)
			WHERE AccIdAccount = @IdAccount
		END

		IF @IdCustomer IS NOT NULL
		BEGIN
			
			--------INICIO Homologación de campos para OAC (Tabla: ConfirmedAddres)--------
			IF @Status = 0
			BEGIN 
					UPDATE ConfirmedAddress
					SET TokenUpdate = @Token
					   ,DateUpdate = GETDATE()
					   ,RowStatus = 0
					WHERE NirPhone = @NirPhone
					AND Phone = @Phone			
			END
			ELSE IF @Status = 1
			BEGIN 
				--Comprobar si existe el telefono
				IF EXISTS (SELECT TOP 1
						1
					FROM DBO.ConfirmedAddress
					WHERE NirPhone = @NirPhone
					AND Phone = @Phone
					AND ProvinceId = @IdDepartment
					AND TownshipId = @IdTownship
					AND [Address] = @Address1)
				BEGIN
					UPDATE ConfirmedAddress SET
							   [NirPhone] =@NirPhone
							   ,[Phone] = @Phone
							   ,[TokenUpdate] =@Token
							   ,[DateUpdate] =GETDATE()
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
				END
				ELSE
				BEGIN
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
						,(SELECT TOP 1 IdStatus from dbo.CatStateConfirmedAddress WHERE NameState='CONFIRMADO'));
					
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
				END			
			END
			--------FIN Homologación de campos para OAC --------

			
			
			-- Si IdAddress es diferente de NULL, es actualización o eliminar
			IF @IdAddress IS NOT NULL 
			BEGIN
				
				DECLARE @ExistsAddress BIT = 0

				SELECT
					@ExistsAddress = 1
				   ,@IsReferredCustomer = IIF(c.[Name] = 'Cliente Referenciado' AND c.[Domain] = '@forzadelivery', 1, 0)
				FROM UserAddress ua WITH (NOLOCK)
				LEFT JOIN Account a WITH (NOLOCK)
					ON ua.UadIdAccount = a.AccIdAccount
				LEFT JOIN Customer c WITH (NOLOCK)
					ON a.IdCustomer = c.IdCustomer
				WHERE ua.UadIdAddress = @IdAddress
				AND ua.UadRowStatus = 1

				IF @ExistsAddress = 1
				BEGIN
					
					-- Si se elimina
					IF @Status = 0
					BEGIN
						
						-- Desactivar filas
						UPDATE UserAddress
						SET UadRowStatus = 0
							,UadTokenUpdated = @Token
							,UadDateUpdated = GETDATE()
						WHERE UadIdAddress = @IdAddress

						UPDATE vpc 
						SET vpc.StatusClient = 0
							,TokenUpdated = @Token
							,DateUpdated = GETDATE()
						FROM UserAddress ua
						LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
							ON ua.CodeOfReference = vpc.CodeOfReference
						WHERE ua.UadIdAddress = @IdAddress

						SELECT
							1 AS 'StatusCode'
						   ,'Se ha eliminado la dirección correctamente.' AS 'Description'
						   ,@IdAddress AS 'IdAddress'
						   ,@CodeOfReference AS 'CodeOfReference'
						   ,@IdAccount AS 'IdAccount'
						   ,@IsReferredCustomer AS 'IsReferredCustomer'

						COMMIT TRANSACTION
					END
					ELSE 
					BEGIN	
						-- Es actualización
						UPDATE [dbo].[UserAddress]
						SET [UadIdTownship] = @IdTownship
						   ,[UadIdAccount] = @IdAccount
						   ,[UadIdCountry] = @IdCountry
						   ,[UadFullName] = @FullName
						   ,[UadAddress1] = @Address1
						   ,[UadAddress2] = @Address2
						   ,[UadNirPhone] = @NirPhone
						   ,[UadPhone] = @Phone
						   ,[UadAdditionalInstructions] = @AdditionalInstructions
						   ,[UadTokenUpdated] = @Token
						   ,[UadDateUpdated] = GETDATE()
						   ,[IdCityPlace] = @IdCityPlace
						WHERE [UadIdAddress] = @IdAddress

						UPDATE vp
						SET vp.IdTownship = @IdTownship
						   ,vp.CountryId = @IdCountry
						   ,vp.DescriptionOfClient = @FullName
						   ,vp.Address = CAST((@Address1 + @Address2) AS NVARCHAR(600))
						   ,vp.Phone = @Phone
						   ,vp.TokenUpdated = @Token
						   ,vp.DateUpdated = GETDATE()
						   ,vp.Town = @TownshipName
						   ,vp.Department = @Department
						   ,vp.IdKindOfVPBusiness = @IdKindOfVPBusiness
						   ,vp.Latitude = @Latitude
						   ,vp.Longitude = @Longitude
						   ,@CodeOfReference = vp.CodeOfReference
						FROM UserAddress ua
						LEFT JOIN VisitPointClient vp WITH (NOLOCK)
							ON ua.CodeOfReference = vp.CodeOfReference
						WHERE UadIdAddress = @IdAddress
						

						SELECT
							1 AS 'StatusCode'
						   ,'Se ha actualizado la dirección correctamente.' AS 'Description'
						   ,@IdAddress AS 'IdAddress'
						   ,@CodeOfReference AS 'CodeOfReference'
						   ,@IdAccount AS 'IdAccount'
						   ,@IsReferredCustomer AS 'IsReferredCustomer'

						COMMIT TRANSACTION
					END
				END
				ELSE
				BEGIN 
					SELECT
						0 AS 'StatusCode'
					   ,'No se ha encontrado la dirección.' AS 'Description'

						ROLLBACK TRANSACTION
				END
			END
			ELSE
			BEGIN
				-- Se crean los registros

				SET @CodeOfReference = (SELECT
						MAX(CodeOfReference) + 1
					FROM VisitPointClient)

				--Inserta Visit Point en la tabla VisitPointClient
				INSERT INTO [dbo].[VisitPointClient] ([CodeOfReference]
				, [DescriptionOfClient]
				, [StatusClient]
				, [CountryId]
				, [VisitPointId]
				, [TokenCreated]
				, [DateCreated]
				, [TokenUpdated]
				, [DateUpdated]
				, [CustomerID]
				, [Address]
				, [Zone]
				, [Town]
				, [Department]
				, [Phone]
				, [ContactName]
				, [IdKindOfVPClient]
				, [IdKindOfVPBusiness]
				, [IdSettlement]
				, [Email]
				, [IdTownship]
				, [Latitude]
				, [Longitude])
					VALUES (@CodeOfReference, @FullName, @Status, @IdCountry, NULL, @Token, GETDATE(), NULL, NULL, @IdCustomer, CAST((@Address1 + @Address2) AS NVARCHAR(600)), NULL, @TownshipName, @Department, @Phone, NULL, 6, @IdKindOfVPBusiness, NULL, NULL, @IdTownship, @Latitude, @Longitude)
				SET @IdVisitPointClient = SCOPE_IDENTITY()

				--insertar nueva direccion
				INSERT INTO [dbo].[UserAddress] ([UadIdTownship]
				, [UadIdAccount]
				, [UadIdCountry]
				, [UadFullName]
				, [UadAddress1]
				, [UadAddress2]
				, [UadNirPhone]
				, [UadPhone]
				, [UadAdditionalInstructions]
				, [UadRowStatus]
				, [UadTokenCreated]
				, [UadDateCreated]
				, [UadTokenUpdated]
				, [UadDateUpdated]
				, CodeOfReference
				, IdCityPlace)
					VALUES (@IdTownship, @IdAccount, @IdCountry, @FullName, CAST(@Address1 AS NVARCHAR(600)), @Address2, @NirPhone, @Phone, @AdditionalInstructions, 1 -- se crean los registros activos por default 
					, @Token, GETDATE(), NULL, NULL, @CodeOfReference, @IdCityPlace)
				SET @IdAddress = SCOPE_IDENTITY()


				SELECT
					1 AS 'StatusCode'
				   ,'Dirección creada correctamente.' AS 'Description'
				   ,@IdAddress AS 'IdAddress'
				   ,@CodeOfReference AS 'CodeOfReference'
				   ,@IdAccount AS 'IdAccount'
				   ,@IsReferredCustomer AS 'IsReferredCustomer'

				COMMIT TRANSACTION
			END
		END
		ELSE
		BEGIN
			SELECT
				0 AS 'StatusCode'
			   ,'No se ha encontrado el cliente.' AS 'Description'

				ROLLBACK TRANSACTION
		END
	END TRY
	BEGIN CATCH

		SELECT
			0 AS 'StatusCode'
		   ,ERROR_MESSAGE() AS 'Description'
		   ,CONVERT(BIGINT, 0) AS 'NumTransferID'

		ROLLBACK TRANSACTION
	END CATCH
END