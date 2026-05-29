
-- =============================================
-- Author:		<Carlos Cano>
-- Create date: <02/09/2020>
-- Description:	<Reporte de producto con tiempo de entrega vencido>
-- =============================================
-- Modified:	<Brandon Pedroza>
-- Create date: <14/06/2024>
-- Description:	<Se agrega parametro para filtrar guias por pais de origen>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_due_product]
	-- Add the parameters for the stored procedure here
	@IdCountry AS NVARCHAR(2)='GT'
AS
BEGIN

	SET NOCOUNT ON;

	-- TODAS LAS GUÍAS CON ESTADO ARRIBÓ CON FECHA DE REGISTRO 1 DÍA HACIA ATRÁS
	select distinct
	SUBQ.Guide_Serie + cast(SUBQ.guide_number as varchar) as guide,
	isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') as receiver,
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
	inner join DeliveryBackOffice.dbo.DeliveryOrder do with(nolock)
	on do.Guide_Serie = w.Guide_Serie 
    AND do.Guide_Number = w.Guide_Number 
	where Active = 1
	and iif(do.SenderCountryId is null, 'GT', do.SenderCountryId)=@IdCountry
	) AS SUBQ
	--
	inner join deliverybackoffice.dbo.deliveryorderdetail dod with(nolock) on dod.Guide_Serie = SUBQ.Guide_Serie and dod.Guide_Number = SUBQ.Guide_Number
	inner join DeliveryBackOffice.dbo.DeliveryOrder do with(nolock) on do.Guide_Serie = SUBQ.Guide_Serie and do.Guide_Number = SUBQ.Guide_Number
	where dod.DateCreated <=  GETDATE() - 1
	AND (SUBQ.Rack_Position NOT LIKE '%(92)%' AND SUBQ.Rack_Position NOT LIKE '%(93)%')
	and iif(do.SenderCountryId is null, 'GT', do.SenderCountryId)=@IdCountry
	and dod.StatusOrderId = 11
	order by Days_Overdue

END