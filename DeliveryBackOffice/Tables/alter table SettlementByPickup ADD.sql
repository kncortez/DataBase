USE DeliveryBackOffice
GO

alter table SettlementByPickup ADD
SequenceCode bigint null,
SubTypeServiceManagmentId  int null,
StartingKilometers nvarchar(50) null,
ArrivalKilometers nvarchar(50) null
go



--select * from SettlementByPickup