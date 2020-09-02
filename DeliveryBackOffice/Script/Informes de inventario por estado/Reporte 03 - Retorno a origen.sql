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


--select 
--	*
--from DeliveryBackOffice.dbo.DeliveryOrderDetail dod
--where Guide_number = 31506
--order by DateCreated desc

--select *
--from DeliveryBackOffice.dbo.Warehouse w
--where Guide_Number = 31506
--and w.Active = 1

