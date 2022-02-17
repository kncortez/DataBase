use DeliveryBackOffice
go
alter table DeliveryOrderPiece ADD
IsPickup bit null
go 
Alter Table DeliveryOrderPiece ADD
	IsDry bit null Default 1
go

