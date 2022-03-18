USE [DeliveryBackOffice]
GO


create table DeliveryBackOffice.dbo.SettlementByPickup
(Id int Identity (1,1) PRIMARY KEY NOT NULL,
RouteAssigmentId int NULL,
DatePrinted datetime NULL,
TokenCreated varchar(50)  NOT NULL,
DateCreated datetime  NOT NULL,
PiecesDry smallint NULL,
PiecesCold smallint NULL,
GuidesQuantity smallint NULL,
PiecesDryReceived smallint NULL,
PiecesColdReceived smallint NULL,
GuidesQuantityReceived smallint NULL
)
GO