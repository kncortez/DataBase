USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_returned_product_IGSS]    Script Date: 2/09/2020 11:19:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Carlos Cano>
-- Create date: <02/09/2020>
-- Description:	<Reporte de producto retornado al origen>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_origin_returned]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	SET NOCOUNT ON;

	select distinct
	w.Guide_Serie + cast(w.guide_number as varchar) as guide,
	do.Receiver_FirstName + ' ' + do.Receiver_LastName as receiver,
	(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(w.Guide_Serie,w.Guide_Number)) as [Ubicacion_Bodega],
	datediff(DAY, SUBQ.Date_Created, GETDATE()) as Days_Overdue
	from DeliveryBackOffice.dbo.Warehouse w,
	(
		select 
			dod.Guide_serie, 
			dod.Guide_number,
			max(dod.datecreated) as Date_Created
		from DeliveryBackOffice.dbo.DeliveryOrderDetail dod with(nolock)
		where StatusOrderId = 6
		group by dod.Guide_Serie, dod.Guide_Number
	) as SUBQ
	JOIN DeliveryBackOffice.dbo.DeliveryOrder do with(nolock) on do.Guide_Serie = subq.guide_serie and do.Guide_Number = subq.guide_number
	where w.Active = 1
	AND SUBQ.Date_Created <=  GETDATE() - 1
	AND SUBQ.Guide_Serie = w.Guide_Serie and SUBQ.Guide_Number = w.Guide_Number
	ORDER BY Days_Overdue

END
GO


