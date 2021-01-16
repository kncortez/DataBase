USE [DeliveryBackOffice]
GO
 
CREATE TABLE DeliveryBackOffice.dbo.CatRateSegment  
   (CrsId int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	CrsName varchar(100) NOT NULL,
	CrsShortName varchar(3) NOT NULL,
	CrsDescription varchar(200)  NULL,
	CrsRowStatus bit NOT NULL,
	CrsTokenCreated varchar(50)  NOT NULL,
	CrsDateCreated datetime  NOT NULL,
	CrsTokenUpdated varchar(50)   NULL,
	CrsDateUpdated datetime   NULL)
GO  

insert into DeliveryBackOffice.dbo.CatRateSegment  
	(CrsName
	,CrsShortName
	,CrsDescription
	,CrsRowStatus
	,CrsTokenCreated
	,CrsDateCreated)
Values('LOCAL','LOC', 'Servicios Locales',1,'SYS-CAQUINO',GETDATE()),
		('METROPOLITANO','MET', 'Servicios Metropolitanos',1,'SYS-CAQUINO',GETDATE()),
		('FORANEO','FOR', 'Servicios Foraneos',1,'SYS-CAQUINO',GETDATE()),
		('ESPECIAL','ESP', 'Servicios Especiales',1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.CatRateSegment  