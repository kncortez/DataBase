-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <21/10/2020>
-- Description:	<Reporte por manifiesto declarado>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_DeliveryBySender_header]
@StartDate	 DATE = '2020-10-03'
,@EndDate	 DATE = '2020-11-05'
AS
BEGIN
IF OBJECT_ID('tempdb..#ListRoutes') IS NOT NULL
BEGIN
 DROP TABLE #ListRoutes			
END

select Guide_Serie,Guide_Number,StatusOrderId,DateCreated 
into #ListRoutes
from DeliveryBackOffice.dbo.DeliveryOrderDetail WITH(NOLOCK)
where StatusOrderId = 4
and CONVERT(VARCHAR, DateCreated, 23) >= CONVERT(VARCHAR, @StartDate, 23)
and CONVERT(VARCHAR, DateCreated, 23) <= CONVERT(VARCHAR, @EndDate, 23)

select distinct
 Sender.ID
,isnull(Sender.First_Name,'') + ' ' + isnull(Sender.Last_Name,'') SenderName
,Sender.CUI
from DeliveryBackOffice.dbo.DeliveryAttempt Att WITH(NOLOCK)
join #ListRoutes lstr on Att.Guide_Serie = lstr.Guide_Serie
and Att.Guide_Number = lstr.Guide_Number
join DeliveryBackOffice.dbo.SenderReceiver Sender WITH(NOLOCK)
on Att.ID_Courier= Sender.ID

END