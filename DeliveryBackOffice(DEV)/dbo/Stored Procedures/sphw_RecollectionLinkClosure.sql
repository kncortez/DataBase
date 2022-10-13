-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <21-09-2022>
-- Description:	<Cierra un link de recolección y genera una solciitud de recolección agrupado por codigo de referencia>
-- =============================================
CREATE PROCEDURE sphw_RecollectionLinkClosure
	@VisitPointDataLinkId BIGINT,
	@TAC1 BIT,
	@TAC2 BIT,
	@TypeVehicleId int,
	@Regularpiezer int,
	@RecollectionLatitude varchar(50),
	@RecollectionLongitude varchar(50),
	@Token nvarchar(100),
	@IdAccount int,
	@Scheduled  bit,
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
	@Longitude varchar(50)=NULL

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
	BEGIN TRY


		--CREANDO SOLICITUD DE RECOLECCIÓN
		DECLARE @CodeOfReference INT;
		DECLARE @CustomerId INT;
		SELECT 
			@CodeOfReference=VPDL.VisitPointId
		FROM DBO.VisitPointDataLink VPDL
		WHERE VPDL.IdVisitPointDataLink=@VisitPointDataLinkId;


		INSERT INTO @RESULTREGISTERRECOLECTION
		(
			StatusCode,
			Description,
			ServiceId
		)
		EXECUTE [dbo].[sphw_RegisterRecollectionRequest] 
			@TAC1
			,@TAC2
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

		
		IF (SELECT StatusCode FROM @RESULTREGISTERRECOLECTION) =1
		BEGIN
			--CERRANDO LINK
			UPDATE DBO.VisitPointDataLink SET
				DataLinkStatusId= (SELECT IdCatDataLinkStatus FROM DBO.CatDataLinkStatus WHERE DataLinkStatusName = 'Completado')
			WHERE IdVisitPointDataLink=@VisitPointDataLinkId;
			SELECT StatusCode 'StatusCode',Description 'Description',ServiceId 'ServiceId' FROM @RESULTrEGISTERRECOLECTION;		

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
			DECLARE @TownShipName NVARCHAR(100)=NULL;
			DECLARE @ProvinceName NVARCHAR(100)=NULL;

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