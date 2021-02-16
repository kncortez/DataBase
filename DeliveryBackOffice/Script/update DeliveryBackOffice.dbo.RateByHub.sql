use DeliveryBackOffice
go
/*
date: 12/02/2021
No cobrar fagil a los usuarios del portal
*/
update DeliveryBackOffice.dbo.RateByHub
set RbhFragileRate = 0
where RbhIdRate= 1
go 
/*16-02-2021
Para clientes portal 1% seguro
*/
update DeliveryBackOffice.dbo.RateByHub
set RbhInsuranceRate = 0.01 --1%
where RbhIdRate = 1 --clientes portal
