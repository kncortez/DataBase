USE DeliveryBackOffice
GO

alter table SettlementByPickup ADD
TokenUpdated nvarchar (50) null,
DateUpdated  datetime null
go