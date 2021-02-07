USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatPackage  
   (PckId int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	PckName varchar(50) NOT NULL,
	PckRowStatus bit NOT NULL,
	PckTokenCreated varchar(50)  NOT NULL,
	PckDateCreated datetime  NOT NULL,
	PckTokenUpdated varchar(50)   NULL,
	PckDateUpdated datetime   NULL
	)
GO  

insert into  DeliveryBackOffice.dbo.CatPackage  
	(PckName
	,PckRowStatus
	,PckTokenCreated
	,PckDateCreated
	)
Values('Caja',1,'SYS-CAQUINO',GETDATE()),
      ('Sobre',1,'SYS-CAQUINO',GETDATE()),
	  ('Otros',1,'SYS-CAQUINO',GETDATE())

select * from dbo.CatPackage