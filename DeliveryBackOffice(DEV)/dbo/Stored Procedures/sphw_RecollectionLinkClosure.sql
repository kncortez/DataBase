-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <21-09-2022>
-- Description:	<Cierra un link de recolección y genera una solciitud de recolección agrupado por codigo de referencia>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_RecollectionLinkClosure]
	@VisitPointDataLinkId BIGINT,
	@TAC1 BIT = NULL,
	@TAC2 BIT = NULL,
	@TAC3 BIT = NULL,
	@TypeVehicleId int = 2,
	@Regularpiezer int = 1,
	@RecollectionLatitude varchar(50) = '',
	@RecollectionLongitude varchar(50) = '',
	@Token nvarchar(100),
	@IdAccount int,
	@Scheduled  bit = 0,
	@Startdate datetime = NULL,
	--DATOS DEL VISITPOINT A MODIFICAR
	@IdTownship INT = NULL,
	@IdCountry  nvarchar(10) = 'GT',
	@NameVP  nvarchar(200) =NULL,
	@Address1  nvarchar(600)=NULL,
	@NirPhone  nvarchar(10) =NULL,
	@Phone  nvarchar(50) =NULL,
	@AdditionalInstructions  nvarchar(250) =NULL,
	@IdCityPlace int = NULL,
	@Latitude varchar(50)=NULL,
	@Longitude varchar(50)=NULL,
	@ContactName varchar(50)=NULL,
	@IsOnlyVisitPoint BIT = 0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION RecolectionLinkClosurePT;
    ELSE  
        BEGIN TRANSACTION;  

	DECLARE @RESULTREGISTERRECOLECTION TABLE
	(StatusCode INT, 
		Description NVARCHAR(100),
		ServiceId INT
	)
	
	DECLARE @IsUpdate BIT = 1
	DECLARE @CodeOfReference INT;
	DECLARE @IdCustomer INT;
	DECLARE @TownShipName NVARCHAR(100)=NULL;
	DECLARE @ProvinceName NVARCHAR(100)=NULL;
	DECLARE @IdKindOfVPBusiness INT
	
	SELECT 
		@CodeOfReference=VPDL.VisitPointId
	FROM DBO.VisitPointDataLink VPDL
	WHERE VPDL.IdVisitPointDataLink=@VisitPointDataLinkId;

	BEGIN TRY

		-- Si se tiene que crear el vp para cliente referenciado
		IF (@IdAccount IS NULL)
		BEGIN 

			SET @IsUpdate = 0

			-- Buscar cliente referenciado
			SELECT
				@IdAccount = AccIdAccount
				,@IdCustomer = IdCustomer
			FROM Account WITH (NOLOCK)
			WHERE IdCustomer = (SELECT
					IdCustomer
				FROM Customer
				WHERE Name = 'Cliente Referenciado'
				AND Domain = '@forzadelivery')
			
			SELECT TOP 1 
				@TownShipName = twn.TownshipName,
				@ProvinceName = prv.ProvinceName
			FROM DBO.Township twn
				LEFT JOIN DBO.Province prv ON twn.IdProvince=prv.IdProvince
			WHERE IdTownship = @IdTownship

			SET @IdKindOfVPBusiness = (SELECT
				IdKindOfVPBusiness
			FROM KindOfVPBusiness WITH (NOLOCK)
			WHERE Shorthand = 'HUB')

			-- Se crean los registros
			SET @CodeOfReference = (SELECT
					MAX(CodeOfReference) + 1
				FROM VisitPointClient)

			--Inserta Visit Point en la tabla VisitPointClient
			INSERT INTO [dbo].[VisitPointClient] ([CodeOfReference]
			, [CustomerID]
			, [IdTownship]
			, [CountryId]
			, [DescriptionOfClient]
			, [ContactName]
			, [Address]
			, [Phone]
			, [Town]
			, [Department]
			, [Latitude]
			, [Longitude]
			, [IdKindOfVPClient]
			, [IdKindOfVPBusiness]
			, [StatusClient]
			, [TokenCreated]
			, [DateCreated]
			, [IsOriginVisitPoint])
				VALUES (@CodeOfReference, @IdCustomer, @IdTownship, @IdCountry, @NameVP, @ContactName, @Address1, @Phone, @TownShipName, @ProvinceName, @RecollectionLatitude, @RecollectionLongitude, 6, @IdKindOfVPBusiness, 1, @Token, GETDATE(), 1)
				
			--insertar nueva direccion
			INSERT INTO [dbo].[UserAddress] ([UadIdTownship]
			, [UadIdAccount]
			, [UadIdCountry]
			, [UadFullName]
			, [UadAddress1]
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
				VALUES (@IdTownship, @IdAccount, @IdCountry, @NameVP, @Address1, @NirPhone, @Phone, @AdditionalInstructions, 1 
				, @Token, GETDATE(), NULL, NULL, @CodeOfReference, @IdCityPlace)

		END
		ELSE IF (@IdAccount IS NOT NULL AND @CodeOfReference IS NULL)
		BEGIN
		
			SET @IsUpdate = 0

			-- Buscar cliente
			SELECT
				@IdCustomer = IdCustomer
			FROM DeliveryBackOffice.dbo.Account Acc WITH (NOLOCK)
			WHERE @IdAccount = Acc.AccIdAccount
			
			SELECT TOP 1 
				@TownShipName = twn.TownshipName,
				@ProvinceName = prv.ProvinceName
			FROM DBO.Township twn
				LEFT JOIN DBO.Province prv ON twn.IdProvince=prv.IdProvince
			WHERE IdTownship = @IdTownship

			SET @IdKindOfVPBusiness = (
			SELECT
				TOP 1
					IdKindOfVPBusiness
			FROM dbo.KindOfVPBusiness WITH (NOLOCK)
			WHERE 
				Shorthand = 'HUB'
			)

			-- Se crean los registros
			SET @CodeOfReference = (SELECT
					MAX(CodeOfReference) + 1
				FROM VisitPointClient)
				
			--Inserta Visit Point en la tabla VisitPointClient
			INSERT INTO [dbo].[VisitPointClient] ([CodeOfReference]
			, [CustomerID]
			, [IdTownship]
			, [CountryId]
			, [DescriptionOfClient]
			, [ContactName]
			, [Address]
			, [Phone]
			, [Town]
			, [Department]
			, [Latitude]
			, [Longitude]
			, [IdKindOfVPClient]
			, [IdKindOfVPBusiness]
			, [StatusClient]
			, [TokenCreated]
			, [DateCreated]
			, [IsOriginVisitPoint])
				VALUES (@CodeOfReference, @IdCustomer, @IdTownship, @IdCountry, @NameVP, @ContactName, @Address1, @Phone, @TownShipName, @ProvinceName, @RecollectionLatitude, @RecollectionLongitude, 6, @IdKindOfVPBusiness, 1, @Token, GETDATE(), 1)
				
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
				VALUES (@IdTownship, @IdAccount, @IdCountry, @NameVP, @Address1, '', @NirPhone, @Phone, @AdditionalInstructions, 1 
				, @Token, GETDATE(), NULL, NULL, @CodeOfReference, @IdCityPlace)

		END
		ELSE
		BEGIN
		
			SELECT 
				@CodeOfReference=VPDL.VisitPointId
			FROM DBO.VisitPointDataLink VPDL
			WHERE VPDL.IdVisitPointDataLink=@VisitPointDataLinkId;

		END

		IF(ISNULL(@IsOnlyVisitPoint, 1) = 0)
		BEGIN
			--CREANDO SOLICITUD DE RECOLECCIÓN
			INSERT INTO @RESULTREGISTERRECOLECTION
			(
				StatusCode,
				Description,
				ServiceId
			)
			EXECUTE [dbo].[sphw_RegisterRecollectionRequest] 
				@TAC1
				,@TAC2
				,@TAC3
				,@Scheduled
				,@CodeOfReference
				,@TypeVehicleId
				,@RecollectionLatitude
				,@RecollectionLongitude
				,@Regularpiezer
				,@Startdate
				,NULL
				,@Token
				,@IdAccount;
		END
	
		IF ((SELECT StatusCode FROM @RESULTREGISTERRECOLECTION) = 1 OR ISNULL(@IsOnlyVisitPoint, 1) = 1)
		BEGIN
			--CERRANDO LINK
			UPDATE DBO.VisitPointDataLink SET
				DataLinkStatusId= (SELECT IdCatDataLinkStatus FROM DBO.CatDataLinkStatus WHERE DataLinkStatusName = 'Completado')
			WHERE IdVisitPointDataLink=@VisitPointDataLinkId;

			IF(ISNULL(@IsOnlyVisitPoint, 1) = 1)
			BEGIN
				SELECT 1 'StatusCode', 'Punto de visita generado exitosamente' 'Description', 0 'ServiceId'
			END
			ELSE
			BEGIN
				SELECT StatusCode 'StatusCode', Description 'Description', ServiceId 'ServiceId' FROM @RESULTrEGISTERRECOLECTION;		
			END

			IF @IsUpdate = 1
			BEGIN

				UPDATE [dbo].[UserAddress]
					SET [UadIdTownship] = ISNULL(@IdTownship,UadIdTownship)
						,[UadIdAccount] = ISNULL(@IdAccount,UadIdAccount)
						,[UadIdCountry] = ISNULL(@IdCountry,UadIdCountry)
						,[UadFullName] = ISNULL(@NameVP,UadFullName) 
						,[UadAddress1] = ISNULL(@Address1,UadAddress1)
						,[UadNirPhone] = ISNULL(@NirPhone,UadNirPhone)
						,[UadPhone] = ISNULL(@Phone,UadPhone)
						,[UadAdditionalInstructions] = ISNULL(@AdditionalInstructions,UadAdditionalInstructions)
						,[UadTokenUpdated] = @Token
						,[UadDateUpdated] = GETDATE()
						,[IdCityPlace] = ISNULL(@IdCityPlace,IdCityPlace)
					WHERE CodeOfReference=@CodeOfReference
				

				SELECT TOP 1 
					@TownShipName = twn.TownshipName,
					@ProvinceName = prv.ProvinceName
				FROM DBO.Township twn
					LEFT JOIN DBO.Province prv ON twn.IdProvince=prv.IdProvince
				WHERE IdTownship = @IdTownship

				UPDATE VP
					SET VP.IdTownship = ISNULL(@IdTownship,VP.IdTownship)
						,VP.CountryId = ISNULL(@IdCountry,VP.CountryId)
						,VP.DescriptionOfClient =ISNULL(@NameVP,VP.DescriptionOfClient) 
						,VP.ContactName =ISNULL(@ContactName,VP.ContactName) 
						,VP.Address = ISNULL(@Address1,VP.Address)
						,VP.Phone =ISNULL(@Phone,VP.Phone)
						,VP.TokenUpdated = @Token
						,VP.DateUpdated = GETDATE()
						,VP.Town= ISNULL(@TownShipName,VP.Town)
						,VP.Department= ISNULL(@ProvinceName,VP.Department)
						,VP.Latitude=ISNULL(@RecollectionLatitude,VP.Latitude)
						,VP.Longitude=ISNULL(@RecollectionLongitude,VP.Longitude)
				FROM [dbo].[VisitPointClient] VP 
					WHERE [CodeOfReference] =  @CodeOfReference
				--------FIN ACTUALIZACIÓN--------------
			END

			IF @TranCounter = 0  
				COMMIT TRANSACTION;
		END
		ELSE
		BEGIN
			SELECT StatusCode 'StatusCode',Description 'Description',ServiceId 'ServiceId' FROM @RESULTrEGISTERRECOLECTION;
		END


    END TRY
    BEGIN CATCH        
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
			ROLLBACK TRANSACTION ProcedureSave2;  
		SELECT 0 'StatusCode', 
		CONCAT(ERROR_MESSAGE(),' LINE:',ERROR_LINE()) 'Description';
    END CATCH;

END