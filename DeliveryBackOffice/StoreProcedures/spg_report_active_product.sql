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
-- Description:	<Reporte de producto vigente>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_active_product]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	SET NOCOUNT ON;

	SELECT * 
	FROM
	(
		select distinct
		w.Guide_Serie + cast(w.guide_number as varchar) as guide,
		do.Receiver_FirstName + ' ' + do.Receiver_LastName as receiver,
		(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(w.Guide_Serie,w.Guide_Number)) as [Ubicacion_Bodega],
		CONVERT(VARCHAR, w.DateCreated, 106) as Ingreso
		from DeliveryBackOffice.dbo.Warehouse w
		JOIN DeliveryBackOffice.dbo.DeliveryOrder do with(nolock) on do.Guide_Serie = w.guide_serie and do.Guide_Number = w.guide_number
		where w.Active = 1
		--AND w.DateCreated <=  GETDATE() - 1
	) AS SUBQ
	WHERE (SUBQ.Ubicacion_Bodega NOT LIKE '%(92)%' AND SUBQ.Ubicacion_Bodega NOT LIKE '%(93)%')
	ORDER BY SUBQ.Ingreso

END
GO


