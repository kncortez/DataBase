
CREATE PROCEDURE [dbo].[sphd_saveVisitPoint]	
	@DescriptionOfClient AS NVARCHAR(100),
	@IdSettlement AS BIGINT,
	@TokenCreated AS NVARCHAR(50),
	@CustomerID AS INT,
	@Address AS NVARCHAR(600),	
	@Town AS NVARCHAR(100),
	@Department AS NVARCHAR(100),
	@Phone AS NVARCHAR(50),
	@ContactName AS NVARCHAR(200),
	@Email AS NVARCHAR(200),
	@Latitude NVARCHAR(20) = NULL,
	@Longitude NVARCHAR(20) = NULL
AS
BEGIN
	-- Control de identificador de registro
	DECLARE @CodeOfReference AS INT = -1;
	SET @CodeOfReference = (SELECT TOP (1) vpc.CodeOfReference + 1 FROM dbo.VisitPointClient vpc
	ORDER BY vpc.CodeOfReference DESC);

	-- Verificación de municipio
	DECLARE @IdTownship AS INT = -1;
	SET @IdTownship = (SELECT IdTownship
	FROM dbo.Township WHERE TownshipName = @Town);

	-- Verificación de poblado
	IF (@IdSettlement = 0)
		SET @IdSettlement = NULL

	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @LastVPCToken AS TABLE(
			Token NVARCHAR(50)
		);

		INSERT INTO [dbo].[VisitPointClient]
			   ([CodeOfReference], [DescriptionOfClient]
			   ,[StatusClient],[CountryId]
			   ,[IdSettlement],[TokenCreated]
			   ,[DateCreated],[CustomerID]
			   ,[Address],[Town]
			   ,[Department],[Phone]
			   ,[ContactName],[Email]
			   ,[IdTownship],[Latitude],[Longitude],[VisitPointToken],[VisitPointTokenExpiration])
		OUTPUT inserted.VisitPointToken INTO @LastVPCToken(Token)
		 VALUES(@CodeOfReference, @DescriptionOfClient,
     			'TRUE','GT',
				@IdSettlement,@TokenCreated,
				GETDATE(),@CustomerID,
				@Address,@Town,
				@Department,@Phone,
				@ContactName,@Email,@IdTownship,@Latitude,@Longitude
				,CONCAT( 'VPC',@CodeOfReference, RIGHT ('00000'+CAST( (FLOOR(RAND()*(99999-0+1))+0) AS NVARCHAR),5))
				,DATEADD(DAY,15,GETDATE()))


		--DECLARE @regexPhoneNumber varchar(max)='[(][0-9][0-9][0-9][)]%';			
		SET @Phone	=REPLACE(@Phone,'-','');
		SET @Phone	=REPLACE(@Phone,' ','');

		DECLARE @Idplace AS INT = (SELECT  ISNULL(IdCityPlace, -1 ) FROM  dbo.CatCityPlace WHERE CityPlace='No Aplica');
		DECLARE @IdCountry AS VARCHAR =(SELECT CC.IdCountry
		FROM dbo.CatCountry CC LEFT JOIN DBO.Province PRV ON PRV.IdCountry=CC.IdCountry 
			LEFT JOIN DBO.Township TS ON TS.IdProvince=PRV.IdProvince WHERE IdTownship = @IdTownship);
		DECLARE @IdAccount INT =(SELECT AccIdAccount FROM DBO.Account ACC WHERE IdCustomer=@CustomerID);


		INSERT INTO DBO.UserAddress 
		(
			UadIdTownship,
			UadIdCountry,
			UadAddress1,
			--UadAddress2 NO SE MODIFICA
			UadNirPhone,
			UadPhone,
			UadAdditionalInstructions,
			UadTokenCreated,
			UadDateCreated,
			CodeOfReference,
			UadIdSettlement,			
			UadFullName,
			IdCityPlace,
			UadIdAccount,
			UadRowStatus
		
		)VALUES(
			@IdTownship,
			@IdCountry,
			@Address,
			'502',
			@Phone,
			'',
			@TokenCreated,
			GETDATE(),
			@CodeOfReference,
			@IdSettlement,
			@DescriptionOfClient,
			@Idplace,
			@IdAccount,
			1
		)

		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION;

		SELECT
			TOP 1
				1 [blnResult]
				,'Datos ingresados exitosamente' [Message]
				,CONCAT('https://forzadelivery.io/',Token) [VPCToken]
		FROM
			@LastVPCToken LVPCT

	END TRY
	BEGIN CATCH
	
        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

		ROLLBACK TRANSACTION;

	END CATCH
END