
-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <19-09-2022>
-- Description:	<Crea una solicitud de recolección>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_RegisterRecollectionRequest]
	-- Add the parameters for the stored procedure here
	@TAC1 BIT = NULL,
	@TAC2 BIT = NULL,
	@TAC3 BIT = NULL,
	@Scheduled BIT = NULL,
	@CodeOfReference int,
    @TypeVehicleId INT = NULL,
    @RecollectionLatitude AS varchar(50) = NULL,
    @RecollectionLongitude AS varchar(50) = NULL,
	@Regularpiezer AS INT = 1,
    @StartDate AS DATETIME = NULL,
    @EndDate AS DATETIME = NULL,
	@Token AS NVARCHAR(100),
    @IdAccount AS INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  

		

        BEGIN TRY
		IF @TAC1 = 0
		BEGIN 
			SELECT			  
				0 AS 'StatusCode',
				'Términos y condiciones de servicios de recolección no aceptados' AS 'Description',
				-1 AS 'ServiceId';
		END
		ELSE IF @TAC2 = 0
		BEGIN
			SELECT			  
				0 AS 'StatusCode',
				'Términos y condiciones de seguro no aceptados' AS 'Description',
				-1 AS 'ServiceId';
		END
		ELSE IF @TAC3 = 0
		BEGIN
			SELECT			  
				0 AS 'StatusCode',
				'Declaración de no contenido de productos ilegales no aceptados' AS 'Description',
				-1 AS 'ServiceId';
		END
		ELSE IF @Scheduled = 1 AND @StartDate IS NULL
		BEGIN
			SELECT			  
				0 AS 'StatusCode',
				'No se ha indicado la fecha y hora de recolección' AS 'Description',
				-1 AS 'ServiceId';			
		END
		ELSE
		BEGIN 


			IF @TranCounter > 0  
				SAVE TRANSACTION ProcedureSave;  
			ELSE  
				BEGIN TRANSACTION;  
					IF @Scheduled = 0

			BEGIN				
				DECLARE @CURRENTDATE DATETIME= GETDATE();
				SET @StartDate =DATEADD(mi,15,@CURRENTDATE);
				SET @EndDate =DATEADD(mi,45,@CURRENTDATE);
			END
			--DECLARE @IDTAC1 BIGINT= (SELECT IdTAC FROM DBO.TermsAndConditions WHERE Name='Collection Services Terms and Conditions' AND RowStatus=1)
			--DECLARE @IDTAC2 BIGINT= (SELECT IdTAC FROM DBO.TermsAndConditions WHERE Name='Declaration no content of illegal products' AND RowStatus=1)

	
			DECLARE @IDSCHEDULEPICKUP INT =NULL;
			DECLARE @IDSERVICEMANAGEMENT INT =NULL;
			SELECT @IDSCHEDULEPICKUP=SP.SchedulePickupId,
					@IDSERVICEMANAGEMENT= SM.IdServiceManagement
			                    FROM dbo.SchedulePickup SP with(nolock)
                        LEFT JOIN dbo.ServiceManagement SM with(nolock)
                            ON SM.IdSchedulePickup = SP.SchedulePickupId
                    WHERE (
								SM.ServiceStatusId IN ( select IdServiceStatus from dbo.CatServiceStatus where Name in ('Creado','Asignado a Ruta','Reprogramado'))
								AND SM.RowStatus = 1
                          )
                          AND
                          (
                              SP.SchedulePickupStatus IS NULL	--RECOLECCIONES ACTIVAS
                              OR SP.SchedulePickupStatus = 1	--RECOLECCIONES ACTIVAS
                          )
                          AND SP.RowStatus = 1
                          AND CONVERT(DATE, SP.StartDate) = CONVERT(DATE, @StartDate)
						  AND SP.SenderId=@CodeOfReference;


			IF @IDSCHEDULEPICKUP IS NULL
			BEGIN							
				INSERT INTO dbo.SchedulePickup
				(
					AccountId,
					StartDate,
					EndDate,
					EstimatedWeight,
					IsLargePackage,
					QuantityRegularPackages,
					QuantityOverDimensionedPackage,
					SpecialInstructions,
					RowStatus,
					TokenCreated,
					DateCreated,
					TokenUpdated,
					DateUpdated,
					SenderId,
					SenderName,
					SenderPhone,
					IdHubLogistics,
					AmountPickup,
					IdSourcePlataform,
					AddressPickup,
					TypeVehicleId,
					IsScheduled
				)
				SELECT @IdAccount,
					   @StartDate,
					   @EndDate,
					   NULL,
					   0,
					   @Regularpiezer,
					   NULL,
					   ua.UadAdditionalInstructions,
					   1,
					   @Token,
					   GETDATE(),
					   NULL,
					   NULL,
					   @CodeOfReference,
					   cu.Name,
					   vp.Phone,
					   HL.IdHublogistic,
					   NULL,
					   NULL,
					   vp.Address,
					   @TypeVehicleId,
					   @Scheduled
				FROM VisitPointClient VP
					INNER JOIN UserAddress UA ON UA.CodeOfReference =VP.CodeOfReference
					INNER JOIN Customer CU ON VP.CustomerID =CU.IdCustomer					
					INNER JOIN Township Twn ON Twn.IdTownship=VP.IdTownship
                    INNER JOIN (
						SELECT
							DSC.HeaderCode
							,MAX(DSC.Hub) 'hub'
						FROM
							[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
						GROUP BY
							DSC.HeaderCode
					) hubcov
                        ON (Twn.HeaderCode = hubcov.HeaderCode)
					INNER JOIN
						[DeliveryBackOffice].[dbo].[HubLogistics] HL WITH(NOLOCK)
						ON
							hubcov.hub = HL.HubAbbreviation COLLATE Latin1_General_CI_AI
				WHERE 
				VP.CodeOfReference =@CodeOfReference;
				SET @IDSCHEDULEPICKUP = SCOPE_IDENTITY();

				--CREANDO SERVICE MANAGEMENT				
				INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagement] (IdSchedulePickup, RowStatus, TokenCreated, DateCreated, ServiceStatusId, Amount, CatPaymentTimeId)
					VALUES(
						@IDSCHEDULEPICKUP
					   ,1
					   ,@token
					   ,GETDATE()
					   ,(SELECT IdServiceStatus FROM DBO.CatServiceStatus WHERE Name='Creado')
					   ,0
					   ,NULL);
				SET @IDSERVICEMANAGEMENT = SCOPE_IDENTITY();

				--CREANDO REGISTRO EN EVENTSERVICE
				INSERT INTO [DeliveryBackOffice].[dbo].[EventService] (ServiceManagementId,ServiceStatusId,RowStauts,TokenCreated,DateCreated)
					VALUES(
						@IDSERVICEMANAGEMENT
					   ,(SELECT IdServiceStatus FROM DBO.CatServiceStatus WHERE Name='Creado')
					   ,1
					   ,@token
					   ,GETDATE())
			END
			

			--REGISTRANDO TERMINOS Y CONDICIONES
			INSERT INTO [dbo].[TermsAndConditionsByService]
					   ([TermsAndConditionsId]
					   ,[ServiceManagementId]
					   ,[IsAccepted]
					   ,[RowStatus]
					   ,[TokenCreated]
					   ,[DateCreated]
					   ,[TokenUpdated]
					   ,[DateUpdated])
				 SELECT IdTAC,
						@IDSERVICEMANAGEMENT,
						1,
						1,
						@Token,
						GETDATE(),
						NULL,
						NULL
				 FROM DBO.TermsAndConditions 				 
				 WHERE NAME IN ('Collection Services Terms and Conditions','Declaration no content of illegal products', 'Insurance acknowledgement');
			---------------------
			
            DECLARE @TempGuides TABLE
            (
                GuideSerie NVARCHAR(25) NULL,
                GuideNumber NVARCHAR(25) NULL
            );
		

			
            --ACTUALIZANDO VEHÍCULO
            UPDATE sp
            SET sp.TypeVehicleId = @TypeVehicleId,
			sp.DateUpdated=GETDATE(),
			SP.TokenUpdated=@Token
            FROM SchedulePickup sp
            WHERE SP.SchedulePickupId=@IDSCHEDULEPICKUP;	

			--ACTUALIZANDO COORDENADAS
			UPDATE VisitPointClient
			SET Latitude=IIF(LTRIM(RTRIM(@RecollectionLatitude)) <> '', @RecollectionLatitude, Latitude),
				Longitude=IIF(LTRIM(RTRIM(@RecollectionLongitude)) <> '', @RecollectionLongitude, Longitude)
			WHERE CodeOfReference=@CodeOfReference;

			

		END

        END TRY
        BEGIN CATCH
			IF @TranCounter = 0  
				ROLLBACK TRANSACTION;  
			ELSE IF XACT_STATE() <> -1  
				ROLLBACK TRANSACTION ProcedureSave;  

			SELECT
				0 'StatusCode', 
			ERROR_MESSAGE() 'Description',
			-1 AS 'ServiceId';

			INSERT INTO dbo.RoutePreparationLogError
			(
				ErrorDescription,
				ErrorNumber,
				ErrorProcedure,
				ErrorLine,
				GuideSerie,
				GuideNumber,
				TokenCreated,
				DateCreated
			)
			VALUES
			 (CAST(ERROR_MESSAGE() AS VARCHAR(300))
					   ,ERROR_NUMBER()
					   ,CAST(ERROR_PROCEDURE() AS VARCHAR(100))
					   ,ERROR_LINE()
					   ,0
					   ,0
					   ,'Error en SetRecolectionRequest filtro 3'
					   ,GETDATE())


        END CATCH;

        IF @IDSERVICEMANAGEMENT IS NOT NULL
        BEGIN
	        IF @TranCounter = 0  
		        COMMIT TRANSACTION;  
			SELECT			  
				1 AS 'StatusCode',
				'Solicitud de recolección correcta' AS 'Description',
				@IDSERVICEMANAGEMENT AS 'ServiceId';
        END;

END