-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <21/10/2020>
-- Description:	<Reporte por manifiesto declarado>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_DeliveryBySender_header_bnhl]
@StartDate	 DATE = '2020-10-03'
,@EndDate	 DATE = '2020-11-05'
AS
BEGIN
IF OBJECT_ID('tempdb..#ListRoutes') IS NOT NULL
BEGIN
 DROP TABLE #ListRoutes			
END

--4 Estado en ruta
select Guide_Serie,Guide_Number,StatusOrderId,DateCreated 
into #ListRoutes
from DeliveryBackOffice.dbo.DeliveryOrderDetail
where StatusOrderId = 4
and CONVERT(VARCHAR, DateCreated, 23) >= CONVERT(VARCHAR, @StartDate, 23)
and CONVERT(VARCHAR, DateCreated, 23) <= CONVERT(VARCHAR, @EndDate, 23)
--AND Guide_Number = 65031

select * from #ListRoutes

select distinct
-- Sender.ID
--,Sender.First_Name + ' ' + Sender.Last_Name SenderName
--,Sender.CUI
*
from DeliveryBackOffice.dbo.DeliveryAttempt Att
join #ListRoutes lstr on Att.Guide_Serie = lstr.Guide_Serie
and Att.Guide_Number = lstr.Guide_Number
--join DeliveryBackOffice.dbo.SenderReceiver Sender
--on Att.ID_Courier= Sender.ID
--and 
--Sender.ID = 31
and Att.ID_Courier = 6

/*
select * from DeliveryBackOffice.dbo.DeliveryAttempt
where Guide_Number = 65031

select * from DeliveryBackOffice.dbo.DeliveryOrder
where Guide_Number = 65031

select * from DeliveryBackOffice.dbo.DeliveryOrderDetail
where Guide_Number = 65031
and StatusOrderId = 4
order by 1 desc


*/
END