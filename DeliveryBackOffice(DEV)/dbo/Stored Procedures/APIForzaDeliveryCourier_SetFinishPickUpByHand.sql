/* =================================================
   SP:        [dbo].[APIForzaDeliveryCourier_SetFinishPickUpByHand]
   Propósito: <Finaliza el proceso de recolección manual insertando información en las tablas de Servicio de recolección.>
   Autor:     Caleb Loarca
   Historia:  <FDAPI-5680>
   Fecha:     <2026-03-30>
   === CHANGELOG ============================
2026-04-23 | Historia/épica: <FDAPI-6122> | Autor: Caleb Loarca | Se agrega declaración de variables de idcourier y idrouteassigment para insertar en servicemanagement.
2026-03-30 | Historia/épica: <FDAPI-5680> | Autor: Caleb Loarca | Se usa de base SP , para modificar y consumir en recolecciones manuales
=========================================== */

ALTER PROCEDURE [dbo].[APIForzaDeliveryCourier_SetFinishPickUpByHand]
    -- Add the parameters for the stored procedure here
    @InGuides NVARCHAR(MAX) = 'FD27434791-1',
    @TypeofInOutMoneyId INT = 1,
    @Token VARCHAR(200) = NULL,
    @Observations VARCHAR(200) = NULL,   
    @Voucher NVARCHAR(200) = ' ',
    @PuSignaturePath NVARCHAR(250) = ' ',
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @PickupLatitude NVARCHAR(20) = NULL,
    @PickupLongitude NVARCHAR(20) = NULL,
    @ReferencesGuide TblReferencesList READONLY,  
	@ContainerReferences TblContainerList READONLY,
	@IdCountry NVARCHAR(2)= 'GT',
    @StationId INT = NULL

AS

BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.	

	SET NOCOUNT ON;


    DECLARE @ValIdPickup INT = NULL;

    -- insertar en tabla temporal posbibles mensajes de respuesta
    --IF OBJECT_ID('tempdb.dbo.#UpdateNow', 'U') IS NOT NULL DROP TABLE #UpdateNow;
    IF OBJECT_ID('tempdb.dbo.#NowInsert', 'U') IS NOT NULL
       DROP TABLE #NowInsert;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
       DROP TABLE #responsemessage;
    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
       DROP TABLE #Temp;

    DECLARE @DateToDay DATE = CAST(GETDATE() AS DATE) ;

	DECLARE @IdPodCourier INT = (
						SELECT TOP 1 [IdCourierman]
						FROM [DeliveryBackOffice].[dbo].[LogTokenPOD] WITH(NOLOCK)
						WHERE	RowStatus = 1 
								and LogTokenPOD = @Token 
								AND cast(DateCreated AS DATE) = @DateToDay);

	DECLARE @IdRouteAss INT = (SELECT TOP 1 RA.IdRouteAssigment	FROM RouteAssigment  RA WITH(NOLOCK)
								INNER JOIN CatRoute CR WITH(NOLOCK)
									ON RA.idroute = CR.idRoute
								WHERE
									RA.IdCurrierMan = @IdPodCourier
									AND	CR.idTypeRoute = 1
									AND cast(RA.DateCreated AS DATE) = @DateToDay
									ORDER BY RA.DateCreated DESC);								

	DECLARE @responsemessage AS TABLE
    (
      IdResult  INT,
      [Message] NVARCHAR(500),
      Id        NVARCHAR(20)
    );

    INSERT INTO @responsemessage
    (
      IdResult,
      [Message],
      Id
    )
    SELECT *
      FROM (
            SELECT 200 AS IdResult,
                   'Estado  cambiado correctamente' AS Message,
                   'OK' AS Id
             UNION
            SELECT 500 AS IdResult,
                   'Error faltal intente de nuevo mas tarde' AS Message,
                   'Transac' AS Id
           ) AS errror;

        CREATE TABLE #Temp
        (
         Guide     VARCHAR(255),
         [Message] VARCHAR(255),
        );


        INSERT INTO #Temp
        (
          Guide,
          [Message]
        )
          EXEC [dbo].[spws_get_validate_guides_pickupByHand]
               @InGuides = @InGuides,              
               @Token = @Token,
               @ReferencesGuide=@ReferencesGuide,  
               @ContainerReferences=@ContainerReferences,  
               @IdCountry=@IdCountry; 


        DECLARE @test INT =
                (
                 SELECT COUNT(*)
                   FROM #Temp
                );

				
				BEGIN TRANSACTION
				BEGIN TRY
					SET NOCOUNT ON;
					INSERT INTO DeliveryBackOffice.dbo.schedulePickup 
						(StartDate
						,EndDate
						,RowStatus
						,TokenCreated
						,DateCreated
						,IsScheduled) 
						values
						(@StartDate
						,@EndDate
						,1
						,@Token
						,GETDATE()
						,0);

					declare    @IdPickup INT = SCOPE_IDENTITY();  -- Captura el último ID generado											

					INSERT INTO DeliveryBackOffice.dbo.ServiceManagement
						(RowStatus
						,IdPuCourrier
						,IdPuRouteAssigment
						,CiPuDate
						,CoPuDate
						,IdSchedulePickup
						,TokenCreated
						,DateCreated
						,ServiceStatusId
						,SubTypeServiceManagmentId
						,[Order] ) 
						values
						(1
						,@IdPodCourier
						,@IdRouteAss
						,@StartDate
						,@EndDate
						,@IdPickup
						,@Token
						,GETDATE()
						,2
						,5
						,1)
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION
						-- Retornar mensaje de error
						SELECT IdResult AS IdResult,  
								ERROR_MESSAGE() AS [Message] 
						FROM @responsemessage
						WHERE Id = 'Transac';
						RETURN;
				END CATCH

				COMMIT TRANSACTION;				

        SET @ValIdPickup = 
        (
          SELECT TOP 1 SchedulePickupId
            FROM DeliveryBackOffice.dbo.FinishPickUpHeader WITH (NOLOCK)
           WHERE SchedulePickupId = @IdPickup
        )

        IF (@test = 0 AND @ValIdPickup IS NULL )
        BEGIN
            BEGIN TRANSACTION;
            BEGIN TRY

                  DECLARE @Status INT =
                          (
                           SELECT IdServiceStatus
                             FROM DeliveryBackOffice.dbo.CatServiceStatus WITH (NOLOCK)
                            WHERE IdServiceStatus = 2
                          );
			
                          ---SE REALIZA EL INSERT
                  INSERT INTO DeliveryBackOffice.dbo.FinishPickUpHeader
                  (
                   SchedulePickupId
                   ,TypeofInOutMoneyId
                   ,Amount
                   ,[Signature]
                   ,StartDate
                   ,EndDate                   
                   ,PickupLatitude
                   ,PickupLongitude
                   ,ServiceStatusId
                   ,Observation
                   ,Voucher
                   ,RowStatus
                   ,TokenCreated
                   ,DateCreated
                   ,TokenUpdated
                   ,DateUpdated
				   ,StationId
                  )
                  VALUES
                  (
                    @IdPickup
                    ,@TypeofInOutMoneyId
                    ,'0.0'--@Amount
                    ,@PuSignaturePath
                    ,@StartDate
                    ,@EndDate                    
                    ,@PickupLatitude
                    ,@PickupLongitude
                    ,@Status
                    ,@Observations
                    ,@Voucher
                    ,1
                    ,@Token
                    ,GETDATE()
                    ,NULL
                    ,NULL
					,@StationId
                  )
               
               IF(@InGuides <>'')
               BEGIN
                  INSERT INTO DeliveryBackOffice.dbo.FinishPickUpDetail
                  (
                   SchedulePickupId
                   ,GuideSerie
                   ,GuideNumber
                   ,GuidePiece
                   ,RowStatus
                   ,TokenCreated
                   ,DateCreated
                   ,TokenUpdated
                   ,DateUpdated
                  )
                  SELECT @IdPickup
                         ,SUBSTRING(s.Item, 1, 2) AS GuideSerie
                         ,SUBSTRING(s.Item, 3, IIF(ca.Pos = 0, (LEN(s.Item)), (ca.Pos - 3))) AS GuideNumber
                         ,REPLACE(SUBSTRING(s.Item, ca.Pos, LEN(s.Item)),'-','')  AS GuidePiece
                         ,1
                         ,@Token
                         ,GETDATE()
                         ,NULL
                         ,NULL
                    FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',') s
                         CROSS APPLY (VALUES (CHARINDEX('-', s.Item))) ca(Pos)
                   WHERE ca.Pos > 0;
               END;

			  IF( EXISTS (SELECT 1 FROM @ReferencesGuide))
			  BEGIN
			  INSERT INTO [DeliveryBackOffice].[dbo].[FinishPickUpReferenceDetail]
							(
							SchedulePickupId
							,Reference
							,RowStatus
							,TokenCreated
							,DateCreated
							,TokenUpdated
							,DateUpdated
							)
							SELECT 
								   @IdPickup
								  ,ReferenceGuide
								  ,1
								  ,@Token
								  ,GETDATE()
								  ,NULL
								  ,NULL
							  FROM @ReferencesGuide;          
			  END

				IF( EXISTS (SELECT 1 FROM @ContainerReferences))
				BEGIN
					INSERT INTO [DeliveryBackOffice].[dbo].[FinishPickUpContainerDetail]
							  (
							   SchedulePickupId
							   ,Container
							   ,RowStatus
							   ,TokenCreated
							   ,DateCreated
							   ,TokenUpdate
							   ,DateUpdate
							  )
							  SELECT 
									 @IdPickup
									 ,ContainerReference
									 ,1
									 ,@Token						 
									 ,GETDATE()
									 ,NULL
									 ,NULL
								FROM @ContainerReferences;
				END

            END TRY
            BEGIN CATCH

                ROLLBACK TRANSACTION;

                -- Retornar mensaje de error
                SELECT IdResult AS IdResult,  
                        ERROR_MESSAGE() AS [Message] 
                  FROM @responsemessage
                 WHERE Id = 'Invalid'

                INSERT INTO DeliveryBackOffice.dbo.RoutePreparationLogError
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
                (
                 CAST(ERROR_MESSAGE() AS VARCHAR(300)),
                 ERROR_NUMBER(),
                 CAST(ERROR_PROCEDURE() AS VARCHAR(100)),
                 ERROR_LINE(),
                 0,
                 0,
                 'APIForzaDeliveryCourier_SetFinishPickUpByHand', GETDATE()
                );

            END CATCH;

            IF @@TRANCOUNT > 0
            BEGIN
                COMMIT TRANSACTION;

                DECLARE @StatusNew INT =
                        (
							SELECT IdServiceStatus FROM DeliveryBackOffice.dbo.CatServiceStatus WITH (NOLOCK) WHERE IdServiceStatus = 3
                        );

                UPDATE DeliveryBackOffice.dbo.ServiceManagement
                   SET ServiceStatusId = @StatusNew,
                       PuSignaturePath = @PuSignaturePath,
                       CiPuDate = @StartDate,
                       CoPuDate = @EndDate,
                       TokenUpdated = @Token,
                       DateUpdated = GETDATE()
                 FROM DeliveryBackOffice.dbo.ServiceManagement
                WHERE IdSchedulePickup = @IdPickup;

                SELECT 200 as IdResult,
                       'Cambios realizados exitosamente' AS [Message]

            END;

        END;
        
		ELSE IF (@test > 0)
        BEGIN
            SELECT 412 AS IdResult,
                   Guide AS Guides,
                   [Message]
              FROM #Temp
        END;

        ELSE IF (@ValIdPickup IS NOT NULL)
        BEGIN
            SELECT 413 AS IdResult,
                   @IdPickup AS Error,
                   'El id de servicio de recolección ya ha sido procesado anteriormente' AS [Message]
        END;

    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
       DROP TABLE #Temp;
END
