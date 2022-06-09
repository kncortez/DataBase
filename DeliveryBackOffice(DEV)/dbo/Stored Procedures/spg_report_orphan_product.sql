
-- =============================================
-- Author:		<Carlos Cano>
-- Create date: <02/09/2020>
-- Description:	<Reporte de producto huérfano>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_orphan_product]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	SET NOCOUNT ON;

	select distinct
	w.Guide_Serie + cast(w.guide_number as varchar) as guide,
	isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') as receiver,
	(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(w.Guide_Serie,w.Guide_Number)) as [Ubicacion_Bodega],
	datediff(DAY, SUBQ.Date_Created, GETDATE()) as Days_Overdue
	from DeliveryBackOffice.dbo.Warehouse w,
	(
	select 
		dod.Guide_serie, 
		dod.Guide_number,
		max(dod.datecreated) as Date_Created
	from DeliveryBackOffice.dbo.DeliveryOrderDetail dod with(nolock)
	where StatusOrderId = 5
	group by dod.Guide_Serie, dod.Guide_Number
	) as SUBQ
	JOIN DeliveryBackOffice.dbo.DeliveryOrder do with(nolock) on do.Guide_Serie = subq.guide_serie and do.Guide_Number = subq.guide_number
	where w.Active = 1
	AND SUBQ.Date_Created <=  GETDATE() - 1
	AND SUBQ.Guide_Serie = w.Guide_Serie and SUBQ.Guide_Number = w.Guide_Number
	ORDER BY Days_Overdue



END
