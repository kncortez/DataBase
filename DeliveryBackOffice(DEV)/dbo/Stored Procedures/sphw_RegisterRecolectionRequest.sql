-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <19-09-2022>
-- Description:	<Crea una solicitud de recolección>
-- =============================================

CREATE PROCEDURE sphw_RegisterRecolectionRequest
	-- Add the parameters for the stored procedure here
	@TAC1 BIT = NULL,
	@TAC2 BIT = NULL,
	@Scheduled BIT = NULL,
	@CodeOfReference int,
    @TypeVehicleId INT = NULL,
    @RecollectionLatitude AS varchar(50) = 0,
    @RecollectionLongitude AS varchar(50) = 0,
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
       BEGIN TRANSACTION;
        BEGIN TRY

		IF @TAC1 = 0
		BEGIN 
			SELECT			  
				0 AS 'StatusCode',
				'Términos y condiciones de servicios de recolección no aceptados' AS 'Description';
		END
		ELSE IF @TAC2 = 0
		BEGIN
			SELECT			  
				0 AS 'StatusCode',
				'Declaración de no contenido de productos ilegales no aceptados' AS 'Description';
		END
		ELSE IF @Scheduled = 1 AND @StartDate IS NULL
		BEGIN
			SELECT			  
				0 AS 'StatusCode',
				'No se ha indicado la fecha y hora de recolección' AS 'Description';			
		END
		BEGIN 

			IF @Scheduled = 0
			BEGIN				
				DECLARE @CURRENTDATE DATETIME= GETDATE();
				SET @StartDate =DATEADD(mi,15,@CURRENTDATE);
				SET @EndDate =DATEADD(mi,30,@CURRENTDATE);
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
					TypeVehicleId
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
					   @TypeVehicleId					   
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
				 WHERE NAME IN ('Collection Services Terms and Conditions','Declaration no content of illegal products');
			---------------------
			
            DECLARE @TempGuides TABLE
            (
                GuideSerie NVARCHAR(25) NULL,
                GuideNumber NVARCHAR(25) NULL
            );
			--Listando guías ASOCIADAS AL CODEOFREFERENCE			
			INSERT INTO @TempGuides
            SELECT DISTINCT
                    DO.Guide_Serie,DO.Guide_Number
			FROM [dbo].[DeliveryOrder] DO 
					LEFT JOIN DBO.DeliveryOrderPaymentDetail DOPD ON DOPD.GuideSerie=DO.Guide_Serie AND DOPD.GuideNumber=DO.Guide_Number
				where DO.Sender_ID=@CodeOfReference AND DOPD.IdHeaderRecolection IS NULL
				AND DO.StatusOrderId IN (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Generado')
            GROUP BY DO.Guide_Serie,
                    DO.Guide_Number


			---	 insertar checkpoint de Solicitado, siempre que no exista y sea posible
			insert into DeliveryBackOffice.dbo.DeliveryOrderDetail ( 
				[Guide_Serie]
				,[Guide_Number]
				,[StatusOrderId]
				,[UserCreated]
				,[DateCreated]
				,[DateCreatedInSystem]
				,[Observations]
				,[Temperature_Celsius]
			)
			select 
				DISTINCT
					TP.GuideSerie
					,TP.GuideNumber
					,(SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Solicitado')
					,@Token
					,GETDATE()
					,GETDATE()
					,null
					,null
			from 
				@TempGuides TP
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK)
					ON
						TP.GuideSerie= DOD.Guide_Serie
						AND
						TP.GuideNumber= DOD.Guide_Number
						AND
						DOD.StatusOrderId IN (1,21)
						AND
						DOD.RowStatus = 1
			WHERE
				DOD.DateCreated IS NULL
		

			
            --ACTUALIZANDO VEHÍCULO
            UPDATE sp
            SET sp.TypeVehicleId = @TypeVehicleId,
			sp.DateUpdated=GETDATE(),
			SP.TokenUpdated=@Token
            FROM SchedulePickup sp
            WHERE SP.SchedulePickupId=@IDSCHEDULEPICKUP;	

			--ACTUALIZANDO COORDENADAS
			UPDATE VisitPointClient
			SET Latitude=@RecollectionLatitude,
				Longitude=@RecollectionLongitude
			WHERE CodeOfReference=@CodeOfReference;


            --ACTUALIZANDO GUIAS 
			UPDATE DO SET
				StatusOrderId = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Solicitado'),
				DateUpdated=GETDATE(),
				TokenUpdated=@Token
			FROM @TempGuides TP
			INNER JOIN  dbo.DeliveryOrder DO  WITH (NOLOCK) ON TP.GuideSerie=DO.Guide_Serie AND TP.GuideNumber=DO.Guide_Number			
			INNER JOIN dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK) ON  
				DO.Guide_Serie=pay.GuideSerie 
				AND DO.Guide_Number = pay.GuideNumber
				and pay.IdHeaderRecolection IS NULL;
			

            UPDATE dbo.DeliveryOrderPaymentDetail
            SET IdHeaderRecolection = @IDSCHEDULEPICKUP,
                StartDate = @StartDate,
                EndDate = @EndDate,
                DateUpdated = GETDATE(),
                TokenUpdated = @Token
            FROM @TempGuides TP
				INNER JOIN dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK) ON TP.GuideSerie=PAY.GuideSerie AND TP.GuideNumber=PAY.GuideNumber
            WHERE PAY.IdHeaderRecolection IS NULL;			

			

		END

        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
			SELECT
				0 'StatusCode', 
			ERROR_MESSAGE() 'Description';

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

        IF @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION;
			SELECT			  
				1 AS 'StatusCode',
				'Solicitud de recolección correcta' AS 'Description';
        END;

END