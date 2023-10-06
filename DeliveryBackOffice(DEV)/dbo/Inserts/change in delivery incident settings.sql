select HasConfirmationProcess,* from  [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH (NOLOCK)
where RowStatus = 1
and ServiceType = 'DELIVERY'
and HasConfirmationProcess = 0

--Todas las incidencias deben ser confirmadas
update [DeliveryBackOffice].[dbo].[CatTypeIncidence]
set HasConfirmationProcess = 1 --todas las incidencias deben ser validadas
where RowStatus = 1
and ServiceType = 'DELIVERY'
and HasConfirmationProcess = 0

update [DeliveryBackOffice].[dbo].[CatTypeIncidence]
set IsForcedIncidence = 1 --todas las incidencias son "incidencia en ruta"
where RowStatus = 1
and ServiceType = 'DELIVERY'
and IsForcedIncidence = 0

update [DeliveryBackOffice].[dbo].[CatTypeIncidence]
set ValidatesLocation = 0 --ya no importa la validación de geolocalización
where RowStatus = 1
and ServiceType = 'DELIVERY'
and ValidatesLocation = 1



