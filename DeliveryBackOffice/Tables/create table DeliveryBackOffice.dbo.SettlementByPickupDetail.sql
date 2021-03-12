

USE [DeliveryBackOffice]
GO
create table DeliveryBackOffice.dbo.SettlementByPickupDetail
(IdSettlementByPickupDetail int Identity (1,1) PRIMARY KEY NOT NULL,
SettlementByPickupId int NULL,
GuideSerie nvarchar(2) NOT NULL,
GuideNumber int  NOT NULL,
RowStatus bit   NULL,
TokenCreated nvarchar(150)  NOT NULL,
DateCreated datetime  NOT NULL,
TokenUpdated nvarchar(150)   NULL,
DateUpdated datetime   NULL,
IsPieceLiquidaded bit NULL,
CONSTRAINT FKSettlementByPickupId FOREIGN KEY (SettlementByPickupId) REFERENCES SettlementByPickup(Id)
)
go





--select * from SettlementByPickup
--select * from SettlementByPickupDetail
----select * from DeliveryOrder
----select * from DeliveryOrderDetail
