USE DeliveryBackOffice
GO

create table DeliveryBackOffice.dbo.CouriermanPhone
(IdCouriermanPhone int Identity (1,1) PRIMARY KEY NOT NULL,
SenderReceiverId int  NULL,
NirPhone nvarchar(20) NULL,
Phone nvarchar (100) NULL,
RowStatus bit   NULL,
TokenCreated nvarchar(150)  NOT NULL,
DateCreated datetime  NOT NULL,
TokenUpdated nvarchar(150)   NULL,
DateUpdated datetime   NULL,
CONSTRAINT FKSenderReceiver FOREIGN KEY (SenderReceiverId) REFERENCES SenderReceiver(ID)
)
go