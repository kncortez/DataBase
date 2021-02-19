USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatTypeVehicle 
   (IdTypeVehicle  int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	Name varchar(100) NOT NULL,
	Description varchar(200) NOT NULL,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL)
GO  

insert into DeliveryBackOffice.dbo.CatTypeVehicle  
	(Name
	,Description
	,RowStatus
	,TokenCreated
	,DateCreated)
Values('Camión','Camión',1,'SYS-CAQUINO',GETDATE())
	,('Panel','Panel ',1,'SYS-CAQUINO',GETDATE())
	,('Motocicleta','Motocicleta',1,'SYS-CAQUINO',GETDATE())
	,('Sedan','Sedan',1,'SYS-CAQUINO',GETDATE())
	,('Pickup','Pickup',1,'SYS-CAQUINO',GETDATE())
	,('Pickup 4x4','Pickup 4x4',1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.CatTypeVehicle  