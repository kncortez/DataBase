USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.RouteAssigment  
   (IdRouteAssigment int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	IdRoute int NULL,
	IdCurrierMan int NULL,
	IdVehicle int null,
	DateOfRoute date null,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL,
	CONSTRAINT FKRoute_Route FOREIGN KEY (IdRoute) REFERENCES CatRoute(IdRoute),
	CONSTRAINT FKRoute_Currierman FOREIGN KEY (IdCurrierMan) REFERENCES SenderReceiver(ID),
	CONSTRAINT FKRoute_Vehicle FOREIGN KEY (IdVehicle) REFERENCES CatVehicle(IdVehicle),
	)
GO  

--select top 34 * from dbo.SenderReceiver


insert into  DeliveryBackOffice.dbo.RouteAssigment  
values (7,3,2,'2021-02-05',1,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	,(8,5,2,'2021-02-05',1,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	,(7,10,2,'2021-02-05',1,'SYS-CAQUINO',GETDATE(),NULL,NULL)


SELECT * FROM dbo.RouteAssigment