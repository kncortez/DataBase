/*
-- NO APLICA (basado en fecha de despacho)
select 
	da.Guide_Serie + cast(da.guide_number as varchar) as guide,
	do.Receiver_FirstName + ' ' + do.Receiver_LastName as receiver,
	w.Rack_Position,
	datediff(DAY, da.Date_Created, GETDATE()) as Days_Overdue
from DeliveryBackOffice.dbo.DeliveryAttempt da
join DeliveryBackOffice.dbo.DeliveryOrder do on do.Guide_Serie = da.Guide_Serie and do.Guide_Number = da.Guide_Number
join DeliveryBackOffice.dbo.Warehouse w on w.Guide_Serie = da.Guide_Serie and w.Guide_Number = da.Guide_Number
where da.Date_Created between GETDATE() - 5  AND GETDATE() - 1
order by Date_Created desc


-- TODO EL PRODUCTO ACTIVO EN BODEGA CON REGISTRO 1 DÍA HACIA ATRÁS
select
	SUBQ.Guide_Serie + cast(SUBQ.guide_number as varchar) as guide,
	do.Receiver_FirstName + ' ' +do.Receiver_LastName as receiver,
	w.Rack_Position,
	datediff(DAY, SUBQ.Date_Created, GETDATE()) as Days_Overdue
FROM
(
-- TODAS LAS GUÍAS CON ESTADO ARRIBÓ
	select
		dod1.Guide_Serie,
		dod1.Guide_Number,
		max(dod1.DateCreated) as Date_Created
	from deliverybackoffice.dbo.deliveryorderdetail dod1
	where dod1.StatusOrderId = 11
	group by dod1.Guide_Serie, dod1.Guide_Number
) AS SUBQ
--
join DeliveryBackOffice.dbo.DeliveryOrder do on do.Guide_Serie = SUBQ.Guide_Serie and do.Guide_Number = SUBQ.Guide_Number
join DeliveryBackOffice.dbo.Warehouse w on w.Guide_Serie = SUBQ.Guide_Serie and w.Guide_Number = SUBQ.Guide_Number AND w.Active = 1
where SUBQ.Date_Created <=  GETDATE() - 1
order by datediff(DAY, SUBQ.Date_Created, GETDATE()) desc
*/


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
order by Days_Overdue
