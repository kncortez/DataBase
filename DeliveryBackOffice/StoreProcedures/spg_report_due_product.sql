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
-- Description:	<Reporte de producto con tiempo de entrega vencido>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_due_product]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	SET NOCOUNT ON;

	-- TODAS LAS GUÍAS CON ESTADO ARRIBÓ CON FECHA DE REGISTRO 1 DÍA HACIA ATRÁS
	select distinct
	SUBQ.Guide_Serie + cast(SUBQ.guide_number as varchar) as guide,
	do.Receiver_FirstName + ' ' + do.Receiver_LastName as receiver,
	SUBQ.Rack_Position,
	datediff(DAY, dod.DateCreated, GETDATE()) as Days_Overdue
	FROM
	-- TODO EL PRODUCTO ACTIVO EN BODEGA
	(
	select
		w.Guide_Serie,
		w.Guide_Number,
		w.Rack_Position
	from DeliveryBackOffice.dbo.Warehouse w with(nolock)
	where Active = 1
	) AS SUBQ
	--
	join deliverybackoffice.dbo.deliveryorderdetail dod with(nolock) on dod.Guide_Serie = SUBQ.Guide_Serie and dod.Guide_Number = SUBQ.Guide_Number and dod.StatusOrderId = 11
	join DeliveryBackOffice.dbo.DeliveryOrder do with(nolock) on do.Guide_Serie = SUBQ.Guide_Serie and do.Guide_Number = SUBQ.Guide_Number
	where dod.DateCreated <=  GETDATE() - 1
	AND (SUBQ.Rack_Position NOT LIKE '%(92)%' AND SUBQ.Rack_Position NOT LIKE '%(93)%')
	order by Days_Overdue

END
GO


