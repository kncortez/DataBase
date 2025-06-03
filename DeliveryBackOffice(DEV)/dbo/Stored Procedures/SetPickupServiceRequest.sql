
-- =============================================
-- Author:      <Juan, Ramirez>
-- Create date: <2025-06-05>
-- Description: <Creación de servicio de recolección por medio de API>
-- =============================================
CREATE PROCEDURE [dbo].[SetPickupServiceRequest]
(
  @CodeOfReference  AS BIGINT,
  @StartDate        AS DATETIME,
  @EndDate          AS DATETIME,
  @QuantityOfPieces AS INT,
  @TypeVehicle      AS INT = 2,  -- 2 Panel
  @CodeApp          AS NVARCHAR(200)
)
AS
BEGIN
      DECLARE @SchedulePickupFinded       AS BIGINT = 0,
              @ServiceManagementFinded    AS INT,
              @CatServiceStatusFinded     AS NVARCHAR(50),
              @ResultService              AS BIGINT,
              @IdResult                   AS INT = 0,
              @ErrorMessage               AS NVARCHAR(500) = '',
              @IsSuccess                  AS BIT = 0,
              @Today                      AS DATE = GETDATE(),
              @TodayTime                  AS DATETIME = GETDATE(),
              @InsdTypeVehicle            AS INT = 2,
              @InsdDescTypeVehicle        AS NVARCHAR(500),
              @IdCountry                  AS NVARCHAR(2),
              @LimitHour                  AS NVARCHAR(5),
              @TransactionStarted         AS INT = 0,
              @ResultStartDate            AS DATETIME = NULL,
              @ResultEndDate              AS DATETIME = NULL,
              @ResultTypeVehiculeId       AS INT,
              @ResultQuantityRegularPackages AS INT = NULL;

      BEGIN TRY
           -- INICIAR TRANSACCIÓN
           IF @@TRANCOUNT = 0
           BEGIN
               BEGIN TRANSACTION;
               SET @TransactionStarted = 1;
           END

            DECLARE @addressPickUp AS VARCHAR(500),
                    @nameSender AS VARCHAR(200),
                    @phoneSender AS VARCHAR(50),
                    @idHub AS INT,
                    @idTownship AS INT,
                    @idProvince AS INT;

            IF(CAST(@StartDate AS DATE) >= @Today)
            BEGIN 
                 -- 1. Validar que no exista un servicio en el día ya solicitado
                 SELECT @SchedulePickupFinded    =SP.SchedulePickupId,
                        @ServiceManagementFinded = SM.IdServiceManagement,
                        @CatServiceStatusFinded  = cs.[name],
                        @ResultStartDate = sp.StartDate,
                        @ResultEndDate = sp.EndDate,
                        @ResultTypeVehiculeId = TypeVehicleId,
                        @ResultQuantityRegularPackages = QuantityRegularPackages
                  FROM dbo.SchedulePickup sp WITH(NOLOCK)
                       LEFT JOIN dbo.ServiceManagement sm WITH(NOLOCK)
                         ON SM.IdSchedulePickup = SP.SchedulePickupId
                       LEFT JOIN DeliveryBackOffice.dbo.CatServiceStatus cs WITH(NOLOCK)
                         ON cs.IdServiceStatus = sm.ServiceStatusId
                 WHERE SM.RowStatus = 1
                       AND (
                            sp.SchedulePickupStatus IS NULL  --RECOLECCIONES ACTIVAS
                            OR sp.SchedulePickupStatus = 1   --RECOLECCIONES ACTIVAS
                           )
                       AND sp.RowStatus = 1
                       AND CONVERT(DATE, SP.StartDate) = CONVERT(DATE, @StartDate)
                       AND sp.SenderId=@CodeOfReference;

                 IF @SchedulePickupFinded > 0
                 BEGIN 
                      SELECT @InsdDescTypeVehicle = [Name]
                        FROM CatTypeVehicle WITH(NOLOCK)
                       WHERE IdTypeVehicle = @ResultTypeVehiculeId

                      SELECT @ResultTypeVehiculeId = CASE 
                                                         WHEN @InsdDescTypeVehicle = 'Motocicleta' THEN 1
                                                         WHEN @InsdDescTypeVehicle = 'Panel' THEN 2
                                                         WHEN @InsdDescTypeVehicle = 'Camión' THEN 3
                                                         ELSE 'Panel'
                                                     END

                      IF @ServiceManagementFinded > 0
                      BEGIN 
                           SELECT @IdResult = 409,
                                  @ErrorMessage = CONCAT('Ya fue solicitado un servicio de recolección el día de hoy para este Punto de Visita ','/ En estado: ' + @CatServiceStatusFinded),
                                  @IsSuccess = 1,
                                  @CodeOfReference = @CodeOfReference,
                                  @ResultService = @ServiceManagementFinded,
                                  @ResultStartDate = FORMAT(@ResultStartDate, 'd/MM/yyyy HH:mm:ss'),
                                  @ResultEndDate = FORMAT(@ResultEndDate, 'd/MM/yyyy HH:mm:ss'),
                                  @ResultTypeVehiculeId = @ResultTypeVehiculeId,
                                  @ResultQuantityRegularPackages = @ResultQuantityRegularPackages;
                      END 
                      ELSE 
                      BEGIN
                           SELECT @IdResult = 409,
                                  @ErrorMessage = 'Ya fue solicitado un servicio de recolección el día de hoy para este punto de Visita pero ocurrio un error',
                                  @IsSuccess = 1,
                                  @CodeOfReference = @CodeOfReference,
                                  @ResultService = 0,
                                  @ResultStartDate = FORMAT(@ResultStartDate, 'd/MM/yyyy HH:mm:ss'),
                                  @ResultEndDate = FORMAT(@ResultEndDate, 'd/MM/yyyy HH:mm:ss'),
                                  @ResultTypeVehiculeId = @ResultTypeVehiculeId,
                                  @ResultQuantityRegularPackages = @ResultQuantityRegularPackages;
                      END
                 END
            END
            ELSE IF(CAST(@StartDate AS DATE) < @Today)
            BEGIN 
                 SELECT @IdResult = 409,
                        @ErrorMessage = 'No es posible solicitar una recolección para un día anterior al día actual',
                        @IsSuccess = 1,
                        @CodeOfReference = @CodeOfReference,
                        @ResultService = 0;
            END

            IF @IsSuccess = 0
               AND @SchedulePickupFinded = 0
            BEGIN 
                  SELECT @nameSender = ISNULL(Cu.[Name],''),
                         @phoneSender = CASE 
                                            WHEN vpc.Phone LIKE '(%' THEN
                                                ISNULL(TRANSLATE(SUBSTRING(vpc.Phone, CHARINDEX(')', vpc.Phone) + 1, LEN(vpc.Phone)), '()- ', '    '),'')
                                            ELSE 
                                                ISNULL(TRANSLATE(vpc.Phone, '()- ', '    '),'')
                                        END,
                         @addressPickUp = ISNULL(VPC.[Address],''),
                         @idTownship = ISNULL(VPC.IdTownship,0),
                         @idHub = ISNULL(HL.IdHubLogistic,''),
                         @idProvince = ISNULL(Tw.IdProvince, ''),
                         @IdCountry = ISNULL(Cu.CountryID,'GT')
                    FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
                         LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK) 
                              ON Cu.IdCustomer = VPC.CustomerID
                         LEFT JOIN [DeliveryBackOffice].[dbo].[Township] Tw WITH(NOLOCK)
                              ON Tw.IdTownship = VPC.IdTownship
                         OUTER APPLY (
                                      SELECT TOP 1 
                                             DSC.HeaderCode
                                            ,MAX(DSC.Hub) AS [Hub]
                                        FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
                                       WHERE DSC.RowStatus = 1
                                         AND DSC.HeaderCode = Tw.HeaderCode 
                                       GROUP BY DSC.HeaderCode
                                     ) DSC 
                         LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] HL WITH(NOLOCK)
                              ON HL.HubAbbreviation = DSC.Hub
                   WHERE VPC.CodeOfReference = @CodeOfReference
                     AND (Cu.RowSatus =1 OR Cu.RowSatus IS NULL)
                     AND VPC.StatusClient=1

                SELECT @LimitHour = dfv.LimitHourPickupByApi
                  FROM DeliveryBackOffice.dbo.DefaultValuesPerCountry dfv WITH(NOLOCK)
                 WHERE dfv.IdCountry = @IdCountry

                IF (CONVERT(TIME, @TodayTime) <= @LimitHour) AND (CAST(@StartDate AS DATE) = @Today)
                   OR (CAST(@StartDate AS DATE) > @Today)
                BEGIN 

                  IF LEN(@addressPickUp) > 0
                     AND LEN(@nameSender) > 0
                     AND LEN(@idProvince) > 0
                     AND LEN(@idTownship) > 0
                     AND LEN(@phoneSender) > 0
                     AND LEN(@idHub) > 0
                  BEGIN
                        IF @EndDate IS NULL 
                        BEGIN
                            --Se agregan 2 horas en caso de venir vacio
                            SET @EndDate=DATEADD(HOUR,2,@startdate )
                        END

                        SET @InsdDescTypeVehicle = CASE 
                                                       WHEN @TypeVehicle = 1 THEN 'Motocicleta'
                                                       WHEN @TypeVehicle = 2 THEN 'Panel'
                                                       WHEN @TypeVehicle = 3 THEN 'Camión'
                                                       ELSE 'Panel'
                                                   END

                        SELECT @InsdTypeVehicle  = IdTypeVehicle
                          FROM DeliveryBackOffice.dbo.CatTypeVehicle WITH(NOLOCK)
                         WHERE [Name] = @InsdDescTypeVehicle
                           AND ISNULL(IdCountry,'GT') = @IdCountry --Necesario el ISNULL debido a valores nulos en el catálogo

                        INSERT INTO [DeliveryBackOffice].[dbo].[SchedulePickup]
                        (
                          StartDate,
                          EndDate,
                          EstimatedWeight,
                          IsLargePackage,
                          QuantityRegularPackages,
                          QuantityOverDimensionedPackage,
                          RowStatus,
                          TokenCreated,
                          DateCreated,
                          SenderId,
                          SenderName,
                          SenderPhone,
                          IdHubLogistics,
                          AmountPickup,
                          IdSourcePlataform,
                          AddressPickup,
                          TownshipId,
                          TypeVehicleId,
                          IsScheduled
                        )
                        VALUES
                        (
                         LEFT(CONVERT(VARCHAR, @startDate, 120), 16),                 --StartDate
                         LEFT(CONVERT(VARCHAR, @endDate, 120), 16),                   --EndDate
                         0,                          --EstimatedWeight
                         0,                          --IsLargePackage
                         @QuantityOfPieces,          --QuantityRegularPackages
                         0,                          --QuantityOverDimensionedPackage
                         1,                          --RowStatus
                         @CodeApp,                   --TokenCreated
                         GETDATE(),                  --DateCreated
                         @CodeOfReference,           --SenderId
                         @nameSender,                --Fullname
                         REPLACE(@phoneSender, ' ', ''), --Phone
                         @idHub,                     --IdHubLogistics
                         0.00,                       --AmountPickup
                         8,                          --IdSourcePlataform
                         @addressPickUp,             --AddressPickup
                         @idTownship,                --Towship
                         @InsdTypeVehicle,           --@TypeVehicle
                         0                           --@IsScheduled
                        );

                        SET @SchedulePickupFinded = SCOPE_IDENTITY();

                        IF @SchedulePickupFinded > 0
                        BEGIN
                            INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagement]
                            (
                              IdSchedulePickup,
                              RowStatus,
                              TokenCreated,
                              DateCreated,
                              ServiceStatusId,
                              Amount,
                              CatPaymentTimeId
                            )
                            VALUES
                            (
                             @SchedulePickupFinded,
                             1,
                             @CodeApp,
                             GETDATE(),
                             1,
                             0.00,
                             NULL
                            );

                            SET @ServiceManagementFinded = SCOPE_IDENTITY();

                            INSERT INTO [DeliveryBackOffice].[dbo].[EventService]
                            (
                             ServiceManagementId,
                             ServiceStatusId,
                             RowStauts,
                             TokenCreated,
                             DateCreated
                            )
                            VALUES 
                            ( 
                             @ServiceManagementFinded,
                             1,
                             1,
                             @CodeApp,
                             GETDATE()
                            );

                            SELECT @IdResult = 200,
                                   @ErrorMessage = 'Solicitud de recolección procesada correctamente ',
                                   @IsSuccess = 1,
                                   @CodeOfReference = @CodeOfReference,
                                   @ResultStartDate = @startDate,
                                   @ResultEndDate = @endDate,
                                   @ResultService = @ServiceManagementFinded,
                                   @ResultQuantityRegularPackages = @QuantityOfPieces,
                                   @ResultTypeVehiculeId = @TypeVehicle;

                            -- COMMIT de la transacción
                            IF @TransactionStarted = 1
                            BEGIN
                                COMMIT TRANSACTION;
                                SET @TransactionStarted = 0;
                            END
                       END
                       ELSE 
                       BEGIN 
                           SELECT @IdResult = 400,
                                  @ErrorMessage = 'No es posible solicitar una recolección',
                                  @IsSuccess = 1,
                                  @CodeOfReference = @CodeOfReference,
                                  @ResultService = 0;

                           -- ROLLBACK en caso de error
                           IF @TransactionStarted = 1 AND @@TRANCOUNT > 0
                           BEGIN
                               ROLLBACK TRANSACTION;
                           END
                       END
                  END
                  ELSE 
                  BEGIN 
                       IF LEN(@addressPickUp) <= 0
                       BEGIN
                           SELECT @IdResult = 400,
                                  @ErrorMessage = 'La dirección del punto de visita indicado está vacía / No es posible procesar la solicitud',
                                  @IsSuccess = 0,
                                  @CodeOfReference = @CodeOfReference;
                       END
                       ELSE IF LEN(@nameSender) <= 0
                       BEGIN
                           SELECT @IdResult = 400,
                                  @ErrorMessage = 'El nombre del cliente relaciado al punto de visita está vacío / No es posible procesar la solicitud',
                                  @IsSuccess = 0,
                                  @CodeOfReference = @CodeOfReference;
                       END
                       ELSE IF @idProvince <= 0
                       BEGIN
                           SELECT @IdResult = 400,
                                  @ErrorMessage = 'El Id de Provincia del punto de visita indicado está vacío / No es posible procesar la solicitud',
                                  @IsSuccess = 0,
                                  @CodeOfReference = @CodeOfReference;
                       END
                       ELSE IF @idTownship <= 0
                       BEGIN
                           SELECT @IdResult = 400,
                                  @ErrorMessage = 'El Id de Poblado del punto de visita indicado está vacío / No es posible procesar la solicitud',
                                  @IsSuccess = 0,
                                  @CodeOfReference = @CodeOfReference;
                       END
                       ELSE IF LEN(@phoneSender) <= 0
                       BEGIN
                           SELECT @IdResult = 400,
                                  @ErrorMessage = 'El Número de telefono asociado al punto de visita está vacío / No es posible procesar la solicitud',
                                  @IsSuccess = 0,
                                  @CodeOfReference = @CodeOfReference;
                       END
                       ELSE IF LEN(@idHub) <= 0
                       BEGIN
                           SELECT @IdResult = 400,
                                  @ErrorMessage = 'El cliente no tiene coberta con ningún Hub para el punto de visita indicado / No es posible procesar la solicitud',
                                  @IsSuccess = 0,
                                  @CodeOfReference = @CodeOfReference;
                       END
                  END
                END
                ELSE 
                BEGIN 
                     SELECT @IdResult = 409 ,
                            @ErrorMessage = CONCAT('Las solicitudes de recolección no pueden solicitarse despues de las ', ISNULL(@LimitHour,'17:00'), ' hrs.'),
                            @IsSuccess = 1,
                            @CodeOfReference = @CodeOfReference,
                            @ResultService = 0;
                END
            END

         -- COMMIT de la transacción
         IF @TransactionStarted = 1
         BEGIN
             COMMIT TRANSACTION;
             SET @TransactionStarted = 0;
         END

      END TRY
      BEGIN CATCH
           -- ROLLBACK en caso de error
           IF @TransactionStarted = 1 AND @@TRANCOUNT > 0
           BEGIN
               ROLLBACK TRANSACTION;
           END

           SELECT @IdResult = 500,
                  @ErrorMessage = CONCAT('Error del sistema: ',CAST(ERROR_MESSAGE() AS NVARCHAR(250))),
                  @IsSuccess = 0;
      END CATCH;

      SELECT REPLACE(@IsSuccess, ' ', '') AS IsSuccess,
             @IdResult AS IdResult,
             @ErrorMessage AS ErrorMessage,
             @CodeOfReference AS CodeOfReference,
             @ResultStartDate AS ResultStartDate,
             @ResultEndDate AS ResultEndDate,
             @ResultService AS ResultService,
             @ResultTypeVehiculeId AS ResultTypeVehiculeId,
             @ResultQuantityRegularPackages AS ResultQuantityRegularPackages,
             CASE 
                 WHEN @IdResult = 200 THEN 'CREATED'
                 WHEN @IdResult = 409 THEN 'ERROR_IN_PROCESS'
                 ELSE 'SYSTEM_ERROR'
             END AS ResultType;

      RETURN;

END;
