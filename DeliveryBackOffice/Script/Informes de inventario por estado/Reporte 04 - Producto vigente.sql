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


--select 
--	*
--from DeliveryBackOffice.dbo.DeliveryOrderDetail dod
--where Guide_number = 31506
--order by DateCreated desc

--select *
--from DeliveryBackOffice.dbo.Warehouse w
--where Guide_Number = 31506
--and w.Active = 1

