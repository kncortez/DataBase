
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

-- =============================================
-- Modiff:		<Hugo,Gomez>
-- Create date: <2021-05-13>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

-- =============================================
-- Modiff:		<Marco,Jiménez>
-- Create date: <2021-09-16>
-- Description:	<Se agregan validaciones para no cobrar el servicio ni COD en la courierapp cuando la entrega sea en un Express Center>
-- Hotfix: FDAPI-337
-- =============================================

-- =============================================
-- Modiff:		<Andres,Ruiz>
-- Create date: <2021-12-13>
-- Description:	< Adición de campos para alertas de servicios >
-- =============================================

/*
EXEC [dbo].[spws_get_daily_route]
@IdCourier = 3
,@DateRoute = '2021-09-09'
*/



CREATE PROCEDURE [dbo].[spws_get_daily_route_new]
	@Token VARCHAR(200)='',
	@IdCourier bigint,
	@DateRoute date 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 
	DECLARE @jsonResult2 NVARCHAR(MAX) 
	DECLARE @jsonResult3 NVARCHAR(MAX) 
	DECLARE @jsonResultErrror NVARCHAR(MAX) 

	-- TOD VALIDAR TOKEN DE COURIERMAN
	--declare @IdCurrier bigint  = (select top 1 t.TknIdUser from TokenLog t
				--		where t.TknIdToken = @Token)
	
	DECLARE @jsonToken NVARCHAR(MAX)
	 declare @TokenAct int  = 1 --(select top 1 RowStatus from LogTokenPOD where LogTokenPOD LIKE '%' + @Token + '%' order by DateCreated desc)
     declare @hourtoken int = 5--(select top 1 DATEDIFF(HOUR, DateCreated, GETDATE() ) as horas from LogTokenPOD where LogTokenPOD  LIKE '%' + @Token + '%')
	DECLARE @IdDeliveryOption AS INT --FDAPI-337

	-- PARA VALIDAR TIPO DE SERVICIO PARA ALERTAS
	DECLARE @PickUpTypeId BIGINT = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH(NOLOCK) WHERE STSM.Name = 'Recolección');
	DECLARE @DeliveryTypeId BIGINT = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH(NOLOCK) WHERE STSM.Name = 'Entrega');
	

	if (@TokenAct = 1 and @hourtoken <= 8)
		begin 

		SET @IdDeliveryOption = (SELECT IdDeliveryOption FROM dbo.CatDeliveryOptions WITH(NOLOCK) where Name = 'Express Center') --FDAPI-337
						set @jsonResult = (SELECT STUFF(( 
							
							select 
									',
									{									
                                    "ServiceType":"' + 'Pickup'  + '",' +
									'"CodeOfReference":"' + convert( varchar,isnull(vpc.CodeOfReference,0))  + '",' +
									'"Id":"' +  isnull( convert(varchar,spk.SchedulePickupId) , '-1') + '",' +
									'"ServiceManagementId":"' +  isnull( convert(varchar,sma.IdServiceManagement) , 'N/A') + '",' +
									'"Sender":"' +  isnull(isnull(spk.SenderName,vpc.DescriptionOfClient), 'N/A') + '",' +
									'"Address":"' +  dbo.fnt_String_Escape(concat( ISNULL( isnull(replace(replace(spk.AddressPickup,CHAR(0),''),'"','') , REPLACE(vpc.Address,'"','')) ,'N/A'), ' ' , vpc.Town , ' ' , vpc.Department),'json') + '",' +
									'"Phone":"' +  isnull( isnull(spk.SenderPhone , vpc.Phone)  ,'N/A') + '",' +
									'"PiecesDry":"' + CONVERT(varchar,isnull((select iif(sum(isnull(ord.Pieces_Dry,0)) =0, (isnull(sum(sc.QuantityOverDimensionedPackage),0) + isnull(sum(sc.QuantityRegularPackages),0))  ,sum(isnull(ord.Pieces_Dry,0)) ) pieces
																from dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
																	left join dbo.DeliveryOrder ord WITH (NOLOCK) on ord.Guide_Serie = pay.GuideSerie and ord.Guide_Number = pay.GuideNumber
																	left join dbo.SchedulePickup sc WITH (NOLOCK) on sc.SchedulePickupId = pay.IdHeaderRecolection
																where pay.IdHeaderRecolection = spk.SchedulePickupId),0))  + '",' +
									'"PiecesCold":"' + CONVERT(varchar,isnull((select sum(isnull(ord.Pieces_Cold,0)) pieces
										 from dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
										 left join dbo.DeliveryOrder ord WITH (NOLOCK) on ord.Guide_Serie = pay.GuideSerie and ord.Guide_Number = pay.GuideNumber
										 where pay.IdHeaderRecolection = spk.SchedulePickupId),0))  + '",' +
									'"ScheduleStart":"' +    substring( CONVERT(varchar, spk.StartDate  ,8),0,6)  + '",' +
									'"ScheduleEnd":"' +     substring(CONVERT(varchar, spk.EndDate  ,8),0,6)   + '",' +
									'"Photo":"' + ISNULL( (select top 1 vpi.PathImage from dbo.ImagesByVisitPoint vpi WITH(NOLOCK)
															where vpi.CodeOfReference =VPC.CodeOfReference 
															order by DateCreated desc) ,'#')  + '",' +
									'"Latitude":"' + convert(varchar, isnull(vpc.Latitude,0) )  + '",' +
									'"Longitude":"' + convert(varchar, isnull(vpc.Longitude,0) )  + '",' +
									'"Precision":"' + convert(varchar, isnull(vpc.Accuracy,0) )  +  '",' +
									'"Price":"' + '0'  +  '",' +
									'"Pickup":"' + '0'  +  '",' +
									'"customerName":"' +   ' ' + '",' +
									'"alterName":"' +   ' ' + '",' +
									'"HighPriority":' + Convert(varchar, IIF((select ISNULL(count(doa.GuideNumber),0)
																 FROM [DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH (NOLOCK)
																	LEFT JOIN
																	[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
																	ON 
																	SP.SchedulePickupId = DOPD.IdHeaderRecolection
																	LEFT JOIN
																	[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH (NOLOCK)
																	ON
																	DOPD.GuideSerie = DOA.GuideSerie
																	AND
																	DOPD.GuideNumber = DOA.GuideNumber
																	AND
																	DOA.ServiceTypeId = @PickUpTypeId
																	AND
																	DOA.RowStatus = 1
																	WHERE
																	SP.SchedulePickupId = spk.SchedulePickupId ) > 0, 'true','false'))+ ',' + 
									
									'"Alerts":[' + IIF( (select ISNULL(count(doa.GuideNumber),0)
																 FROM [DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH (NOLOCK)
																	LEFT JOIN
																	[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
																	ON 
																	SP.SchedulePickupId = DOPD.IdHeaderRecolection
																	LEFT JOIN
																	[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH (NOLOCK)
																	ON
																	DOPD.GuideSerie = DOA.GuideSerie
																	AND
																	DOPD.GuideNumber = DOA.GuideNumber
																	AND
																	DOA.ServiceTypeId = @PickUpTypeId
																	AND
																	DOA.RowStatus = 1
																	WHERE
																	SP.SchedulePickupId = spk.SchedulePickupId ) > 0 ,
																	(SELECT STUFF((SELECT ',{"TypeAlert":' +Convert(varchar,doa.AlertTypeId) + ',' + 
																 '"DescriptionAlert":"' + dbo.fnt_String_Escape(dbo.fn_replace_special_characters(doa.AlertDescription),'json')  + '",' + 
																 '"DateCreated":"' + (Convert(varchar,doa.DateCreated,24)) + ' - '+ (Convert(varchar,doa.DateCreated,103)) + '"}'
																 FROM [DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH (NOLOCK)
																	LEFT JOIN
																	[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
																	ON 
																	SP.SchedulePickupId = DOPD.IdHeaderRecolection
																	LEFT JOIN
																	[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH (NOLOCK)
																	ON
																	DOPD.GuideSerie = DOA.GuideSerie
																	AND
																	DOPD.GuideNumber = DOA.GuideNumber
																	AND
																	DOA.ServiceTypeId = @PickUpTypeId
																	AND
																	DOA.RowStatus = 1
																	WHERE
																	SP.SchedulePickupId = spk.SchedulePickupId
																	ORDER BY
																	DOA.DateCreated DESC
									 FOR XML PATH ('')), 1, 1, '')) , '') 
										+
									'],' +
									'"Status":"' + convert(varchar,isnull(sma.ServiceStatusId,1))  +
										+ '"}'
									from dbo.RouteAssigment ras WITH (NOLOCK)
									left join dbo.ServiceManagement sma WITH (NOLOCK) on sma.IdPuRouteAssigment = ras.IdRouteAssigment
									left join dbo.SchedulePickup spk WITH (NOLOCK) on spk.SchedulePickupId = sma.IdSchedulePickup
									left join dbo.VisitPointClient vpc WITH (NOLOCK) on vpc.CodeOfReference = spk.SenderId 
										where 
										ras.IdCurrierMan= @IdCourier 
										and ras.DateOfRoute = @DateRoute
								
									
					
								FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
											) )
print CONCAT('@jsonResult ',@jsonResult)
						set @jsonResult2 = (SELECT STUFF(( 
						SELECT JDRS2.JsonDataRow FROM ( select distinct JDRS.JsonDataRow, MIN(ISNULL(JDRS.ShownOrder,999)) topOrder from( select top 100 percent REPLACE( 
									',
									{									
                                    "ServiceType":"' +  'Delivery'  + '",' +
									'"CodeOfReference":"' + convert( varchar,isnull(vpr.CodeOfReference,0))  + '",' +
									'"Id":"' +  isnull( convert(varchar,DOR.Guide_Serie + CONVERT(varchar,DOR.Guide_Number)) , '-1') + '",' +
									'"ServiceManagementId":"' +  isnull( convert(varchar,0) , 'N/A') + '",' +
									'"Sender":"'  +   isnull(isnull(COALESCE(dbo.fn_ReplaceSpecialCharsForJSON(DOR.Sender_FirstName),'')+ ' ' + COALESCE(dbo.fn_ReplaceSpecialCharsForJSON(DOR.Sender_LastName),''),dbo.fn_ReplaceSpecialCharsForJSON(vpc.DescriptionOfClient)), 'N/A') + '",' +
									'"Address":"' + IIF(kvp.KindOfVPName ='Express Center', ISNULL(dbo.fn_ReplaceSpecialCharsForJSON(vpr.Address),''),  dbo.fnt_String_Escape( /*concat(*/ ISNULL( isnull(REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(DOR.Receiver_Address),'"',''), REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(vpc.Address),'"','')) ,'N/A')/*, ' ' , vpc.Town , ' ' , vpc.Department)*/,'json')) + '",' +
									'"Phone":"' +  isnull( isnull(DOR.Receiver_Phone , dor.Receiver_Alternant_Phone)  ,'N/A') + '",' +
									'"PiecesDry":"' + CONVERT(varchar,isnull((select (sum(isnull(DOR2.Pieces_Dry,0))) pieces
										 from DeliveryBackOffice.dbo.DeliveryOrder DOR2 WITH (NOLOCK)
										 where DOR2.Guide_Serie = DAT.Guide_Serie
										 and DOR2.Guide_Number = DAT.Guide_Number
																),0))  + '",' +
									'"PiecesCold":"' + CONVERT(varchar,isnull((select (sum(isnull(DOR2.Pieces_Cold,0))) pieces
										 from DeliveryBackOffice.dbo.DeliveryOrder DOR2 WITH (NOLOCK)
										 where DOR2.Guide_Serie = DAT.Guide_Serie
										 and DOR2.Guide_Number = DAT.Guide_Number
																),0))  + '",' +
									'"ScheduleStart":"' +   ''  + '",' +
									'"ScheduleEnd":"' +     ''   + '",' +
									'"Photo":"' + ISNULL( (select top 1 vpi.PathImage from dbo.ImagesByVisitPoint vpi WITH(NOLOCK)
															where vpi.CodeOfReference =VPC.CodeOfReference 
															order by DateCreated desc) ,'#')  + '",' +
									'"Latitude":"' + convert(varchar,
										(CASE
											WHEN ISNULL(SDFG.Latitude,0) != 0 AND ISNULL(SDFG.Longitude,0) != 0 THEN convert(varchar,ISNULL(SDFG.Latitude,0))
											WHEN ISNULL(EPS.Latitude,0) != 0 AND ISNULL(EPS.Longitude,0) != 0 THEN CONVERT(varchar, ISNULL(EPS.Latitude,0))
											WHEN ISNULL(VPr.Latitude,'0') <> '' THEN ISNULL(VPr.Latitude,'0')
											ELSE '0'
										END)
									)  + '",' +
									'"Longitude":"' + convert(varchar,
										(CASE
											WHEN ISNULL(SDFG.Latitude,0) != 0 AND ISNULL(SDFG.Longitude,0) != 0 THEN convert(varchar,ISNULL(SDFG.Longitude,0))
											WHEN ISNULL(EPS.Latitude,0) != 0 AND ISNULL(EPS.Longitude,0) != 0 THEN CONVERT(varchar, ISNULL(EPS.Longitude,0))
											WHEN ISNULL(VPr.Longitude,'0') <> '' THEN ISNULL(VPr.Longitude,'0')
											ELSE '0'
										END)
									)  + '",' +
									IIF(ISNULL(SDFG.Latitude,0) != 0 AND ISNULL(SDFG.Longitude,0) != 0, '"LocationConfirmed":1,', '') +
									'"Precision":"' + convert(varchar, isnull(vpc.Accuracy,0) )  +  '",' +
									CASE WHEN DOR.IdDeliveryOption = @IdDeliveryOption THEN  
									'"Price_COD":"0",' 
									ELSE
									'"Price_COD":"' + IIF(kvp.KindOfVPName ='Express Center', '0',   CONVERT(varchar,isnull(DOR.Collect_OnDelivery,0)))  +  '",' 
									END +
									
									CASE WHEN DOR.IdDeliveryOption = @IdDeliveryOption THEN
									'"Price":"0",' 
									ELSE
									'"Price":"' + IIF(kvp.KindOfVPName ='Express Center', '0',    CONVERT(varchar,iif(isnull(DOR.IsCollect ,0)=1, isnull(DOR.PriceShippment,0),0 )))  +  '",' 
									END 
									+
									CASE WHEN DOR.IdDeliveryOption = @IdDeliveryOption THEN
									'"Pickup":"0",' 
									ELSE
									'"Pickup":"' + CONVERT(varchar,isnull((SELECT top 1
										iif(isnull(dp.TimePlaId,0) = 3 ,sc.AmountPickup,0)
										FROM dbo.DeliveryOrderPaymentDetail dp WITH(NOLOCK)
										left join dbo.SchedulePickup sc WITH(NOLOCK) on sc.SchedulePickupId = dp.IdHeaderRecolection
										where dp.GuideNumber = DOR.Guide_Number AND DP.GuideSerie = DOR.Guide_Serie
										),0) )  +  '",' 
										END 
										+
									'"customerName":"' +    IIF(kvp.KindOfVPName ='Express Center', ISNULL(dbo.fn_ReplaceSpecialCharsForJSON(vpr.DescriptionOfClient),''), ISNULL(REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(DOR.Receiver_FirstName),'"',''),'N/A')) + '",' +
									'"alterName":"' +   isnull(isnull(REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(DOR.Receiver_Alternant_FullName),'"',''),REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(dor.Receiver_FirstName),'"','')),'N/A') + '",' +
									'"Status":"' + convert(varchar,isnull(DOR.StatusOrderId,4))  +'"'+ 
									IIF( doa.GuideNumber IS NOT NULL, ',"HighPriority":' + Convert(varchar, IIF((select ISNULL(count(doa.GuideNumber),0)
																 FROM DeliveryOrderAlert doa WITH (NOLOCK)
																	 where doa.GuideNumber = DOR.Guide_Number
																	 AND doa.RowStatus = 1
																	 AND doa.ServiceTypeId = @DeliveryTypeId ) > 0, 'true','false'))+ ',' + 
									'"Alerts": [ ' +   
										(SELECT STUFF((SELECT TOP 1 ' { "TypeAlert": ' +Convert(varchar,doa.AlertTypeId) + ', ' + 
																 '"DescriptionAlert": "' + dbo.fnt_String_Escape(dbo.fn_replace_special_characters(doa.AlertDescription),'json')  + '", ' + 
																 '"DateCreated": "' + (select top 1 Convert(varchar,doa.DateCreated,24)) + ' - '+ (select top 1 Convert(varchar,doa.DateCreated,103)) + '" }, '
																 FROM DeliveryOrderAlert doa WITH (NOLOCK)
																	 where doa.GuideNumber = DOR.Guide_Number
																	 AND doa.RowStatus = 1
																	 AND doa.ServiceTypeId = @DeliveryTypeId
																	 ORDER BY doa.DateCreated DESC
									 FOR XML PATH ('')), 1, 1, ''))+
									'],' ,'')
									 
										+ '}',CHAR(31),'')  JsonDataRow
										, isnull(DSD.GuideOrder,999) 'ShownOrder' 
									from (select distinct Guide_Serie,Guide_Number,ID_Courier 
									     from dbo.DeliveryAttempt  WITH (NOLOCK)
										 where CAST(Date_Created AS DATE) = CAST(@DateRoute AS DATE)
										 ) DAT /*dbo.DeliveryAttempt DAT*/
									join DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
									    on      DAT.Guide_Serie = DOR.Guide_Serie
											and DAT.Guide_Number = DOR.Guide_Number
											and DOR.StatusOrderId in (4,5,12,20,25) --En ruta|entregado|Intento de entrega fallida(incidencia)|Devolución
									join DeliveryBackOffice.dbo.DeliverySettlementDetail DSD WITH (NOLOCK)
										on     DSD.Guide_Serie = DAT.Guide_Serie 
										   and DSD.Guide_Number = DAT.Guide_Number
										   and DSD.RowStatus = 1
									join DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS WITH (NOLOCK)
									    on     DOS.ID = DSD.ID_DeliveryOrderBySettlement
										   and DOS.ID_Courier = DAT.ID_Courier
									left join DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
									    on     VPC.CodeOfReference = DOR.Sender_ID
									left join DeliveryBackOffice.dbo.ServiceDataForGuide SDFG WITH (NOLOCK) 
										on DOR.Guide_Serie = SDFG.GuideSerie
										and DOR.Guide_Number = SDFG.GuideNumber
										and SDFG.IsDelivery = 1
									LEFT JOIN (
										SELECT
											EPSA.GuideSerie
											,EPSA.GuideNumber
											,EPS.Latitude
											,EPS.Longitude
										FROM
											DeliveryBackOffice.dbo.ExtPlatformService EPS WITH(NOLOCK)
											JOIN
											(
												SELECT
													EPSRWG.GuideSerie
													,EPSRWG.GuideNumber
													,MAX(EPS.IdService) 'LastService'
												FROM
													DeliveryBackOffice.dbo.ExtPlatServiceRelationshipWithGuide EPSRWG WITH(NOLOCK)
													LEFT JOIN
													DeliveryBackOffice.dbo.ExtPlatformService EPS WITH(NOLOCK)
														ON EPSRWG.ExtPlatServiceId = EPS.IdExtPlatformService
												GROUP BY
													EPSRWG.GuideSerie,EPSRWG.GuideNumber
											) EPSA
											ON EPS.IdService = EPSA.LastService
										WHERE
											CAST(EPS.EstimatedTimeArrival AS DATE) = CAST(@DateRoute AS DATE)
									) EPS
										ON DAT.Guide_Serie = EPS.GuideSerie
										AND DAT.Guide_Number = EPS.GuideNumber
									left join DeliveryBackOffice.dbo.VisitPointClient VPr WITH (NOLOCK)
									    on     VPr.CodeOfReference = DOR.Receiver_ID
									LEFT JOIN dbo.KindOfVPClient kvp  WITH(NOLOCK)
										ON kvp.IdKindOfVPClient = VPr.IdKindOfVPClient
									LEFT JOIN dbo.DeliveryOrderAlert doa  WITH (NOLOCK)
										ON doa.GuideNumber = DAT.Guide_Number 
										AND doa.RowStatus = 1
										AND doa.ServiceTypeId = @DeliveryTypeId
									where
									DAT.ID_Courier = @IdCourier
									order by isnull('ShownOrder',999) asc) JDRS
									group by JDRS.JsonDataRow ) JDRS2
									order by topOrder ASC
                                    
									--and CAST(DAT.Date_Created AS DATE) = CAST(@DateRoute AS DATE)
								FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
											) )
			print CONCAT('@jsonResult2',@jsonResult2)				
-----------------------------Start Sumary, ListGuides Return----------------------------------------------
		
		IF OBJECT_ID('tempdb.dbo.#GuideService', 'U') IS NOT NULL DROP TABLE #GuideService;


SELECT smg.IdServiceManagement, dpc.GuideSerie, dpc.GuideNumber, smg.ServiceStatusId, @IdCourier IdPuCourrier 
Into #GuideService
FROM dbo.SettlementByPickup stp WITH (NOLOCK)
	LEFT JOIN dbo.SettlementByPickupDetail std WITH (NOLOCK) ON std.SettlementByPickupId = stp.Id
	LEFT JOIN dbo.DeliveryOrderPiece dpc WITH (NOLOCK) ON dpc.GuideSerie = std.GuideSerie AND dpc.GuideNumber = std.GuideNumber
	LEFT JOIN dbo.PieceByService pbs WITH (NOLOCK) ON pbs.GuidePieceId = dpc.GuidePiece
	LEFT JOIN dbo.ServiceManagement smg WITH (NOLOCK) ON smg.IdServiceManagement = pbs.ServiceManagmentId
	LEFT JOIN dbo.RouteAssigment ras WITH (NOLOCK) ON ras.IdRouteAssigment = smg.IdDlRouteAssigment
WHERE stp.IdCourier = @IdCourier AND CONVERT(DATE, stp.DateCreated) = CONVERT(DATE, GETDATE())
and smG.SubTypeServiceManagmentId = 3


declare @guides nvarchar (MAX) = (select stuff((select ','+concat(GuideSerie,GuideNumber) from #GuideService
											FOR XML PATH ('')),1,1,''))

											PRINT CONCAT('GUIDES',@guides)

		declare @Temp as table
		(	GuideSerie			nvarchar (25) null,
			GuideNumber			nvarchar (25) null,
			IsCollect			nvarchar (25) null,
			Price				decimal (14,2) null,
			COD					decimal (14,2) null,
			AmountPaid			decimal (14,2) null,
			CODPaid				decimal (14,2) null,
			CODIsPaid			decimal (14,2) null,
			PaymentTime			int null,
			TimeSequence		int null,
			FelNumber			nvarchar (50) null,
			IsPaid				int null,
			IsCustomer			int null,
			ConditionPayment	nvarchar(200) null,
			HaveCredit			nvarchar (50) null,
			CollectCOD			nvarchar (50) null,
			ReturnRate			decimal (14,2) null,
			AmountToPay			decimal (14,2) null,
			CODAmount			decimal (14,2) null,
			ReturnRates			decimal (14,2) null)
			INSERT INTO @Temp (GuideSerie,GuideNumber,IsCollect,Price,COD,AmountPaid,CODPaid
				,CODIsPaid,PaymentTime,TimeSequence	,FelNumber,IsPaid,IsCustomer
				,ConditionPayment,HaveCredit,CollectCOD,ReturnRate,AmountToPay,CODAmount,ReturnRates)
			EXEC  [dbo].[spws_get_guide_pending_payment]
				@InGuides = @guides,
				@InTime = 3,
				@IsReturn = 1,
				@CodeApp = 'SIFDCECOM300720201459',
				@IdModule = 1,
				@Token = @Token

PRINT 'guias devolucion'
	PRINT @guides

--------------------------------End Sumary,ListGuides Return----------------------------------------------------------------------


-----------------------Start Retuns Services ---------------------------------------------
								set @jsonResult3 = (SELECT STUFF(( 
									 select  distinct
									',
									{									
                                                "ServiceType":"' +  'Return'  + '",' +
									'"CodeOfReference":"' + convert( varchar,isnull(vpc.CodeOfReference,0))  + '",' +
									'"ServiceManagementId":"' +  isnull( convert(varchar, gs.IdServiceManagement ,0) , 'N/A') + '",' +
									'"Sender":"'  +  isnull(isnull(COALESCE(dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_FirstName),'')+ ' ' + COALESCE(dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_LastName),''), COALESCE( dbo.fn_ReplaceSpecialCharsForJSON(vpc.DescriptionOfClient),'') ), 'N/A') + '",' +
									'"Address":"' + dbo.fnt_String_Escape( concat(  ISNULL(REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_Address),'"','') ,' ') , isnull(dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_Address), REPLACE(dbo.fn_ReplaceSpecialCharsForJSON(vpc.Address),'"','')) , ' ' , ISNULL( dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_Town), '') , ' ' , isnull(dbo.fn_ReplaceSpecialCharsForJSON(do.Sender_Department),'')),'json') + '",' +
									'"Phone":"' +  isnull( isnull(do.Sender_Phone, '')  ,'N/A') + '",' +
									--'"PiecesDry":"' + CONVERT(varchar,isnull((select (sum(isnull(do.Pieces_Dry,0)))),0))  + '",' +
									--'"PiecesCold":"' + CONVERT(varchar,isnull((select (sum(isnull(do.Pieces_Cold,0)))),0))  + '",' +
									'"ScheduleStart":"' +   ''  + '",' +
									'"ScheduleEnd":"' +     ''   + '",' +
									'"Photo":"' + ISNULL( (select top 1 vpi.PathImage from dbo.ImagesByVisitPoint vpi
															where vpi.CodeOfReference =VPC.CodeOfReference 
															order by DateCreated desc) ,'#')  + '",' +
									'"Latitude":"' + convert(varchar, isnull(vpc.Latitude,0) )  + '",' +
									'"Longitude":"' + convert(varchar, isnull(vpc.Longitude,0) )  + '",' +
									'"Precision":"' + convert(varchar, isnull(vpc.Accuracy,0) )  +  '",' +
									'"Status":"' + convert(varchar,isnull(gs.ServiceStatusId,7)) +  '",' +
									'"CurrencySymbol":"' +     'Q.'   + '",' +
								--	'"Summary":' + @jsonResult8 + ',' +
								CASE WHEN do.IdDeliveryOption = @IdDeliveryOption THEN
									'"TotalServiceAmount":"0",' 
									ELSE
									'"TotalServiceAmount":"' + convert( varchar,isnull(gt.AmountToPay,0))  + '",' 
									END +
									CASE WHEN do.IdDeliveryOption = @IdDeliveryOption THEN
								    '"TotalReturnAmount":"0",' 
									ELSE
									'"TotalReturnAmount":"' + convert( varchar,isnull(gt.ReturnRates,0))  + '",' 
									END +
									CASE WHEN do.IdDeliveryOption = @IdDeliveryOption THEN
									'"TotalAmount":"0",' 
									ELSE
									'"TotalAmount":"' + convert( varchar,isnull(gt.AmountToPay + gt.ReturnRates,0))  + '",' 
									END +
									'"PiecesList":[' + (select stuff((SELECT ','+    '"' +   isnull(CONCAT(isnull(convert(varchar,dop.GuideSerie), 'N/A') ,isnull(convert(varchar,dop.GuideNumber), 'N/A'), '-' ,isnull(convert(varchar,dop.NoPiece), 'N/A' )  ) , 'N/A') +  '"'  
											 	from ServiceManagement sm WITH (NOLOCK)
											join SenderReceiver sr  WITH (NOLOCK) ON (sr.ID = sm.IdPuCourrier)
											join PieceByService ps WITH (NOLOCK) on (ps.ServiceManagmentId = sm.IdServiceManagement)
											join DeliveryOrderPiece dop WITH (NOLOCK) on (dop.GuidePiece = ps.GuidePieceId)
											where sm.ServiceStatusId in ( 1,4,7,8) and sm.IdPuCourrier = @IdCourier and CONVERT(varchar,sm.DateCreated,103)  =  CONVERT(varchar,GETDATE(),103) and sm.IdServiceManagement = gs.IdServiceManagement
											FOR XML PATH ('')),1,1,'')) + ']' +
										+ '}' 
									from   
											#GuideService gs
											left join @Temp gt  on gt.GuideSerie = gs.GuideSerie and gt.GuideNumber = gs.GuideNumber
											join DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK) on do.Guide_Serie = gs.GuideSerie and do.Guide_Number = gs.GuideNumber 
											left join DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
									    on     VPC.CodeOfReference = do.Sender_ID
										group by gs.IdServiceManagement, do.Sender_Address,  VPC.CodeOfReference, do.Sender_FirstName, do.Sender_LastName,
										 VPC.DescriptionOfClient,  VPC.Address, do.Sender_Town, do.Sender_Department, do.Sender_Phone,  VPC.Latitude,  VPC.Longitude,  VPC.Accuracy
										 ,gs.ServiceStatusId, gt.AmountToPay, gt.ReturnRates,do.IdDeliveryOption
									--and CAST(DAT.Date_Created AS DATE) = CAST(@DateRoute AS DATE)
										FOR XML PATH(''), TYPE
											).value('.', 'varchar(max)'),1,1,''
													) )
		---------------------------------------------End Retuns Services --------------------------------------------------		

						
							/*
							select 
									',{"CodeOfReference":"' + convert( varchar,	isnull(vpc.CodeOfReference,0))  + '",' +
									'"IdPickup":"' +  isnull( convert(varchar,spk.SchedulePickupId) , '-1') + '",' +
									'"ServiceManagementId":"' +  isnull( convert(varchar,sma.IdServiceManagement) , 'N/A') + '",' +
									'"Sender":"' +  isnull(isnull(spk.SenderName,vpc.DescriptionOfClient), 'N/A') + '",' +
									'"Address":"' +  concat( ISNULL( isnull(spk.AddressPickup , vpc.Address) ,'N/A'), ' ' , vpc.Town , ' ' , vpc.Department) + '",' +
									'"Phone":"' +  isnull( isnull(spk.SenderPhone , vpc.Phone)  ,'N/A') + '",' +
									'"Pieces":"' + CONVERT(varchar,isnull((select (sum(isnull(ord.Pieces_Dry,0))+ sum(isnull(ord.Pieces_Cold,0))) pieces
																from dbo.DeliveryOrderPaymentDetail pay
																	left join dbo.DeliveryOrder ord on ord.Guide_Serie = pay.GuideSerie and ord.Guide_Number = pay.GuideNumber
																where pay.IdHeaderRecolection = spk.SchedulePickupId),0))  + '",' +
									'"ScheduleStart":"' +    substring( CONVERT(varchar, spk.StartDate  ,8),0,6)  + '",' +
									'"ScheduleEnd":"' +     substring(CONVERT(varchar, spk.EndDate  ,8),0,6)   + '",' +
									'"Photo":"' + '#'  + '",' +
									'"Latitude":"' + '0'  + '",' +
									'"Longitude":"' + '0'  + '",' +
									'"Precision":"' + '0'  +  '",' +
									'"Status":"' + convert(varchar,isnull(sma.ServiceStatusId,1))  +
										+ '"}'
									from dbo.RouteAssigment ras
									left join dbo.ServiceManagement sma on sma.IdPuRouteAssigment = ras.IdRouteAssigment
									left join dbo.SchedulePickup spk on spk.SchedulePickupId = sma.IdSchedulePickup
									left join dbo.VisitPointClient vpc on vpc.CodeOfReference = spk.SenderId 
										where ras.IdCurrierMan= @IdCurrier and ras.DateOfRoute = @DateRoute
					
								FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
											) )*/
		print CONCAT('@jsonResult3',ISNULL(@jsonResult3,'hay un valor null'))					
						If @jsonResult is null and @jsonResult2 is null and @jsonResult3 is null
						begin
							set @jsonResultErrror =(
										SELECT STUFF(( 
										SELECT '{{"IdResult":500,' 
										+ '"Message":" No se encontraron registros"}' 
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,''
											  ) 
										)
						end

						
						
							select ('[' + COALESCE(@jsonResultErrror,'') 
						+ CASE WHEN @jsonResult IS NOT NULL and @jsonResult2 Is null and @jsonResult3 Is null THEN CONCAT( @jsonResult ,'')  ELSE '' END 
						+ CASE WHEN @jsonResult IS NOT NULL and (@jsonResult2 IS NOT NULL OR @jsonResult3 IS NOT NULL) THEN CONCAT( @jsonResult ,',')  ELSE '' END 
						+ CASE WHEN @jsonResult2 IS NOT NULL and @jsonResult3 Is null THEN CONCAT( @jsonResult2 ,'')  ELSE '' END
						+ CASE WHEN @jsonResult2 IS NOT NULL and @jsonResult3 IS NOT NULL THEN CONCAT( @jsonResult2 ,',') ELSE '' END 
						+ COALESCE(@jsonResult3,'') +  ']') jsonResult

						IF OBJECT_ID('tempdb.dbo.#GuideService', 'U') IS NOT NULL DROP TABLE #GuideService;

						--select ('[' + COALESCE(@jsonResult,'') 
						--+ CASE WHEN @jsonResult IS NOT NULL THEN ',' ELSE '' END 
						--+ CASE WHEN @jsonResult2 IS NOT NULL THEN ',' ELSE ''',' END    
						--+ COALESCE(@jsonResult3,'') + ']') jsonResult



	end
						
		else if(@TokenAct = 0 or @TokenAct is null or @hourtoken > 8)
		begin 
			  print 'token inválido'
					SET @jsonToken = (
				   SELECT STUFF((
		   			SELECT  
					',{"IdResult":' + '403' + ',' +
					'"DescriptionError":"' + 'Token inválido'  + '"' +	  	  
					'}' 
					FOR XML PATH(''), TYPE
				   ).value('.', 'varchar(max)'),1,1,''
		   					  ) 
				   )
					 select '['+ @jsonToken + ']' jsonToken
	
				   return
		end
END