-- =============================================
-- Author:		<Bidcar,Herrera>
-- Create date: <2023-09-12>
-- Description:	<Obtener datos para Sistema de Control de Calidad>
-- =============================================
-- Author:	 <Brandon, Pedroza>
-- Modified: <2024-08-06>
-- Description:	<Se agrega parametro para filtrar incidencias por pais>
-- =============================================
-- Author:	 <Brandon, Pedroza>
-- Modified: <2024-08-06>
-- Description:	<Se devuelven simbolo de moneda para precio de envio y COD>
-- =============================================
-- Author:	 <Brandon, Pedroza>
-- Modified: <2024-08-14>
-- Description:	<Se agrega validacion para mostrar guia sin tomar en cuenta filtro del pais>
-- =============================================
-- =============================================
-- Author:	 <Cristian Suazo>
-- Modified: <2025-01-24>
-- Description:	<Se agrega el parametro de ticketNumber para el proyecto de temu>
-- =============================================
-- Author:	 <Walter Orozco>
-- Modified: <2025-05-12>
-- Description:	<Se realizan mejoras de multimoneda para proyecto de SV.>
-- =============================================
-- Author:	 <Bilkar Morataya>
-- Modified: <2025-04-15>
-- Description:	<Se agregan incidencias del portal EXC/CNC (SystemOrigin = 5) para Control de Calidad.>
-- Description:	<Se cambia LGN_LogByToken por TokenLog + RegisterUser + Person para mostrar nombre completo del usuario.>
-- =============================================
CREATE PROCEDURE [dbo].[GetQualityControlData] --BNHL
    @GuideSerie NVARCHAR(2) = '',
    @GuideNumber INT,
    @TblHubLogistic TblHubLogistic READONLY,
    @TblCustomerType TblCustomerType READONLY,
    @TblCustomer TblCustomer READONLY,
    @TblVisitPointClient TblVisitPointClient READONLY,
    @TblIncidenceType TblIncidenceType READONLY,
    @IdCountry AS NVARCHAR(2) = 'GT',
    @TicketNumber NVARCHAR(300) = NULL
AS
BEGIN
    SET ARITHABORT ON;
    BEGIN TRY
        --contadores en ruta y entregadas
        DECLARE @Pending_Counter INT = 0,
                @Delivered_Counter INT = 0;

        /**********************************************************************************************************************************
        ************************************************** CONSTRUCCION DETALLE ***********************************************************
        ***********************************************************************************************************************************/

        --tabla temporal gu�as a procesar?
        IF OBJECT_ID('tempdb.dbo.#TodaysCheckpointsDetail', 'U') IS NOT NULL
            DROP TABLE #TodaysCheckpointsDetail;

        --tabla temporal para mostrar los datos
        IF OBJECT_ID('tempdb.dbo.#DetailGetQualityControlData ', 'U') IS NOT NULL
            DROP TABLE #DetailGetQualityControlData;

        CREATE TABLE #DetailGetQualityControlData
        (
            Pending INT,
            [Delivered] INT,
            [ConfirmationIncidents] INT,
            [UnConfirmationIncidents] INT,
            [ID] BIGINT,
            [ID_Courier] INT,
            [Date_Received] DATETIME,
            [IdRoute] INT,
            [ID_Incident] INT,
            [IdUser] INT,
            [Username] NVARCHAR(50),
            [RouteDescription] NVARCHAR(200),
            [User] NVARCHAR(100),
            [GuideSerie] NVARCHAR(2),
            [GuideNumber] INT,
            [Ticket_Number] NVARCHAR(300),
            [SenderName] NVARCHAR(150),
            [ReceiverName] NVARCHAR(150),
            [SenderPhone] NVARCHAR(150),
            [ReceiverPhone] NVARCHAR(100),
            [ReceiverAddress] NVARCHAR(600),
            [TypeOfIncident] NVARCHAR(50),
            [Incident] NVARCHAR(50),
            [EventDate] DATETIME,
            [Attempts] NVARCHAR(10),
            [PriceShippment] DECIMAL(14, 2),
            [CollectOnDelivery] DECIMAL(14, 2),
            [OrderDescription] NVARCHAR(50),
            [StatusOfIncident] NVARCHAR(50),
            [IdHubLogistic] INT,
            [Pendiente] INT,
            [CourierPhone] NVARCHAR(50),
            [Customer] INT,
            [CodeOfReference] NVARCHAR(50),
            [CustomerType] INT,
            [IdIncidenceType] INT,
            [ShippmentCurrencySymbol] NVARCHAR(2),
            [CODCurrencySymbol] NVARCHAR(2)
        );

        CREATE NONCLUSTERED INDEX IX_DetailGetQualityControlData_ConfirmationIncidents
        ON #DetailGetQualityControlData (UnConfirmationIncidents);

        CREATE NONCLUSTERED INDEX IX_ConfirmationIncidents_ControlData
        ON #DetailGetQualityControlData (ConfirmationIncidents);

        CREATE TABLE #TodaysCheckpointsDetail
        (
            [GuideSerie] NVARCHAR(2),
            [GuideNumber] INT,
            [DateCheckpoint] DATETIME,
            [DateCreatedInSystem] DATETIME,
            [Statusorderid] INT,
            [SystemOrigin] INT,
            [DeliveryAttemptId] INT,
            [UserCreated] NVARCHAR(50),
            [SettlementID] INT,
            [Settlement_IdCourier] INT,
            [Settlement_CatRouteId] INT,
            [Settlement_Date_Received] DATETIME
        );

        CREATE CLUSTERED INDEX CX_TodaysCheckpointsDetail
        ON #TodaysCheckpointsDetail (
                                        GuideSerie,
                                        GuideNumber
                                    );

        CREATE NONCLUSTERED INDEX IX_IdStatusDetail
        ON #TodaysCheckpointsDetail (Statusorderid);

        CREATE NONCLUSTERED INDEX IX_DeliveryAttemptIdDetail
        ON #TodaysCheckpointsDetail (DeliveryAttemptId);

        CREATE NONCLUSTERED INDEX IX_Settlement_IdCourierDetail
        ON #TodaysCheckpointsDetail (Settlement_IdCourier);

        SET @Pending_Counter = 0;
        SET @Delivered_Counter = 0;


        IF @TicketNumber != ''
        BEGIN
            SELECT @GuideNumber = Guide_Number,
                   @GuideSerie = Guide_Serie
            FROM DeliveryOrder WITH (NOLOCK)
            WHERE Ticket_Number = @TicketNumber;
        END;

        SELECT @Pending_Counter = COUNT(   CASE
                                               WHEN ord.StatusOrderId NOT IN ( 5, 24, 25, 22 ) THEN
                                                   ord.Guide_Number
                                               ELSE
                                                   NULL
                                           END
                                       ),
               @Delivered_Counter = COUNT(   CASE
                                                 WHEN ord.StatusOrderId IN ( 5, 24, 25, 22 ) THEN
                                                     ord.Guide_Number
                                                 ELSE
                                                     NULL
                                             END
                                         )
        FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] ds WITH (NOLOCK)
                ON dsd.ID_DeliveryOrderBySettlement = ds.ID
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] ord WITH (NOLOCK)
                ON ord.Guide_Serie = dsd.Guide_Serie
                   AND ord.Guide_Number = dsd.Guide_Number
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township] tw WITH (NOLOCK)
                ON tw.IdTownship = ord.ReceiverIdTownship
            OUTER APPLY
        (
            SELECT TOP 1
                   HBL.IdHubLogistic
            FROM dbo.DumpServiceCoverage dum WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                    ON dum.Hub = HBL.HubAbbreviation
            WHERE dum.HeaderCode = tw.HeaderCode
                  AND HBL.HubStatus = 1
        ) HUbs
        WHERE dsd.DateCreated >= CONVERT(DATE, GETDATE())
              AND dsd.DateCreated < DATEADD(DAY, 1, CONVERT(DATE, GETDATE()))
              AND ord.StatusOrderId NOT IN ( 45, 50 )
              AND dsd.RowStatus = 1
              AND
              (
                  dsd.Guide_Settlement = 0
                  OR dsd.Guide_Settlement IS NULL
              )
              AND
              (
                  NOT EXISTS
        (
            SELECT 1 FROM @TblHubLogistic
        )
                  OR HUbs.IdHubLogistic IN
                     (
                         SELECT IdHubLogistics FROM @TblHubLogistic
                     )
              )
              AND ord.SenderCountryId = @IdCountry
        OPTION (RECOMPILE);

        PRINT '@Pending_Counter';
        PRINT @Pending_Counter;
        PRINT '@Delivered_Counter';
        PRINT @Delivered_Counter;

        --Insertar guias despachadas
        INSERT INTO #TodaysCheckpointsDetail
        SELECT gdd.Guide_Serie,
               gdd.Guide_Number,
               gdd.DateCreated,
               gdd.DateCreatedInSystem,
               gdd.StatusOrderId,
               gdd.SystemOrigin,
               gdd.DeliveryAttemptId,
               gdd.UserCreated,
               ds.ID SettlementID,
               ds.ID_Courier,
               ds.CatRouteId,
               ds.Date_Received
        FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] ds WITH (NOLOCK)
                ON dsd.ID_DeliveryOrderBySettlement = ds.ID
            INNER JOIN dbo.DeliveryOrder DOR WITH (NOLOCK)
                ON DOR.Guide_Serie = dsd.Guide_Serie
                   AND DOR.Guide_Number = dsd.Guide_Number
            OUTER APPLY
        (
            SELECT TOP 1
                   ordd.Guide_Serie,
                   ordd.Guide_Number,
                   ordd.DateCreated,
                   ordd.DateCreatedInSystem,
                   ordd.StatusOrderId,
                   ordd.SystemOrigin,
                   ordd.DeliveryAttemptId,
                   ordd.UserCreated,
                   ord.SenderCountryId
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] ordd WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] ord WITH (NOLOCK)
                    ON ordd.Guide_Serie = ord.Guide_Serie
                       AND ordd.Guide_Number = ord.Guide_Number
            WHERE dsd.Guide_Serie = ordd.Guide_Serie
                  AND dsd.Guide_Number = ordd.Guide_Number
            ORDER BY DateCreated DESC
        ) gdd
        WHERE dsd.DateCreated >= CONVERT(DATE, GETDATE())
              AND dsd.DateCreated < DATEADD(DAY, 1, CONVERT(DATE, GETDATE()))
              AND dsd.RowStatus = 1
              AND DOR.StatusOrderId IN ( 45, 50 ) --solo incidencias confirmadas y pendientes para el detalle		   
              AND
              (
                  (
                      @GuideNumber = 0
                      AND DOR.SenderCountryId = @IdCountry
                  )
                  OR
                  (
                      DOR.Guide_Serie = @GuideSerie
                      AND DOR.Guide_Number = @GuideNumber
                  )
              )
        OPTION (RECOMPILE);

        --Insertar incidencias de escritorio
        INSERT INTO #TodaysCheckpointsDetail
        SELECT Guide_Serie,
               Guide_Number,
               DateCreated,
               DateCreatedInSystem,
               StatusOrderId,
               SystemOrigin,
               DeliveryAttemptId,
               UserCreated,
               ID,
               ID_Courier,
               CatRouteId,
               Date_Received
        FROM
        (
            SELECT A3.Guide_Serie,
                   A3.Guide_Number,
                   A3.DateCreated,
                   A3.DateCreatedInSystem,
                   A3.StatusOrderId,
                   A3.SystemOrigin,
                   A3.DeliveryAttemptId,
                   A3.UserCreated,
                   ds.ID,
                   ds.ID_Courier,
                   ds.CatRouteId,
                   ds.Date_Received,
                   ROW_NUMBER() OVER (PARTITION BY A3.Guide_Serie,
                                                   A3.Guide_Number
                                      ORDER BY A3.DateCreated DESC,
                                               dsd.DateCreated DESC
                                     ) AS rn
            FROM dbo.ConfirmationOfIncidence A1 WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt A2 WITH (NOLOCK)
                    ON A1.IdConfirmationOfIncidence = A2.ConfirmationOfIncidenceId
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail A3 WITH (NOLOCK)
                    ON A3.DeliveryAttemptId = A2.ID
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder A4 WITH (NOLOCK)
                    ON A4.Guide_Serie = A3.Guide_Serie
                       AND A4.Guide_Number = A3.Guide_Number
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)
                    ON dsd.Guide_Serie = A4.Guide_Serie
                       AND dsd.Guide_Number = A4.Guide_Number
                       AND dsd.RowStatus = 1
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] ds WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
            WHERE CAST(A1.DateStatusOrder AS DATE) = CAST(GETDATE() AS DATE)
                  AND A1.StatusOrderId IN ( 45, 50 )
                  AND A1.RowStatus = 1
                  AND A3.RowStatus = 1
                  AND A3.StatusOrderId IN ( 45, 50 ) --solo incidencias confirmadas y pendientes del dia de hoy para el detalle
                  AND A3.SystemOrigin IN (2, 5) --incidencias de desktop y portal EXC/CNC                 
				AND
                  (
                      (
                          @GuideNumber = 0
                          AND A4.SenderCountryId = @IdCountry
                      )
                      OR
                      (
                          A4.Guide_Serie = @GuideSerie
                          AND A4.Guide_Number = @GuideNumber
                      )
                  )        ) INCDESKT
        WHERE INCDESKT.rn = 1;

        INSERT INTO #DetailGetQualityControlData
        SELECT 0 [Pending],
               0 [Delivered],
               (CASE
                    WHEN [da].[ID] IS NOT NULL
                         AND coi.IsConfirmed = 1 THEN
                        1
                    ELSE
                        0
                END
               ) [ConfirmationIncidents],
               (CASE
                    WHEN coi.IsConfirmed = 0
                         AND
                         (
                             (
                                 [da].[ID] IS NOT NULL
                                 AND SystemOrigin IN ( 3 )
                             )
                             OR
                             (
                                 ord.StatusOrderId IN ( 45 )
                                 AND SystemOrigin IN ( 2, 5 )
                             )
                         ) THEN
                        1
                    ELSE
                        0
                END
               ) [UnConfirmationIncidents],
               ISNULL(TCD.SettlementID, 0) [ID],
               ISNULL(TCD.Settlement_IdCourier, 0) [ID_Courier],
               TCD.Settlement_Date_Received [Date_Received],
               da.ID_Incident [Id_Incident],
               ISNULL(TCD.Settlement_CatRouteId, 0) [IdRoute],
               (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        tk2.SSN_IdUser
                    WHEN TCD.SystemOrigin = 5 THEN
                        TKL.TknIdUser
                    ELSE
                        NULL
                END
               ) [IdUser],
               (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        tk2.SSN_Username
                    WHEN TCD.SystemOrigin = 5 THEN
                        IIF(PER.PerFirstName IS NOT NULL OR PER.PerLastName IS NOT NULL, 
                            NULL, 
                            ISNULL(RUS.UsrNickName, 'EXC/CNC'))
                    ELSE
                        NULL
                END
               ) [Username],
               (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        'Usuario Desktop'
                    WHEN TCD.SystemOrigin = 5 THEN
                        'Usuario Portal EXC/CNC'
                    ELSE
                        'Vendedor Rutero'
                END
               ) [RouteDescription],
               (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        NULL
                    WHEN TCD.SystemOrigin = 5 THEN
                        IIF(PER.PerFirstName IS NOT NULL OR PER.PerLastName IS NOT NULL,
                            RTRIM(LTRIM(CONCAT(ISNULL(PER.PerFirstName, ''), ' ', ISNULL(PER.PerLastName, '')))),
                            NULL)
                    ELSE
                        CONCAT(COALESCE(sr.First_Name, ''), ' ', COALESCE(sr.Last_Name, ''))
                END
               ) [User],
               ord.Guide_Serie [GuideSerie],
               ord.Guide_Number [GuideNumber],
               ord.Ticket_Number,
               CONCAT(   CASE
                             WHEN imp.CodeOfReference > 0 THEN
                                 imp.DescriptionOfClient + '/'
                             ELSE
                                 ''
                         END,
                         CASE
                             WHEN imp.CodeOfReference > 0 THEN
                                 ord.Sender_FirstName + ord.Sender_LastName
                             ELSE
                                 vpc.DescriptionOfClient
                         END
                     ) [SenderName],
               COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [ReceiverName],
               ord.Sender_Phone [SenderPhone],
               ord.Receiver_Phone [ReceiverPhone],
               ord.Receiver_Address [ReceiverAddress],
               ISNULL(cic.IncidenceTypeName, '') [TypeOfIncident],
               cti.NameIncidence [Incident],
               TCD.DateCheckpoint [EventDate],
               (CASE
                    WHEN cti.NameIncidence IS NULL THEN
                        NULL
                    ELSE
                        CONCAT(
                                  CONVERT(
                                             NVARCHAR(4),
                                             IIF(atd.GuideDeliveryAttemptCount = atd.GuideDeliveryMaxAttemptCount,
                                                 atd.GuideDeliveryAttemptCount,
                                                 IIF(cti.IncidenceClasificationId <> 1,
                                                     atd.GuideDeliveryAttemptCount,
                                                     atd.GuideDeliveryAttemptCount + 1))
                                         ),
                                  '/',
                                  CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                              )
                END
               ) [Attempts],
               ord.PriceShippment [PriceShippment],
               ord.Collect_OnDelivery [CollectOnDelivery],
               std.OrderDescription [OrderDescription],
               (CASE
                    WHEN coi.IsConfirmed IS NULL THEN
                        NULL
                    WHEN coi.IsConfirmed = 0 THEN
                        'Pendiente'
                    ELSE
               (CASE
                    WHEN coi.IsDenied = 1 THEN
                        'Rechazada'
                    ELSE
                        'Aprobada'
                END
               )
                END
               ) [StatusOfIncident],
               HUbs.IdHubLogistic [IdHubLogistic],
               (CASE
                    WHEN TCD.Statusorderid = 4 THEN
                        1
                    ELSE
                        0
                END
               ) [Pendiente],
               sr.Phone [CourierPhone],
               cus.IdCustomer [Customer],
               vpc.CodeOfReference [CodeOfReference],
               cus.IdCustomerType [CustomerType],
               cti.IdIncidenceType [IdIncidenceType],
               cur.Symbol [ShippmentCurrencySymbol],
               curCOD.Symbol [CODCurrencySymbol]
        FROM #TodaysCheckpointsDetail TCD
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] ord WITH (NOLOCK)
                ON ord.Guide_Serie = TCD.GuideSerie
                   AND ord.Guide_Number = TCD.GuideNumber
            INNER JOIN [DeliveryBackOffice].[dbo].[Cost] co WITH (NOLOCK)
                ON ord.Guide_Serie = co.GuideSerie
                   AND ord.Guide_Number = co.GuideNumber
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD] cur WITH (NOLOCK)
                ON ISNULL(co.ShippingCurrency, 1) = cur.IdCatCurrencyCOD
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD] curCOD WITH (NOLOCK)
                ON ISNULL(co.CodCurrency, co.ShippingCurrency) = curCOD.IdCatCurrencyCOD
            LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
                ON vpc.CodeOfReference = ord.Sender_ID
            LEFT JOIN dbo.VisitPointClient imp WITH (NOLOCK)
                ON imp.CodeOfReference = ord.OriginSenderId
            LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] cus WITH (NOLOCK)
                ON cus.IdCustomer = vpc.CustomerID
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township] tw WITH (NOLOCK)
                ON tw.IdTownship = ord.ReceiverIdTownship
            LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder] std WITH (NOLOCK)
                ON std.StatusOrderId = TCD.Statusorderid
            OUTER APPLY
        (
            SELECT TOP 1
                   HBL.IdHubLogistic
            FROM dbo.DumpServiceCoverage dum WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                    ON dum.Hub = HBL.HubAbbreviation
            WHERE dum.HeaderCode = tw.HeaderCode
                  AND HBL.HubStatus = 1
        ) HUbs
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] da WITH (NOLOCK)
                ON [da].[ID] = TCD.[DeliveryAttemptId]
            -- Desktop (SystemOrigin = 2): usa LGN_LogByToken
            LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk2 WITH (NOLOCK)
                ON tk2.SSN_IdToken = CONVERT(VARCHAR(50), da.User_Created)
            -- Portal EXC/CNC (SystemOrigin = 5): usa TokenLog + RegisterUser + Person
            LEFT JOIN DeliveryBackOffice.dbo.TokenLog TKL WITH (NOLOCK)
                ON TKL.TknIdToken = CONVERT(VARCHAR(50), da.User_Created)
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser RUS WITH (NOLOCK)
                ON RUS.UsrIdUser = TKL.TknIdUser
            LEFT JOIN DeliveryBackOffice.dbo.Person PER WITH (NOLOCK)
                ON PER.PerIdPerson = RUS.UsrIdPerson
            LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] coi WITH (NOLOCK)
                ON [coi].[IdConfirmationOfIncidence] = [da].[ConfirmationOfIncidenceId]
                   AND coi.RowStatus = 1
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence] cti WITH (NOLOCK)
                ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification] cic WITH (NOLOCK)
                ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] sr WITH (NOLOCK)
                ON sr.ID = TCD.Settlement_IdCourier
            LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                ON atd.GuideSerie = ord.Guide_Serie
                   AND atd.GuideNumber = ord.Guide_Number
        WHERE ord.IsLastMileReturn = 0 --NO INCLUIR DEVOLUCION
              AND
              (
                  NOT EXISTS
        (
            SELECT 1 FROM @TblHubLogistic
        )
                  OR HUbs.IdHubLogistic IN
                     (
                         SELECT IdHubLogistics FROM @TblHubLogistic
                     )
              )
              AND
              (
                  NOT EXISTS
        (
            SELECT 1 FROM @TblCustomerType
        )
                  OR cus.IdCustomerType IN
                     (
                         SELECT IdCustomerType FROM @TblCustomerType
                     )
              )
              AND
              (
                  NOT EXISTS
        (
            SELECT 1 FROM @TblVisitPointClient
        )
                  OR vpc.CodeOfReference IN
                     (
                         SELECT IdVisitPointClient FROM @TblVisitPointClient
                     )
              )
              AND
              (
                  NOT EXISTS
        (
            SELECT 1 FROM @TblIncidenceType WHERE IdIncidenceType <> 0
        )
                  OR cti.IdIncidenceType IN
                     (
                         SELECT IdIncidenceType FROM @TblIncidenceType WHERE IdIncidenceType <> 0
                     )
              )
              AND
              (
                  NOT EXISTS
        (
            SELECT 1 FROM @TblCustomer
        )
                  OR cus.IdCustomer IN
                     (
                         SELECT IdCustomer FROM @TblCustomer
                     )
              )
        OPTION (RECOMPILE);



        SELECT @Pending_Counter [Pending],
               @Delivered_Counter [Delivered],
               COUNT(   CASE
                            WHEN ConfirmationIncidents = 1 THEN
                                ConfirmationIncidents
                            ELSE
                                NULL
                        END
                    ) [ConfirmationIncidents],
               COUNT(   CASE
                            WHEN UnConfirmationIncidents = 1 THEN
                                UnConfirmationIncidents
                            ELSE
                                NULL
                        END
                    ) [UnConfirmationIncidents]
        FROM #DetailGetQualityControlData;

        SELECT TOP 100
               Pending,
               [Delivered],
               [ConfirmationIncidents],
               [UnConfirmationIncidents],
               [ID],
               [ID_Courier],
               [Date_Received],
               [IdRoute],
               [ID_Incident],
               [IdUser],
               [Username],
               [RouteDescription],
               [User],
               [GuideSerie],
               [GuideNumber],
               [Ticket_Number],
               [SenderName],
               [ReceiverName],
               [SenderPhone],
               [ReceiverPhone],
               [ReceiverAddress],
               [TypeOfIncident],
               [Incident],
               [EventDate],
               [Attempts],
               [PriceShippment],
               [CollectOnDelivery],
               [OrderDescription],
               [StatusOfIncident],
               [IdHubLogistic],
               [Pendiente],
               [CourierPhone],
               [Customer],
               [CodeOfReference],
               [CustomerType],
               [IdIncidenceType],
               [ShippmentCurrencySymbol],
               [CODCurrencySymbol]
        FROM #DetailGetQualityControlData
        WHERE UnConfirmationIncidents = 1
        UNION ALL
        SELECT TOP 100
               Pending,
               [Delivered],
               [ConfirmationIncidents],
               [UnConfirmationIncidents],
               [ID],
               [ID_Courier],
               [Date_Received],
               [IdRoute],
               [ID_Incident],
               [IdUser],
               [Username],
               [RouteDescription],
               [User],
               [GuideSerie],
               [GuideNumber],
               [Ticket_Number],
               [SenderName],
               [ReceiverName],
               [SenderPhone],
               [ReceiverPhone],
               [ReceiverAddress],
               [TypeOfIncident],
               [Incident],
               [EventDate],
               [Attempts],
               [PriceShippment],
               [CollectOnDelivery],
               [OrderDescription],
               [StatusOfIncident],
               [IdHubLogistic],
               [Pendiente],
               [CourierPhone],
               [Customer],
               [CodeOfReference],
               [CustomerType],
               [IdIncidenceType],
               [ShippmentCurrencySymbol],
               [CODCurrencySymbol]
        FROM #DetailGetQualityControlData
        WHERE ConfirmationIncidents = 1
        ORDER BY ConfirmationIncidents ASC,
                 EventDate ASC;

        IF OBJECT_ID('tempdb.dbo.#TodaysCheckpointsDetail', 'U') IS NOT NULL
            DROP TABLE #TodaysCheckpointsDetail;

    END TRY
    BEGIN CATCH

        SELECT CAST(0 AS BIT) AS 'boolResult',
               ERROR_MESSAGE() AS 'DescriptionResult',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';

    END CATCH;

END;