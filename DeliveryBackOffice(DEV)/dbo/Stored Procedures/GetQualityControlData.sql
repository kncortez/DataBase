-- =============================================
-- Author:		<Bidcar,Herrera>
-- Create date: <2023-09-12>
-- Description:	<Obtener datos para Sistema de Control de Calidad>
-- =============================================
CREATE PROCEDURE [dbo].[GetQualityControlData]
    @GuideSerie NVARCHAR(2) = ''
  , @GuideNumber INT= 0
  , @TblHubLogistic  TblHubLogistic READONLY
  , @TblCustomerType TblCustomerType READONLY
  , @TblCustomer     TblCustomer    READONLY
  , @TblVisitPointClient TblVisitPointClient  READONLY
  , @TblIncidenceType TblIncidenceType  READONLY
AS


BEGIN
    SET ARITHABORT ON;
    BEGIN TRY
        
        /**********************************************************************************************************************************
		************************************************** CONSTRUCCION DETALLE ***********************************************************
		***********************************************************************************************************************************/
	DECLARE @FIlterByHub bit=0
	set @FIlterByHub = (select top 1 1  from @TblHubLogistic)

DECLARE @CurrentDateAsDatetime datetime=CAST(CAST(GETDATE() AS DATE) AS DATETIME);
DECLARE @CurrentDateAsDatetimeFinishDay datetime=DATEADD(day, 1,@CurrentDateAsDatetime) ;
DECLARE @CURRENTDATE DATE=CONVERT(DATE,@CurrentDateAsDatetime);

if object_id('tempdb.dbo.#TodaysCheckpointsDetail', 'U') is not null
        drop table #TodaysCheckpointsDetail;


 CREATE TABLE  #TodaysCheckpointsDetail(
		[GuideSerie] NVARCHAR(2)
		,[GuideNumber] int
		,[DateCheckpoint] DATETIME
		,[DateCreatedInSystem] DATETIME
		,[Statusorderid] int
		,[SystemOrigin] int
		,[DeliveryAttemptId] int
		,[UserCreated] NVARCHAR (50)
		,[SettlementID] int
		,[Settlement_IdCourier] int
		,[Settlement_CatRouteId] int
		,[Settlement_Date_Received] datetime		
		);


	
	
WITH TodaysCheckpoints AS (
    SELECT
        ordd.guide_serie,
		ordd.guide_number,		
        ordd.datecreated,
		ordd.DateCreatedInSystem,
		ordd.statusorderid,
		ordd.SystemOrigin,
		ordd.DeliveryAttemptId,
		ordd.UserCreated,
		dsd.ID_DeliveryORderBYSettlement SettlementID,
		DSD.datecreated SettlementDetailDatecreated,
        ROW_NUMBER() OVER (PARTITION BY ordd.guide_serie,ordd.guide_number ORDER BY COALESCE(ordd.datecreated,DSD.datecreated) desc) AS rn

		from [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] ordd WITH (NOLOCK)
			LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)
				on dsd.guide_Number=ordd.guide_number
				and dsd.guide_serie=ordd.guide_serie
				and ISNULL(dsd.guide_settlement,0)=0
				and dsd.rowstatus=1
				--and ordd.statusorderid in (45,50)--Solo manifiestos de checkpoints en estado 45,50
		WHERE 
		ordd.rowstatus=1
		and ordd.statusorderid in (4,45,50,5,24,25)
		and ordd.datecreated >@CurrentDateAsDatetime 
		AND ( @GuideSerie = '' OR ordd.Guide_Serie = @GuideSerie)
		AND ( @GuideNumber = 0 OR ordd.Guide_Number = @GuideNumber)
		
)

INSERT INTO #TodaysCheckpointsDetail
SELECT

        TC.guide_serie guide_serie, 
		TC.guide_number guide_number,
        TC.datecreated datecreated,
		TC.DateCreatedInSystem DateCreatedInSystem,
		TC.statusorderid statusorderid,
		TC.SystemOrigin SystemOrigin,
		TC.DeliveryAttemptId DeliveryAttemptId,
		TC.UserCreated UserCreated,
	CASE  WHEN CONVERT(DATE, TC.SettlementDetailDatecreated)= @CURRENTDATE THEN ds.ID ELSE NULL END ID ,
	CASE  WHEN CONVERT(DATE, TC.SettlementDetailDatecreated)= @CURRENTDATE THEN ds.ID_Courier ELSE NULL END ID_Courier,
	CASE  WHEN CONVERT(DATE, TC.SettlementDetailDatecreated)= @CURRENTDATE THEN ds.CatRouteId ELSE NULL END CatRouteId,
	CASE  WHEN CONVERT(DATE, TC.SettlementDetailDatecreated)= @CURRENTDATE THEN ds.Date_Received ELSE NULL END Date_Received

FROM
    TodaysCheckpoints TC
		LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] ds WITH (NOLOCK)
		ON TC.SettlementID= ds.ID	
WHERE
    TC.rn = 1

	CREATE NONCLUSTERED INDEX IX_MiTablaTemporal_Columna1_Columna2
ON #TodaysCheckpointsDetail (Guideserie, Guidenumber,DateCheckpoint);


  SELECT 

   (case when TCD.StatusOrderId=4 and coi.IdConfirmationOfIncidence is null then 1 else 0 end) [Pending],
   (case when TCD.StatusOrderId in (5,24,25) then 1 else 0 end) [Delivered],
   (case when [DA].[ID] is not null and coi.isconfirmed =1  then 1 else 0 end) [ConfirmationIncidents],
   (case when 	
	coi.isconfirmed =0
	AND
	(
		([DA].[ID] is not null AND SystemOrigin   in(3) )
		or 
		(ord.StatusOrderId in (45) and SystemOrigin in (2) )
	)
	then 1 else 0 end) [UnConfirmationIncidents]
	 


				, ISNULL(TCD.SettlementID,0)																			[ID]
				, ISNULL(TCD.Settlement_IdCourier,0)																	[ID_Courier]
				, TCD.Settlement_Date_Received																[Date_Received]
				, da.ID_Incident																	[Id_Incident]
				, ISNULL(TCD.Settlement_CatRouteId,0)												[IdRoute]
				, (CASE
                    WHEN TCD.SystemOrigin=2THEN
                        tk2.SSN_IdUser		
                    ELSE
                         NULL
					END
					) [IdUser]
				, (CASE
                    WHEN TCD.SystemOrigin=2THEN
                        tk2.SSN_Username
                    ELSE
                         NULL
					END
					)		[Username]
				, (CASE
                    WHEN TCD.SystemOrigin=2THEN
                        'Usuario Desktop'
                    ELSE
                        'Vendedor Rutero'
                END
                )                                                                                [RouteDescription]
                , (CASE
                    WHEN TCD.SystemOrigin=2THEN
                        NULL
                    ELSE
                         CONCAT(COALESCE(sr.First_Name, ''), ' ', COALESCE(sr.Last_Name, ''))
					END
					)						[User]
				,ord.Guide_Serie																	[GuideSerie]
                , ord.Guide_Number																	[GuideNumber]
                --, ord.Sender_FirstName + ' ' + ord.Sender_LastName																	[SenderName]
				--, vpc.DescriptionOfClient																	[SenderName]
				,CONCAT(CASE WHEN IMP.CODEOFREFERENCE>0 THEN imp.DescriptionOfClient+'/'ELSE '' END	,cus.Name)																	[SenderName]
                , COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '')																	[ReceiverName]
                , ord.Sender_Phone																	[SenderPhone]
                , ord.Receiver_Phone																[ReceiverPhone]
                , ord.Receiver_Address																[ReceiverAddress]
                , ISNULL(cic.IncidenceTypeName, '')													[TypeOfIncident]
                , cti.NameIncidence																				[Incident]
				, TCD.DateCheckpoint																	[EventDate]
				, (CASE
						WHEN cti.NameIncidence IS NULL THEN
							NULL
						ELSE
							CONCAT(
									CONVERT(
												NVARCHAR(4)
											, IIF(
														atd.GuideDeliveryAttemptCount = atd.GuideDeliveryMaxAttemptCount
													, atd.GuideDeliveryAttemptCount
													, IIF(cti.IncidenceClasificationId <> 1, atd.GuideDeliveryAttemptCount, atd.GuideDeliveryAttemptCount+1))
											)
									, '/'
									, CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
								)
					END
				)																				[Attempts]
				
                , ord.PriceShippment																[PriceShippment]
                , ord.Collect_OnDelivery															[CollectOnDelivery]
                , std.OrderDescription																[OrderDescription]
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
                , HUbs.IdHubLogistic																[IdHubLogistic]
				--,0 [IdHubLogistic]
                , (case when TCD.StatusOrderId=4 then 1 else 0 end)									[Pendiente]
                , sr.Phone																			[CourierPhone]
				, cus.IdCustomer																	[Customer]
				, vpc.CodeOfReference																[CodeOfReference]
				, cus.IdCustomerType																[CustomerType]
				, cti.IdIncidenceType 																					[IdIncidenceType]
				,TCD.SystemOrigin

FROM
#TodaysCheckpointsDetail TCD
INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] ord WITH (NOLOCK)
	ON ord.guide_serie=TCD.guideserie
	and ord.guide_number=TCD.guidenumber	
    LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpc WITH (NOLOCK)
        ON vpc.CodeOfReference = ord.Sender_ID
	LEFT JOIN dbo.VisitPointClient imp WITH(NOLOCK)
		ON imp.CodeOfReference = ord.OriginSenderId
    LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] cus WITH (NOLOCK)
        ON cus.IdCustomer = vpc.CustomerID
    LEFT JOIN [DeliveryBackOffice].[dbo].[Township] tw WITH (NOLOCK)
        ON tw.IdTownship = ord.ReceiverIdTownship
	LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]									std WITH (NOLOCK)
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
	--INNER JOIN @TblHubLogistic TBLHL ON
	--	TBLHL.IdHubLogistics=IdHubLogistic
	--INNER JOIN @TblCustomerType TBLCST ON 
	--	TBLCST.IdCustomerType=cus.IdCustomerType
	--INNER JOIN @TblCustomer TBCSTM ON
	--	TBCSTM.IdCustomer=cus.IdCustomer
	--INNER JOIN @TblVisitPointClient TBLVPC ON
	--	TBLVPC.IdVisitPointClient=vpc.CodeOfReference



		

					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]								da  WITH (NOLOCK)
											ON [DA].[ID] = TCD.[DeliveryAttemptId]
											--and da.rowstatus=1
					LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken								tk2 WITH (NOLOCK)
						ON tk2.SSN_IdToken = CONVERT(VARCHAR(50), da.User_Created) --ddd.UserCreated						
					LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]						coi WITH (NOLOCK)
						ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
						AND coi.Rowstatus=1
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]								cti WITH (NOLOCK)
							ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)
					--INNER JOIN @TblIncidenceType TBLINCTYP ON
					--	TBLINCTYP.IdINcidenceType=cti.IdIncidenceType
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification]						cic WITH (NOLOCK)
						ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
    
	LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]								sr WITH (NOLOCK)
		ON sr.ID = TCD.Settlement_IdCourier
    LEFT JOIN dbo.DeliveryOrderAttemptData        atd WITH (NOLOCK)
        ON atd.GuideSerie = ord.Guide_Serie
            AND atd.GuideNumber = ord.Guide_Number


WHERE 
ord.IsLastMileReturn = 0 --NO INCLUIR DEVOLUCIÓN
AND ord.statusorderid=TCD.statusorderid
AND ord.statusorderid in (4,45,50,5,24,25)
AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)   OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType)  OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR VPC.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )	
		AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)      OR 
			  cus.IdCustomer IN (
								SELECT IdCustomer FROM @TblCustomer
								UNION 
								SELECT DISTINCT A2.CustomerID IdCustomer
									FROM [DeliveryBackOffice].[dbo].[Customer] A1
									INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2
											ON A2.CustomerID = A1.IdCustomer
									WHERE	IdCustomerType = 2 
											AND 81 IN (SELECT IdCustomer FROM @TblCustomer)
											AND IdCustomer <> 81
											AND A2.StatusClient = 1
											AND A2.IdKindOfVPClient = 1 
								)
			)
ORDER BY 
    CASE 
        WHEN 
(
	coi.isconfirmed =0
	AND
	(
		([DA].[ID] is not null AND SystemOrigin   in(3) )
		or 
		(ord.StatusOrderId in (45) and SystemOrigin in (2) )
	)
)		
		
		THEN 0
        ELSE 1 
    END,TCD.DateCheckpoint asc;



if object_id('tempdb.dbo.#TodaysCheckpointsDetail', 'U') is not null
        drop table #TodaysCheckpointsDetail;




    END TRY
    BEGIN CATCH

        SELECT CAST(0 AS BIT)                    AS 'boolResult'
             , ERROR_MESSAGE()                   AS 'DescriptionResult'
             , CONVERT(BIGINT, 0)                AS 'NumTransferID'
             , CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';

    END CATCH;

END;