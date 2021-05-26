USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_daily_route]    Script Date: 5/24/2021 11:10:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================
/*
EXEC [dbo].[spws_get_daily_route]
@DateRoute = '2021-03-10'
,@IdCurrier = 3
*/
ALTER PROCEDURE [dbo].[spws_get_daily_route]
	-- Add the parameters for the stored procedure here
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
									'"Address":"' +  dbo.fnt_String_Escape(concat( ISNULL( isnull(spk.AddressPickup , vpc.Address) ,'N/A'), ' ' , vpc.Town , ' ' , vpc.Department),'json') + '",' +
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
                                    "ServiceType":"' + iif( DOR.StatusOrderId =6,'Return', 'Delivery')  + '",' +
									'"CodeOfReference":"' + convert( varchar,isnull(vpc.CodeOfReference,0))  + '",' +
									'"Id":"' +  isnull( convert(varchar,DOR.Guide_Serie + CONVERT(varchar,DOR.Guide_Number)) , '-1') + '",' +
									'"ServiceManagementId":"' +  isnull( convert(varchar,0) , 'N/A') + '",' +
									'"Sender":"'  + iif(DOR.StatusOrderId =6, 'Forza Delivery',  isnull(isnull(COALESCE(DOR.Sender_FirstName,'')+ ' ' + COALESCE(DOR.Sender_LastName,''),vpc.DescriptionOfClient), 'N/A')) + '",' +
									'"Address":"' + dbo.fnt_String_Escape( concat( ISNULL(   iif(DOR.StatusOrderId =6, ISNULL(DOR.Sender_Address ,' ') , isnull(DOR.Receiver_Address, vpc.Address)) ,'N/A'), ' ' , vpc.Town , ' ' , vpc.Department),'json') + '",' +
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
									'"customerName":"' +  iif(DOR.StatusOrderId =6, isnull(isnull(COALESCE(DOR.Sender_FirstName,'')+ ' ' + COALESCE(DOR.Sender_LastName,''),vpc.DescriptionOfClient), 'N/A')  ,  isnull(DOR.Receiver_FirstName,'N/A')) + '",' +
									'"alterName":"' +   isnull(isnull(DOR.Receiver_Alternant_FullName,dor.Receiver_FirstName),'N/A') + '",' +
									'"Status":"' + convert(varchar,isnull(DOR.StatusOrderId,1))  +
										+ '"}' 
									from (select distinct Guide_Serie,Guide_Number,ID_Courier 
									     from dbo.DeliveryAttempt 
										 where CAST(Date_Created AS DATE) = CAST(@DateRoute AS DATE)
										 ) DAT /*dbo.DeliveryAttempt DAT*/
									join DeliveryBackOffice.dbo.DeliveryOrder DOR
									    on      DAT.Guide_Serie = DOR.Guide_Serie
											and DAT.Guide_Number = DOR.Guide_Number
											and DOR.StatusOrderId in (4,5,12,6) --En ruta|entregado|Intento de entrega fallida(incidencia)|Devolución
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
						If @jsonResult is null and @jsonResult2 is null
						begin
							set @jsonResult =(
										SELECT STUFF(( 
										SELECT '{{"IdResult":500,' 
										+ '"Message":" No se encontraron registros"}' 
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,''
											  ) 
										)
						end
						select ('[' + COALESCE(@jsonResult,'') 
						+ CASE WHEN @jsonResult IS NOT NULL THEN ',' ELSE '' END 
						+ COALESCE(@jsonResult2,'') +  ']') jsonResult
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