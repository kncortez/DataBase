-- =============================================
-- Author:		<Bidcar,Herrera>
-- Create date: <2023-09-12>
-- Description:	<Obtener datos para Sistema de Control de Calidad>
-- =============================================
CREATE PROCEDURE [dbo].[GetQualityControlData_mejorado]
    --DECLARE 
    @GuideSerie NVARCHAR(2) = ''
  , @GuideNumber INT = 0
  , @TblHubLogistic TblHubLogistic READONLY
  , @TblCustomerType TblCustomerType READONLY
  , @TblCustomer TblCustomer READONLY
  , @TblVisitPointClient TblVisitPointClient READONLY
  , @TblIncidenceType TblIncidenceType READONLY
AS
BEGIN
    SET ARITHABORT ON;
    BEGIN TRY

        /**********************************************************************************************************************************
		************************************************** CONSTRUCCION DETALLE ***********************************************************
		***********************************************************************************************************************************/
        DECLARE @FIlterByHub BIT = 0;
        SET @FIlterByHub =
        (
            SELECT TOP 1 1 FROM @TblHubLogistic
        );

        DECLARE @CurrentDateAsDatetime DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME);
        --set @CurrentDateAsDatetime ='2024-07-25 00:00:00.000'
        DECLARE @CurrentDateAsDatetimeFinishDay DATETIME = DATEADD(DAY, 1, @CurrentDateAsDatetime);
        DECLARE @CURRENTDATE DATE = CONVERT(DATE, @CurrentDateAsDatetime);

        IF OBJECT_ID('tempdb.dbo.#TodaysCheckpointsDetail', 'U') IS NOT NULL
            DROP TABLE #TodaysCheckpointsDetail;


        CREATE TABLE #TodaysCheckpointsDetail
        (
            [GuideSerie] NVARCHAR(2)
          , [GuideNumber] INT
          , [DateCheckpoint] DATETIME
          , [DateCreatedInSystem] DATETIME
          , [Statusorderid] INT
          , [SystemOrigin] INT
          , [DeliveryAttemptId] INT
          , [UserCreated] NVARCHAR(50)
          , [SettlementID] INT
          , [Settlement_IdCourier] INT
          , [Settlement_CatRouteId] INT
          , [Settlement_Date_Received] DATETIME
        );

        CREATE NONCLUSTERED INDEX IX_MiTablaTemporal_Columna1_Columna2
        ON #TodaysCheckpointsDetail (
                                        GuideSerie
                                      , GuideNumber
                                    );


        CREATE NONCLUSTERED INDEX IX_MiTablaTemporal_DeliveryAttemptId
        ON #TodaysCheckpointsDetail (DeliveryAttemptId);

        CREATE NONCLUSTERED INDEX IX_MiTablaTemporal_StatusOrderId
        ON #TodaysCheckpointsDetail (Statusorderid);




        INSERT INTO #TodaysCheckpointsDetail
        SELECT gdd.Guide_Serie
             , gdd.Guide_Number
             , gdd.DateCreated
             , gdd.DateCreatedInSystem
             , gdd.StatusOrderId
             , gdd.SystemOrigin
             , gdd.DeliveryAttemptId
             , gdd.UserCreated
             , ds.ID SettlementID
             , ds.ID_Courier
             , ds.CatRouteId
             , ds.Date_Received
        FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]            dsd WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] ds WITH (NOLOCK)
                ON dsd.ID_DeliveryOrderBySettlement = ds.ID
            OUTER APPLY
        (
            SELECT TOP 1
                   ordd.Guide_Serie
                 , ordd.Guide_Number
                 , ordd.DateCreated
                 , ordd.DateCreatedInSystem
                 , ordd.StatusOrderId
                 , ordd.SystemOrigin
                 , ordd.DeliveryAttemptId
                 , ordd.UserCreated
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] ordd WITH(NOLOCK)
            WHERE ordd.Guide_Serie = dsd.Guide_Serie
                  AND ordd.Guide_Number = dsd.Guide_Number
            ORDER BY DateCreated DESC
        )                                                                     gdd
        WHERE --dsd.DateCreated BETWEEN @CurrentDateAsDatetime AND @CurrentDateAsDatetimeFinishDay
			  CAST(dsd.datecreated AS DATE) = CAST(GETDATE() AS DATE)
              AND dsd.RowStatus = 1;





        WITH TodaysCheckpoints
        AS (SELECT ordd.Guide_Serie
                 , ordd.Guide_Number
                 , ordd.DateCreated
                 , ordd.DateCreatedInSystem
                 , ordd.StatusOrderId
                 , ordd.SystemOrigin
                 , ordd.DeliveryAttemptId
                 , ordd.UserCreated
                 , ds.ID
                 , ds.ID_Courier
                 , ds.CatRouteId
                 , ds.Date_Received
                 , ROW_NUMBER() OVER (PARTITION BY ordd.Guide_Serie
                                                 , ordd.Guide_Number
                                      ORDER BY ordd.DateCreated DESC
                                     ) AS rn
            FROM dbo.DeliveryOrderDetail                                         ordd WITH (NOLOCK)
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]  dsd WITH (NOLOCK)
                    ON dsd.Guide_Serie = ordd.Guide_Serie
                        AND
                        dsd.Guide_Number = ordd.Guide_Number
                       AND dsd.RowStatus = 1
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] ds WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
            WHERE --ordd.DateCreated  BETWEEN @CurrentDateAsDatetime AND @CurrentDateAsDatetimeFinishDay
                  CAST(ordd.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
				  AND ordd.StatusOrderId IN ( 45, 50 )
                  AND NOT EXISTS
            (
                SELECT 1
                FROM #TodaysCheckpointsDetail TCPD
                WHERE TCPD.GuideNumber = ordd.Guide_Number
                      AND TCPD.GuideSerie = ordd.Guide_Serie
            )
        --ORDER BY DATECREATED DESC

        )
        INSERT INTO #TodaysCheckpointsDetail
        SELECT Guide_Serie
             , Guide_Number
             , DateCreated
             , DateCreatedInSystem
             , StatusOrderId
             , SystemOrigin
             , DeliveryAttemptId
             , UserCreated
             , ID
             , ID_Courier
             , CatRouteId
             , Date_Received
        FROM TodaysCheckpoints
        WHERE rn = 1;














        SELECT COUNT(   CASE
                            WHEN TCD.Statusorderid = 4 THEN
                                1
                        END
                    ) [Pending]
             , COUNT(   CASE
                            WHEN TCD.Statusorderid IN ( 5, 24, 25 ) THEN
                                1
                        END
                    ) [Delivered]
             , COUNT(   CASE
                            WHEN coi.IsConfirmed = 1 THEN
                                1
                        END
                    ) [ConfirmationIncidents]
             , COUNT(   CASE
                            WHEN coi.IsConfirmed = 0
                                 AND
                                 (
                                     (
                                         [da].[ID] IS NOT NULL
                                         AND SystemOrigin IN ( 3 )
                                     )
                                     OR
                                     (
                                         TCD.Statusorderid IN ( 45 )
                                         AND SystemOrigin IN ( 2 )
                                     )
                                 ) THEN
                                1
                        END
                    ) [UnConfirmationIncidents]
        FROM #TodaysCheckpointsDetail                                      TCD
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder]          ord WITH (NOLOCK)
                ON ord.Guide_Serie = TCD.GuideSerie
                   AND ord.Guide_Number = TCD.GuideNumber
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]         da WITH (NOLOCK)
                ON [da].[ID] = TCD.[DeliveryAttemptId]
            LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] coi WITH (NOLOCK)
                ON [coi].[IdConfirmationOfIncidence] = [da].[ConfirmationOfIncidenceId]
        WHERE ord.IsLastMileReturn = 0; --NO INCLUIR DEVOLUCIÓN
        --and
        --TCD.statusorderid in (4,5,45,50,24,25)

        SELECT TOP 100
               (CASE
                    WHEN TCD.Statusorderid = 4
                         AND coi.IdConfirmationOfIncidence IS NULL THEN
                        1
                    ELSE
                        0
                END
               )                                                                                [Pending]
             , (CASE
                    WHEN TCD.Statusorderid IN ( 5, 24, 25 ) THEN
                        1
                    ELSE
                        0
                END
               )                                                                                [Delivered]
             , (CASE
                    WHEN [da].[ID] IS NOT NULL
                         AND coi.IsConfirmed = 1 THEN
                        1
                    ELSE
                        0
                END
               )                                                                                [ConfirmationIncidents]
             , (CASE
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
                                 AND SystemOrigin IN ( 2 )
                             )
                         ) THEN
                        1
                    ELSE
                        0
                END
               )                                                                                [UnConfirmationIncidents]
             , ISNULL(TCD.SettlementID, 0)                                                      [ID]
             , ISNULL(TCD.Settlement_IdCourier, 0)                                              [ID_Courier]
             , TCD.Settlement_Date_Received                                                     [Date_Received]
             , da.ID_Incident                                                                   [Id_Incident]
             , ISNULL(TCD.Settlement_CatRouteId, 0)                                             [IdRoute]
             , (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        tk2.SSN_IdUser
                    ELSE
                        NULL
                END
               )                                                                                [IdUser]
             , (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        tk2.SSN_Username
                    ELSE
                        NULL
                END
               )                                                                                [Username]
             , (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        'Usuario Desktop'
                    ELSE
                        'Vendedor Rutero'
                END
               )                                                                                [RouteDescription]
             , (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        NULL
                    ELSE
                        CONCAT(COALESCE(sr.First_Name, ''), ' ', COALESCE(sr.Last_Name, ''))
                END
               )                                                                                [User]
             , ord.Guide_Serie                                                                  [GuideSerie]
             , ord.Guide_Number                                                                 [GuideNumber]
             , CONCAT(   CASE
                             WHEN imp.CodeOfReference > 0 THEN
                                 imp.DescriptionOfClient + '/'
                             ELSE
                                 ''
                         END
                       , CASE
                             WHEN imp.CodeOfReference > 0 THEN
                                 cus.Name
                             ELSE
                                 vpc.DescriptionOfClient
                         END
                     )                                                                          [SenderName]
             , COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [ReceiverName]
             , ord.Sender_Phone                                                                 [SenderPhone]
             , ord.Receiver_Phone                                                               [ReceiverPhone]
             , ord.Receiver_Address                                                             [ReceiverAddress]
             , ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
             , cti.NameIncidence                                                                [Incident]
             , TCD.DateCheckpoint                                                               [EventDate]
             , (CASE
                    WHEN cti.NameIncidence IS NULL THEN
                        NULL
                    ELSE
                        CONCAT(
                                  CONVERT(
                                             NVARCHAR(4)
                                           , IIF(atd.GuideDeliveryAttemptCount = atd.GuideDeliveryMaxAttemptCount
                                               , atd.GuideDeliveryAttemptCount
                                               , IIF(cti.IncidenceClasificationId <> 1
                                                  , atd.GuideDeliveryAttemptCount
                                                  , atd.GuideDeliveryAttemptCount + 1))
                                         )
                                , '/'
                                , CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                              )
                END
               )                                                                                [Attempts]
             , ord.PriceShippment                                                               [PriceShippment]
             , ord.Collect_OnDelivery                                                           [CollectOnDelivery]
             , std.OrderDescription                                                             [OrderDescription]
             , (CASE
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
               )                                                                                [StatusOfIncident]
             , HUbs.IdHubLogistic                                                               [IdHubLogistic]
             --,0 [IdHubLogistic]
             , (CASE
                    WHEN TCD.Statusorderid = 4 THEN
                        1
                    ELSE
                        0
                END
               )                                                                                [Pendiente]
             , sr.Phone                                                                         [CourierPhone]
             , cus.IdCustomer                                                                   [Customer]
             , vpc.CodeOfReference                                                              [CodeOfReference]
             , cus.IdCustomerType                                                               [CustomerType]
             , cti.IdIncidenceType                                                              [IdIncidenceType]
             , TCD.SystemOrigin
        FROM #TodaysCheckpointsDetail                               TCD
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder]   ord WITH (NOLOCK)
                ON ord.Guide_Serie = TCD.GuideSerie
                   AND ord.Guide_Number = TCD.GuideNumber
            LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
                ON vpc.CodeOfReference = ord.Sender_ID
            LEFT JOIN dbo.VisitPointClient                          imp WITH (NOLOCK)
                ON imp.CodeOfReference = ord.OriginSenderId
            LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]         cus WITH (NOLOCK)
                ON cus.IdCustomer = vpc.CustomerID
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township]         tw WITH (NOLOCK)
                ON tw.IdTownship = ord.ReceiverIdTownship
            LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]      std WITH (NOLOCK)
                ON std.StatusOrderId = TCD.Statusorderid
            OUTER APPLY
        (
            SELECT TOP 1
                   HBL.IdHubLogistic
            FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                    ON dum.Hub = HBL.HubAbbreviation
                       AND HBL.HubStatus = 1
            WHERE dum.HeaderCode = tw.HeaderCode
        )                                                           HUbs
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]           da WITH (NOLOCK)
                ON [da].[ID] = TCD.[DeliveryAttemptId]
            --and da.rowstatus=1
            LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken                    tk2 WITH (NOLOCK)
                ON tk2.SSN_IdToken = CONVERT(VARCHAR(50), da.User_Created) --ddd.UserCreated						
            LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]   coi WITH (NOLOCK)
                ON [coi].[IdConfirmationOfIncidence] = [da].[ConfirmationOfIncidenceId]
                   AND coi.RowStatus = 1
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]          cti WITH (NOLOCK)
                ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)
            --INNER JOIN @TblIncidenceType TBLINCTYP ON
            --	TBLINCTYP.IdINcidenceType=cti.IdIncidenceType
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification] cic WITH (NOLOCK)
                ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]            sr WITH (NOLOCK)
                ON sr.ID = TCD.Settlement_IdCourier
            LEFT JOIN dbo.DeliveryOrderAttemptData                           atd WITH (NOLOCK)
                ON atd.GuideSerie = ord.Guide_Serie
                   AND atd.GuideNumber = ord.Guide_Number
        WHERE ord.IsLastMileReturn = 0 --NO INCLUIR DEVOLUCIÓN
              AND ord.StatusOrderId IN ( 4, 45, 50 )
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
            SELECT 1 FROM @TblIncidenceType
        )
                  OR cti.IdIncidenceType IN
                     (
                         SELECT IdIncidenceType FROM @TblIncidenceType
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
                         SELECT IdCustomer
                         FROM @TblCustomer
                         UNION
                         SELECT DISTINCT
                                A2.CustomerID IdCustomer
                         FROM [DeliveryBackOffice].[dbo].[Customer]                   A1 WITH (NOLOCK)
                             INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2 WITH (NOLOCK)
                                 ON A2.CustomerID = A1.IdCustomer
                         WHERE IdCustomerType = 2
                               AND 81 IN
                                   (
                                       SELECT IdCustomer FROM @TblCustomer
                                   )
                               AND IdCustomer <> 81
                               AND A2.StatusClient = 1
                               AND A2.IdKindOfVPClient = 1
                     )
              )
        ORDER BY CASE
                     WHEN
                     (
                         coi.IsConfirmed = 0
                         AND
                         (
                             (
                                 [da].[ID] IS NOT NULL
                                 AND SystemOrigin IN ( 3 )
                             )
                             OR
                             (
                                 ord.StatusOrderId IN ( 45 )
                                 AND SystemOrigin IN ( 2 )
                             )
                         )
                     ) THEN
                         0
                     ELSE
                         1
                 END
               , TCD.DateCheckpoint ASC

			   option (optimize for unknown)

        IF OBJECT_ID('tempdb.dbo.#TodaysCheckpointsDetail', 'U') IS NOT NULL
            DROP TABLE #TodaysCheckpointsDetail;




    END TRY

    BEGIN CATCH

        SELECT CAST(0 AS BIT)                    AS 'boolResult'
             , ERROR_MESSAGE()                   AS 'DescriptionResult'
             , CONVERT(BIGINT, 0)                AS 'NumTransferID'
             , CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';

    END CATCH;



END;