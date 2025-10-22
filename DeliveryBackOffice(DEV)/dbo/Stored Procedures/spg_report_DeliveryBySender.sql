-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <21/10/2020>
-- Description:	<Reporte por manifiesto declarado>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_DeliveryBySender]
@StartDate	 DATE = '2020-10-03'
,@EndDate	 DATE = '2020-11-05'
AS
BEGIN

IF OBJECT_ID('tempdb..#ListRoutes') IS NOT NULL
BEGIN
 DROP TABLE #ListRoutes			
END

IF OBJECT_ID('tempdb..#ListAttempt') IS NOT NULL
BEGIN
 DROP TABLE #ListAttempt
END



select Guide_Serie,Guide_Number,StatusOrderId,DateCreated 
into #ListRoutes
from DeliveryBackOffice.dbo.DeliveryOrderDetail with (nolock)
where StatusOrderId = 4
and CONVERT(VARCHAR, DateCreated, 23) >= CONVERT(VARCHAR, @StartDate, 23)
and CONVERT(VARCHAR, DateCreated, 23) <= CONVERT(VARCHAR, @EndDate, 23)

select CONVERT(DATE, lstr.DateCreated, 23) DateCreated
,Sender.ID SenderID
,Sender.First_Name + ' ' + Sender.Last_Name SenderName
,Sender.CUI
,lstr.Guide_Serie,lstr.Guide_Number
,coalesce(case when Att.Delivered = 1 then 1 else 0 end,0) Delivered
,coalesce(case when Accepted = 1 then 1 else 0 end ,0) Accepted
into #ListAttempt
from DeliveryBackOffice.dbo.DeliveryAttempt Att with (nolock)
inner join #ListRoutes lstr on Att.Guide_Serie = lstr.Guide_Serie
and Att.Guide_Number = lstr.Guide_Number
inner join DeliveryBackOffice.dbo.SenderReceiver Sender
on Att.ID_Courier= Sender.ID

select DateCreated
,SenderID
,SenderName
,CUI
,count(*) DeliveriesDespatched
,sum(Delivered) DeliveriesDone
,sum(Accepted) DelivieriesAccepted
,sum(Accepted)/count(*)*100 CompliancePercentage
from #ListAttempt
group by DateCreated,SenderName,CUI,SenderID

/*
--DECLARE	@PreprationDate DATE = '2020-06-24'
select do.Preparation_Date,
	do.Manifest_Serie,
	do.Manifest_Number,
	do.Guide_Serie,
	do.Guide_Number,
	do.Sender_FirstName + do.Sender_LastName as Sender,
	do.Pieces_Dry as Pieces_Dry_Declared,
	do.Pieces_Cold as Pieces_Cold_Declared,
	do.Receiver_FirstName +' '+ do.Receiver_LastName ReceiverName
into #HeaderDeliveryOrder
from DeliveryBackOffice.dbo.DeliveryOrder do
where CONVERT(VARCHAR, Preparation_Date, 23) = CONVERT(VARCHAR, @PreparationDate, 23)

--Piezas arribadas
select det.Guide_Serie,det.Guide_Number,
do.Manifest_Serie,
do.Manifest_Number,
sum(case when Temperature_Celsius is null then 1 else 0 end) Pieces_Dry_Arrived,
sum(case when Temperature_Celsius is null then 0 else 1 end) Pieces_Cold_Arrived
into #Pieces_Arrived
from #HeaderDeliveryOrder do
join DeliveryOrderDetail det on do.Guide_Serie = det.Guide_Serie
and do.Guide_Number = det.Guide_Number and det.StatusOrderId = 11
group by det.Guide_Serie,det.Guide_Number,do.Manifest_Serie,
do.Manifest_Number


/*
select * from #Pieces_Arrived

select * from DeliveryBackOffice.dbo.DeliveryOrderDetail
where Guide_Number = 12643 and StatusOrderId = 11

update DeliveryBackOffice.dbo.DeliveryOrderDetail
set StatusOrderId = 12
where Guide_Number = 12643 and StatusOrderId = 11
and DateCreatedInSystem = '2020-08-02 20:47:36.850'
*/
select CONVERT(varchar, head.Preparation_Date, 103) Preparation_Date,
	head.Manifest_Serie + 
	CAST(head.Manifest_Number as varchar) Manifest,
	head.Sender,
	head.Guide_Serie + CAST(head.Guide_Number as varchar) Guide,	
    head.ReceiverName,
	head.Pieces_Dry_Declared - coalesce(arrv.Pieces_Dry_Arrived,0) NotDryArrived,
	head.Pieces_Cold_Declared -coalesce(arrv.Pieces_Cold_Arrived,0) NotColdDryArrived
--	coalesce(sum(arrv.Pieces_Dry_Arrived),0) Pieces_Dry_Arrived,
--	coalesce(sum(arrv.Pieces_Cold_Arrived),0) Pieces_Cold_Arrived
from #HeaderDeliveryOrder head
left join #Pieces_Arrived arrv on 
    head.Guide_Serie = arrv.Guide_Serie
and head.Guide_Number = arrv.Guide_Number
and head.Manifest_Serie = arrv.Manifest_Serie 
and head.Manifest_Number= arrv.Manifest_Number
and 
(arrv.Pieces_Dry_Arrived < head.Pieces_Dry_Declared
or arrv.Pieces_Cold_Arrived < head.Pieces_Cold_Declared
)

*/
END