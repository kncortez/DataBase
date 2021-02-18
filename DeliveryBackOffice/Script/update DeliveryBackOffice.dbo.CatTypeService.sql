use DeliveryBackOffice
go
/* DATE: 12/02/2021 */
update DeliveryBackOffice.dbo.CatTypeService
set CtsDescription =  'Entrega el mismo día' 
where CtsShortName  = 'SDD' and CtsRowStatus = 1 

update DeliveryBackOffice.dbo.CatTypeService
set CtsDescription =  'Entrega al siguiente día' 
where CtsShortName  = 'NDD' and CtsRowStatus = 1 
