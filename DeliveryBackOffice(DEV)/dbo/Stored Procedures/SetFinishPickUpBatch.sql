-- =============================================
-- Author:        <Cristian Suazo>
-- Updated date:<21-02-2025>
-- Description:    <Se crea sp para manejo de recolecciones en servicio PickupProcessingService>
-- =============================================
-- =============================================
-- Author:        <Edelman>
-- Updated date:<02-05-2025>
-- Description:    <Actualizar tablas de referencia y contenedores que se hayan procesado en el servicio recolección POD>
-- =============================================

CREATE PROCEDURE [dbo].[SetFinishPickUpBatch]
    -- Add the parameters for the stored procedure here
    @InGuides NVARCHAR(MAX),
    @IdPickup INT,
    @TypeofInOutMoneyId INT = 1,
    @Token VARCHAR(200) = NULL,
    @Observations VARCHAR(200) = NULL,
    @Amount DECIMAL(12, 2) = 0,
    @Voucher NVARCHAR(200) = ' ',
    @PuSignaturePath NVARCHAR(250) = ' ',
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @PickupLatitude NVARCHAR(20) = NULL,
    @PickupLongitude NVARCHAR(20) = NULL,
    @PickUpEmail NVARCHAR(200) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @jsonResult1 NVARCHAR(MAX);
    DECLARE @jsonResult2 NVARCHAR(MAX);
    DECLARE @jsonError NVARCHAR(MAX);
    DECLARE @jsonToken NVARCHAR(MAX);
    DECLARE @ManifestSerie VARCHAR(10) = 'FM';
    DECLARE @ManifestNumber BIGINT;

    DECLARE @CodeOfReference INT;
    DECLARE @CourierID INT;

    -- insertar en tabla temporal posbibles mensajes de respuesta
    --IF OBJECT_ID('tempdb.dbo.#UpdateNow', 'U') IS NOT NULL DROP TABLE #UpdateNow;
    IF OBJECT_ID('tempdb.dbo.#NowInsert', 'U') IS NOT NULL
        DROP TABLE #NowInsert;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;
    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
        DROP TABLE #Temp;

    DECLARE @responsemessage AS TABLE
    (
        IdResult INT,
        [Message] NVARCHAR(500),
        Id NVARCHAR(20)
    );

    INSERT INTO @responsemessage
    (
        IdResult,
        [Message],
        Id
    )
    SELECT *
    FROM
    (
        SELECT 200 AS IdResult,
               'Estado  cambiado correctamente' AS [Message],
               'OK' AS Id
        UNION
        SELECT 500 AS IdResult,
               'Error fatal intente de nuevo mas tarde' AS [Message],
               'Transac' AS Id
    ) AS errror;

    -- Variables para verificar ubicación en geocerca
    DECLARE @FixedLatitude NVARCHAR(20) = @PickupLatitude;
    DECLARE @FixedLongitude NVARCHAR(20) = @PickupLongitude;

    IF OBJECT_ID('tempdb.dbo.#InsertedRecords', 'U') IS NOT NULL
       DROP TABLE #InsertedRecords;

    CREATE TABLE #InsertedRecords 
    (
       GuideNumber         INT,
       GuideSerie          NVARCHAR(2),
       IdProcessedGuideCOD INT
    );
    CREATE NONCLUSTERED INDEX INDX_ProcessedGuideCOD_TempTable ON #InsertedRecords (GuideSerie, GuideNumber);

    BEGIN TRY

        IF (
               RTRIM(LTRIM(ISNULL(@PickupLatitude, ''))) <> ''
               AND RTRIM(LTRIM(ISNULL(@PickupLongitude, ''))) <> ''
           )
        BEGIN
            DECLARE @TargetGeofence GEOMETRY;
            DECLARE @TargetGeofenceAsText NVARCHAR(MAX);

            DECLARE @TargetPoint GEOMETRY;
            DECLARE @TargetPointAsText NVARCHAR(MAX) = CONCAT('POINT (', @PickupLongitude, ' ', @PickupLatitude, ')');

            SET @TargetGeofenceAsText
                = (CONCAT(
                             'POLYGON ((',
                   (
                       SELECT STUFF(
                                       (
                                           SELECT ', '
                                                  + CONCAT(
                                                              CAST(P.PointLongitude AS DECIMAL(9, 6)),
                                                              ' ',
                                                              CAST(P.PointLatitude AS DECIMAL(9, 6))
                                                          )
                                           FROM [DeliveryBackOffice].[dbo].[Geofence] G WITH (NOLOCK)
                                               INNER JOIN [DeliveryBackOffice].[dbo].[GeofencePoint] GP WITH (NOLOCK)
                                                   ON G.IdGeofence = GP.IdGeofence             
                                               INNER JOIN [DeliveryBackOffice].[dbo].[Point] P WITH (NOLOCK)
                                                   ON GP.IdPoint = P.IdPoint                  
                                           WHERE G.RowStatus = 1
                                                 AND GP.RowStatus = 1
                                                 AND P.RowStatus = 1
                                                 AND G.IdGeofence = 1 -- Geocerca de GT
                                           ORDER BY GP.GeofencePointOrder ASC
                                           FOR XML PATH(''), TYPE
                                       ).value('.', 'varchar(max)'),
                                       1,
                                       1,
                                       ''
                                   )
                   ),
                             '))'
                         )
                  );

            SET @TargetGeofence = geometry::STGeomFromText(@TargetGeofenceAsText, 0);

            SET @TargetPoint = geometry::STGeomFromText(@TargetPointAsText, 0);

            DECLARE @IsValidLocation BIT
                = CASE
                      WHEN @TargetPoint.STIntersection(@TargetGeofence).ToString() = 'GEOMETRYCOLLECTION EMPTY' THEN
                          0
                      ELSE
                          1
                  END;

            IF (@IsValidLocation = 0)
            BEGIN
                SET @FixedLatitude = NULL;
                SET @FixedLongitude = NULL;
            END;
        END;

    END TRY
    BEGIN CATCH
        SET @FixedLatitude = NULL;
        SET @FixedLongitude = NULL;
    END CATCH;


        CREATE TABLE #Temp
        (
            Guide VARCHAR(255),
            Message VARCHAR(255),
        );

        CREATE NONCLUSTERED INDEX tempTemp ON #Temp (Guide);

        -- Add the parameters for the stored procedure here
        INSERT INTO #Temp
        (
          Guide,
          [Message]
        )
        EXEC [dbo].[spws_get_validate_guides_pickup]
             @InGuides = @InGuides,
             @IdPickup = @IdPickup,
             @Token = @Token;

        DECLARE @test INT =
                (
                    SELECT COUNT(*)FROM #Temp
                );

        IF (@test = 0)
        BEGIN
            BEGIN TRANSACTION;
            BEGIN TRY

                --IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;
                IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
                    DROP TABLE #listGuides;

                CREATE TABLE #listGuides
                (
                    ItemSerie NVARCHAR(2),
                    ItemNumber INT,
                    ItemPiece INT
                );

                CREATE NONCLUSTERED INDEX templistGuides_Piece495
                ON #listGuides (
                                   ItemSerie,
                                   ItemNumber
                               );

                CREATE NONCLUSTERED INDEX templistGuides_4444
                ON #listGuides (
                                   ItemSerie,
                                   ItemNumber,
                                   ItemPiece
                               );

                INSERT INTO #listGuides
                (
                    ItemSerie,
                    ItemNumber,
                    ItemPiece
                )
                SELECT SUBSTRING(Item, 1, 2) ItemSerie,
                       SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
                       ISNULL(   (CASE
                                      WHEN LEN(SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item))) > 1 THEN
                                          1
                                      ELSE
                                          SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item))
                                  END
                                 ),
                                 0
                             ) ItemPiece
                FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

                UPDATE [#listGuides]
                   SET [ItemPiece] = 1
                 WHERE [ItemPiece] = 0;

                --------------------------------inserta en una tabla temporal, los campos requeridos para insertar en DeliveryPaymentDetail las guias no generadas en el portal--------------------------------------
                DECLARE @AmountPickup DECIMAL(14, 2) =
                        (
                            SELECT CONVERT(DECIMAL(14, 2), Value)
                            FROM CatToCharge WITH (NOLOCK)
                            WHERE IdToCharge = 1
                        );

                SELECT [Guide_Number],
                       [Guide_Serie],
                       [PriceShippment],
                       [recolect],
                       [IsCollect]
                INTO #NowInsert
                FROM
                (
                    SELECT ord.Guide_Number,
                           ord.Guide_Serie,
                           ord.PriceShippment,
                           (@AmountPickup) AS recolect,
                           ord.IsCollect
                    FROM DeliveryOrder ord WITH (NOLOCK)
                        LEFT JOIN DeliveryOrderPaymentDetail dop WITH (NOLOCK)
                            ON (
                                   ord.Guide_Number = dop.GuideNumber
                                   AND ord.Guide_Serie = dop.GuideSerie
                               )
                        INNER JOIN #listGuides ls
                            ON (
                                   ord.Guide_Number = ls.ItemNumber
                                   AND ord.Guide_Serie = ls.ItemSerie
                               )
                    WHERE ord.Guide_Number IN
                          (
                           SELECT ItemNumber 
                             FROM #listGuides 
                          )
                          AND ord.Guide_Serie IN 
                          (
                           SELECT ItemSerie 
                             FROM #listGuides
                          )
                          AND ord.StatusOrderId IN ( 15, 1, 16 )
                          AND dop.GuideNumber IS NULL
                ) AS Table1;

                --    declare @AmountPickup decimal (18,2) = (select  Convert(decimal(18,2),Value) from ConfigParams where ConfigParamsId = 15)

                CREATE NONCLUSTERED INDEX tempNowInsert
                ON #NowInsert (
                                  Guide_Number,
                                  Guide_Serie
                              );

                ----------------------------------------------Inserta en la tabla DeliveryOrderPaymentDetail los datos de la tabla temporal ----------------------------------
                INSERT INTO dbo.DeliveryOrderPaymentDetail
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
                SELECT DISTINCT
                       ls.Guide_Number,
                       ls.Guide_Serie,
                       1,
                       @TypeofInOutMoneyId,
                       IIF(ls.IsCollect = 'true', 3, 4),
                       NULL,
                       @Token,
                       GETDATE(),
                       NULL,
                       NULL,
                       NULL,
                       0.00,
                       0.00,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       @IdPickup,
                       0.00,
                       0.00,
                       @AmountPickup
                FROM #NowInsert ls;


                --------------------------------------------- Registra en la tabla DeliveryOrderDetail la recoleccion de la guia  ---------------------------------
                INSERT INTO DeliveryOrderDetail
                (
                    [Guide_Serie],
                    [Guide_Number],
                    [StatusOrderId],
                    [UserCreated],
                    [DateCreated],
                    [DateCreatedInSystem],
                    [Observations],
                    [Temperature_Celsius]
                )
                SELECT ni.ItemSerie,
                       ni.ItemNumber,
                       2,
                       @Token,
                       GETDATE(),
                       GETDATE(),
                       NULL,
                       NULL
                FROM #listGuides ni;

                -------------------------- Drop la tabla temporal -------------------------------------------------------------------

                --DROP TABLE #UpdateNow
                DROP TABLE #NowInsert;


                ---------------------------------Obtner los datos a actualizar del encabezado del lote de guias -------------------------------------
                DECLARE @SenderId INT =
                        (
                            SELECT TOP 1
                                   ord.Sender_ID
                            FROM #listGuides ls
                                INNER JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                            WHERE ord.Guide_Number IN
                                  (
                                    SELECT ItemNumber FROM #listGuides
                                  )
                                  AND ord.Guide_Serie IN 
                                  (
                                    SELECT ItemSerie FROM #listGuides
                                  )
                        );

                DECLARE @CustomerId INT =
                        (
                            SELECT TOP 1
                                   ISNULL(ord.IdCustomer, 6)
                            FROM #listGuides ls
                                INNER JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                            WHERE ord.Guide_Number IN
                                  (
                                   SELECT ItemNumber FROM #listGuides
                                  )
                                  AND ord.Guide_Serie IN 
                                  (
                                   SELECT ItemSerie FROM #listGuides
                                  )
                        );

                DECLARE @SenderName VARCHAR(50) =
                        (
                            SELECT TOP 1
                                   CONCAT(ord.Sender_FirstName, ord.Sender_LastName) AS SenderName
                            FROM #listGuides ls
                                INNER JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                            WHERE ord.Guide_Number IN
                                  (
                                    SELECT ItemNumber FROM #listGuides
                                  )
                                   AND ord.Guide_Serie IN 
                                  (
                                    SELECT ItemSerie FROM #listGuides
                                  )
                        );

                DECLARE @Sender_Phone VARCHAR(20) =
                        (
                            SELECT TOP 1
                                   ord.Sender_Phone
                            FROM #listGuides ls
                                INNER JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (
                                           ord.Guide_Number = ls.ItemNumber
                                           AND ord.Guide_Serie = ls.ItemSerie
                                       )
                            WHERE ord.Guide_Number IN
                                  (
                                   SELECT ItemNumber FROM #listGuides
                                  )
                                  AND ord.Guide_Serie IN 
                                  (
                                   SELECT ItemSerie FROM #listGuides
                                  )
                        );

                DECLARE @IdHublogistic INT =
                        (
                          SELECT TOP 1
                                 HBG.IdHubLogistic
                            FROM #listGuides ls
                                 INNER JOIN DeliveryOrder ord WITH (NOLOCK)
                                     ON (
                                            ord.Guide_Number = ls.ItemNumber
                                            AND ord.Guide_Serie = ls.ItemSerie
                                        )
                                 INNER JOIN DeliveryBackOffice.dbo.Township TWN WITH(NOLOCK)
                                     ON ord.SenderIdTownship = twn.IdTownship 
                                 INNER JOIN DeliveryBackOffice.dbo.DumpServiceCoverage THB WITH(NOLOCK)
                                     ON THB.HeaderCode = twn.HeaderCode
                                 INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBG WITH(NOLOCK)
                                     ON HBG.HubAbbreviation = THB.Hub 
                                 INNER JOIN DeliveryOrderPaymentDetail dop WITH (NOLOCK)
                                     ON (
                                         dop.GuideNumber = ord.Guide_Number
                                         AND dop.GuideSerie = ord.Guide_Serie
                                        )
                           WHERE ord.Guide_Number IN
                                 (
                                     SELECT ItemNumber FROM #listGuides
                                 )
                                 AND ord.Guide_Serie IN 
                                 (
                                       SELECT ItemSerie FROM #listGuides
                                 )
                                 AND THB.RowStatus = 1
                                 AND twn.TownshipStatus = 1
                                 AND HBG.HubStatus = 1
                        );

                DECLARE @Sender_Address VARCHAR(200) =
                        (
                         SELECT TOP 1
                                  ord.Sender_Address
                           FROM #listGuides ls
                                INNER JOIN DeliveryOrder ord WITH (NOLOCK)
                                   ON (
                                       ord.Guide_Number = ls.ItemNumber
                                       AND ord.Guide_Serie = ls.ItemSerie
                                      )
                            WHERE ord.Guide_Number IN
                                  (
                                   SELECT ItemNumber 
                                     FROM #listGuides
                                  )
                                  AND ord.Guide_Serie IN 
                                  (
                                   SELECT ItemSerie
                                     FROM #listGuides
                                  )
                        );

                DECLARE @Sender_Email VARCHAR(200) =
                        (
                         SELECT TOP 1
                                ISNULL(REPLACE(REPLACE(cus.RegexEmail, '$', ''), '^', ''), ' ')
                           FROM #listGuides ls
                                INNER JOIN DeliveryOrder ord WITH (NOLOCK)
                                   ON (
                                          ord.Guide_Number = ls.ItemNumber
                                          AND ord.Guide_Serie = ls.ItemSerie
                                      )
                                LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                                   ON cus.IdCustomer = ord.IdCustomer
                        );

                -----------------------------------------------------Actualiza los datos obtenidos anteriormente para la tabla SchedulePickup-----------------------------------------------------------
                UPDATE dbo.SchedulePickup
                   SET AmountPickup = @AmountPickup,
                       TokenUpdated = @Token,
                       DateUpdated  = GETDATE()
                 WHERE SchedulePickupId = @IdPickup;
                ---------------------------------------------------------Agrupa el lote de guias a una sola transaccion ------------------------------------------------------------------------------

                UPDATE DeliveryOrderPaymentDetail
                   SET IdHeaderRecolection = @IdPickup,
                       TokenUpdated = @Token,
                       DateUpdated  = GETDATE()
                  FROM DeliveryOrderPaymentDetail dop WITH (NOLOCK)
                       INNER JOIN DeliveryOrder ord WITH (NOLOCK)
                           ON (
                                  ord.Guide_Number = dop.GuideNumber
                                  AND ord.Guide_Serie = dop.GuideSerie
                              )
                  WHERE dop.GuideSerie = 'FD'
                        AND dop.GuideNumber IN
                            (
                                SELECT ItemNumber FROM #listGuides
                            )
                        AND ord.StatusOrderId IN ( 15, 1, 16 )
                        AND
                        (
                            dop.IdHeaderRecolection = @IdPickup
                            OR dop.IdHeaderRecolection IS NULL
                        );

                -- Quitar guías no recolectadas asociadas al servicio
                UPDATE DeliveryOrderPaymentDetail
                SET IdHeaderRecolection = NULL
                FROM DeliveryOrderPaymentDetail dop WITH (NOLOCK)
                    LEFT JOIN #listGuides LG
                        ON dop.GuideNumber = LG.ItemNumber
                           AND dop.GuideSerie = LG.ItemSerie
                WHERE dop.IdHeaderRecolection = @IdPickup
                      AND LG.ItemNumber IS NULL
                      AND LG.ItemSerie IS NULL;

                ------------------------------------------------- Actualiza su StatusId a 2 = Recoleccion todas las guias del lote -------------------------------------

                UPDATE DeliveryOrder
                   SET StatusOrderId = 2
                  FROM DeliveryOrder WITH (NOLOCK)
                 WHERE Guide_Number IN
                       (
                        SELECT ItemNumber 
                          FROM #listGuides
                       )
                       AND Guide_Serie IN
                       (
                        SELECT ItemSerie 
                          FROM #listGuides
                       );

                DECLARE @CartGuides AS TABLE
                (
                    GuideSerie NVARCHAR(2),
                    GuideNumber INT
                );
                UPDATE ASCD
                SET RowStatus = 0,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                FROM [DeliveryBackOffice].[dbo].[AccountServiceCartDetail] ASCD WITH (NOLOCK)
                    INNER JOIN #listGuides LGE WITH (NOLOCK)
                        ON ASCD.GuideSerie = LGE.ItemSerie
                           AND ASCD.GuideNumber = LGE.ItemNumber
                           AND ASCD.RowStatus = 1;

                UPDATE DOPD
                SET DOPD.ShipmentCompleted = 1
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
                    INNER JOIN @CartGuides CG
                        ON DOPD.GuideSerie = CG.GuideSerie
                           AND DOPD.GuideNumber = CG.GuideNumber;

                ---------------------WEBHOOK.INI--------------------------------
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
                                WHERE WT.WebhookName = 'GuideStatusChange' 
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
                           TLG.ItemSerie,
                           TLG.ItemNumber,
                           DO.StatusOrderId
                    FROM #listGuides TLG
                        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                            ON TLG.ItemNumber = DO.Guide_Number
                               AND TLG.ItemSerie = DO.Guide_Serie;

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
                           @Token,
                           GETDATE()
                    FROM @WebhookCustomerTable WCT
                        LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH (NOLOCK)
                            ON WCT.CustomerId = WRBU.CustomerId
                               AND WCT.GuideStatusId = WRBU.StatusOrderId
                               AND WCT.WebhookType = WRBU.WebhookTypeId
                        INNER JOIN [DeliveryBackOffice].[dbo].[WebhookEndpoint] WHE WITH (NOLOCK)
                            ON WRBU.CustomerId = WHE.CustomerId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH (NOLOCK)
                            ON WCT.GuideSerie = WTQ.GuideSerie
                               AND WCT.GuideNumber = WTQ.GuideNumber
                               AND WCT.GuideStatusId = WTQ.StatusOrderId
                    WHERE WRBU.IdWebhookRestrinctionByUser IS NOT NULL
                          AND WTQ.IdWebhookTrackingQueue IS NULL
                          AND WHE.TypeConnectionId = 1

                    
                --Agregar datos en cola de webhooks de cliente DHL---INI
                DECLARE @GuidePiecesTable AS TABLE
                (
                    CustomerId INT,
                    CustomerEndpointId BIGINT,
                    WebhookType INT,
                    GuideSerie NVARCHAR(2),
                    GuideNumber INT,
                    GuideStatusId TINYINT,
                    NumberPieces INT,
                    NumberRelatedPieces INT
                    
                );

                INSERT INTO @GuidePiecesTable 
                       (
                       CustomerId,
                       GuideSerie,
                       GuideNumber,
                       GuideStatusId,
                       NumberPieces
                       )
                       SELECT wct.CustomerId,
                              dop.GuideSerie,dop.GuideNumber, 
                              wct.GuideStatusId,
                              Count(dop.GuideNumber)
                         FROM DeliveryOrderPiece dop WITH(NOLOCK)
                              INNER JOIN @WebhookCustomerTable wct
                                  ON dop.GuideSerie = wct.GuideSerie
                                  AND dop.GuideNumber = wct.GuideNumber
                              INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
                                  ON wct.CustomerId = WHE.CustomerId
                              INNER JOIN DeliveryOrder do WITH(NOLOCK)
                                  ON dop.GuideSerie = do.Guide_Serie 
                                  AND dop.GuideNumber = do.Guide_Number
                        WHERE do.IdCustomer = wct.CustomerId
                          AND WHE.TypeConnectionId = 2
                        GROUP BY wct.CustomerId,
                          dop.GuideSerie,dop.GuideNumber, 
                          wct.GuideStatusId

                   DECLARE @PiecesGuideRelatedTable AS TABLE
                (
                    CustomerId INT,
                    CustomerEndpointId BIGINT,
                    WebhookType INT,
                    GuideSerie NVARCHAR(2),
                    GuideNumber INT,
                    GuideStatusId TINYINT,
                    NumberRelatedPieces INT
                    
                );

                INSERT INTO @PiecesGuideRelatedTable 
                       ( 
                        CustomerId,
                        GuideSerie,
                        GuideNumber,
                        GuideStatusId,
                        NumberRelatedPieces
                       )
                       SELECT wct.CustomerId,
                              dop.GuideSerie,dop.GuideNumber, 
                              wct.GuideStatusId,
                              Count(dop.GuideNumber)
                         FROM DeliveryOrderPiece dop WITH(NOLOCK)
                              INNER JOIN @WebhookCustomerTable wct
                                  ON dop.GuideSerie = wct.GuideSerie
                                  AND dop.GuideNumber = wct.GuideNumber
                              INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
                                  ON wct.CustomerId = WHE.CustomerId
                              INNER JOIN DeliveryOrder do WITH(NOLOCK)
                                  ON dop.GuideSerie = do.Guide_Serie
                                  AND dop.GuideNumber = do.Guide_Number
                        WHERE do.IdCustomer = wct.CustomerId
                          AND WHE.TypeConnectionId = 2
                          AND dop.ExternalPieceId IS NOT NULL
                        GROUP BY wct.CustomerId,
                              dop.GuideSerie,dop.GuideNumber, 
                              wct.GuideStatusId

                INSERT INTO WebhookTrackingQueueDetailForSFTP 
                      (
                       CustomerId,
                       GuideSerie,
                       GuideNumber,
                       GuidePiece,
                       ExternalNumber,
                       ExternalPieceId,
                       StatusOrderId,
                       RowStatus,
                       DateCreated,
                       TokenCreated
                      )
                      SELECT wct.CustomerId,
                             dop.GuideSerie,dop.GuideNumber, dop.GuidePiece, do.Ticket_Number,dop.ExternalPieceId, 
                             wct.GuideStatusId, 1 AS RowStatus, GETDATE()AS DateCreated,@Token AS TokenCreated
                        FROM DeliveryOrderPiece dop WITH(NOLOCK)
                             INNER JOIN @WebhookCustomerTable wct
                                 ON dop.GuideSerie = wct.GuideSerie
                                 AND dop.GuideNumber = wct.GuideNumber
                             INNER JOIN WebhookEndpoint WHE WITH(NOLOCK)
                                 ON wct.CustomerId = WHE.CustomerId
                             INNER JOIN DeliveryOrder do WITH(NOLOCK)
                                 ON dop.GuideSerie = do.Guide_Serie
                                 AND dop.GuideNumber = do.Guide_Number
                             INNER JOIN @GuidePiecesTable gpt
                                 ON wct.GuideNumber = gpt.GuideNumber
                             INNER JOIN @PiecesGuideRelatedTable pgt
                                 ON gpt.GuideNumber = pgt.GuideNumber
                       WHERE do.IdCustomer = wct.CustomerId
                         AND WHE.TypeConnectionId = 2
                         AND gpt.NumberPieces = pgt.NumberRelatedPieces

                END TRY
                BEGIN CATCH

                END CATCH;

                --------------------WEBHOOK.FIN------------------------------

                ---------------------------------------------- Coloca true a IsPickup para que se entienda que es Recoleccion o fue escaneada la guia --------------------
                UPDATE DeliveryOrderPiece
                   SET IsPickup = 1,
                       StatusOrderId = 2
                  FROM DeliveryOrderPiece WITH (NOLOCK)
                 WHERE GuideNumber IN
                       (
                           SELECT ItemNumber FROM #listGuides
                       )
                       AND GuideSerie IN
                       (
                           SELECT ItemSerie FROM #listGuides
                       );

                ---------------------------------------------- Actualiza el Status del Servicio  -------------------------------------------------------------------------

                DECLARE @Status INT =
                        (
                            SELECT IdServiceStatus FROM CatServiceStatus WITH (NOLOCK) WHERE IdServiceStatus = 3
                        );

                UPDATE ServiceManagement
                SET ServiceStatusId = @Status,
                    PuSignaturePath = @PuSignaturePath,
                    CiPuDate = @StartDate,
                    CoPuDate = @EndDate,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                FROM ServiceManagement WITH (NOLOCK)
                WHERE IdSchedulePickup = @IdPickup;

                DECLARE @transac INT =
                        (
                            SELECT TOP 1
                                   IdServiceManagement
                              FROM ServiceManagement WITH (NOLOCK)
                             WHERE IdSchedulePickup = @IdPickup
                        );

                ---------------------------------------------- Inserta en EventService el comportamiento del Pickup  -------------------------------------------------------------------------    

                INSERT INTO EventService
                (
                    ServiceManagementId,
                    ServiceStatusId,
                    RowStauts,
                    TokenCreated,
                    DateCreated,
                    Observations
                )
                VALUES
                (@transac, @Status, 1, @Token, GETDATE(), @Observations);

                -----------------------------------------Registrar pago ---------------------------------------------------------------------------


                -- Revisar la existencia de un service management para ruta de Rabbit
                IF (EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM [DeliveryBackOffice].[dbo].[SettlementPickupStationDetail] SPSD WITH (NOLOCK)
                    WHERE SPSD.ServiceManagementId = @transac
                          AND SPSD.RowStatus = 1
                          AND CAST(SPSD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
                          AND SPSD.SettlementDate IS NULL
                )
                   )
                BEGIN

                    UPDATE SPSD
                    SET SPSD.Price = @Amount
                    FROM [DeliveryBackOffice].[dbo].[SettlementPickupStationDetail] SPSD WITH (NOLOCK)
                    WHERE SPSD.ServiceManagementId = @transac
                          AND SPSD.RowStatus = 1
                          AND CAST(SPSD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
                          AND SPSD.SettlementDate IS NULL;

                END;

                DECLARE @fecha AS DATE = GETDATE();
                IF @Amount > 0
                BEGIN

                    DECLARE @PaymentUpdated AS TABLE
                    (
                        CostId INT,
                        GuideSerie NVARCHAR(2),
                        GuideNumber INT
                    );

                    --- REGISTRO DE PAGO DE LAS GUÍAS RECOLECTADAS
                    UPDATE C
                    SET C.TotalAmountPaid = C.TotalAmount,
                        C.PaymentDate = @fecha,
                        C.TokenUpdated = @Token,
                        C.DateUpdated = GETDATE()
                    OUTPUT inserted.IdCost,
                           LG.ItemSerie,
                           LG.ItemNumber
                    INTO @PaymentUpdated
                    (
                        CostId,
                        GuideSerie,
                        GuideNumber
                    ) -- Control de guías pagadas
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                        INNER JOIN #listGuides LG
                            ON C.GuideSerie = LG.ItemSerie AND C.GuideNumber = LG.ItemNumber
                        LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
                            ON LG.ItemSerie = DOPD.GuideSerie
                               AND LG.ItemNumber = DOPD.GuideNumber
                    WHERE DOPD.TimePlaId = 2 -- Guías cuyo pago sea solo en la recolección
                          AND C.TotalAmountPaid IS NULL;

                    --- REGISTRO DEL DETALLE DEL PAGO DE LAS GUÍAS RECOLECTADAS
                    INSERT INTO dbo.CostDetail
                    (
                        IdCost,
                        IdTypeOfMoney,
                        Amount,
                        Voucher,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    SELECT C.IdCost,
                           @TypeofInOutMoneyId,
                           C.TotalAmountPaid,
                           IIF(@TypeofInOutMoneyId = 6, @Voucher, ''),
                           1,
                           @Token,
                           GETDATE()
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                        INNER JOIN @PaymentUpdated PU
                            ON C.IdCost = PU.CostId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
                            ON C.IdCost = CD.IdCost
                    WHERE CD.IdCostDetail IS NULL; -- Que no se haya generado aun su detalle de pago

                END;


                DECLARE @mail VARCHAR(200) =
                        (
                            SELECT TOP 1
                                   RegexEmail
                            FROM Customer ct WITH (NOLOCK)
                                INNER JOIN DeliveryOrder ord WITH (NOLOCK)
                                    ON (ord.IdCustomer = ct.IdCustomer)
                            WHERE ord.Guide_Number IN
                                  (
                                      SELECT ItemNumber FROM #listGuides
                                  )
                                  AND ord.Guide_Serie IN 
                                  (
                                        SELECT ItemSerie FROM #listGuides
                                  )
                        );




                -----------------------------------------Registrar Manifiesto ---------------------------------------------------------------------------
                SET @CourierID =
                (
                    SELECT TOP 1
                           sr.ID
                    FROM DeliveryBackOffice.dbo.SenderReceiver sr WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.LogTokenPOD ltp WITH (NOLOCK)
                            ON  ltp.IdCourierman = sr.ID
                               --AND ltp.RowStatus = 1
                               WHERE ltp.LogTokenPOD = @Token 
                );

                INSERT INTO [dbo].[CourierPickupManifest]
                (
                    [ManifestSerie],
                    [SenderReceiverId],
                    [ManifestURL],
                    [RowStatus],
                    [TokenCreated],
                    [DateCreated],
                    [TokenUpdated],
                    [DateUpdated]
                )
                VALUES
                (@ManifestSerie, @CourierID, NULL, 1, @Token, GETDATE(), NULL, NULL);
                
                DECLARE @IdManifest AS BIGINT = SCOPE_IDENTITY();

                SET @ManifestNumber = @IdManifest;

                INSERT INTO [dbo].[CourierPickupManifestDetail]
                (
                    [ManifestId],
                    [GuideSerie],
                    [GuideNumber],
                    [PieceNumber],
                    [TokenCreated],
                    [DateCreated],
                    [TokenUpdated],
                    [DateUpdated],
                    [RowStatus]
                )
                SELECT @IdManifest,
                       lg.ItemSerie,
                       lg.ItemNumber,
                       lg.ItemPiece,
                       @Token,
                       GETDATE(),
                       NULL,
                       NULL,
                       1
                FROM #listGuides lg;

                SET @CodeOfReference =
                (
                    SELECT TOP 1
                           schp.SenderId
                    FROM DeliveryBackOffice.dbo.SchedulePickup schp WITH (NOLOCK)
                    WHERE schp.SchedulePickupId = @IdPickup
                          AND schp.RowStatus = 1
                    ORDER BY schp.DateCreated ASC
                );


                ---------------------UPDATE VISIT POINT-------------------------

                IF (ISNULL(@CodeOfReference, 0) != 0)
                BEGIN

                    DECLARE @VPLatitude NVARCHAR(20);
                    DECLARE @VPLongitude NVARCHAR(20);

                    SELECT @VPLatitude = vpc.Latitude,
                           @VPLongitude = vpc.Longitude
                    FROM VisitPointClient vpc WITH (NOLOCK)
                    WHERE vpc.CodeOfReference = @CodeOfReference;

                    IF (
                           RTRIM(LTRIM(ISNULL(@VPLatitude, ''))) <> ''
                           AND RTRIM(LTRIM(ISNULL(@VPLongitude, ''))) <> ''
                       )
                    BEGIN

                        -- Punto de visita con ubicación existente
                        IF (
                               RTRIM(LTRIM(ISNULL(@FixedLatitude, ''))) <> ''
                               AND RTRIM(LTRIM(ISNULL(@FixedLongitude, ''))) <> ''
                           )
                        BEGIN

                            -- Si existe una ubicación para registrar
                            -- Distancia (en metros) entre recolección y el punto de visita
                            -- Se coloca en 10 metros para evitar actualizar puntos de visita con ubicación correcta
                            IF ((geography::STPointFromText(
                                                               CONCAT('POINT (', @VPLongitude, ' ', @VPLatitude, ')'),
                                                               4326
                                                           ).STDistance(geography::STPointFromText(
                                                                                                      CONCAT(
                                                                                                                'POINT (',
                                                                                                                @FixedLongitude,
                                                                                                                ' ',
                                                                                                                @FixedLatitude,
                                                                                                                ')'
                                                                                                            ),
                                                                                                      4326
                                                                                                  )
                                                                       )
                                ) > 10
                               )
                            BEGIN
                                -- Si la distancia es mayor a 10 metros
                                -- Guardar última ubicación
                                UPDATE [DeliveryBackOffice].[dbo].[VisitPointClient]
                                SET LogLatitude = Latitude,
                                    LogLongitude = Longitude,
                                    TokenUpdated = @Token,
                                    DateUpdated = GETDATE()
                                WHERE CodeOfReference = @CodeOfReference;

                                -- Guardar nueva ubicación de recolección
                                UPDATE [DeliveryBackOffice].[dbo].[VisitPointClient]
                                SET Latitude = @FixedLatitude,
                                    Longitude = @FixedLongitude,
                                    TokenUpdated = @Token,
                                    DateUpdated = GETDATE()
                                WHERE CodeOfReference = @CodeOfReference;

                            END;
                            ELSE
                            BEGIN
                                -- Guardar nueva ubicación de recolección en "bitácora" para revisión
                                UPDATE [DeliveryBackOffice].[dbo].[VisitPointClient]
                                SET LogLatitude = @FixedLatitude,
                                    LogLongitude = @FixedLongitude,
                                    TokenUpdated = @Token,
                                    DateUpdated = GETDATE()
                                WHERE CodeOfReference = @CodeOfReference;

                            END;
                        END;

                    END;
                    ELSE
                    BEGIN

                        -- Punto de visita sin ubicación registrada
                        IF (
                               RTRIM(LTRIM(ISNULL(@FixedLatitude, ''))) <> ''
                               AND RTRIM(LTRIM(ISNULL(@FixedLongitude, ''))) <> ''
                           )
                        BEGIN

                            -- Si existe una ubicación para registrar
                            UPDATE [DeliveryBackOffice].[dbo].[VisitPointClient]
                            SET Latitude = @FixedLatitude,
                                Longitude = @FixedLongitude,
                                TokenUpdated = @Token,
                                DateUpdated = GETDATE()
                            WHERE CodeOfReference = @CodeOfReference;

                        END;
                    END;
                END;
                ----------------------------------------------------------------
                --------------PROCESSGUIDECOD.INI
                --HW-67
                -- variable para obtener el módulo de origen de los datos
                DECLARE @DataOriginId INT;
                -- variable para asignar el nombre del módulo del cuál se desea obtener su id
                DECLARE @ModName NVARCHAR(50);
                -- asignar valor a la variable ModName
                SET @ModName = N'Courier App';

                SELECT TOP 1
                       @DataOriginId = cm.ModIdModule
                  FROM DeliveryBackOffice.dbo.CatModule cm WITH (NOLOCK)
                 WHERE cm.ModName = @ModName;

                INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD
                (
                    GuideSerie,
                    GuideNumber,
                    CourierManId,
                    DataOriginId,
                    Token,
                    CustomerId,
                    Date
                )
                OUTPUT inserted.GuideSerie,
                       inserted.GuideNumber,
                       inserted.IdProcessedGuideCOD
                  INTO #InsertedRecords
                SELECT DISTINCT
                       lge.ItemSerie GuideSerie,
                       lge.ItemNumber GuideNumber,
                       (
                         SELECT TOP 1
                                IdCourierman
                           FROM DeliveryBackOffice.dbo.LogTokenPOD WITH (NOLOCK)
                          WHERE LogTokenPOD = @Token
                       ) AS 'CourierManId',
                       @DataOriginId AS 'DataOriginId',
                       @Token UserCreated,
                       cus.IdCustomer CustomerId,
                       GETDATE()
                FROM #listGuides lge
                     INNER JOIN dbo.DeliveryOrder dlo WITH (NOLOCK)
                         ON lge.ItemSerie = dlo.Guide_Serie
                            AND lge.ItemNumber = dlo.Guide_Number
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
                       dlo.Collect_OnDelivery = 0
                       AND dlo.IsCollect = 'false'
                       AND DOP.TimePlaId = 2
                      )
                      AND pcd.IdProcessedGuideCOD IS NULL;

                  --------------PROCESSGUIDECOD.FIN
                  -- Retornar resultado en formato json
            END TRY
            BEGIN CATCH
                ROLLBACK TRANSACTION;
                SELECT ERROR_MESSAGE();
                -- retornar mensaje de error

                    SELECT IdResult AS IdResult, 
                            ERROR_MESSAGE() AS [Message] 
                    FROM @responsemessage
                    WHERE Id = 'Invalid'


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
                (CAST(ERROR_MESSAGE() AS VARCHAR(300)), ERROR_NUMBER(), CAST(ERROR_PROCEDURE() AS VARCHAR(100)),
                 ERROR_LINE(), 0, 0, 'SetFinishPickup', GETDATE());

                IF OBJECT_ID('tempdb.dbo.#InsertedRecords', 'U') IS NOT NULL
                DROP TABLE #InsertedRecords;

            END CATCH;

            IF @@TRANCOUNT > 0
            BEGIN
                DECLARE @BatchStatus INT = 0;

                BEGIN TRY

                    BEGIN TRAN Detail_SetFinishPickUpBatch


                       SET @BatchStatus =
                       (
                           SELECT IdServiceStatus
                           FROM CatServiceStatus WITH (NOLOCK)
                           WHERE Name = 'Recolectado'
                       )

                       UPDATE FinishPickUpHeader
                          SET ServiceStatusId = @BatchStatus,
                              TokenUpdated = 'SYS-GetProcessBatchPOD',
                              DateUpdated = GETDATE()
                        WHERE SchedulePickupId = @IdPickup
                       
                       UPDATE FinishPickUpDetail
                          SET TokenUpdated = 'SYS-GetProcessBatchPOD',
                              DateUpdated = GETDATE()
                       WHERE SchedulePickupId = @IdPickup

                        UPDATE FinishPickUpContainerDetail
                          SET TokenUpdate = 'SYS-GetProcessBatchPOD',
                              DateUpdate = GETDATE()
                       WHERE SchedulePickupId = @IdPickup

                        UPDATE FinishPickUpReferenceDetail
                          SET TokenUpdated = 'SYS-GetProcessBatchPOD',
                              DateUpdated = GETDATE()
                       WHERE SchedulePickupId = @IdPickup

                       UPDATE PG
                          SET IsCompleted = 1
                         FROM DeliveryBackOffice.dbo.ProcessedGuideCOD PG  WITH(NOLOCK)
                              INNER JOIN #InsertedRecords IR
                                 ON PG.GuideSerie = IR.GuideSerie
                                     AND PG.GuideNumber = IR.GuideNumber
                        WHERE PG.IdProcessedGuideCOD = IR.IdProcessedGuideCOD;

                       SELECT 200 AS StatusCode,
                              'Se procesaron las guías con exito' AS [Message],
                              @Token AS Token,
                              @PickUpEmail AS Email


                       -- CORREO A ENVIAR MANIFIESTO

                       -- DATOS DEL MANIFIESTO A GENERAR
                       SELECT @ManifestNumber AS 'IdManifest',
                              @ManifestSerie AS 'Manifest_Serie',
                              @ManifestNumber AS 'Manifest_Number',
                              slp.SenderName AS 'Sender_FirstName',
                              slp.AddressPickup AS 'Sender_Address',
                              ISNULL(vpc.Zone, '') AS 'Sender_Zone',
                              ISNULL(vpc.Town, '') AS 'Sender_Town',
                              ISNULL(vpc.Department, '') AS 'Sender_Department',
                              0 AS 'Consolidated_Number',
                              ISNULL(vpc.Email, '') AS 'Sender_Email'
                       FROM DeliveryBackOffice.dbo.SchedulePickup slp WITH (NOLOCK)
                           RIGHT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
                               ON vpc.CodeOfReference = slp.SenderId
                       WHERE slp.SchedulePickupId = @IdPickup;

                       -- DETALLE DE LAS GUIAS RECOLECTADAS
                       WITH GUIDEMONITOR (GuideNumber, PiecesColdCounter, PiecesDryCounter, TotalPieces)
                       AS (
                           SELECT COALESCE(dop.GuideNumber, dop2.GuideNumber) GuideNumber,
                                  COUNT(dop.GuideNumber) 'PiecesColdCounter',
                                  COUNT(dop2.GuideNumber) 'PiecesDryCounter',
                                  COUNT(dop.NoPiece) + COUNT(dop2.NoPiece) 'TotalPieces'
                           FROM #listGuides lp
                               LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH (NOLOCK)
                                   ON lp.ItemSerie = dop.GuideSerie
                                      AND lp.ItemNumber = dop.GuideNumber
                                      AND lp.ItemPiece = dop.NoPiece
                                      AND dop.IsDry = 0
                               LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop2 WITH (NOLOCK)
                                   ON lp.ItemSerie = dop2.GuideSerie
                                      AND lp.ItemNumber = dop2.GuideNumber
                                      AND lp.ItemPiece = dop2.NoPiece
                                      AND dop2.IsDry = 1
                           GROUP BY dop.GuideNumber,
                                    dop2.GuideNumber
                       )

                       SELECT COUNT(GM.GuideNumber) 'GuidesCounter',
                              SUM(GM.PiecesColdCounter) 'PiecesColdCounter',
                              SUM(GM.PiecesDryCounter) 'PiecesDryCounter',
                              SUM(GM.TotalPieces) 'TotalPieces'
                       FROM GUIDEMONITOR GM;

                       -- DETALLE DE LAS PIEZAS DE LAS GUIAS RECOLECTADAS
                       SELECT CONCAT(dop.GuideSerie, dop.GuideNumber, '-', dop.NoPiece) [Piece],
                              CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName)  [ReceiverName],
                              LEFT(do.Receiver_Address, 200)                             [ReceiverAddress],
                              ISNULL(do.ReceiverCountryId,'GT')                         [ReceiverCountryId]
                       FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH (NOLOCK)
                           INNER JOIN #listGuides lp
                               ON lp.ItemSerie = dop.GuideSerie
                                  AND lp.ItemNumber = dop.GuideNumber
                           INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                               ON do.Guide_Serie = dop.GuideSerie
                                  AND do.Guide_Number = dop.GuideNumber
                       GROUP BY dop.GuideNumber,
                                dop.GuideSerie,
                                dop.NoPiece,
                                do.Receiver_FirstName,
                                do.Receiver_LastName,
                                do.Receiver_Address,
                                do.ReceiverCountryId
                       ORDER BY dop.GuideNumber ASC;

                    COMMIT TRAN Detail_SetFinishPickUpBatch
                END TRY
                BEGIN CATCH
                     ROLLBACK TRAN detail

                        SELECT CONVERT(VARCHAR, IdResult) AS IdResult, 
                            ERROR_MESSAGE() AS [Message] 
                        FROM @responsemessage
                        WHERE Id = 'Invalid'

                END CATCH

               COMMIT TRANSACTION;
            END;

        END;

        ELSE IF (@test > 0)
        BEGIN

            SELECT 'IdResult' AS IdResult,
					Guide,
					Message
            FROM #Temp
            WHERE Guide IN
                    (
                        SELECT Guide FROM #Temp
                    )

        END;

    -- Destruir tablas temporales
    IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
        DROP TABLE #listGuides;

    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
        DROP TABLE #Temp;

    IF OBJECT_ID('tempdb.dbo.#InsertedRecords', 'U') IS NOT NULL
        DROP TABLE #InsertedRecords;

    -- Retornar resultado en formato json
END;