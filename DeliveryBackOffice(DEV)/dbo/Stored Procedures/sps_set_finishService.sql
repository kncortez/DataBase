-- =============================================
-- Author: <Jerson Ochoa>
-- Updated date: <2023-01-26>
-- Description: <Agregar acumulación de puntos forza>
-- =============================================

CREATE PROCEDURE [dbo].[sps_set_finishService]
    @InGuidesP VARCHAR(MAX),
    @TblListGuides AS TblListGuides READONLY,
    @TblDetail AS TblPaymentList READONLY,
    @IdModuleP INT,
    @TokenP VARCHAR(100),
    @ServiceType VARCHAR(100),
    @CUI VARCHAR(100),
    @Name VARCHAR(100),
    @TblPayment AS TblPayment READONLY,
    @TblExclusions AS TblExclusions READONLY
AS
BEGIN

    DECLARE @DateCreated DATETIME = GETDATE();
    DECLARE @Output VARCHAR(MAX);

    BEGIN
        -- Insert statements for procedure here
        --IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
        IF OBJECT_ID('tempdb.dbo.#listGuidesNotExist', 'U') IS NOT NULL
            DROP TABLE #listGuidesNotExist;
        IF OBJECT_ID('tempdb.dbo.#listGuidesEnabled', 'U') IS NOT NULL
            DROP TABLE #listGuidesEnabled;
        IF OBJECT_ID('tempdb.dbo.#listGuidesEnabled', 'U') IS NOT NULL
            DROP TABLE #listGuidesEnabled;
        IF OBJECT_ID('tempdb.dbo.#listGuidesDisabled', 'U') IS NOT NULL
            DROP TABLE #listGuidesDisabled;

        SELECT *
        INTO #TblListGuidesTwo
        FROM @TblListGuides;

        DECLARE @IdTypeOfMoney INT;
        DECLARE @Amount DECIMAL(18, 2);
        DECLARE @Voucher VARCHAR(100);
        DECLARE @Responsible VARCHAR(100);

        SELECT @IdTypeOfMoney = td.IdTypeOfMoney,
               @Amount = td.Amount,
               @Voucher = td.Voucher,
               @Responsible = td.Responsible
        FROM @TblDetail td;

        SELECT *
        INTO #TblExclusions2
        FROM @TblExclusions;



        CREATE NONCLUSTERED INDEX IX_TLGT_SERIE
        ON #TblListGuidesTwo (
                                 Guide_Serie,
                                 Guide_Number
                             );
        --CREATE NONCLUSTERED INDEX IX_TLGT_NUMBER
        --ON #TblListGuidesTwo (Guide_Number);
        CREATE NONCLUSTERED INDEX IX_TLGT_EXCLUDE
        ON #TblListGuidesTwo (ExcludeCOD);

        ---- Obtener guias que no existen ------------------------------------
        SELECT lg.Guide_Serie,
               lg.Guide_Number,
               -1 StatusOrderId,
               'La guía no existe en el sistema.' 'Description'
        INTO #listGuidesNotExist
        FROM #TblListGuidesTwo lg
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
            WHERE lg.Guide_Serie = do.Guide_Serie
                  AND lg.Guide_Number = do.Guide_Number
        );

        CREATE NONCLUSTERED INDEX IX_LGNE_SERIE
        ON #listGuidesNotExist (
                                   Guide_Serie,
                                   Guide_Number
                               );
        --CREATE NONCLUSTERED INDEX IX_LGNE_NUMBER
        --ON #listGuidesNotExist (Guide_Number);

        --SELECT COUNT(1) FROM #listGuidesNotExist;
        IF ((SELECT COUNT(1)FROM #listGuidesNotExist) <= 0)
            BEGIN TRANSACTION;
        BEGIN TRY

            IF (UPPER(@ServiceType) = 'PICKUP')
            BEGIN
                UPDATE #TblListGuidesTwo
                SET ExcludeCOD = 0;
            END;

            -- OBTENER GUIAS HABILITADAS --------------------------------------------------------------------

            SELECT lg.Guide_Serie,
                   lg.Guide_Number,
                   so.StatusOrderId,
                   so.OrderDescription StatusOrderDescription,
                   lg.ExcludeCOD
            INTO #listGuidesEnabled
            FROM #TblListGuidesTwo lg
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                    ON lg.Guide_Serie = do.Guide_Serie
                       AND lg.Guide_Number = do.Guide_Number
                INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                    ON do.StatusOrderId = so.StatusOrderId
            WHERE (
                      UPPER(@ServiceType) = 'PICKUP'
                      AND so.StatusOrderId IN ( 15, 4, 1, 16 )
                  )
                  OR
                  (
                      UPPER(@ServiceType) = 'DELIVERY'
                      AND so.StatusOrderId IN ( 2, 3, 10, 11, 20, 21 )
                  )
                  OR
                  (
                      UPPER(@ServiceType) = 'RETURN'
                      AND so.StatusOrderId IN ( 2, 3, 8, 10, 11, 12, 17, 18, 20, 21 )
                  );


            CREATE NONCLUSTERED INDEX IX_TLGT_SERIE_enable
            ON #listGuidesEnabled (
                                      Guide_Serie,
                                      Guide_Number
                                  );

            CREATE NONCLUSTERED INDEX IX_TLGT_SERIE_enable_excludeCOD
            ON #listGuidesEnabled (ExcludeCOD);

            -- OBTENER GUIAS DESHABILITADAS ---------------------------------------------------------------------
            SELECT lg.Guide_Serie,
                   lg.Guide_Number,
                   so.StatusOrderId,
                   so.OrderDescription StatusOrderDescription
            INTO #listGuidesDisabled
            FROM #TblListGuidesTwo lg
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                    ON lg.Guide_Serie = do.Guide_Serie
                       AND lg.Guide_Number = do.Guide_Number
                INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                    ON do.StatusOrderId = so.StatusOrderId
            WHERE (
                      UPPER(@ServiceType) = 'PICKUP'
                      AND so.StatusOrderId NOT IN ( 15, 4, 1, 16 )
                  )
                  OR
                  (
                      UPPER(@ServiceType) = 'DELIVERY'
                      AND so.StatusOrderId NOT IN ( 2, 3, 10, 11, 20, 21 )
                  )
                  OR
                  (
                      UPPER(@ServiceType) = 'RETURN'
                      AND so.StatusOrderId NOT IN ( 2, 3, 8, 10, 11, 12, 17, 18, 20, 21 )
                  );

            --Select *From #listGuidesDisabled;
            DECLARE @GuidesEnable INT;
            DECLARE @GuidesDisable INT;
            SET @GuidesEnable =
            (
                SELECT COUNT(1)FROM #listGuidesEnabled
            );
            SET @GuidesDisable =
            (
                SELECT COUNT(1)FROM #listGuidesDisabled
            );

            --------VALIDAR PAGO---------------------------------------------------------
            DECLARE @InTimeP INT;
            DECLARE @IsReturnP BIT;
            IF UPPER(@ServiceType) = 'PICKUP'
            BEGIN
                SET @InTimeP = 2;
                SET @IsReturnP = 'FALSE';
            END;
            ELSE IF UPPER(@ServiceType) = 'DELIVERY'
            BEGIN
                SET @InTimeP = 3;
                SET @IsReturnP = 'FALSE';
            END;
            ELSE IF @ServiceType = 'RETURN'
            BEGIN
                SET @InTimeP = 3;
                SET @IsReturnP = 'TRUE';
            END;

            CREATE TABLE #PendingPaymentTemp
            (
                GuideSerie NVARCHAR(25) NULL,
                GuideNumber INT,
                IsCollect BIT,
                Price DECIMAL(14, 2) NULL,
                COD DECIMAL(14, 2) NULL,
                AmountPaid DECIMAL(14, 2) NULL,
                CODPaid DECIMAL(14, 2) NULL,
                CODIsPaid BIT,
                PaymentTime INT NULL,
                TimeSequence INT NULL,
                FelNumber NVARCHAR(50) NULL,
                IsPaid BIT,
                IsCustomer INT NULL,
                ConditionPayment VARCHAR(200),
                HaveCredit BIT,
                CollectCOD BIT,
                ReturnRate DECIMAL(14, 2) NULL,
                AmountToPay DECIMAL(14, 2) NULL,
                CODAmount DECIMAL(14, 2) NULL,
                ReturnRates DECIMAL(14, 2) NULL
            );

            CREATE NONCLUSTERED INDEX IX_PPT_GS
            ON #PendingPaymentTemp (
                                       GuideSerie,
                                       GuideNumber
                                   );

            INSERT INTO #PendingPaymentTemp
            (
                GuideSerie,
                GuideNumber,
                IsCollect,
                Price,
                COD,
                AmountPaid,
                CODPaid,
                CODIsPaid,
                PaymentTime,
                TimeSequence,
                FelNumber,
                IsPaid,
                IsCustomer,
                ConditionPayment,
                HaveCredit,
                CollectCOD,
                ReturnRate,
                AmountToPay,
                CODAmount,
                ReturnRates
            )
            EXEC DeliveryBackOffice.dbo.spws_get_guide_pending_payment @InGuides = @InGuidesP,
                                                                       @InTime = @InTimeP,
                                                                       @IsReturn = @IsReturnP,
                                                                       @CodeApp = '',
                                                                       @IdModule = @IdModuleP,
                                                                       @Token = @TokenP;

            --SELECT ROW_NUMBER() OVER (ORDER BY ppt.GuideNumber ASC) AS Id,
            --       ppt.GuideSerie,
            --       ppt.GuideNumber,
            --       ppt.IsCollect,
            --       ppt.Price,
            --       ppt.COD,
            --       ppt.AmountPaid,
            --       ppt.CODPaid,
            --       ppt.CODIsPaid,
            --       ppt.PaymentTime,
            --       ppt.TimeSequence,
            --       ppt.FelNumber,
            --       ppt.IsPaid,
            --       ppt.IsCustomer,
            --       ppt.ConditionPayment,
            --       ppt.HaveCredit,
            --       ppt.CollectCOD,
            --       ppt.ReturnRate,
            --       ppt.AmountToPay,
            --       ppt.CODAmount,
            --       ppt.ReturnRates,
            --       CONCAT(
            --                 do.Sender_Department,
            --                 ', ',
            --                 do.Sender_Town,
            --                 ', ',
            --                 'Zona ',
            --                 do.Sender_Zone,
            --                 ', ',
            --                 do.Sender_Address
            --             ) SenderAddress,
            --       CONCAT(
            --                 do.Receiver_Department,
            --                 ', ',
            --                 do.Receiver_Town,
            --                 ', ',
            --                 'Zona ',
            --                 do.Receiver_Zone,
            --                 ', ',
            --                 do.Receiver_Address
            --             ) ReceiverAddress,
            --       IIF(LTRIM(RTRIM(ISNULL(do.Sender_FirstName, ''))) = '',
            --           LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))),
            --           IIF(LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))) = '',
            --               LTRIM(RTRIM(do.Sender_FirstName)),
            --               CONCAT(LTRIM(RTRIM(do.Sender_FirstName)), ' ', LTRIM(RTRIM(do.Sender_LastName))))) SenderName,
            --       CONCAT(
            --                 IIF(LTRIM(RTRIM(ISNULL(do.Receiver_FirstName, ''))) = '',
            --                     LTRIM(RTRIM(ISNULL(do.Receiver_LastName, ''))),
            --                     IIF(LTRIM(RTRIM(ISNULL(do.Receiver_LastName, ''))) = '',
            --                         LTRIM(RTRIM(do.Receiver_FirstName)),
            --                         CONCAT(
            --                                   LTRIM(RTRIM(do.Receiver_FirstName)),
            --                                   ' ',
            --                                   LTRIM(RTRIM(do.Receiver_LastName))
            --                               ))),
            --                 IIF(LTRIM(RTRIM(ISNULL(do.Receiver_Alternant_FullName, ''))) = '',
            --                     '',
            --                     CONCAT(' / ', LTRIM(RTRIM(do.Sender_FirstName))))
            --             ) ReceiverName,
            --       IIF(UPPER(@ServiceType) = 'DELIVERY',
            --           LTRIM(RTRIM(ISNULL(do.IndicationsToSendDestination, ''))),
            --           LTRIM(RTRIM(ISNULL(do.IndicationsToSendOrigin, '')))) Indications,
            --       (ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0)) Pieces,
            --       IIF(do.TypeService = 'EXP', 'NDD', ISNULL(do.TypeService, 'NDD')) ServiceType
            --INTO #PendingPaymentTempId
            --FROM #PendingPaymentTemp ppt
            --    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
            --        ON ppt.GuideSerie = do.Guide_Serie
            --           AND ppt.GuideNumber = do.Guide_Number;


            DECLARE @TotalAmountBD DECIMAL(18, 2);
            DECLARE @TotalAmountPortal DECIMAL(18, 2);
            SET @TotalAmountBD =
            (
                SELECT SUM(AmountToPay)FROM #PendingPaymentTemp
            );
            SET @TotalAmountPortal =
            (
                SELECT SUM(ServiceAmount)FROM @TblPayment
            );

            IF (@TotalAmountBD IS NULL)
            BEGIN
                SET @TotalAmountBD = 0;
            END;

            DECLARE @TotalCODAmountBD DECIMAL(18, 2);
            DECLARE @TotalCODAmountPortal DECIMAL(18, 2);
            DECLARE @Exclude INT;
            SET @TotalCODAmountBD =
            (
                SELECT SUM(CODAmount)FROM #PendingPaymentTemp
            );
            SET @TotalCODAmountPortal =
            (
                SELECT SUM(CODAmount)FROM @TblPayment
            );

            SET @Exclude =
            (
                SELECT COUNT(ExcludeCOD)FROM #TblListGuidesTwo WHERE ExcludeCOD = 1
            );

            --IF((SELECT COUNT(1) FROM #listGuidesEnabled2) > 0) --VER GUIAS VALIDAS
            IF (
                   (
                   (
                       SELECT COUNT(1)FROM #listGuidesEnabled
                   ) > 0
                   )
                   AND (
                       (
                           SELECT COUNT(1)FROM #listGuidesDisabled
                       ) <= 0
                       )
               )
            BEGIN
                --select @TotalAmountBD
                --select @TotalAmountPortal

                --select @TotalCODAmountBD
                --select @TotalCODAmountPortal

                IF (@TotalAmountBD = @TotalAmountPortal) --VALIDAR SUMAS ServiceAmount
                BEGIN

                    IF (
                           (
                               (@TotalCODAmountBD = @TotalCODAmountPortal)
                               AND (@Exclude = 0)
                           )
                           OR (@Exclude > 0)
                       ) --VALIDAR SUMAS CODAmount
                    BEGIN

                        ---------TABLA PARA GUIAS INCLUDE--------------------
                        CREATE TABLE #TblInclude
                        (
                            Guide_Serie VARCHAR(2) NULL,
                            Guide_Number INT NULL,
                            ExcludeCOD BIT NULL
                        );

                        CREATE NONCLUSTERED INDEX TMP_IDX_TblInclude_Guide
                        ON #TblInclude (
                                           Guide_Serie,
                                           Guide_Number
                                       );

                        INSERT INTO #TblInclude
                        (
                            Guide_Serie,
                            Guide_Number,
                            ExcludeCOD
                        )
                        SELECT tlg.Guide_Serie,
                               tlg.Guide_Number,
                               tlg.ExcludeCOD
                        FROM #TblListGuidesTwo tlg
                        WHERE tlg.ExcludeCOD = 0;

                        DECLARE @TotalGuidesInclude DECIMAL(18, 2);
                        SET @TotalGuidesInclude =
                        (
                            SELECT SUM(pd.CODAmount)
                            FROM #PendingPaymentTemp pd
                                INNER JOIN #TblInclude ti
                                    ON pd.GuideNumber = ti.Guide_Number
                                       AND pd.GuideSerie = ti.Guide_Serie
                        );


                        --select * from #PendingPaymentTemp;
                        IF (@TotalGuidesInclude IS NULL)
                        BEGIN
                            SET @TotalGuidesInclude = 0;
                        END;
                        --select @TotalGuidesInclude as cod;
                        --select @TotalCODAmountPortal;
                        ---------------------------------------------------------
                        IF (@TotalGuidesInclude = @TotalCODAmountPortal)
                        BEGIN
                            DECLARE @VoucherExclude VARCHAR(100);
                            DECLARE @ResponsibleExclude VARCHAR(100);

                            SET @VoucherExclude =
                            (
                                SELECT TOP 1 Voucher FROM @TblExclusions
                            );
                            SET @ResponsibleExclude =
                            (
                                SELECT TOP 1 Responsible FROM @TblExclusions
                            );

                            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                            (
                                Guide_Serie,
                                Guide_Number,
                                StatusOrderId,
                                UserCreated,
                                DateCreated,
                                DateCreatedInSystem,
                                Observations
                            )
                            SELECT lge.Guide_Serie,
                                   lge.Guide_Number,
                                   CASE UPPER(@ServiceType)
                                       WHEN 'PICKUP' THEN
                                           21
                                       WHEN 'DELIVERY' THEN
                                           22
                                       WHEN 'RETURN' THEN
                                           23
                                   END StatusOrderId,
                                   @TokenP UserCreated,
                                   @DateCreated DateCreated,
                                   @DateCreated DateCreatedInSystem,
                                   CASE UPPER(@ServiceType)
                                       WHEN 'PICKUP' THEN
                                           'Recibido de ' + @Name
                                       WHEN 'DELIVERY' THEN
                                           'Entregado a ' + @Name
                                       WHEN 'RETURN' THEN
                                           'Devueldo a ' + @Name
                                   END Observations
                            --@CUI+'-'+@Name
                            FROM #listGuidesEnabled lge;


                            UPDATE dot
                            SET dot.Observations = 'Entregado a ' + @Name + ', Entrega sin cobro COD '
                                                   + @VoucherExclude + ' ' + @ResponsibleExclude
                            FROM DeliveryOrderDetail dot WITH (NOLOCK)
                                INNER JOIN #listGuidesEnabled lge
                                    ON lge.Guide_Number = dot.Guide_Number
                                       AND lge.Guide_Serie = dot.Guide_Serie
                            WHERE lge.ExcludeCOD = 1
                                  AND dot.StatusOrderId = 22;






                            ----INSERTAR REGISTRO EN ProcessGuideCOD CUANDO SEA ENTREGA Y SEA COD---------
                            IF (UPPER(@ServiceType) = 'DELIVERY')
                            BEGIN

                                UPDATE do
                                SET do.Collect_OnDelivery = 0,
                                    do.LastCollectOnDelivery = ppt.CODAmount
                                FROM DeliveryOrder do WITH (NOLOCK)
                                    INNER JOIN #listGuidesEnabled lge
                                        ON lge.Guide_Number = do.Guide_Number
                                           AND lge.Guide_Serie = do.Guide_Serie
                                    INNER JOIN #PendingPaymentTemp ppt
                                        ON ppt.GuideNumber = do.Guide_Number
                                           AND ppt.GuideSerie = do.Guide_Serie
                                WHERE lge.ExcludeCOD = 1;


                                INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
                                (
                                    GuideSerie,
                                    GuideNumber,
                                    DataOriginId,
                                    Token,
                                    CustomerId
                                )
                                SELECT lge.Guide_Serie,
                                       lge.Guide_Number,
                                       25,
                                       @TokenP UserCreated,
                                       cus.IdCustomer
                                FROM #listGuidesEnabled lge
                                    INNER JOIN DeliveryOrder dlo WITH (NOLOCK)
                                        ON lge.Guide_Number = dlo.Guide_Number
                                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                                        ON vp.CodeOfReference = dlo.Sender_ID
                                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                                        ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
                                    LEFT JOIN ProcessedGuideCOD pcd WITH (NOLOCK)
                                        ON pcd.GuideSerie = dlo.Guide_Serie
                                           AND pcd.GuideNumber = dlo.Guide_Number
                                WHERE dlo.Collect_OnDelivery > 0
                                      AND pcd.IdProcessedGuideCOD IS NULL
                                UNION
                                SELECT lge.Guide_Serie,
                                       lge.Guide_Number,
                                       25,
                                       @TokenP UserCreated,
                                       cus.IdCustomer
                                FROM #listGuidesEnabled lge
                                    INNER JOIN DeliveryOrder dlo WITH (NOLOCK)
                                        ON lge.Guide_Number = dlo.Guide_Number
                                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                                        ON vp.CodeOfReference = dlo.Sender_ID
                                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                                        ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
                                    LEFT JOIN ProcessedGuideCOD pcd WITH (NOLOCK)
                                        ON pcd.GuideSerie = dlo.Guide_Serie
                                           AND pcd.GuideNumber = dlo.Guide_Number
                                WHERE (
                                          dlo.Collect_OnDelivery = 0
                                          AND dlo.IsCollect = 'true'
                                      )
                                      AND pcd.IdProcessedGuideCOD IS NULL
                                UNION
                                SELECT lge.Guide_Serie,
                                       lge.Guide_Number,
                                       25,
                                       @TokenP UserCreated,
                                       cus.IdCustomer
                                FROM #listGuidesEnabled lge
                                    INNER JOIN DeliveryOrder dlo WITH (NOLOCK)
                                        ON lge.Guide_Number = dlo.Guide_Number
                                    INNER JOIN dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)
                                        ON dlo.Guide_Serie = DOP.GuideSerie
                                           AND dlo.Guide_Number = DOP.GuideNumber
                                    LEFT JOIN dbo.VisitPointClient vp WITH (NOLOCK)
                                        ON vp.CodeOfReference = dlo.Sender_ID
                                    LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                                        ON cus.IdCustomer = ISNULL(dlo.IdCustomer, vp.CustomerID)
                                    LEFT JOIN ProcessedGuideCOD pcd WITH (NOLOCK)
                                        ON pcd.GuideSerie = dlo.Guide_Serie
                                           AND pcd.GuideNumber = dlo.Guide_Number
                                WHERE (
                                          dlo.IsCollect = 'false'
                                          AND DOP.TimePlaId = 2
                                      )
                                      AND pcd.IdProcessedGuideCOD IS NULL;
                            END;

                            UPDATE do
                            SET do.StatusOrderId = (CASE UPPER(@ServiceType)
                                                        WHEN 'PICKUP' THEN
                                                            21
                                                        WHEN 'DELIVERY' THEN
                                                            22
                                                        WHEN 'RETURN' THEN
                                                            23
                                                    END
                                                   )
                            FROM DeliveryOrder do WITH (NOLOCK)
                                INNER JOIN #listGuidesEnabled lge
                                    ON lge.Guide_Number = do.Guide_Number
                                       AND lge.Guide_Serie = do.Guide_Serie;

                            UPDATE dop
                            SET StatusOrderId = (CASE UPPER(@ServiceType)
                                                     WHEN 'PICKUP' THEN
                                                         21
                                                     WHEN 'DELIVERY' THEN
                                                         22
                                                     WHEN 'RETURN' THEN
                                                         23
                                                 END
                                                )
                            FROM DeliveryOrderPiece dop WITH (NOLOCK)
                                INNER JOIN #listGuidesEnabled lge WITH (NOLOCK)
                                    ON lge.Guide_Number = dop.GuideNumber
                                       AND lge.Guide_Serie = dop.GuideSerie;

                            DECLARE @CartGuides AS TABLE
                            (
                                GuideSerie NVARCHAR(2),
                                GuideNumber INT
                            );
                            UPDATE ASCD
                            SET RowStatus = 0,
                                TokenUpdated = @TokenP,
                                DateUpdated = GETDATE()
                            OUTPUT inserted.GuideSerie,
                                   inserted.GuideNumber
                            INTO @CartGuides
                            (
                                GuideSerie,
                                GuideNumber
                            )
                            FROM [DeliveryBackOffice].[dbo].[AccountServiceCartDetail] ASCD WITH (NOLOCK)
                                INNER JOIN #listGuidesEnabled LGE WITH (NOLOCK)
                                    ON ASCD.GuideSerie = LGE.Guide_Serie
                                       AND ASCD.GuideNumber = LGE.Guide_Number
                                       AND ASCD.RowStatus = 1;

                            UPDATE DOPD
                            SET DOPD.ShipmentCompleted = 1
                            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD
                                INNER JOIN @CartGuides CG
                                    ON DOPD.GuideSerie = CG.GuideSerie
                                       AND DOPD.GuideNumber = CG.GuideNumber;

                            -----------------WEBHOOK.INI-----------------------		
                            DECLARE @WebhookCustomerTable AS TABLE
                            (
                                CustomerId INT,
                                CustomerEndpointId BIGINT,
                                WebhookType INT,
                                GuideSerie NVARCHAR(2),
                                GuideNumber INT,
                                GuideStatusId TINYINT
                            );
                            BEGIN TRY
                                DECLARE @GuideStatusChangeWebhook INT =
                                        (
                                            SELECT TOP 1
                                                   WT.IdWebhookType
                                            FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH (NOLOCK)
                                            WHERE WT.WebhookName = 'GuideStatusChange' COLLATE Latin1_General_CI_AI
                                                  AND WT.RowStatus = 1
                                        );

                                -- Clientes de las guías por procesar
                                INSERT INTO @WebhookCustomerTable
                                (
                                    CustomerId,
                                    GuideSerie,
                                    GuideNumber,
                                    GuideStatusId
                                )
                                SELECT DISTINCT
                                       DO.IdCustomer,
                                       TLG.Guide_Serie,
                                       TLG.Guide_Number,
                                       DO.StatusOrderId
                                FROM @TblListGuides TLG
                                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                                        ON TLG.Guide_Number = DO.Guide_Number
                                           AND TLG.Guide_Serie = DO.Guide_Serie;

                                -- Ingresar endpoints de cliente
                                UPDATE @WebhookCustomerTable
                                SET CustomerEndpointId = WE.IdWebhookEndpoint,
                                    WebhookType = @GuideStatusChangeWebhook
                                FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH (NOLOCK)
                                    INNER JOIN @WebhookCustomerTable WCT
                                        ON WE.CustomerId = WCT.CustomerId
                                           AND WE.WebhookTypeId = @GuideStatusChangeWebhook;

                                DECLARE @ResponseTable AS TABLE
                                (
                                    InsertedId BIGINT
                                );

                                INSERT INTO [DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
                                (
                                    [GuideSerie],
                                    [GuideNumber],
                                    [CustomerId],
                                    [StatusOrderId],
                                    [WebhookEndpointId],
                                    [HasNotified],
                                    [TokenCreated],
                                    [DateCreated]
                                )
                                OUTPUT inserted.IdWebhookTrackingQueue
                                INTO @ResponseTable
                                (
                                    InsertedId
                                )
                                SELECT WCT.GuideSerie,
                                       WCT.GuideNumber,
                                       WCT.CustomerId,
                                       WCT.GuideStatusId,
                                       WCT.CustomerEndpointId,
                                       0,
                                       @TokenP,
                                       GETDATE()
                                FROM @WebhookCustomerTable WCT
                                    LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH (NOLOCK)
                                        ON WCT.CustomerId = WRBU.CustomerId
                                           AND WCT.GuideStatusId = WRBU.StatusOrderId
                                           AND WCT.WebhookType = WRBU.WebhookTypeId
                                    LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH (NOLOCK)
                                        ON WCT.GuideSerie = WTQ.GuideSerie
                                           AND WCT.GuideNumber = WTQ.GuideNumber
                                           AND WCT.GuideStatusId = WTQ.StatusOrderId
                                           AND WTQ.RowStatus = 1
                                WHERE WRBU.IdWebhookRestrinctionByUser IS NOT NULL
                                      AND WTQ.IdWebhookTrackingQueue IS NULL;

                            END TRY
                            BEGIN CATCH

                            END CATCH;
                            -------------------WEBHOOK.FIN------------------------------	

                            -------GUARDAR COSTO--------------------
                            DECLARE @IdCost INT = 0;
                            DECLARE @TotalAmountPaid DECIMAL(12, 2) = 0;
                            DECLARE @ProductNumber VARCHAR(25);
                            DECLARE @FullPayment DECIMAL(18, 2);
                            DECLARE @CODPayment DECIMAL(18, 2);
                            DECLARE @Serie VARCHAR(2);
                            DECLARE @Number VARCHAR(20);


                            BEGIN TRY
                                -- si no existe insertar registro en tabla cost

                                INSERT INTO [dbo].[Cost]
                                (
                                    [IdProduct],
                                    [ProductNumber],
                                    [IdTypeCharge],
                                    [TotalAmount],
                                    [PaymentDate],
                                    [IdModule],
                                    [RowStatus],
                                    [TokenCreated],
                                    [DateCreated],
                                    [TotalAmountPaid],
                                    [CODAmount],
                                    [GuideSerie],
                                    [GuideNumber]
                                )
                                SELECT 1 IdProduct,
                                       CONCAT(ti.Guide_Serie, ti.Guide_Number) ProductNumber,
                                       1 IdTypeCharge,
                                       IIF(((pgt.AmountToPay = 0) AND (@ServiceType = 'PICKUP')), NULL, pgt.AmountToPay) TotalAmount,
                                       GETDATE() PaymentDate,
                                       @IdModuleP IdModule,
                                       1 RowStatus,
                                       @TokenP TokenCreated,
                                       GETDATE() DateCreated,
                                       IIF(((pgt.AmountToPay = 0) AND (@ServiceType = 'PICKUP')), NULL, pgt.AmountToPay) TotalAmountPaid,
                                       IIF(((pgt.CODAmount = 0) AND (@ServiceType = 'PICKUP')), NULL, pgt.CODAmount) CODAmount,
                                       ti.Guide_Serie,
                                       ti.Guide_Number
                                FROM #TblInclude ti
                                    INNER JOIN #PendingPaymentTemp pgt
                                        ON ti.Guide_Number = pgt.GuideNumber
                                           AND ti.Guide_Serie = pgt.GuideSerie
                                WHERE NOT EXISTS
                                (
                                    SELECT 1
                                    FROM dbo.Cost ct WITH (NOLOCK)
                                    WHERE ct.ProductNumber = CONCAT(ti.Guide_Serie, ti.Guide_Number)
                                );

                            --SET @IdCost = SCOPE_IDENTITY();

                            END TRY
                            BEGIN CATCH

                            END CATCH;

                            PRINT (CONVERT(VARCHAR(24), GETDATE(), 121));
                            UPDATE ct
                            SET ct.[PaymentDate] = GETDATE(),
                                ct.[TokenUpdated] = @TokenP,
                                ct.[DateUpdated] = GETDATE(),
                                ct.[TotalAmountPaid] = IIF(((ppt.AmountToPay = 0) AND (@ServiceType = 'PICKUP')),
                                                           NULL,
                                                           ppt.AmountToPay),
                                ct.[CODAmount] = IIF(((ppt.CODAmount = 0) AND (@ServiceType = 'PICKUP')),
                                                     NULL,
                                                     ppt.CODAmount),
                                ct.[GuideSerie] = (CASE
                                                       WHEN ct.IdCost = CoAux.IdCost THEN
                                                           ti.Guide_Serie
                                                       ELSE
                                                           NULL
                                                   END
                                                  ),
                                ct.[GuideNumber] = (CASE
                                                        WHEN ct.IdCost = CoAux.IdCost THEN
                                                            ti.Guide_Number
                                                        ELSE
                                                            NULL
                                                    END
                                                   )
                            FROM Cost ct WITH (NOLOCK)
                                INNER JOIN #PendingPaymentTemp ppt
                                    ON ct.ProductNumber = CONCAT(ppt.GuideSerie, ppt.GuideNumber)
                                INNER JOIN #TblInclude ti
                                    ON ct.ProductNumber = CONCAT(ti.Guide_Serie, ti.Guide_Number)
                                OUTER APPLY
                            (
                                SELECT TOP 1
                                       Co.IdCost
                                FROM [DeliveryBackOffice].[dbo].[Cost] Co WITH (NOLOCK)
                                WHERE (
                                          (
                                              Co.GuideSerie = ti.Guide_Serie
                                              AND Co.GuideNumber = ti.Guide_Number
                                          )
                                          OR
                                          (
                                              Co.ProductNumber = CONCAT(ti.Guide_Serie, ti.Guide_Number)
                                              AND Co.GuideSerie IS NULL
                                              AND Co.GuideNumber IS NULL
                                          )
                                      )
                                      AND Co.RowStatus = 1
                                ORDER BY Co.DateCreated DESC
                            ) CoAux
                            WHERE ISNULL(ct.TotalAmountPaid, 0) = 0;

                            IF (@Amount > 0)
                            BEGIN
                                INSERT INTO [dbo].[CostDetail]
                                (
                                    [IdCost],
                                    [IdTypeOfMoney],
                                    [Amount],
                                    [Voucher],
                                    [RowStatus],
                                    [TokenCreated],
                                    [DateCreated],
                                    [Responsible]
                                )
                                SELECT ct.IdCost,
                                       @IdTypeOfMoney,
                                       ct.TotalAmountPaid,
                                       IIF(@IdTypeOfMoney = 6, @Voucher, ''),
                                       1, -- crear registro activo por default
                                       @TokenP,
                                       GETDATE(),
                                       @Responsible
                                FROM Cost ct
                                    INNER JOIN #TblInclude ti
                                        ON ct.ProductNumber = CONCAT(ti.Guide_Serie, ti.Guide_Number)
                                    LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD
                                        ON ct.IdCost = CD.IdCost
                                WHERE CD.IdCostDetail IS NULL
                                      AND ISNULL(ct.TotalAmountPaid, 0) <> 0;

                                UPDATE CD
                                SET CD.Amount = ct.TotalAmountPaid,
                                    CD.IdTypeOfMoney = @IdTypeOfMoney,
                                    CD.Voucher = IIF(@IdTypeOfMoney = 6, @Voucher, ''),
                                    CD.TokenUpdated = @TokenP,
                                    CD.DateUpdated = GETDATE()
                                FROM Cost ct
                                    INNER JOIN #TblInclude ti
                                        ON ct.ProductNumber = CONCAT(ti.Guide_Serie, ti.Guide_Number)
                                    INNER JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD
                                        ON ct.IdCost = CD.IdCost
                                WHERE ISNULL(ct.TotalAmountPaid, 0) <> 0;
                            END;
                            -----------------------------------------


                            -----------------------------------------

                            DECLARE @OutSize2 INT;
                            DECLARE @OutPrueba2 VARCHAR(MAX);
                            SET @OutPrueba2
                                = '[ { ' + '"Guides": [ '
                                  +
                                  (
                                      SELECT STUFF(
                                             (
                                                 SELECT ' { "Guide": "'
                                                        + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR))
                                                        + '", '
                                                        +
                                                     --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                                     --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                                     '"StatusOrderId": '
                                                        + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
                                                        + '"StatusOrderDescription": "' + lge.StatusOrderDescription
                                                        + '" }, '
                                                 FROM #listGuidesEnabled lge
                                                 FOR XML PATH('')
                                             ),
                                             1,
                                             1,
                                             ''
                                                  )
                                  );

                            --PRINT(@OutPrueba);
                            SET @OutSize2 = LEN(@OutPrueba2) - 1;
                            PRINT (@OutSize2);
                            DECLARE @FINAL2 VARCHAR(MAX);
                            SET @FINAL2 =
                            (
                                SELECT SUBSTRING(@OutPrueba2, 1, @OutSize2)
                            );

                            SET @Output
                                = @FINAL2 + '], ' + '"Client": [ '
                                  +
                                  (
                                      SELECT STUFF(
                                             (
                                                 SELECT ' { "CUI": "' + @CUI + '", '
                                                        +
                                                     --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                                     --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                                     '"Name": "' + @Name + '" }, '
                                                 FOR XML PATH('')
                                             ),
                                             1,
                                             1,
                                             ''
                                                  )
                                  ) + '] } ]';

                            SET @Output
                                = SUBSTRING(@Output, 1, (LEN(@Output) - 7))
                                  + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

                            SELECT @Output FormatJson;

                        END;
                        ELSE
                        BEGIN
                            SET @Output
                                = '[ { ' + '"Rejects": [ '
                                  +
                                  (
                                      SELECT STUFF(
                                             (
                                                 SELECT ' {"StatusOrderDescription": "'
                                                        + ('La suma de las guias no coincide con el monto de pago.')
                                                        + '" }, '
                                                 FOR XML PATH('')
                                             ),
                                             1,
                                             1,
                                             ''
                                                  )
                                  ) + '] } ]';

                            SET @Output
                                = SUBSTRING(@Output, 1, (LEN(@Output) - 7))
                                  + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

                            SELECT @Output FormatJson;
                        END;

                    END;


                    ELSE --VALIDAR SUMAS CODAmount
                    BEGIN
                        SET @Output
                            = '[ { ' + '"Rejects": [ '
                              +
                              (
                                  SELECT STUFF(
                                         (
                                             SELECT ' {"StatusOrderDescription": "'
                                                    + ('La suma de las guias no coincide con el monto de pago.')
                                                    + '" }, '
                                             FOR XML PATH('')
                                         ),
                                         1,
                                         1,
                                         ''
                                              )
                              ) + '] } ]';

                        SET @Output
                            = SUBSTRING(@Output, 1, (LEN(@Output) - 7))
                              + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

                        SELECT @Output FormatJson;
                    END;

                END;

                ELSE IF ((SELECT COUNT(1)FROM #listGuidesNotExist) > 0)
                BEGIN
                    SET @Output
                        = '[ { ' + '"Rejects": [ '
                          +
                          (
                              SELECT STUFF(
                                     (
                                         SELECT ' { "Guide": "'
                                                + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' +
                                             --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                             --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                             '"StatusOrderId": ' + ('-1') + ', ' + '"Description": "'
                                                + (lge.Description) + '" }, '
                                         FROM #listGuidesNotExist lge
                                         FOR XML PATH('')
                                     ),
                                     1,
                                     1,
                                     ''
                                          )
                          ) + '] } ]';

                    SET @Output
                        = SUBSTRING(@Output, 1, (LEN(@Output) - 7))
                          + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));
                    SELECT @Output FormatJson;

                END;

                ELSE IF ((@GuidesEnable > 0) AND (@GuidesDisable > 0))
                BEGIN

                    DECLARE @OutSize INT;
                    DECLARE @OutPrueba VARCHAR(MAX);
                    SET @OutPrueba
                        = '[ { ' + '"Guides": [ '
                          +
                          (
                              SELECT STUFF(
                                     (
                                         SELECT ' { "Guide": "'
                                                + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' +
                                             --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                             --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                             '"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
                                                + '"StatusOrderDescription": "' + lge.StatusOrderDescription + '" }, '
                                         FROM #listGuidesEnabled lge
                                         FOR XML PATH('')
                                     ),
                                     1,
                                     1,
                                     ''
                                          )
                          );

                    PRINT (@OutPrueba);
                    SET @OutSize = LEN(@OutPrueba) - 1;
                    PRINT (@OutSize);
                    DECLARE @FINAL VARCHAR(MAX);
                    SET @FINAL =
                    (
                        SELECT SUBSTRING(@OutPrueba, 1, @OutSize)
                    );

                    SET @Output
                        = @FINAL + '], ' + '"Rejects": [ '
                          +
                          (
                              SELECT STUFF(
                                     (
                                         SELECT ' { "Guide": "'
                                                + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' +
                                             --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                             --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                             '"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
                                                + '"StatusOrderDescription": "' + lge.StatusOrderDescription + '" }, '
                                         FROM #listGuidesDisabled lge
                                         FOR XML PATH('')
                                     ),
                                     1,
                                     1,
                                     ''
                                          )
                          ) + '] } ]';

                    SET @Output
                        = SUBSTRING(@Output, 1, (LEN(@Output) - 7))
                          + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

                    SELECT @Output FormatJson;
                END;

                ELSE
                BEGIN
                    SET @Output
                        = '[ { ' + '"Rejects": [ '
                          +
                          (
                              SELECT STUFF(
                                     (
                                         SELECT ' {"StatusOrderDescription": "'
                                                + ('La suma de las guias no coincide con el monto de pago.') + '" }, '
                                         FOR XML PATH('')
                                     ),
                                     1,
                                     1,
                                     ''
                                          )
                          ) + '] } ]';

                    SET @Output
                        = SUBSTRING(@Output, 1, (LEN(@Output) - 7))
                          + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

                    SELECT @Output FormatJson;
                END;


            -----------------------------------------------------------------------------------------------------	
            END; --VER GUIAS VALIDAS
            ELSE IF (
                        (
                        (
                            SELECT COUNT(1)FROM #listGuidesEnabled
                        ) > 0
                        )
                        AND (
                            (
                                SELECT COUNT(1)FROM #listGuidesDisabled
                            ) > 0
                            )
                    )
            BEGIN

                DECLARE @OutSizee INT;
                DECLARE @OutPruebaa VARCHAR(MAX);
                SET @OutPruebaa
                    = '[ { ' + '"Guides": [ '
                      +
                      (
                          SELECT STUFF(
                                 (
                                     SELECT ' { "Guide": "'
                                            + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' +
                                         --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                         --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                         '"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
                                            + '"StatusOrderDescription": "' + lge.StatusOrderDescription + '" }, '
                                     FROM #listGuidesEnabled lge
                                     FOR XML PATH('')
                                 ),
                                 1,
                                 1,
                                 ''
                                      )
                      );

                SET @OutSizee = LEN(@OutPruebaa) - 1;
                DECLARE @FINALL VARCHAR(MAX);
                SET @FINALL =
                (
                    SELECT SUBSTRING(@OutPruebaa, 1, @OutSizee)
                );

                SET @Output
                    = @FINALL + '], ' + '"Rejects": [ '
                      +
                      (
                          SELECT STUFF(
                                 (
                                     SELECT ' { "Guide": "'
                                            + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' +
                                         --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                         --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                         '"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
                                            + '"StatusOrderDescription": "' + lge.StatusOrderDescription + '" }, '
                                     FROM #listGuidesDisabled lge
                                     FOR XML PATH('')
                                 ),
                                 1,
                                 1,
                                 ''
                                      )
                      ) + '] } ]';

                SET @Output
                    = SUBSTRING(@Output, 1, (LEN(@Output) - 7)) + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

                SELECT @Output FormatJson;


            END;

            ELSE IF ((SELECT COUNT(1)FROM #listGuidesDisabled) > 0)
            BEGIN
                SET @Output
                    = '[ { ' + '"Rejects": [ '
                      +
                      (
                          SELECT STUFF(
                                 (
                                     SELECT ' { "Guide": "'
                                            + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR)) + '", ' +
                                         --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                         --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                         '"StatusOrderId": ' + CAST(ISNULL(lge.StatusOrderId, 0) AS VARCHAR) + ', '
                                            + '"StatusOrderDescription": "' + lge.StatusOrderDescription + '" }, '
                                     FROM #listGuidesDisabled lge
                                     FOR XML PATH('')
                                 ),
                                 1,
                                 1,
                                 ''
                                      )
                      ) + '] } ]';

                SET @Output
                    = SUBSTRING(@Output, 1, (LEN(@Output) - 7)) + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

                SELECT @Output FormatJson;

            END;

			if (@ServiceType='RETURN' or @ServiceType='DELIVERY' )
			Begin
			
			--- Borrado Logico de posición en la guía

			UPDATE wh
			SET Active = 0
			   ,UserUpdated = @TokenP
			   ,DateUpdated = GETDATE()
			FROM Warehouse wh
			INNER JOIN @TblListGuides tlg
				ON wh.Guide_Serie = tlg.Guide_Serie
				AND wh.Guide_Number = tlg.Guide_Number
			WHERE wh.Active = 1
			End


        END TRY
        BEGIN CATCH

            SELECT 'ERROR' AS message,
                   'FALSE' blnResult,
                   CAST(500 AS VARCHAR(5)) StatusResult,
                   CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
                   CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
                   CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
                   CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
                   CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
                   CAST(ERROR_MESSAGE() AS VARCHAR(100)) AS ResultMessage;

            ROLLBACK TRANSACTION;
        END CATCH;


        IF @@TRANCOUNT > 0
        BEGIN

            COMMIT TRANSACTION;

        END;
        ELSE
        BEGIN
            SET @Output
                = '[ { ' + '"Rejects": [ '
                  +
                  (
                      SELECT STUFF(
                             (
                                 SELECT ' { "Guide": "' + CONCAT(lge.Guide_Serie, CAST(lge.Guide_Number AS VARCHAR))
                                        + '", ' +
                                     --'"GuideSerie": "' + lge.Guide_Serie + '", ' + 
                                     --'"GuideNumber": "' + CAST(lge.Guide_Number AS VARCHAR) + '", ' + 
                                     '"StatusOrderId": ' + ('-1') + ', ' + '"Description": "' + (lge.Description)
                                        + '" }, '
                                 FROM #listGuidesNotExist lge
                                 FOR XML PATH('')
                             ),
                             1,
                             1,
                             ''
                                  )
                  ) + '] } ]';

            SET @Output
                = SUBSTRING(@Output, 1, (LEN(@Output) - 7)) + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));
            SELECT @Output FormatJson;
        END;

    END;
END;

