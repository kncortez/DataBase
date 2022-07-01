
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-15>
-- Description:	<Desasignación de un servicio a una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_SchedulePickUp]
    @startDate AS DATETIME,
    @endDate AS DATETIME,
    @estimateWeight AS DECIMAL,
    @quantityRegular AS INT,
    @quantityOverDimensioned AS INT,
    @token AS VARCHAR(50),
    @idSender AS INT,
    @nameSender AS VARCHAR(200),
    @phoneSender AS VARCHAR(50),
    @idHub AS INT,
    @addressPickUp AS VARCHAR(500),
    @idTownship AS INT,
    @Guides NVARCHAR(MAX),
    @TotalAmount DECIMAL(16, 2) = 0,
    @PaymentTime VARCHAR(55) = NULL,
    @TypeVehicle INT = 2,          -- 2 Panel
    @IsScheduled BIT = 1,
    @SchedulePickupId BIGINT = -1, --Si existe duplicado y se acepto > Id de la solicitud
    @IsCanceledPar BIT = 0,        --Si está cancelado el duplicado
    @IsReturn BIT = 0
AS
BEGIN
    DECLARE @amountPickUp AS INT;
    DECLARE @idSchedulePickUp AS INT;
    DECLARE @idSchedule AS INT;
    DECLARE @GuideSerie NVARCHAR(2);
    DECLARE @GuideNumber INT;
    DECLARE @dopdId INT;
    DECLARE @CatPaymentTimeId INT;
    DECLARE @GuidesIterate TABLE
    (
        GuideSerie NVARCHAR(2),
        GuideNumber INT
    );
    IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
        DROP TABLE #listGuides;

    --Variables de control para validar duplicados
    DECLARE @IsDuplicated BIT = 0;
    DECLARE @SchedulePickupFinded BIGINT;
    DECLARE @SchedulePickupStatusFinded BIT;
    DECLARE @ServiceManagementFinded INT;
    DECLARE @CatServiceStatusFinded INT;
    DECLARE @CatServiceStatusName NVARCHAR(100);
    DECLARE @MessageToReturn NVARCHAR(200);
    DECLARE @IsCanceled BIT = 0;
    DECLARE @IsIncidence BIT = 0;
    DECLARE @CodeRoute VARCHAR(100);

    --Si no se ha confirmo una solicitud duplicada 
    IF @SchedulePickupId = -1
    BEGIN
        --Verificar si ya existe la solicitud
        SELECT TOP 1
               @SchedulePickupFinded = SchedulePickupId,
               @SchedulePickupStatusFinded = SchedulePickupStatus
        FROM SchedulePickup
        WHERE CAST(StartDate AS DATE) = CAST(@startDate AS DATE)
              AND
              (
                  (
                      @IsReturn = 0
                      AND SenderId = @idSender
                  )
                  OR
                  (
                      @IsReturn = 1
                      AND AddressPickup = @addressPickUp
                  )
              )
              AND RowStatus = 1
        ORDER BY SchedulePickupId DESC;

        IF @SchedulePickupFinded IS NOT NULL
        BEGIN

            SET @IsDuplicated = 1;

            --Verificar si ya fué asignada
            SELECT @ServiceManagementFinded = sm.IdServiceManagement,
                   @CatServiceStatusFinded = sm.ServiceStatusId,
                   @CodeRoute = CONCAT(' (', cr.CodeRoute, ')')
            FROM ServiceManagement sm
                LEFT JOIN RouteAssigment ra
                    ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
                       AND ra.RowStatus = 1
                LEFT JOIN CatRoute cr
                    ON cr.IdRoute = ra.IdRoute
            WHERE sm.IdSchedulePickup = @SchedulePickupFinded
                  AND sm.RowStatus = 1;

            IF @ServiceManagementFinded IS NOT NULL
            BEGIN

                IF @CodeRoute IS NULL
                    SET @CodeRoute = '';

                --Si se encuentra, validar en qué estado se encuentra
                SELECT @CatServiceStatusName = [Name]
                FROM CatServiceStatus
                WHERE IdServiceStatus = @CatServiceStatusFinded;

                IF @CatServiceStatusName = 'Cancelado'
                BEGIN
                    SET @IsCanceled = 1;
                    SET @MessageToReturn
                        = CONCAT(
                                    'Ya existe una recolección identificada con el número ',
                                    @ServiceManagementFinded,
                                    ' asignado a ruta',
                                    @CodeRoute,
                                    ', pero se encuentra cancelado. ¿Desea habilitarlo?'
                                );
                END;
                ELSE IF @CatServiceStatusName = 'Incidencia'
                BEGIN
                    SET @IsIncidence = 1;
                    SET @MessageToReturn
                        = CONCAT(
                                    'Ya existe una recolección identificada con el número ',
                                    @ServiceManagementFinded,
                                    ' asignado a ruta',
                                    @CodeRoute,
                                    ', pero con incidencia. ¿Desea crear otra solicitud? '
                                );
                END;
                ELSE IF @CatServiceStatusName = 'Recolectado'
                BEGIN
                    SET @IsIncidence = 1;
                    SET @MessageToReturn
                        = CONCAT(
                                    'Ya existe una recolección identificada con el número ',
                                    @ServiceManagementFinded,
                                    ' recolectada. ¿Desea crear otra otra solicitud?'
                                );
                END;
                ELSE IF @CatServiceStatusName = 'Reprogramado'
                BEGIN
                    SET @MessageToReturn
                        = CONCAT(
                                    'Ya existe una recolección identificada con el número ',
                                    @ServiceManagementFinded,
                                    ' en estado ',
                                    @CatServiceStatusName,
                                    '. No se puede crear la solicitud. '
                                );
                END;
                ELSE
                BEGIN
                    IF @CatServiceStatusName = 'Creado'
                    BEGIN
                        IF @SchedulePickupStatusFinded = 0
                        BEGIN
                            SET @IsCanceled = 1;
                            SET @MessageToReturn
                                = CONCAT(
                                            'Ya existe una recolección identificada con el número ',
                                            @ServiceManagementFinded,
                                            ', pero se encuentra cancelada. ¿Desea habilitarla?'
                                        );
                        END;
                        ELSE
                            SET @MessageToReturn
                                = CONCAT(
                                            'Ya existe una recolección identificada con el número ',
                                            @ServiceManagementFinded,
                                            '. No se puede crear la solicitud.'
                                        );
                    END;
                    ELSE
                    BEGIN
                        SET @MessageToReturn
                            = CONCAT(
                                        'Ya existe una recolección identificada con el número ',
                                        @ServiceManagementFinded,
                                        ' asignada a ruta',
                                        @CodeRoute,
                                        ' en estado "',
                                        @CatServiceStatusName,
                                        '". No se puede crear la solicitud.'
                                    );
                    END;
                END;
            END;
            ELSE
            BEGIN
                IF @SchedulePickupStatusFinded = 0
                BEGIN
                    SET @IsCanceled = 1;
                    SET @MessageToReturn
                        = N'Ya existe una recolección , pero se encuentra cancelada. ¿Desea habilitarla?';
                END;
                ELSE
                    SET @MessageToReturn
                        = CONCAT(
                                    'Ya existe una recolección ',
                                    IIF(@ServiceManagementFinded IS NOT NULL,
                                        CONCAT('identificada con el número ', @ServiceManagementFinded),
                                        ''),
                                    '. No se puede crear la solicitud.'
                                );
            END;

        END;
    END;

    --Si no se encuntra un duplicado o se tiene que crear otro servicio confirmado
    IF (
           @IsDuplicated = 0
           AND @SchedulePickupId = -1
       )
       OR
       (
           @SchedulePickupId <> -1
           AND @IsCanceledPar = 0
       )
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            IF @Guides = ''
                SET @Guides = NULL;

            SELECT SUBSTRING(Item, 1, 2) ItemSerie,
                   SUBSTRING(Item, 3, LEN(Item)) ItemNumber
            INTO #listGuides
            FROM DeliveryBackOffice.dbo.SplitUnlimited(@Guides, ',');

            INSERT INTO @GuidesIterate
            SELECT ItemSerie,
                   ItemNumber
            FROM #listGuides;

            IF @PaymentTime IS NOT NULL
                SET @CatPaymentTimeId =
            (
                SELECT TimePlaId FROM CatPaymentTime WHERE TimePlaName = @PaymentTime
            )   ;

            SELECT @amountPickUp = Value
            FROM [DeliveryBackOffice].[dbo].[CatToCharge]
            WHERE IdToCharge = 1;

            IF @idHub != ''
            BEGIN
                IF @idTownship != ''
                BEGIN
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
                    (@startDate, @endDate, @estimateWeight, 0, @quantityRegular, @quantityOverDimensioned, 1, @token,
                     GETDATE(), @idSender, @nameSender, @phoneSender, @idHub, @amountPickUp, 2, @addressPickUp,
                     @idTownship, @TypeVehicle, @IsScheduled);
                END;
                ELSE
                BEGIN
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
                        TypeVehicleId,
                        IsScheduled
                    )
                    VALUES
                    (@startDate, @endDate, @estimateWeight, 0, @quantityRegular, @quantityOverDimensioned, 1, @token,
                     GETDATE(), @idSender, @nameSender, @phoneSender, @idHub, @amountPickUp, 2, @addressPickUp,
                     @TypeVehicle, @IsScheduled);
                END;
            END;
            ELSE
            BEGIN
                IF @idTownship != ''
                BEGIN
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
                        AmountPickup,
                        IdSourcePlataform,
                        AddressPickup,
                        TownshipId,
                        TypeVehicleId,
                        IsScheduled
                    )
                    VALUES
                    (@startDate, @endDate, @estimateWeight, 0, @quantityRegular, @quantityOverDimensioned, 1, @token,
                     GETDATE(), @idSender, @nameSender, @phoneSender, @amountPickUp, 2, @addressPickUp, @idTownship,
                     @TypeVehicle, @IsScheduled);
                END;
                ELSE
                BEGIN
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
                        AmountPickup,
                        IdSourcePlataform,
                        AddressPickup,
                        TypeVehicleId,
                        IsScheduled
                    )
                    VALUES
                    (@startDate, @endDate, @estimateWeight, 0, @quantityRegular, @quantityOverDimensioned, 1, @token,
                     GETDATE(), @idSender, @nameSender, @phoneSender, @amountPickUp, 2, @addressPickUp, @TypeVehicle,
                     @IsScheduled);
                END;
            END;

            --SELECT  @idSchedulePickUp =  IDENT_CURRENT('[DeliveryBackOffice].[dbo].[SchedulePickup]')
            SET @idSchedulePickUp = SCOPE_IDENTITY();

            --Asignar el SchedulePickup en la DeliveryOrderPaymentDetail
            WHILE EXISTS (SELECT TOP 1 1 FROM @GuidesIterate)
            BEGIN
                SELECT TOP 1
                       @GuideSerie = GuideSerie,
                       @GuideNumber = GuideNumber
                FROM @GuidesIterate;

                --Validar que tenga registro en la DeliveryOrderPaymentDetail sino lo crea
                SELECT @dopdId = dopd.DopId
                FROM DeliveryOrderPaymentDetail dopd
                WHERE dopd.GuideSerie = @GuideSerie
                      AND dopd.GuideNumber = @GuideNumber;

                IF @dopdId IS NULL
                BEGIN

                    INSERT INTO [dbo].[DeliveryOrderPaymentDetail]
                    (
                        [GuideNumber],
                        [GuideSerie],
                        [PayTypeId],
                        [TypeofInOutMoneyId],
                        [TimePlaId],
                        [amount],
                        [TokenCreated],
                        [DateCreated],
                        [TokenUpdated],
                        [DateUpdated],
                        [PaymentRecollections],
                        [PaymentNow],
                        [PaymentDelivery],
                        [StartDate],
                        [EndDate],
                        [ShipmentCompleted],
                        [RecollectionCompleted],
                        [PaidGuide],
                        [TransaccionFAC],
                        [IdHeaderRecolection],
                        [RecolectNow],
                        [RecolectDelivery],
                        [RecolectPayment]
                    )
                    --,[TypeService]
                    --,[IdAccount])
                    SELECT @GuideNumber,
                           @GuideSerie,
                           CASE
                               WHEN do.IsCollect = 1 THEN
                               (
                                   SELECT PayTypeId FROM CatPaymentType WHERE PayTypeAbrev = 'COLLT'
                               )
                               WHEN cu.ConditionOfPaymentID > 1 THEN
                               (
                                   SELECT PayTypeId FROM CatPaymentType WHERE PayTypeAbrev = 'CREDT'
                               )
                               ELSE
                           (
                               SELECT PayTypeId FROM CatPaymentType WHERE PayTypeAbrev = 'CONT'
                           )
                           END,
                           CASE
                               WHEN do.IsCollect = 1 THEN
                                   1
                               WHEN cu.ConditionOfPaymentID > 1 THEN
                                   8
                               ELSE
                                   1
                           END,
                           CASE
                               WHEN do.IsCollect = 1 THEN
                               (
                                   SELECT TimePlaId FROM CatPaymentTime WHERE TimePlaAbrev = 'DEST'
                               )
                               WHEN cu.ConditionOfPaymentID > 1 THEN
                               (
                                   SELECT TimePlaId FROM CatPaymentTime WHERE TimePlaAbrev = 'POST'
                               )
                               ELSE
                           (
                               SELECT TimePlaId FROM CatPaymentTime WHERE TimePlaAbrev = 'AHR'
                           )
                           END,
                           0,
                           @token,
                           GETDATE(),
                           NULL,
                           NULL,
                           0,
                           0,
                           0,
                           NULL,
                           NULL,
                           0,
                           0,
                           0,
                           NULL,
                           @idSchedulePickUp,
                           NULL,
                           NULL,
                           NULL
                    --,NULL
                    --,NULL
                    FROM DeliveryOrder do
                        JOIN Customer cu
                            ON cu.IdCustomer =
                            (
                                SELECT TOP 1
                                       ISNULL(do.IdCustomer, vpc.CustomerID)
                                FROM dbo.VisitPointClient vpc
                                WHERE vpc.CodeOfReference = do.Sender_ID
                            )
                    WHERE do.Guide_Serie = @GuideSerie
                          AND do.Guide_Number = @GuideNumber;
                END;
                ELSE
                    UPDATE [dbo].[DeliveryOrderPaymentDetail]
                    SET IdHeaderRecolection = @idSchedulePickUp
                    WHERE DopId = @dopdId;

                -- cambiar statusorder 
                UPDATE [dbo].[DeliveryOrder]
                SET StatusOrderId = 1
                WHERE Guide_Serie = @GuideSerie
                      AND Guide_Number = @GuideNumber;

                -- insertar checkpoint
                INSERT INTO [dbo].[DeliveryOrderDetail]
                (
                    [Guide_Serie],
                    [Guide_Number],
                    [StatusOrderId],
                    [UserCreated],
                    [DateCreated],
                    [DateCreatedInSystem],
                    [Observations],
                    [Temperature_Celsius],
                    [PieceId],
                    [RowStatus]
                )
                VALUES
                (@GuideSerie, @GuideNumber, 1, @token, GETDATE(), GETDATE(), NULL, NULL, NULL, 'TRUE');




                -- se elimina la guía de la tabla temporal
                DELETE FROM @GuidesIterate
                WHERE GuideSerie = @GuideSerie
                      AND GuideNumber = @GuideNumber;
            END;

            IF NOT EXISTS
            (
                SELECT IdSchedulePickup
                FROM [DeliveryBackOffice].[dbo].[ServiceManagement]
                WHERE IdSchedulePickup = @idSchedulePickUp
            )
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
                (@idSchedulePickUp, 1, @token, GETDATE(), 1, @TotalAmount, @CatPaymentTimeId);

                --SELECT  @idSchedule =  IDENT_CURRENT('[DeliveryBackOffice].[dbo].[ServiceManagement]')
                SET @idSchedule = SCOPE_IDENTITY();

                INSERT INTO [DeliveryBackOffice].[dbo].[EventService]
                (
                    ServiceManagementId,
                    ServiceStatusId,
                    RowStauts,
                    TokenCreated,
                    DateCreated
                )
                VALUES
                (@idSchedule, 1, 1, @token, GETDATE());
            END;
            ELSE
            BEGIN
                DECLARE @LastServiceManagement AS TABLE
                (
                    IdServiceManagement INT,
                    DateOfSM DATETIME
                );

                UPDATE [dbo].[ServiceManagement]
                SET Amount = @TotalAmount,
                    CatPaymentTimeId = @CatPaymentTimeId,
                    TokenUpdated = @token,
                    DateUpdated = GETDATE()
                OUTPUT inserted.IdServiceManagement,
                       inserted.DateCreated
                INTO @LastServiceManagement
                (
                    IdServiceManagement,
                    DateOfSM
                )
                WHERE IdSchedulePickup = @idSchedulePickUp;

                SELECT TOP 1
                       @idSchedule = LSM.IdServiceManagement
                FROM @LastServiceManagement LSM
                ORDER BY LSM.DateOfSM DESC;
            END;

            --Registro log si es duplicado
            IF @SchedulePickupId <> -1
            BEGIN

                INSERT INTO [dbo].[SchedulePickupDuplicateLog]
                (
                    [SchedulePickupIdOld],
                    [SchedulePickupIdNew],
                    [RowStatus],
                    [TokenCreated],
                    [DateCreated],
                    [TokenUpdated],
                    [DateUpdated]
                )
                VALUES
                (@SchedulePickupId, @idSchedulePickUp, 1, @token, GETDATE(), NULL, NULL);

            END;

            IF @@TRANCOUNT > 0
            BEGIN
                COMMIT TRANSACTION;

                SELECT 1 [blnResult],
                       'Registros guardados correctamente' [Description],
                       @idSchedule [IdService],
                       @@TRANCOUNT [NumTransferID];
            END;
            ELSE
            BEGIN
                ROLLBACK TRANSACTION;

                SELECT -1 [blnResult],
                       'Registros no guardados' [Description],
                       @@TRANCOUNT [NumTransferID];
            END;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;

            SELECT 0 [blnResult],
                   ERROR_NUMBER() [ErrorNumber],
                   ERROR_SEVERITY() [ErrorSeverity],
                   ERROR_STATE() [ErrorState],
                   ERROR_PROCEDURE() [ErrorProcedure],
                   ERROR_LINE() [ErrorLine],
                   ERROR_MESSAGE() [ErrorMessage];
        END CATCH;
    END;
    ELSE IF @IsDuplicated = 1
    BEGIN
        IF @IsCanceled = 1
        BEGIN
            SELECT 400 [blnResult],
                   @MessageToReturn [Description],
                   @SchedulePickupFinded [SchedulePickupId];
        END;
        ELSE IF @IsIncidence = 1
        BEGIN
            SELECT 401 [blnResult],
                   @MessageToReturn [Description],
                   @SchedulePickupFinded [SchedulePickupId];
        END;
        ELSE
        BEGIN
            SELECT 402 [blnResult],
                   @MessageToReturn [Description];
        END;
    END;
    ELSE IF @SchedulePickupId <> -1
            AND @IsCanceledPar = 1
    BEGIN
        --Habilitar servicios y actualizar la información
        BEGIN TRY
            BEGIN TRANSACTION;

            IF @PaymentTime IS NOT NULL
                SET @CatPaymentTimeId =
            (
                SELECT TimePlaId FROM CatPaymentTime WHERE TimePlaName = @PaymentTime
            )   ;

            SELECT @ServiceManagementFinded = sm.IdServiceManagement,
                   @CatServiceStatusName = css.[Name]
            FROM ServiceManagement sm
                INNER JOIN CatServiceStatus css
                    ON css.IdServiceStatus = sm.ServiceStatusId
            WHERE sm.IdSchedulePickup = @SchedulePickupId;

            IF @ServiceManagementFinded IS NOT NULL
               AND @CatServiceStatusName = 'Cancelado'
            BEGIN
                UPDATE ServiceManagement
                SET CatPaymentTimeId = @CatPaymentTimeId,
                    ServiceStatusId = 2,
                    TokenUpdated = @token,
                    DateUpdated = GETDATE()
                WHERE IdSchedulePickup = @SchedulePickupId;
            END;
            ELSE
            BEGIN
                IF @ServiceManagementFinded IS NOT NULL
                BEGIN
                    UPDATE ServiceManagement
                    SET CatPaymentTimeId = @CatPaymentTimeId,
                        TokenUpdated = @token,
                        DateUpdated = GETDATE()
                    WHERE IdSchedulePickup = @SchedulePickupId;
                END;
            END;

            UPDATE SchedulePickup
            SET StartDate = @startDate,
                EndDate = @endDate,
                EstimatedWeight = @estimateWeight,
                IsLargePackage = 0,
                QuantityRegularPackages = @quantityRegular,
                QuantityOverDimensionedPackage = @quantityOverDimensioned,
                TokenUpdated = @token,
                DateUpdated = GETDATE(),
                SenderName = @nameSender,
                SenderPhone = @phoneSender,
                IdHubLogistics = IIF(@idHub != '', @idHub, IdHubLogistics),
                AmountPickup = @amountPickUp,
                IdSourcePlataform = 2,
                AddressPickup = @addressPickUp,
                TownshipId = IIF(@idTownship != '', @idTownship, TownshipId),
                TypeVehicleId = @TypeVehicle,
                IsScheduled = @IsScheduled,
                SchedulePickupStatus = 1
            WHERE SchedulePickupId = @SchedulePickupId;

            IF @@TRANCOUNT > 0
            BEGIN
                COMMIT TRANSACTION;

                SELECT 1 [blnResult],
                       'Registros guardados correctamente' [Description],
                       @ServiceManagementFinded [IdService],
                       @@TRANCOUNT [NumTransferID];
            END;
            ELSE
            BEGIN
                ROLLBACK TRANSACTION;

                SELECT -1 [blnResult],
                       'Registros no guardados' [Description],
                       @@TRANCOUNT [NumTransferID];
            END;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;

            SELECT 0 [blnResult],
                   ERROR_NUMBER() [ErrorNumber],
                   ERROR_SEVERITY() [ErrorSeverity],
                   ERROR_STATE() [ErrorState],
                   ERROR_PROCEDURE() [ErrorProcedure],
                   ERROR_LINE() [ErrorLine],
                   ERROR_MESSAGE() [ErrorMessage];
        END CATCH;
    END;
END;
