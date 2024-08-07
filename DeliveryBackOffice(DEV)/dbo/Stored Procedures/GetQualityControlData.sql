-- =============================================
-- Author:		<Bidcar,Herrera>
-- Create date: <2023-09-12>
-- Description:	<Obtener datos para Sistema de Control de Calidad>
-- =============================================
CREATE PROCEDURE [dbo].[GetQualityControlData]
    @GuideSerie NVARCHAR(2) = ''
  , @GuideNumber INT
  , @TblHubLogistic  TblHubLogistic  READONLY
  , @TblCustomerType TblCustomerType  READONLY
  , @TblCustomer     TblCustomer    READONLY
  , @TblVisitPointClient TblVisitPointClient   READONLY
  , @TblIncidenceType TblIncidenceType  READONLY

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
        
		--tabla temporal guías a procesar?
        if object_id('tempdb.dbo.#TodaysCheckpointsDetail', 'U') is not null
            drop table #TodaysCheckpointsDetail;

		--tabla temporal para mostrar los datos
        if object_id('tempdb.dbo.#DetailGetQualityControlData ', 'U') is not null
            drop table #DetailGetQualityControlData;

        CREATE TABLE #TodaysCheckpointsDetail
        (
            [GuideSerie] NVARCHAR(2),
            [GuideNumber] int,
            [DateCheckpoint] DATETIME,
            [DateCreatedInSystem] DATETIME,
            [Statusorderid] int,
            [SystemOrigin] int,
            [DeliveryAttemptId] int,
            [UserCreated] NVARCHAR(50),
            [SettlementID] int,
            [Settlement_IdCourier] int,
            [Settlement_CatRouteId] int,
            [Settlement_Date_Received] datetime
        );

        set @Pending_Counter = 0
        set @Delivered_Counter = 0
		
        select @Pending_Counter = COUNT(   case
                                             when ord.statusorderid NOT IN  (5,24,25,22) then
                                                 ord.guide_Number
                                             else
                                                 NULL
                                         end
                                     ),
               @Delivered_Counter = COUNT(   case
                                               when ord.statusorderid in (5,24,25,22) then
                                                   ord.guide_Number
                                               else
                                                   NULL
                                           end
                                       )
      
        from [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] ds WITH (NOLOCK)
                ON dsd.ID_DeliveryORderBYSettlement = ds.ID
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] ord
				on ord.guide_serie=dsd.guide_serie and ord.guide_Number=dsd.guide_number
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township] tw WITH (NOLOCK)
                ON tw.IdTownship = ord.ReceiverIdTownship
            OUTER APPLY
        (
            SELECT TOP 1
                HBL.IdHubLogistic
            FROM dbo.DumpServiceCoverage dum WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                    ON dum.Hub = HBL.HubAbbreviation
                       AND HBL.HubStatus = 1
            WHERE dum.HeaderCode = tw.HeaderCode
        ) HUbs
        WHERE 
				CAST(dsd.datecreated AS DATE) = CAST(GETDATE() AS DATE)
              --dsd.datecreated BETWEEN @CurrentDateAsDatetime AND @CurrentDateAsDatetimeFinishDay
              and ord.statusorderid NOT in ( 45,50)
              and dsd.rowstatus = 1
			  and isnull(Guide_Settlement,0)=0
			  AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)   OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic));

		PRINT '@Pending_Counter'
		PRINT @Pending_Counter
		PRINT '@Delivered_Counter'
		PRINT @Delivered_Counter


        INSERT INTO #TodaysCheckpointsDetail
        select gdd.guide_serie,
               gdd.guide_number,
               gdd.datecreated,
               gdd.DateCreatedInSystem,
               gdd.statusorderid,
               gdd.SystemOrigin,
               gdd.DeliveryAttemptId,
               gdd.UserCreated,
               ds.ID SettlementID,
               ds.ID_Courier,
               ds.CatRouteId,
               ds.Date_Received
        --,IdConfirmationOfIncidence
		
        from [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] ds WITH (NOLOCK)
                ON dsd.ID_DeliveryORderBYSettlement = ds.ID
            outer apply
        (
            select top 1
                ordd.guide_serie,
                ordd.guide_number,
                ordd.datecreated,
                ordd.DateCreatedInSystem,
                ordd.statusorderid,
                ordd.SystemOrigin,
                ordd.DeliveryAttemptId,
                ordd.UserCreated
            from [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] ordd WITH (NOLOCK)
            where dsd.guide_Number = ordd.guide_number
                  and dsd.guide_serie = ordd.guide_serie
            order by datecreated desc
        ) gdd
        where --dsd.datecreated BETWEEN @CurrentDateAsDatetime AND @CurrentDateAsDatetimeFinishDay
			  CAST(dsd.datecreated AS DATE) = CAST(GETDATE() AS DATE)
              and dsd.rowstatus = 1
			  --and ISNULL(dsd.Guide_Settlement,0)=0
              and gdd.statusorderid in ( 45, 50 ); --solo incidencias confirmadas y pendientes para el detalle
			  


        WITH TodaysCheckpoints
        AS (SELECT ordd.guide_serie,
                   ordd.guide_number,
                   ordd.datecreated,
                   ordd.DateCreatedInSystem,
                   ordd.statusorderid,
                   ordd.SystemOrigin,
                   ordd.DeliveryAttemptId,
                   ordd.UserCreated,
                   ds.ID,
                   ds.ID_Courier,
                   ds.CatRouteId,
                   ds.Date_Received,
                   ROW_NUMBER() OVER (PARTITION BY ordd.guide_serie,
                                                   ordd.guide_number
                                      ORDER BY ordd.datecreated desc
                                     ) AS rn
            FROM DBO.DELIVERYORDERDETAIL ordd
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)
                    ON dsd.guide_Number = ordd.guide_number
                       and dsd.guide_serie = ordd.guide_serie
                       and dsd.rowstatus = 1
					   and ISNULL(dsd.Guide_Settlement,0)=0
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] ds WITH (NOLOCK)
                    ON dsd.ID_DeliveryORderBYSettlement = ds.ID
            WHERE 
				 CAST(ordd.datecreated AS DATE) = CAST(GETDATE() AS DATE)
			      --ordd.datecreated BETWEEN @CurrentDateAsDatetime AND @CurrentDateAsDatetimeFinishDay
                  AND ordd.STATUSORDERID IN ( 45, 50 ) --solo incidencias confirmadas y pendientes del día de hoy para el detalle
                  AND NOT EXISTS
            (
                SELECT 1
                FROM #TodaysCheckpointsDetail TCPD
                WHERE TCPD.GUIDENUMBER = ordd.GUIDE_NUMBER
                      and TCPD.GUIDESERIE = ordd.GUIDE_SERIE
            )
           )
        INSERT INTO #TodaysCheckpointsDetail
        SELECT guide_serie,
               guide_number,
               datecreated,
               DateCreatedInSystem,
               statusorderid,
               SystemOrigin,
               DeliveryAttemptId,
               UserCreated,
               ID,
               ID_Courier,
               CatRouteId,
               Date_Received
        FROM TodaysCheckpoints
        WHERE rn = 1

        CREATE NONCLUSTERED INDEX IX_TodaysCheckpointsDetail
        ON #TodaysCheckpointsDetail
        (
            Guideserie,
            Guidenumber,
            DateCheckpoint
        );





        CREATE TABLE #DetailGetQualityControlData
        (
            Pending int,
            [Delivered] int,
            [ConfirmationIncidents] int,
            [UnConfirmationIncidents] INT,
            [ID] bigint,
            [ID_Courier] int,
            [Date_Received] DATETIME,
            [IdRoute] int,
            [ID_Incident] int,
            [IdUser] int,
            [Username] NVARCHAR(50),
            [RouteDescription] NVARCHAR(200),
            [User] NVARCHAR(100),
            [GuideSerie] NVARCHAR(2),
            [GuideNumber] int,
            [SenderName] NVARCHAR(150),
            [ReceiverName] NVARCHAR(150),
            [SenderPhone] NVARCHAR(150),
            [ReceiverPhone] NVARCHAR(50),
            [ReceiverAddress] NVARCHAR(600),
            [TypeOfIncident] NVARCHAR(50),
            [Incident] NVARCHAR(50),
            [EventDate] DATETIME,
            [Attempts] NVARCHAR(10),
            [PriceShippment] DECIMAL(14, 2),
            [CollectOnDelivery] DECIMAL(14, 2),
            [OrderDescription] NVARCHAR(50),
            [StatusOfIncident] NVARCHAR(50),
            [IdHubLogistic] int,
            [Pendiente] int,
            [CourierPhone] NVARCHAR(50),
            [Customer] int,
            [CodeOfReference] NVARCHAR(50),
            [CustomerType] int,
            [IdIncidenceType] int
        )


        insert into #DetailGetQualityControlData
        SELECT 0 [Pending],
               0 [Delivered],
               (case
                    when [DA].[ID] is not null
                         and coi.isconfirmed = 1 then
                        1
                    else
                        0
                end
               ) [ConfirmationIncidents],
               (case
                    when coi.isconfirmed = 0
                         AND (
                                 (
                                     [DA].[ID] is not null
                                     AND SystemOrigin in ( 3 )
                                 )
                                 or (
                                        ord.StatusOrderId in ( 45 )
                                        and SystemOrigin in ( 2 )
                                    )
                             ) then
                        1
                    else
                        0
                end
               ) [UnConfirmationIncidents],
               ISNULL(TCD.SettlementID, 0) [ID],
               ISNULL(TCD.Settlement_IdCourier, 0) [ID_Courier],
               TCD.Settlement_Date_Received [Date_Received],
               da.ID_Incident [Id_Incident],
               ISNULL(TCD.Settlement_CatRouteId, 0) [IdRoute],
               (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        --tk2.SSN_IdUser
						''
                    ELSE
                        NULL
                END
               ) [IdUser],
               (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        --tk2.SSN_Username
						''
                    ELSE
                        NULL
                END
               ) [Username],
               (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        'Usuario Desktop'
                    ELSE
                        'Vendedor Rutero'
                END
               ) [RouteDescription],
               (CASE
                    WHEN TCD.SystemOrigin = 2 THEN
                        NULL
                    ELSE
                        CONCAT(COALESCE(sr.First_Name, ''), ' ', COALESCE(sr.Last_Name, ''))
                END
               ) [User],
               ord.Guide_Serie [GuideSerie],
               ord.Guide_Number [GuideNumber],
               CONCAT(   CASE
                             WHEN IMP.CODEOFREFERENCE > 0 THEN
                                 imp.DescriptionOfClient + '/'
                             ELSE
                                 ''
                         END,
                         CASE
                             WHEN IMP.CODEOFREFERENCE > 0 THEN
                                 ORD.Sender_FirstName+ORD.Sender_LastName
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
               --,0 [IdHubLogistic]
               (case
                    when TCD.StatusOrderId = 4 then
                        1
                    else
                        0
                end
               ) [Pendiente],
               sr.Phone [CourierPhone],
               cus.IdCustomer [Customer],
               vpc.CodeOfReference [CodeOfReference],
               cus.IdCustomerType [CustomerType],
               cti.IdIncidenceType [IdIncidenceType]
        --,TCD.SystemOrigin
        --,ROW_NUMBER() OVER (PARTITION BY 
        --	--pending 
        --	(case when TCD.StatusOrderId=4 and coi.IdConfirmationOfIncidence is null then 1 else 0 end)
        --ORDER BY TCD.DateCheckpoint asc) AS rn
        FROM #TodaysCheckpointsDetail TCD
            INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] ord WITH (NOLOCK)
                ON ord.guide_serie = TCD.guideserie
                   and ord.guide_number = TCD.guidenumber
            LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
                ON vpc.CodeOfReference = ord.Sender_ID
            LEFT JOIN dbo.VisitPointClient imp WITH (NOLOCK)
                ON imp.CodeOfReference = ord.OriginSenderId
            LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] cus WITH (NOLOCK)
                ON cus.IdCustomer = vpc.CustomerID
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township] tw WITH (NOLOCK)
                ON tw.IdTownship = ord.ReceiverIdTownship
            LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder] std WITH (NOLOCK)
                ON std.StatusOrderId = TCD.StatusOrderId
            OUTER APPLY
        (
            SELECT TOP 1
                HBL.IdHubLogistic
            FROM dbo.DumpServiceCoverage dum WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                    ON dum.Hub = HBL.HubAbbreviation
                       AND HBL.HubStatus = 1
            WHERE dum.HeaderCode = tw.HeaderCode
        ) HUbs
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] da WITH (NOLOCK)
                ON [DA].[ID] = TCD.[DeliveryAttemptId]
            --LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk2 WITH (NOLOCK)
              --  ON tk2.SSN_IdToken = CONVERT(VARCHAR(50), da.User_Created) --ddd.UserCreated						
            LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] coi WITH (NOLOCK)
                ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
                   AND coi.Rowstatus = 1
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence] cti WITH (NOLOCK)
                ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification] cic WITH (NOLOCK)
                ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver] sr WITH (NOLOCK)
                ON sr.ID = TCD.Settlement_IdCourier
            LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                ON atd.GuideSerie = ord.Guide_Serie
                   AND atd.GuideNumber = ord.Guide_Number
        WHERE ord.IsLastMileReturn = 0 --NO INCLUIR DEVOLUCIÓN
        AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)   OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic))
        AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType)  OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
        AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR VPC.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )	
        AND ( NOT EXISTS (SELECT 1 FROM @TblIncidenceType where idincidencetype <>0) OR cti.IdIncidenceType IN (SELECT IdIncidenceType FROM @TblIncidenceType where idincidencetype <>0) )	
        AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)      OR 
        	  cus.IdCustomer IN (
        						SELECT IdCustomer FROM @TblCustomer        						
        						)
        	)
		


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
        FROM #DetailGetQualityControlData
					
			SELECT TOP 100
            Pending ,
            [Delivered] ,
            [ConfirmationIncidents] ,
            [UnConfirmationIncidents] ,
            [ID] ,
            [ID_Courier] ,
            [Date_Received] ,
            [IdRoute] ,
            [ID_Incident] ,
            [IdUser] ,
            [Username] ,
            [RouteDescription] ,
            [User] ,
            [GuideSerie] ,
            [GuideNumber],
            [SenderName] ,
            [ReceiverName],
            [SenderPhone] ,
            [ReceiverPhone] ,
            [ReceiverAddress],
            [TypeOfIncident] ,
            [Incident] ,
            [EventDate],
            [Attempts] ,
            [PriceShippment] ,
            [CollectOnDelivery],
            [OrderDescription] ,
            [StatusOfIncident] ,
            [IdHubLogistic] ,
            [Pendiente] ,
            [CourierPhone] ,
            [Customer] ,
            [CodeOfReference] ,
            [CustomerType] ,
            [IdIncidenceType] 
			FROM #DetailGetQualityControlData WITH (NOLOCK)
			WHERE UnConfirmationIncidents=1
			UNION ALL
			SELECT TOP 100
            Pending ,
            [Delivered] ,
            [ConfirmationIncidents] ,
            [UnConfirmationIncidents] ,
            [ID] ,
            [ID_Courier] ,
            [Date_Received] ,
            [IdRoute] ,
            [ID_Incident] ,
            [IdUser] ,
            [Username] ,
            [RouteDescription] ,
            [User] ,
            [GuideSerie] ,
            [GuideNumber],
            [SenderName] ,
            [ReceiverName],
            [SenderPhone] ,
            [ReceiverPhone] ,
            [ReceiverAddress],
            [TypeOfIncident] ,
            [Incident] ,
            [EventDate],
            [Attempts] ,
            [PriceShippment] ,
            [CollectOnDelivery],
            [OrderDescription] ,
            [StatusOfIncident] ,
            [IdHubLogistic] ,
            [Pendiente] ,
            [CourierPhone] ,
            [Customer] ,
            [CodeOfReference] ,
            [CustomerType] ,
            [IdIncidenceType] 
			FROM #DetailGetQualityControlData WITH (NOLOCK)
			WHERE ConfirmationIncidents=1
			ORDER BY ConfirmationIncidents asc ,EventDate asc;			

        if object_id('tempdb.dbo.#TodaysCheckpointsDetail', 'U') is not null
            drop table #TodaysCheckpointsDetail;

    END TRY
    BEGIN CATCH

        SELECT CAST(0 AS BIT) AS 'boolResult',
               ERROR_MESSAGE() AS 'DescriptionResult',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';

    END CATCH;

END;