USE DeliveryBackOffice
GO

create table DeliveryBackOffice.dbo.CatTypeCourierman
(IdTypeCourierman int Identity (1,1) PRIMARY KEY NOT NULL,
Name nvarchar(200) NOT NULL,
RowStatus bit   NULL,
TokenCreated nvarchar(150)  NOT NULL,
DateCreated datetime  NOT NULL,
TokenUpdated nvarchar(150)   NULL,
DateUpdated datetime   NULL
)
go