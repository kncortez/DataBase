use DeliveryBackOffice
go
/*
date: 12/02/2021
No cobrar fagil a los usuarios del portal
*/
update DeliveryBackOffice.dbo.RateByHub
set RbhFragileRate = 0
where RbhIdRate= 1