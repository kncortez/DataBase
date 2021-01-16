USE [DeliveryBackOffice]
GO
 
CREATE TABLE DeliveryBackOffice.dbo.CatTypeService  
   (CtsId int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	CtsName varchar(100) NOT NULL,
	CtsShortName varchar(3) NOT NULL,
	CtsDescription varchar(200)  NULL,
	CtsRowStatus bit NOT NULL,
	CtsTokenCreated varchar(50)  NOT NULL,
	CtsDateCreated datetime  NOT NULL,
	CtsTokenUpdated varchar(50)   NULL,
	CtsDateUpdated datetime   NULL)
GO  

insert into DeliveryBackOffice.dbo.CatTypeService  
	(CtsName
	,CtsShortName
	,CtsDescription
	,CtsRowStatus
	,CtsTokenCreated
	,CtsDateCreated)
Values('Same Day','SMD', 'Entrega en Ruta - Mismo Día',1,'SYS-CAQUINO',GETDATE()),
		('Next Day','NXD', 'Entrega en Ruta - 24 Horas',1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.CatTypeService  