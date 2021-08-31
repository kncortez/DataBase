USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_daily_route]    Script Date: 27/08/2021 09:59:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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


/*
EXEC [dbo].[spws_get_daily_route]
@DateRoute = '2021-03-10'
,@IdCurrier = 3
*/

ALTER PROCEDURE [dbo].[spws_get_daily_route]
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
	

	if (@TokenAct = 1 and @hourtoken <= 8)
		begin 


						set @jsonResult = (SELECT STUFF(( 
							
							select 
									',
									{									
                                    "ServiceType":"' + 'Pickup'  + '",' +
									'"CodeOfReference":"' + convert( varchar,isnull(vpc.CodeOfReference,0))  + '",' +
									'"Id":"' +  isnull( convert(varchar,spk.SchedulePickupId) , '-1') + '",' +
									'"ServiceManagementId":"' +  isnull( convert(varchar,sma.IdServiceManagement) , 'N/A') + '",' +
									'"Sender":"' +  isnull(isnull(spk.SenderName,vpc.DescriptionOfClient), 'N/A') + '",' +
									'"Address":"' +  dbo.fnt_String_Escape(concat( ISNULL( isnull(replace(spk.AddressPickup,'"','') , REPLACE(vpc.Address,'"','')) ,'N/A'), ' ' , vpc.Town , ' ' , vpc.Department),'json') + '",' +
									'"Phone":"' +  isnull( isnull(spk.SenderPhone , vpc.Phone)  ,'N/A') + '",' +
									'"PiecesDry":"' + CONVERT(varchar,isnull((select iif(sum(isnull(ord.Pieces_Dry,0)) =0, (isnull(sum(sc.QuantityOverDimensionedPackage),0) + isnull(sum(sc.QuantityRegularPackages),0))  ,sum(isnull(ord.Pieces_Dry,0)) ) pieces
																from dbo.DeliveryOrderPaymentDetail pay
																	left join dbo.DeliveryOrder ord on ord.Guide_Serie = pay.GuideSerie and ord.Guide_Number = pay.GuideNumber
																	left join dbo.SchedulePickup sc on sc.SchedulePickupId = pay.IdHeaderRecolection
																where pay.IdHeaderRecolection = spk.SchedulePickupId),0))  + '",' +
									'"PiecesCold":"' + CONVERT(varchar,isnull((select sum(isnull(ord.Pieces_Cold,0)) pieces
										 from dbo.DeliveryOrderPaymentDetail pay
										 left join dbo.DeliveryOrder ord on ord.Guide_Serie = pay.GuideSerie and ord.Guide_Number = pay.GuideNumber
										 where pay.IdHeaderRecolection = spk.SchedulePickupId),0))  + '",' +
									'"ScheduleStart":"' +    substring( CONVERT(varchar, spk.StartDate  ,8),0,6)  + '",' +
									'"ScheduleEnd":"' +     substring(CONVERT(varchar, spk.EndDate  ,8),0,6)   + '",' +
									'"Photo":"' + ISNULL( (select top 1 vpi.PathImage from dbo.ImagesByVisitPoint vpi
															where vpi.CodeOfReference =VPC.CodeOfReference 
															order by DateCreated desc) ,'#')  + '",' +
									'"Latitude":"' + convert(varchar, isnull(vpc.Latitude,0) )  + '",' +
									'"Longitude":"' + convert(varchar, isnull(vpc.Longitude,0) )  + '",' +
									'"Precision":"' + convert(varchar, isnull(vpc.Accuracy,0) )  +  '",' +
									'"Price":"' + '0'  +  '",' +
									'"Pickup":"' + '0'  +  '",' +
									'"customerName":"' +   ' ' + '",' +
									'"alterName":"' +   ' ' + '",' +
									'"Status":"' + convert(varchar,isnull(sma.ServiceStatusId,1))  +
										+ '"}'
									from dbo.RouteAssigment ras
									left join dbo.ServiceManagement sma on sma.IdPuRouteAssigment = ras.IdRouteAssigment
									left join dbo.SchedulePickup spk on spk.SchedulePickupId = sma.IdSchedulePickup
									left join dbo.VisitPointClient vpc on vpc.CodeOfReference = spk.SenderId 
										where 
										ras.IdCurrierMan= @IdCourier 
										and ras.DateOfRoute = @DateRoute
								
									
					
								FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
											) )


						set @jsonResult2 = (SELECT STUFF(( 
						select  distinct
									',
									{									
                                    "ServiceType":"' +  'Delivery'  + '",' +
									'"CodeOfReference":"' + convert( varchar,isnull(vpc.CodeOfReference,0))  + '",' +
									'"Id":"' +  isnull( convert(varchar,DOR.Guide_Serie + CONVERT(varchar,DOR.Guide_Number)) , '-1') + '",' +
									'"ServiceManagementId":"' +  isnull( convert(varchar,0) , 'N/A') + '",' +
									'"Sender":"'  +  isnull(isnull(COALESCE(DOR.Sender_FirstName,'')+ ' ' + COALESCE(DOR.Sender_LastName,''),vpc.DescriptionOfClient), 'N/A') + '",' +
									'"Address":"' + dbo.fnt_String_Escape( concat( ISNULL( isnull(REPLACE(DOR.Receiver_Address,'"',''), REPLACE(vpc.Address,'"','')) ,'N/A'), ' ' , vpc.Town , ' ' , vpc.Department),'json') + '",' +
									'"Phone":"' +  isnull( isnull(DOR.Receiver_Phone , dor.Receiver_Alternant_Phone)  ,'N/A') + '",' +
									'"PiecesDry":"' + CONVERT(varchar,isnull((select (sum(isnull(DOR2.Pieces_Dry,0))) pieces
										 from DeliveryBackOffice.dbo.DeliveryOrder DOR2
										 where DOR2.Guide_Serie = DAT.Guide_Serie
										 and DOR2.Guide_Number = DAT.Guide_Number
																),0))  + '",' +
									'"PiecesCold":"' + CONVERT(varchar,isnull((select (sum(isnull(DOR2.Pieces_Cold,0))) pieces
										 from DeliveryBackOffice.dbo.DeliveryOrder DOR2
										 where DOR2.Guide_Serie = DAT.Guide_Serie
										 and DOR2.Guide_Number = DAT.Guide_Number
																),0))  + '",' +
									'"ScheduleStart":"' +   ''  + '",' +
									'"ScheduleEnd":"' +     ''   + '",' +
									'"Photo":"' + ISNULL( (select top 1 vpi.PathImage from dbo.ImagesByVisitPoint vpi
															where vpi.CodeOfReference =VPC.CodeOfReference 
															order by DateCreated desc) ,'#')  + '",' +
									'"Latitude":"' + convert(varchar, isnull(vpc.Latitude,0) )  + '",' +
									'"Longitude":"' + convert(varchar, isnull(vpc.Longitude,0) )  + '",' +
									'"Precision":"' + convert(varchar, isnull(vpc.Accuracy,0) )  +  '",' +
									'"Price_COD":"' + CONVERT(varchar,isnull(DOR.Collect_OnDelivery,0))  +  '",' +
									'"Price":"' + CONVERT(varchar,iif(isnull(DOR.IsCollect ,0)=1, isnull(DOR.PriceShippment,0),0 ))  +  '",' +
									'"Pickup":"' + CONVERT(varchar,isnull((SELECT top 1
										iif(isnull(dp.TimePlaId,0) = 3 ,sc.AmountPickup,0)
										FROM dbo.DeliveryOrderPaymentDetail dp
										left join dbo.SchedulePickup sc on sc.SchedulePickupId = dp.IdHeaderRecolection
										where dp.GuideNumber = DOR.Guide_Number AND DP.GuideSerie = DOR.Guide_Serie
										),0) )  +  '",' +
									'"customerName":"' +    isnull(REPLACE(DOR.Receiver_FirstName,'"',''),'N/A') + '",' +
									'"alterName":"' +   isnull(isnull(REPLACE(DOR.Receiver_Alternant_FullName,'"',''),REPLACE(dor.Receiver_FirstName,'"','')),'N/A') + '",' +
									'"Status":"' + convert(varchar,isnull(DOR.StatusOrderId,4))  +
										+ '"}' 
									from (select distinct Guide_Serie,Guide_Number,ID_Courier 
									     from dbo.DeliveryAttempt 
										 where CAST(Date_Created AS DATE) = CAST(@DateRoute AS DATE)
										 ) DAT /*dbo.DeliveryAttempt DAT*/
									join DeliveryBackOffice.dbo.DeliveryOrder DOR
									    on      DAT.Guide_Serie = DOR.Guide_Serie
											and DAT.Guide_Number = DOR.Guide_Number
											and DOR.StatusOrderId in (4,5,12) --En ruta|entregado|Intento de entrega fallida(incidencia)|Devolución
									join DeliveryBackOffice.dbo.DeliverySettlementDetail DSD
										on     DSD.Guide_Serie = DAT.Guide_Serie 
										   and DSD.Guide_Number = DAT.Guide_Number
									join DeliveryBackOffice.dbo.DeliveryOrderBySettlement DOS
									    on     DOS.ID = DSD.ID_DeliveryOrderBySettlement
										   and DOS.ID_Courier = DAT.ID_Courier
									left join DeliveryBackOffice.dbo.VisitPointClient VPC
									    on     VPC.CodeOfReference = DOR.Sender_ID
									where
									DAT.ID_Courier = @IdCourier 
									--and CAST(DAT.Date_Created AS DATE) = CAST(@DateRoute AS DATE)
								FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
											) )
							
-----------------------------Start Sumary, ListGuides Return----------------------------------------------
		
		IF OBJECT_ID('tempdb.dbo.#GuideService', 'U') IS NOT NULL DROP TABLE #GuideService;

select sm.IdServiceManagement, dp.GuideSerie, dp.GuideNumber, sm.ServiceStatusId, sm.IdPuCourrier
Into #GuideService
from dbo.RouteAssigment ra
	left join dbo.ServiceManagement sm on sm.IdPuRouteAssigment = ra.IdRouteAssigment
	left join dbo.PieceByService ps on ps.ServiceManagmentId = sm.IdServiceManagement
	left join dbo.DeliveryOrderPiece dp on dp.GuidePiece = ps.GuidePieceId
where  
CONVERT(varchar,ra.DateOfRoute,103)  =  CONVERT(varchar,GETDATE(),103)
and ra.IdCurrierMan = @IdCourier
and sm.SubTypeServiceManagmentId = 3
declare @guides nvarchar (MAX) = (select stuff((select ','+concat(GuideSerie,GuideNumber) from #GuideService
											FOR XML PATH ('')),1,1,''))
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
				@InTime = 1,
				@IsReturn = 1,
				@CodeApp = 'SIFDCECOM300720201459',
				@IdModule = 1,
				@Token = @Token


	

--------------------------------End Sumary,ListGuides Return----------------------------------------------------------------------


-----------------------Start Retuns Services ---------------------------------------------
								set @jsonResult3 = (SELECT STUFF(( 
									 select  distinct
									',
									{									
                                                "ServiceType":"' +  'Return'  + '",' +
									'"CodeOfReference":"' + convert( varchar,isnull(vpc.CodeOfReference,0))  + '",' +
									'"ServiceManagementId":"' +  isnull( convert(varchar, gs.IdServiceManagement ,0) , 'N/A') + '",' +
									'"Sender":"'  +  isnull(isnull(COALESCE(do.Sender_FirstName,'')+ ' ' + COALESCE(do.Sender_LastName,''), COALESCE( vpc.DescriptionOfClient,'') ), 'N/A') + '",' +
									'"Address":"' + dbo.fnt_String_Escape( concat(  ISNULL(REPLACE(do.Sender_Address,'"','') ,' ') , isnull(do.Sender_Address, REPLACE(vpc.Address,'"','')) , ' ' , ISNULL( do.Sender_Town, '') , ' ' , isnull(do.Sender_Department,'')),'json') + '",' +
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
									'"TotalServiceAmount":"' + convert( varchar,isnull(gt.AmountToPay,0))  + '",' +
									'"TotalReturnAmount":"' + convert( varchar,isnull(gt.ReturnRates,0))  + '",' +
									'"TotalAmount":"' + convert( varchar,isnull(gt.AmountToPay + gt.ReturnRates,0))  + '",' +
									'"PiecesList":[' + (select stuff((SELECT ','+    '"' +   isnull(CONCAT(isnull(convert(varchar,dop.GuideSerie), 'N/A') ,isnull(convert(varchar,dop.GuideNumber), 'N/A'), '-' ,isnull(convert(varchar,dop.NoPiece), 'N/A' )  ) , 'N/A') +  '"'  
											 	from ServiceManagement sm 
											join SenderReceiver sr on (sr.ID = sm.IdPuCourrier)
											join PieceByService ps on (ps.ServiceManagmentId = sm.IdServiceManagement)
											join DeliveryOrderPiece dop on (dop.GuidePiece = ps.GuidePieceId)
											where sm.ServiceStatusId in ( 1,4,7,8) and sm.IdPuCourrier = @IdCourier and CONVERT(varchar,sm.DateCreated,103)  =  CONVERT(varchar,GETDATE(),103) and sm.IdServiceManagement = gs.IdServiceManagement
											FOR XML PATH ('')),1,1,'')) + ']' +
										+ '}' 
									from   
											#GuideService gs
											left join @Temp gt  on gt.GuideSerie = gs.GuideSerie and gt.GuideNumber = gs.GuideNumber
											join DeliveryBackOffice.dbo.DeliveryOrder do on do.Guide_Serie = gs.GuideSerie and do.Guide_Number = gs.GuideNumber 
											left join DeliveryBackOffice.dbo.VisitPointClient VPC
									    on     VPC.CodeOfReference = do.Sender_ID
										group by gs.IdServiceManagement, do.Sender_Address,  VPC.CodeOfReference, do.Sender_FirstName, do.Sender_LastName,
										 VPC.DescriptionOfClient,  VPC.Address, do.Sender_Town, do.Sender_Department, do.Sender_Phone,  VPC.Latitude,  VPC.Longitude,  VPC.Accuracy
										 ,gs.ServiceStatusId, gt.AmountToPay, gt.ReturnRates
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





