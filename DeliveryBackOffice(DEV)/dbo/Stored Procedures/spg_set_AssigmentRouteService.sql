
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-12>
-- Description:	<Asigna una ruta a un servicio>
-- =============================================
CREATE PROCEDURE [dbo].[spg_set_AssigmentRouteService]
    @idSchedulePickup AS INT
  , @idRoute AS INT
  , @dateRoute AS DATE
  , @token AS VARCHAR(50)
  , @dateCreated AS DATETIME
  , @idSchedulePickupOld AS INT
--@Amount DECIMAL(16, 2) = 0
AS
BEGIN
    IF OBJECT_ID('tempdb.dbo.#listaCheck', 'U') IS NOT NULL
        DROP TABLE #listaCheck;
    IF OBJECT_ID('tempdb.dbo.#listaCheck1', 'U') IS NOT NULL
        DROP TABLE #listaCheck1;

    DECLARE @idCourrier AS INT;
    DECLARE @idRouteAssigment AS INT;
    DECLARE @idSchedule AS INT;
    DECLARE @Amount DECIMAL(16, 2) = 0;
    DECLARE @status INT =
            (
                SELECT StatusOrderId
                FROM StatusOrder
                WHERE OrderDescription = 'Programado para recolección'
            );

    BEGIN TRANSACTION;
    BEGIN TRY
        -------------------------------------------------------------------------------
        --Inicio calculo el monto a cobrar por el servicio (Amount)
        --VERIFICANDO LAS GUÍAS QUE POSEE
        DECLARE @guides NVARCHAR(MAX) =
                (
                    SELECT STUFF((
                                     SELECT DISTINCT
                                            ',' + CONCAT(GuideSerie, GuideNumber)
                                     FROM
                                     (
                                         SELECT DOP.GuideSerie
                                              , DOP.GuideNumber
                                              , DOP.TimePlaId
                                              , ISNULL(SM.Amount, 0) Amount
                                         FROM dbo.SchedulePickup                      SCP WITH(NOLOCK)
                                             LEFT JOIN dbo.DeliveryOrderPaymentDetail DOP WITH(NOLOCK)
                                                 ON SCP.SchedulePickupId = DOP.IdHeaderRecolection
                                             LEFT JOIN dbo.ServiceManagement          SM WITH(NOLOCK)
                                                 ON SM.IdSchedulePickup = SCP.SchedulePickupId
                                         WHERE SchedulePickupId = @idSchedulePickup
                                               AND (
                                             --CONVERSION DE OR A AND : X OR Y = NOT(NOT X AND NOT Y )
                                             --(
                                             -- @dateRoute >= CONVERT(DATE, SCP.StartDate)
                                             -- AND CONVERT(DATE, SCP.EndDate) >=@dateRoute
                                             --)
                                             --OR (@dateRoute = '')
                                             ------
                                             NOT (
                                                     NOT (
                                                             @dateRoute >= CONVERT(DATE, SCP.StartDate)
                                                             AND CONVERT(DATE, SCP.EndDate) >= @dateRoute
                                                         )
                                                     AND NOT (@dateRoute = '')
                                                 )
                                                   )
                                               AND (
                                             --CONVERSION DE OR A AND : X OR Y = NOT(NOT X AND NOT Y )
                                             NOT (
                                                     NOT (AssigmentStatus = 0)
                                                     AND NOT (AssigmentStatus IS NULL)
                                                 )
                                                   )
                                               AND SCP.RowStatus = 1
                                     ) GD
                                     WHERE GD.Amount = 0
                                           AND GD.TimePlaId < 3
                                     GROUP BY GuideSerie
                                            , GuideNumber
                                     FOR XML PATH('')
                                 )
                               , 1
                               , 1
                               , ''
                                )
                );
        IF
        (
            SELECT CodeRoute FROM CatRoute WHERE IdRoute = @idRoute
        ) LIKE '%RABBIT%'
        OR LEN(@guides) > 0
        BEGIN
            DECLARE @TempPrice TABLE
            (
                GuideSerie NVARCHAR(25) NULL
              , GuideNumber NVARCHAR(25) NULL
              , IsCollect NVARCHAR(25) NULL
              , Price DECIMAL(14, 2) NULL
              , COD DECIMAL(14, 2) NULL
              , AmountPaid DECIMAL(14, 2) NULL
              , CODPaid DECIMAL(14, 2) NULL
              , CODIsPaid DECIMAL(14, 2) NULL
              , PaymentTime INT NULL
              , TimeSequence INT NULL
              , FelNumber NVARCHAR(50) NULL
              , IsPaid INT NULL
              , IsCustomer INT NULL
              , ConditionPayment NVARCHAR(200) NULL
              , HaveCredit NVARCHAR(50) NULL
              , CollectCOD NVARCHAR(50) NULL
              , ReturnRate DECIMAL(14, 2) NULL
              , CurrencyPrice_CODCodeISO NVARCHAR(8)
              , CurrencyPrice_CODSymbol NVARCHAR(8)
              , CurrencyPriceCodeISO NVARCHAR(8)
              , CurrencyPriceSymbol NVARCHAR(8)
              , AmountToPay DECIMAL(14, 2) NULL
              , CODAmount DECIMAL(14, 2) NULL
              , ReturnRates DECIMAL(14, 2) NULL
            );
            INSERT INTO @TempPrice
            (
                GuideSerie
              , GuideNumber
              , IsCollect
              , Price
              , COD
              , AmountPaid
              , CODPaid
              , CODIsPaid
              , PaymentTime
              , TimeSequence
              , FelNumber
              , IsPaid
              , IsCustomer
              , ConditionPayment
              , HaveCredit
              , CollectCOD
              , ReturnRate
              , CurrencyPrice_CODCodeISO
              , CurrencyPrice_CODSymbol
              , CurrencyPriceCodeISO
              , CurrencyPriceSymbol
              , AmountToPay
              , CODAmount
              , ReturnRates
            )
            EXEC [dbo].[spws_get_guide_pending_payment] @InGuides = @guides
                                                      , @InTime = 2
                                                      , @IsReturn = 'FALSE'
                                                      , @CodeApp = 'SIFDCECOM300720201459'
                                                      , @IdModule = 1
                                                      , @Token = 'SYSTEM';

        END;
        SET @Amount = ISNULL((
                                 SELECT SUM(ISNULL(TP.AmountToPay, 0))FROM @TempPrice TP
                             )
                           , 0
                            );
        --SET @Amount=(SELECT  SUM(ISNULL(TP.AmountToPay,0)) FROM @TempPrice TP);
        --Fin calculo el monto a cobrar por el servicio (Amount)
        -------------------------------------------------------------------------------

        IF EXISTS
        (
            SELECT IdRouteAssigment
            FROM DeliveryBackOffice.dbo.RouteAssigment
            WHERE IdRoute = @idRoute
                  AND DateOfRoute = @dateRoute
        )
        BEGIN

            SET @idCourrier =
            (
                SELECT IdCurrierMan
                FROM DeliveryBackOffice.dbo.RouteAssigment WITH(NOLOCK)
                WHERE IdRoute = @idRoute
                      AND DateOfRoute = @dateRoute
            );

            SET @idRouteAssigment =
            (
                SELECT IdRouteAssigment
                FROM [DeliveryBackOffice].[dbo].[RouteAssigment] WITH(NOLOCK)
                WHERE IdRoute = @idRoute
                      AND DateOfRoute = @dateRoute
            );

            IF EXISTS
            (
                SELECT IdServiceManagement
                FROM DeliveryBackOffice.dbo.ServiceManagement
                WHERE IdSchedulePickup = @idSchedulePickup
            )
            BEGIN
                SELECT @idSchedule = IdServiceManagement
                FROM DeliveryBackOffice.dbo.ServiceManagement WITH(NOLOCK)
                WHERE IdSchedulePickup = @idSchedulePickup;

                UPDATE DeliveryBackOffice.dbo.ServiceManagement
                SET IdPuCourrier = @idCourrier
                  , IdPuRouteAssigment = @idRouteAssigment
                  , ServiceStatusId = 2
                  , Amount = ISNULL(Amount, 0) + @Amount
                WHERE IdServiceManagement = @idSchedule;
            END;
            ELSE
            BEGIN
                INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagement]
                (
                    IdPuCourrier
                  , IdPuRouteAssigment
                  , IdSchedulePickup
                  , RowStatus
                  , TokenCreated
                  , DateCreated
                  , ServiceStatusId
                  , Amount
                )
                VALUES
                (@idCourrier, @idRouteAssigment, @idSchedulePickup, 1, @token, @dateCreated, 2, @Amount);

                SET @idSchedule = SCOPE_IDENTITY();
            END;

            UPDATE [DeliveryBackOffice].[dbo].[SchedulePickup]
            SET AssigmentStatus = '1'
            WHERE SchedulePickupId = @idSchedulePickup;

            IF (@idSchedulePickup != @idSchedulePickupOld)
            BEGIN
                UPDATE DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail
                SET IdHeaderRecolection = @idSchedulePickup
                WHERE IdHeaderRecolection = @idSchedulePickupOld;
                UPDATE DeliveryBackOffice.dbo.SchedulePickup
                SET RowStatus = 0
                WHERE SchedulePickupId = @idSchedulePickupOld;
            END;



            INSERT INTO [DeliveryBackOffice].[dbo].[EventService]
            (
                ServiceManagementId
              , ServiceStatusId
              , RowStauts
              , TokenCreated
              , DateCreated
            )
            VALUES
            (@idSchedule, 2, 1, @token, GETDATE());



            INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
            (
                [Guide_Serie]
              , [Guide_Number]
              , [StatusOrderId]
              , [UserCreated]
              , [DateCreated]
              , [DateCreatedInSystem]
            )
            SELECT ordp.GuideSerie
                 , ordp.GuideNumber
                 , @status
                 , @token
                 , GETDATE()
                 , GETDATE()
            FROM ServiceManagement                    sm WITH (NOLOCK)
                INNER JOIN SchedulePickup             sp WITH (NOLOCK)
                    ON (sm.IdSchedulePickup = sp.SchedulePickupId)
                INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
                    ON (dopd.IdHeaderRecolection = sp.SchedulePickupId)
                INNER JOIN DeliveryOrder              ord WITH (NOLOCK)
                    ON (
                           ord.Guide_Serie = dopd.GuideSerie
                           AND ord.Guide_Number = dopd.GuideNumber
                       )
                INNER JOIN DeliveryOrderPiece         ordp WITH (NOLOCK)
                    ON (
                           ordp.GuideSerie = ord.Guide_Serie
                           AND ordp.GuideNumber = ord.Guide_Number
                       )
            WHERE sm.IdSchedulePickup = @idSchedulePickup;


            UPDATE DeliveryBackOffice.dbo.DeliveryOrder
            SET StatusOrderId = @status
              , TokenUpdated = @token
              , DateUpdated = GETDATE()
            FROM ServiceManagement                    sm WITH (NOLOCK)
                INNER JOIN SchedulePickup             sp WITH (NOLOCK)
                    ON (sm.IdSchedulePickup = sp.SchedulePickupId)
                INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
                    ON (dopd.IdHeaderRecolection = sp.SchedulePickupId)
                INNER JOIN DeliveryOrder              ord WITH (NOLOCK)
                    ON (
                           ord.Guide_Serie = dopd.GuideSerie
                           AND ord.Guide_Number = dopd.GuideNumber
                       )
            WHERE sm.IdSchedulePickup = @idSchedulePickup;



            UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
            SET StatusOrderId = @status
              , DateUpdated = GETDATE()
            FROM ServiceManagement                    sm WITH (NOLOCK)
                INNER JOIN SchedulePickup             sp WITH (NOLOCK)
                    ON (sm.IdSchedulePickup = sp.SchedulePickupId)
                INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
                    ON (dopd.IdHeaderRecolection = sp.SchedulePickupId)
                INNER JOIN DeliveryOrder              ord WITH (NOLOCK)
                    ON (
                           ord.Guide_Serie = dopd.GuideSerie
                           AND ord.Guide_Number = dopd.GuideNumber
                       )
                INNER JOIN DeliveryOrderPiece         ordp WITH (NOLOCK)
                    ON (
                           ordp.GuideSerie = ord.Guide_Serie
                           AND ordp.GuideNumber = ord.Guide_Number
                       )
            WHERE sm.IdSchedulePickup = @idSchedulePickup;


        END;
        ELSE
        BEGIN
            INSERT INTO [DeliveryBackOffice].[dbo].[RouteAssigment]
            (
                IdRoute
              , DateOfRoute
              , RowStatus
              , TokenCreated
              , DateCreated
            )
            VALUES
            (@idRoute, @dateRoute, 1, @token, @dateCreated);

            SET @idRouteAssigment =
            (
                SELECT IdRouteAssigment
                FROM [DeliveryBackOffice].[dbo].[RouteAssigment] WITH(NOLOCK)
                WHERE IdRoute = @idRoute
                      AND DateOfRoute = @dateRoute
            );

            IF EXISTS
            (
                SELECT IdServiceManagement
                FROM [DeliveryBackOffice].[dbo].[ServiceManagement]
                WHERE IdSchedulePickup = @idSchedulePickup
            )
            BEGIN
                SELECT @idSchedule = IdServiceManagement 
                FROM [DeliveryBackOffice].[dbo].[ServiceManagement] WITH(NOLOCK)
                WHERE IdSchedulePickup = @idSchedulePickup;

                UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement]
                SET IdPuCourrier = @idCourrier
                  , IdPuRouteAssigment = @idRouteAssigment
                  , ServiceStatusId = 2
                  , Amount = ISNULL(Amount, 0) + @Amount
                WHERE IdServiceManagement = @idSchedule;
            END;
            ELSE
            BEGIN
                INSERT INTO [DeliveryBackOffice].[dbo].[ServiceManagement]
                (
                    IdPuRouteAssigment
                  , IdSchedulePickup
                  , RowStatus
                  , TokenCreated
                  , DateCreated
                  , ServiceStatusId
                  , Amount
                )
                VALUES
                (@idRouteAssigment, @idSchedulePickup, 1, @token, @dateCreated, 2, @Amount);

                SET @idSchedule = SCOPE_IDENTITY();
            END;

            UPDATE [DeliveryBackOffice].[dbo].[SchedulePickup]
            SET AssigmentStatus = '1'
            WHERE SchedulePickupId = @idSchedulePickup;

            IF (@idSchedulePickup != @idSchedulePickupOld)
            BEGIN
                UPDATE DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail
                SET IdHeaderRecolection = @idSchedulePickup
                WHERE IdHeaderRecolection = @idSchedulePickupOld;
                UPDATE DeliveryBackOffice.dbo.SchedulePickup
                SET RowStatus = 0
                WHERE SchedulePickupId = @idSchedulePickupOld;
            END;

            INSERT INTO [DeliveryBackOffice].[dbo].[EventService]
            (
                ServiceManagementId
              , ServiceStatusId
              , RowStauts
              , TokenCreated
              , DateCreated
            )
            VALUES
            (@idSchedule, 2, 1, @token, GETDATE());


            INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
            (
                [Guide_Serie]
              , [Guide_Number]
              , [StatusOrderId]
              , [UserCreated]
              , [DateCreated]
              , [DateCreatedInSystem]
            )
            SELECT ordp.GuideSerie
                 , ordp.GuideNumber
                 , @status
                 , @token
                 , GETDATE()
                 , GETDATE()
            FROM ServiceManagement                    sm WITH(NOLOCK)
                INNER JOIN SchedulePickup             sp WITH(NOLOCK)
                    ON (sm.IdSchedulePickup = sp.SchedulePickupId)
                INNER JOIN DeliveryOrderPaymentDetail dopd WITH(NOLOCK)
                    ON (dopd.IdHeaderRecolection = sp.SchedulePickupId)
                INNER JOIN DeliveryOrder              ord WITH(NOLOCK)
                    ON (
                           ord.Guide_Serie = dopd.GuideSerie
                           AND ord.Guide_Number = dopd.GuideNumber
                       )
                INNER JOIN DeliveryOrderPiece         ordp WITH(NOLOCK)
                    ON (
                           ordp.GuideSerie = ord.Guide_Serie
                           AND ordp.GuideNumber = ord.Guide_Number
                       )
            WHERE sm.IdSchedulePickup = @idSchedulePickup;


            UPDATE DeliveryBackOffice.dbo.DeliveryOrder
            SET StatusOrderId = @status
              , TokenUpdated = @token
              , DateUpdated = GETDATE()
            FROM ServiceManagement                    sm
                INNER JOIN SchedulePickup             sp WITH (NOLOCK)
                    ON (sm.IdSchedulePickup = sp.SchedulePickupId)
                INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
                    ON (dopd.IdHeaderRecolection = sp.SchedulePickupId)
                INNER JOIN DeliveryOrder              ord WITH (NOLOCK)
                    ON (
                           ord.Guide_Serie = dopd.GuideSerie
                           AND ord.Guide_Number = dopd.GuideNumber
                       )
            WHERE sm.IdSchedulePickup = @idSchedulePickup;



            UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
            SET StatusOrderId = @status
              , DateUpdated = GETDATE()
            FROM ServiceManagement                    sm WITH (NOLOCK)
                INNER JOIN SchedulePickup             sp WITH (NOLOCK)
                    ON (sm.IdSchedulePickup = sp.SchedulePickupId)
                INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
                    ON (dopd.IdHeaderRecolection = sp.SchedulePickupId)
                INNER JOIN DeliveryOrder              ord WITH (NOLOCK)
                    ON (
                           ord.Guide_Serie = dopd.GuideSerie
                           AND ord.Guide_Number = dopd.GuideNumber
                       )
                INNER JOIN DeliveryOrderPiece         ordp WITH (NOLOCK)
                    ON (
                           ordp.GuideSerie = ord.Guide_Serie
                           AND ordp.GuideNumber = ord.Guide_Number
                       )
            WHERE sm.IdSchedulePickup = @idSchedulePickup;
        END;

        --Proceso para rutas de Rabbit
        IF
        (
            SELECT CodeRoute FROM CatRoute WHERE IdRoute = @idRoute
        ) LIKE '%RABBIT%'
        BEGIN
            DECLARE @SettlementPickupStationId BIGINT;
            DECLARE @SettlementPickupStationDetailId BIGINT;

            SET @SettlementPickupStationId =
            (
                SELECT IdSettlementPickupStation
                FROM SettlementPickupStation WITH(NOLOCK)
                WHERE RouteId = @idRoute
                      AND TransactionDate = @dateRoute
                      AND RowStatus = 'TRUE'
            );

            --Si no se ha creado el registro para la ruta y el día, se crea
            IF @SettlementPickupStationId IS NULL
            BEGIN

                INSERT INTO [dbo].[SettlementPickupStation]
                (
                    [CouriermanId]
                  , [RouteId]
                  , [TransactionDate]
                  , [RowStatus]
                  , [TokenCreated]
                  , [DateCreated]
                  , [TokenUpdated]
                  , [DateUpdated]
                )
                VALUES
                (@idCourrier, @idRoute, @dateRoute, 'TRUE', @token, GETDATE(), NULL, NULL);

                SET @SettlementPickupStationId = SCOPE_IDENTITY();
            END;

            --Se verifica si existe el detalle
            SET @SettlementPickupStationDetailId =
            (
                SELECT IdSettlementPickupStationDetail
                FROM SettlementPickupStationDetail WITH(NOLOCK)
                WHERE SettlementPickupStationId = @SettlementPickupStationId
                      AND ServiceManagementId = @idSchedule
                      AND RowStatus = 'TRUE'
            );

            IF @SettlementPickupStationDetailId IS NULL
                INSERT INTO [dbo].[SettlementPickupStationDetail]
                (
                    [SettlementPickupStationId]
                  , [ServiceManagementId]
                  , [Price]
                  , [SettlementStationId]
                  , [SettlementDate]
                  , [TokenSettlement]
                  , [RowStatus]
                  , [TokenCreated]
                  , [DateCreated]
                  , [TokenUpdated]
                  , [DateUpdated]
                )
                VALUES
                (@SettlementPickupStationId, @idSchedule, @Amount, NULL, NULL, NULL, 'TRUE', @token, GETDATE(), NULL
               , NULL);
            ELSE
                UPDATE SettlementPickupStationDetail
                SET Price = Price + @Amount
                  , TokenUpdated = @token
                  , DateUpdated = GETDATE()
                WHERE IdSettlementPickupStationDetail = @SettlementPickupStationDetailId;
        END;
        IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;

        SELECT 1                                 [blnResult]
             , 'Datos registrados correctamente' 'Description';

        SELECT SPC.SchedulePickupId
             , SPC.SenderName                                                                                  [Name]
             , SPC.AddressPickup                                                                               [Address]
             , SPC.SenderPhone                                                                                 [Phone]
             , CONCAT(CONVERT(VARCHAR(10), SPC.StartDate, 108), '   ', CONVERT(VARCHAR(10), SPC.EndDate, 108)) AS rangeHour
             , SPC.QuantityRegularPackages
             , SPC.QuantityOverDimensionedPackage
             , CONCAT(snr.First_Name, ' ', snr.Last_Name)                                                      AS NameCourrier
             , css.[Name]                                                                                      AS NameStatus
             , ISNULL(smt.Amount, 0)                                                                           Amount
             , smt.IdServiceManagement                                                                         IdServiceManagement
             , smt.[Order]                                                                                     [Order]
             , SPC.IsScheduled                                                                                 IsScheduled
        FROM dbo.SchedulePickup                                               SPC
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] dop WITH (NOLOCK)
                ON dop.IdHeaderRecolection = SPC.SchedulePickupId
            INNER JOIN [DeliveryBackOffice].[dbo].[ServiceManagement]         AS smt WITH (NOLOCK)
                ON SPC.SchedulePickupId = smt.IdSchedulePickup
            INNER JOIN [DeliveryBackOffice].[dbo].[RouteAssigment]            AS rat WITH (NOLOCK)
                ON smt.IdPuRouteAssigment = rat.IdRouteAssigment
            LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]             AS snr WITH (NOLOCK)
                ON rat.IdCurrierMan = snr.ID
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus]           AS css WITH (NOLOCK)
                ON css.IdServiceStatus = smt.ServiceStatusId
        WHERE SchedulePickupId = @idSchedulePickup;

    END TRY
    BEGIN CATCH

        SELECT 0                 [blnResult]
             , ERROR_NUMBER()    AS [ErrorNumber]
             , ERROR_SEVERITY()  AS [ErrorSeverity]
             , ERROR_STATE()     AS [ErrorState]
             , ERROR_PROCEDURE() AS [ErrorProcedure]
             , ERROR_LINE()      AS [ErrorLine]
             , ERROR_MESSAGE()   AS [ErrorMessage];

        ROLLBACK TRANSACTION;
    END CATCH;
END;