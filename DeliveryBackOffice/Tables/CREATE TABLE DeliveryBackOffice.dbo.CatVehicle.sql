USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatVehicle  
   (IdVehicle int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	UnitNumber varchar(10) NOT NULL,
	CodeName varchar(200) NOT NULL,
	IdTypeVehicle int null,
	Plate varchar(20) null,
	Year int null,
	Capacity decimal(12,2) null,
	WhiteLineCapacity decimal(12,2) null,
	IrregularCapacity decimal(12,2) null,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL,
	CONSTRAINT FKVehicleType FOREIGN KEY (IdTypeVehicle) REFERENCES CatTypeVehicle(IdTypeVehicle)
	)
GO  

insert into  DeliveryBackOffice.dbo.CatVehicle  
values ('1234','panel 1234',1,'C288BHR',2010,100,100,100,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	,('456','panel 345',1,'C266BHY',2010,100,100,100,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	,('4567','CAMION 4567',1,'C558QGT',2010,100,100,100,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)


SELECT * FROM dbo.CatVehicle