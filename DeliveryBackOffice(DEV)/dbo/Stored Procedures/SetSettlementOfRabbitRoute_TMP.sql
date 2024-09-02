



-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-16>
-- Description:	< Finaliza un proceso de liquidación de una ruta de Rabbit >
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Update date: <2022-02-21>
-- Description:	< Adición de WITH(NOLOCK) para evitar posibles bloqueos >
-- =============================================
-- =============================================
-- Author:		<Edelman,Vásquez>
-- Update date: <2022-03-30>
-- Description:	< ejcución de SP [dbo].[sphdSetTransferClosing], para insert en dbo.DeliveryOrderPaymentTransaction y variable de código de usuario HD  >
-- =============================================
-- =============================================
-- Author:		<Edelman,Vásquez>
-- Update date: <2022-03-30>
-- Description:	< cambio de campo price por AmountToPay, esto identifica si es pago contado o collet el monto es 0  >
-- =============================================
CREATE PROCEDURE [dbo].[SetSettlementOfRabbitRoute_TMP]
    @IdSettlementPickupStation INT,                                     -- Id del Manifiesto
    @ServiceManagementToUpdate TblExtPlatNumericParameterList READONLY, -- Tabla de service management ya cargados en la liquidacion
    @GuidesToServiceManagement TblGuidePrice READONLY,                  -- Tabla de guías que les falta service management
    @GuidesToUpdate TblGuides READONLY,                                 -- Total de guías a actualizar
    @Token NVARCHAR(50),                                                -- Token de liquidador
    @IdStation INT,                                                     -- Estación que liquida
    @IdUser AS NVARCHAR(100)                                            --Código de usuario
AS
BEGIN

    -- Variables de la secuencia
    DECLARE @TopSequence INT = -1;
    SET @TopSequence = NEXT VALUE FOR [DeliveryBackOffice].[dbo].[SettlementPickupStationSequence];

    -- Variables para manejo de service management
    DECLARE @AllServiceManagementToUpdate AS TABLE
    (
        IdServiceManagement INT
    );
    DECLARE @COUNTSERVICEMANAGEMENT INT = 0;
    SET @COUNTSERVICEMANAGEMENT = ISNULL(
                                  (
                                      SELECT COUNT(*)FROM @GuidesToServiceManagement
                                  ),
                                  0
                                        );


    -- ID de Express center
    DECLARE @IdExpressCenter INT = NULL;
    SET @IdExpressCenter =
    (
        SELECT TOP 1
               CS.CodeOfReference
        FROM [DeliveryBackOffice].[dbo].[CatStation] CS WITH (NOLOCK)
        WHERE CS.IdStation = @IdStation
              AND CS.RowStatus = 1
    );

    -- Trasladado a express center
    DECLARE @NewStatus INT =
            (
                SELECT TOP 1
                       SO.StatusOrderId
                FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
                WHERE SO.OrderDescription = 'Traslado a express center' COLLATE Latin1_General_CI_AI
            );

    -- Variables del courier
    DECLARE @IDCOURIER INT = -1;
    DECLARE @IDROUTE INT = -1;
    DECLARE @NAMECOURIER NVARCHAR(50) = N'';
    DECLARE @DPICOURIER NVARCHAR(50) = N'';

    BEGIN TRANSACTION;
    BEGIN TRY

        SELECT @IDCOURIER = SPS.CouriermanId,
               @IDROUTE = SPS.RouteId,
               @NAMECOURIER = RTRIM(CONCAT(SR.First_Name, ' ', SR.Last_Name)),
               @DPICOURIER = SR.CUI
        FROM dbo.SettlementPickupStation SPS WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH (NOLOCK)
                ON SPS.CouriermanId = SR.ID
        WHERE IdSettlementPickupStation = @IdSettlementPickupStation;

        DECLARE @guides AS TABLE
        (
            guide_serie NVARCHAR(2),
            guide_number INT
        );
        INSERT INTO @guides
        SELECT GuideSerie,
               GuideNumber
        FROM @GuidesToServiceManagement;

		SELECT 'BDCAR', GuideSerie,
               GuideNumber
        FROM @GuidesToServiceManagement;

        WHILE EXISTS (SELECT 1 FROM @guides)
        BEGIN
		    PRINT 'ENTRA'
            DECLARE @GuideSerie NVARCHAR(2);
            DECLARE @GuideNumber INT;
            SELECT TOP 1
                   @GuideSerie = guide_serie,
                   @GuideNumber = guide_number
            FROM @guides;
            DELETE FROM @guides
            WHERE guide_serie = @GuideSerie
                  AND guide_number = @GuideNumber;

            DECLARE @tiempo DATE =
                    (
                        SELECT CAST(GETDATE() AS DATE)
                    );
            DECLARE @hasIdHeaderRecolection BIT;
            DECLARE @Sender_ID INT;
            DECLARE @SchedulePickupId INT;
            DECLARE @dopdId INT;
            DECLARE @CreateSchedulePickup BIT = 0;

            --Validar que tenga registro en la DeliveryOrderPaymentDetail sino lo crea
            SELECT @dopdId = dopd.DopId,
                   @hasIdHeaderRecolection = IIF(dopd.IdHeaderRecolection IS NULL, 0, 1)
            FROM DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
            WHERE dopd.GuideSerie = @GuideSerie
                  AND dopd.GuideNumber = @GuideNumber;

            IF @dopdId IS NULL
            BEGIN
                SET @hasIdHeaderRecolection = 0;

                --INSERT INTO [dbo].[DeliveryOrderPaymentDetail]
                --(
                --    [GuideNumber],
                --    [GuideSerie],
                --    [PayTypeId],
                --    [TypeofInOutMoneyId],
                --    [TimePlaId],
                --    [amount],
                --    [TokenCreated],
                --    [DateCreated],
                --    [TokenUpdated],
                --    [DateUpdated],
                --    [PaymentRecollections],
                --    [PaymentNow],
                --    [PaymentDelivery],
                --    [StartDate],
                --    [EndDate],
                --    [ShipmentCompleted],
                --    [RecollectionCompleted],
                --    [PaidGuide],
                --    [TransaccionFAC],
                --    [IdHeaderRecolection],
                --    [RecolectNow],
                --    [RecolectDelivery],
                --    [RecolectPayment]
                --)
                SELECT @GuideNumber,
                       @GuideSerie,
                       CASE
                           WHEN do.IsCollect = 1 THEN
                           (
                               SELECT PayTypeId FROM CatPaymentType WITH(NOLOCK) WHERE PayTypeAbrev = 'COLLT'
                           )
                           WHEN cu.ConditionOfPaymentID > 1 THEN
                           (
                               SELECT PayTypeId FROM CatPaymentType WITH(NOLOCK) WHERE PayTypeAbrev = 'CREDT'
                           )
                           ELSE
                       (
                           SELECT PayTypeId FROM CatPaymentType WITH(NOLOCK) WHERE PayTypeAbrev = 'CONT'
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
                               SELECT TimePlaId FROM CatPaymentTime WITH(NOLOCK) WHERE TimePlaAbrev = 'DEST'
                           )
                           WHEN cu.ConditionOfPaymentID > 1 THEN
                           (
                               SELECT TimePlaId FROM CatPaymentTime WITH(NOLOCK) WHERE TimePlaAbrev = 'POST'
                           )
                           ELSE
                       (
                           SELECT TimePlaId FROM CatPaymentTime WITH(NOLOCK) WHERE TimePlaAbrev = 'AHR'
                       )
                       END,
                       0,
                       @Token,
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
                       NULL,
                       NULL,
                       NULL,
                       NULL
                FROM DeliveryOrder do WITH (NOLOCK)
                    INNER JOIN Customer cu WITH (NOLOCK)
                        ON cu.IdCustomer =
                        (
                            SELECT TOP 1
                                   ISNULL(do.IdCustomer, vpc.CustomerID)
                            FROM dbo.VisitPointClient vpc WITH (NOLOCK)
                            WHERE vpc.CodeOfReference = do.Sender_ID
                        )
                WHERE do.Guide_Serie = @GuideSerie
                      AND do.Guide_Number = @GuideNumber;

            END;

            --Validar si pertenece a un punto de visita
            SELECT @Sender_ID = do.Sender_ID
            FROM DeliveryOrder do WITH (NOLOCK)
            WHERE do.Guide_Serie = @GuideSerie
                  AND do.Guide_Number = @GuideNumber;

            --Si no tiene asociado un servicio y si el Sender_ID no es 0
            IF @hasIdHeaderRecolection = 0
               AND @Sender_ID <> 0
            BEGIN
                SELECT @SchedulePickupId = sm.IdSchedulePickup
                FROM RouteAssigment ra WITH (NOLOCK)
                    INNER JOIN ServiceManagement sm WITH (NOLOCK)
                        ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
                    INNER JOIN SchedulePickup sp WITH (NOLOCK)
                        ON sp.SchedulePickupId = sm.IdSchedulePickup
                WHERE ra.IdRoute = @IDROUTE
                      AND ra.DateOfRoute = @tiempo
                      AND sp.SenderId = @Sender_ID;

                --Si se encuentra el visit point entre los servicios de recolección se asigna
                IF @SchedulePickupId IS NOT NULL
                BEGIN
				    PRINT '@SchedulePickupId'
                    --UPDATE DeliveryOrderPaymentDetail
                    --SET IdHeaderRecolection = @SchedulePickupId
                    --WHERE GuideSerie = @GuideSerie
                    --      AND GuideNumber = @GuideNumber;

                    --UPDATE sm
                    --SET ServiceStatusId = 3
                    --FROM ServiceManagement sm WITH (NOLOCK)
                    --WHERE sm.IdSchedulePickup = @SchedulePickupId;
                END;
                ELSE
                    SET @CreateSchedulePickup = 1;
            END;
            ELSE IF @hasIdHeaderRecolection = 0
                SET @CreateSchedulePickup = 1;

            --Si no tiene registro en SchedulePickup, crea uno y lo asocia al servicio
            IF @CreateSchedulePickup = 1
            BEGIN

                --INSERT INTO [dbo].[SchedulePickup]
                --(
                --    [AccountId],
                --    [StartDate],
                --    [EndDate],
                --    [EstimatedWeight],
                --    [IsLargePackage],
                --    [QuantityRegularPackages],
                --    [QuantityOverDimensionedPackage],
                --    [SpecialInstructions],
                --    [RowStatus],
                --    [TokenCreated],
                --    [DateCreated],
                --    [TokenUpdated],
                --    [DateUpdated],
                --    [SenderId],
                --    [SenderName],
                --    [SenderPhone],
                --    [IdHubLogistics],
                --    [AmountPickup],
                --    [IdSourcePlataform],
                --    [AddressPickup],
                --    [AssigmentStatus],
                --    [TransaccionFAC],
                --    [TownshipId]
                --)
                SELECT TOP 1
                       acc.AccIdAccount,
                       CONCAT(CAST(GETDATE() AS DATE), ' 08:00:00'),
                       CONCAT(CAST(GETDATE() AS DATE), ' 17:00:00'),
                       0,
                       0,
                       0,
                       0,
                       '',
                       1,
                       @Token,
                       GETDATE(),
                       NULL,
                       NULL,
                       do.Sender_ID,
                       CONCAT(
                                 ISNULL(do.Sender_FirstName, ''),
                                 IIF(do.Sender_FirstName IS NULL, '', IIF(do.Sender_LastName IS NULL, '', ' ')),
                                 ISNULL(do.Sender_LastName, '')
                             ),
                       do.Sender_Phone,
                       NULL, -- [IdHubLogistics]
                       NULL, -- [AmountPickup]
                       2,    -- [IdSourcePlataform]
                       do.Sender_Address,
                       1,
                       NULL, --TransaccionFAC
                       NULL  --TownshipId
                FROM DeliveryOrder do WITH (NOLOCK)
                    LEFT JOIN Account acc WITH (NOLOCK)
                        ON acc.IdCustomer =
                        (
                            SELECT TOP 1
                                   ISNULL(do.IdCustomer, vpc.CustomerID)
                            FROM dbo.VisitPointClient vpc WITH(NOLOCK)
                            WHERE vpc.CodeOfReference = do.Sender_ID
                        )
                WHERE do.Guide_Serie = @GuideSerie
                      AND do.Guide_Number = @GuideNumber;

                SET @SchedulePickupId = SCOPE_IDENTITY();

                --UPDATE DeliveryOrderPaymentDetail
                --SET IdHeaderRecolection = @SchedulePickupId
                --WHERE GuideSerie = @GuideSerie
                --      AND GuideNumber = @GuideNumber;

                --INSERT INTO [dbo].[ServiceManagement]
                --(
                --    [IdPuCourrier],
                --    [IdDlCourrier],
                --    [CiPuDate],
                --    [CoPuDate],
                --    [CiDlDate],
                --    [CoDlDate],
                --    [IdPuRouteAssigment],
                --    [IdDlRouteAssigment],
                --    [IdSchedulePickup],
                --    [IdProofOnDelivery],
                --    [RowStatus],
                --    [TokenCreated],
                --    [DateCreated],
                --    [TokenUpdated],
                --    [DateUpdated],
                --    [ServiceStatusId],
                --    [PuSignaturePath],
                --    [DiSignaturePath],
                --    [SubTypeServiceManagmentId],
                --    [IdHubDestination],
                --    [Order]
                --)
                SELECT ra.IdCurrierMan,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       ra.IdRouteAssigment,
                       NULL,
                       @SchedulePickupId,
                       NULL,
                       1,
                       @Token,
                       GETDATE(),
                       NULL,
                       NULL,
                       3,
                       NULL,
                       NULL,
                       1,
                       NULL,
                       1
                FROM RouteAssigment ra WITH (NOLOCK)
                WHERE ra.IdRoute = @IDROUTE
                      AND ra.DateOfRoute = @tiempo;

                DECLARE @idservicemanagment INT = SCOPE_IDENTITY();

                IF (NOT EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM @AllServiceManagementToUpdate
                    WHERE IdServiceManagement = @idservicemanagment
                )
                   )
                BEGIN
                    INSERT INTO @AllServiceManagementToUpdate
                    VALUES
                    (@idservicemanagment);
                END;

                DECLARE @BrainProcessedGuides AS TABLE
                (
                    GuideSerie NVARCHAR(2),
                    GuideNumber INT,
                    IsCollect BIT,
                    Price DECIMAL(18, 2),
                    COD DECIMAL(18, 2),
                    AmountPaid DECIMAL(18, 2),
                    CODPaid DECIMAL(18, 2),
                    CODIsPaid BIT,
                    PaymentTime INT,
                    TimeSequence INT,
                    FelNumber NVARCHAR(50),
                    IsPaid BIT,
                    IsCustomer INT,
                    ConditionPayment NVARCHAR(200),
                    HaveCredit BIT,
                    CollectCOD BIT,
                    ReturnRate DECIMAL(5, 2),
                    CurrencyPrice_CODCodeISO NVARCHAR(8),
	  	            CurrencyPrice_CODSymbol  NVARCHAR(8),
	                CurrencyPriceCodeISO     NVARCHAR(8),
	                CurrencyPriceSymbol      NVARCHAR(8),
                    AmountToPay DECIMAL(18, 2),
                    CODAmount DECIMAL(18, 2),
                    ReturnRates DECIMAL(5, 2)
                );
                DECLARE @GUIDECONCAT NVARCHAR(MAX) = CONCAT(@GuideSerie, CONVERT(NVARCHAR(MAX), @GuideNumber));
                --INSERT INTO @BrainProcessedGuides
                EXEC [dbo].[spws_get_guide_pending_payment] @GUIDECONCAT, -- Guías recibidas
                                                            2,            -- Tiempo de pago 2 - En recolección
                                                            0,            -- No es ret5orno
                                                            '',           -- Codeapp
                                                            1,            -- Identificador de modulo donde proviene
                                                            @Token;       -- Token de courier

                --INSERT INTO [dbo].[SettlementPickupStationDetail]
                --(
                --    [SettlementPickupStationId],
                --    [ServiceManagementId],
                --    [Price],
                --    [SettlementStationId],
                --    [SettlementDate],
                --    [TokenSettlement],
                --    [RowStatus],
                --    [TokenCreated],
                --    [DateCreated],
                --    [TokenUpdated],
                --    [DateUpdated]
                --)
                SELECT TOP 1
                       @IdSettlementPickupStation,
                       @idservicemanagment,
                       0, --PENDIENTE
                       @IdExpressCenter,
                       GETDATE(),
                       @Token,
                       1,
                       @Token,
                       GETDATE(),
                       @Token,
                       GETDATE()
                FROM @BrainProcessedGuides;

            END;

        END;

        INSERT INTO @AllServiceManagementToUpdate
        (
            IdServiceManagement
        )
        SELECT NumericParameter
        FROM @ServiceManagementToUpdate
        WHERE NumericParameter NOT IN
              (
                  SELECT IdServiceManagement FROM @AllServiceManagementToUpdate
              );

        -- INSERT INTO TRANSFERLOG SO WE CAN MONITOR ALL THE GUIDES THAT WERE TRANSFER TO A EXPRESS CENTER
        --INSERT INTO DeliveryBackOffice.dbo.TransferLog
        --(
        --    [IdCourier],
        --    [CourierName],
        --    [DPI],
        --    [IdIncidence],
        --    [IncidenceName],
        --    [Comentary],
        --    [GuideSerie],
        --    [GuideNumber],
        --    [TokenCreated],
        --    [DateCreated]
        --)
        SELECT @IDCOURIER,
               @NAMECOURIER,
               @DPICOURIER,
               NULL,
               NULL,
               '',
               lge.Guide_Serie,
               lge.Guide_Number,
               @Token,
               GETDATE()
        FROM @GuidesToUpdate lge;

        -- Actualizar service management con el estado de recolectado
        --UPDATE SM
        --SET SM.ServiceStatusId = 3
        --FROM [DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH (NOLOCK)
        --   inner JOIN @AllServiceManagementToUpdate ASMTU
        --        ON SM.IdServiceManagement = ASMTU.IdServiceManagement;

        -- Actualizar estado de guía a traslado a express center
        --UPDATE DO
        --SET StatusOrderId = @NewStatus
        --FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
        --    INNER JOIN @GuidesToUpdate GTU
        --        ON DO.Guide_Number = GTU.Guide_Number
        --           AND DO.Guide_Serie = GTU.Guide_Serie;

        -- Insertar en historico de estados el nuevo estado de las guías
        --INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
        --(
        --    Guide_Serie,
        --    Guide_Number,
        --    StatusOrderId,
        --    RowStatus,
        --    UserCreated,
        --    DateCreated,
        --    DateCreatedInSystem
        --)
        SELECT GTU.Guide_Serie,
               GTU.Guide_Number,
               @NewStatus,
               1,
               @Token,
               GETDATE(),
               GETDATE()
        FROM @GuidesToUpdate GTU
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] WITH (NOLOCK)
            WHERE StatusOrderId = @NewStatus
                  AND Guide_Serie = GTU.Guide_Serie
                  AND Guide_Number = GTU.Guide_Number
                  AND CAST(DateCreated AS DATE) = CAST(GETDATE() AS DATE)
        );

        -- Indicar cambio en registro de SettlementPickupStation
        --UPDATE SPS
        --SET SPS.TokenUpdated = @Token,
        --    SPS.DateUpdated = GETDATE()
        --FROM [DeliveryBackOffice].[dbo].[SettlementPickupStation] SPS WITH (NOLOCK)
        --WHERE SPS.IdSettlementPickupStation = @IdSettlementPickupStation
        --      AND SPS.RowStatus = 1;

        -- Actualizar montos de registros de servicios liquidados
        --UPDATE SPSD
        --SET SPSD.SettlementStationId = @IdExpressCenter,
        --    SPSD.SettlementSequence = @TopSequence,
        --    SPSD.Price = SPSD.Price + GTSM.GuidePrice,
        --    SPSD.TokenSettlement = @Token,
        --    SPSD.SettlementDate = GETDATE(),
        --    SPSD.TokenUpdated = @Token,
        --    SPSD.DateUpdated = GETDATE()
        --FROM [DeliveryBackOffice].[dbo].[SettlementPickupStation] SPS WITH (NOLOCK)
        --    INNER JOIN [DeliveryBackOffice].[dbo].[SettlementPickupStationDetail] SPSD WITH (NOLOCK)
        --        ON SPS.IdSettlementPickupStation = SPSD.SettlementPickupStationId
        --           AND SPSD.RowStatus = 1
        --    INNER JOIN [DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH (NOLOCK)
        --        ON SPSD.ServiceManagementId = SM.IdServiceManagement
        --    INNER JOIN [DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH (NOLOCK)
        --        ON SM.IdSchedulePickup = SP.SchedulePickupId
        --    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
        --        ON SP.SchedulePickupId = DOPD.IdHeaderRecolection
        --    INNER JOIN @GuidesToServiceManagement GTSM
        --        ON GTSM.GuideSerie = DOPD.GuideSerie
        --           AND GTSM.GuideNumber = DOPD.GuideNumber
        --WHERE SPS.IdSettlementPickupStation = @IdSettlementPickupStation
        --      AND SPS.RowStatus = 1;

        -- Actualizar registros de servicios liquidados 
        --UPDATE SPSD
        --SET SPSD.SettlementStationId = @IdExpressCenter,
        --    SPSD.SettlementSequence = @TopSequence,
        --    SPSD.TokenSettlement = @Token,
        --    SPSD.SettlementDate = GETDATE(),
        --    SPSD.TokenUpdated = @Token,
        --    SPSD.DateUpdated = GETDATE()
        --FROM [DeliveryBackOffice].[dbo].[SettlementPickupStation] SPS WITH (NOLOCK)
        --    INNER JOIN [DeliveryBackOffice].[dbo].[SettlementPickupStationDetail] SPSD WITH (NOLOCK)
        --        ON SPS.IdSettlementPickupStation = SPSD.SettlementPickupStationId
        --           AND SPSD.RowStatus = 1
        --    INNER JOIN @AllServiceManagementToUpdate SMTU
        --        ON SPSD.ServiceManagementId = SMTU.IdServiceManagement
        --WHERE SPS.IdSettlementPickupStation = @IdSettlementPickupStation
        --      AND SPS.RowStatus = 1;

        -- Actualizar registros de servicios liquidados a partir ç

        -------------------------SP Insert DeliveryOrderPaymentTransaction-----------------------------

        DECLARE @GUIDECONCAT2 NVARCHAR(MAX);
        SET @GUIDECONCAT2 =
        (
            SELECT STUFF(
                            (
                                SELECT ',' + CONCAT(Guide_Serie, CONVERT(NVARCHAR(MAX), Guide_Number))
                                FROM @GuidesToUpdate
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

		PRINT 'ejecuta pending payment'
		DELETE FROM @BrainProcessedGuides;
        INSERT INTO @BrainProcessedGuides
        EXEC [dbo].[spws_get_guide_pending_payment] @GUIDECONCAT2, -- Guías recibidas
                                                    2,             -- Tiempo de pago 2 - En recolección
                                                    0,             -- No es ret5orno
                                                    '',            -- Codeapp
                                                    1,             -- Identificador de modulo donde proviene
                                                    @Token;        -- Token de courier

        DECLARE @TblDeliveryOrdersList AS dbo.TblDeliveryOrdersTransferList;
        --INSERT INTO @TblDeliveryOrdersList
        --(
        --    [Guide_Serie],
        --    [Guide_Number],
        --    [TypeofInOutMoneyId],
        --    [amount],
        --    [TokenCreated],
        --    [IdTypeService],
        --    [AccountId]
        --)
        SELECT BP.GuideSerie,
               BP.GuideNumber,
               1,
               Case  When BP.PaymentTime = 2 THEN BP.Price
			       ELSE BP.AmountToPay END ,
               @Token,
               ISNULL(
               (
                   SELECT TOP 1
                          IdTypeService
                   FROM CatTypeServiceClosure WITH(NOLOCK)
                   WHERE NameTypeService = 'Traslado'
               ),
               0
                     ),
               @IdUser
        FROM @BrainProcessedGuides BP
            LEFT JOIN dbo.DeliveryOrderPaymentTransaction DOPT with(nolock)
                ON BP.GuideNumber = DOPT.GuideNumber
                   AND BP.GuideSerie = DOPT.GuideSerie
        WHERE DOPT.GuideNumber IS NULL;

		PRINT 'Ejecutas transfer closing'

        EXEC [dbo].[sphdSetTransferClosing] @TblDeliveryOrdersList,
                                            @IdUser = @IdUser,
                                            @FEL = 'No Asignado';
        --------------------------------------------------------------
		PRINT 'termina transfer closing'
		-------------------------------
        --IF (@@TRANCOUNT > 0) 
		COMMIT TRANSACTION;

        SELECT 1 [blnResult],
               @TopSequence [SettlementSequence],
               'Se registro la liquidación' AS [SuccessMessage];

        SELECT IdServiceManagement
        FROM @AllServiceManagementToUpdate;


    END TRY
    BEGIN CATCH
	  ROLLBACK TRANSACTION;
        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

      

		--INSERT INTO dbo.RoutePreparationLogError
		--	(
		--		ErrorDescription,
		--		ErrorNumber,
		--		ErrorProcedure,
		--		ErrorLine,
		--		GuideSerie,
		--		GuideNumber,
		--		TokenCreated,
		--		DateCreated
		--	)
		--	VALUES
		--	 (CAST(ERROR_MESSAGE() AS VARCHAR(300))
		--			   ,ERROR_NUMBER()
		--			   ,CAST(ERROR_PROCEDURE() AS VARCHAR(100))
		--			   ,ERROR_LINE()
		--			   ,0
		--			   ,0
		--			   ,'Error en rabbit'
		--			   ,GETDATE())

    END CATCH;

END;