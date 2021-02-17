USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatTypeRoute 
   (IdTypeRoute int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	Name varchar(100) NOT NULL,
	Description varchar(200) NOT NULL,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL)
GO  

insert into DeliveryBackOffice.dbo.CatTypeRoute  
	(Name
	,Description
	,RowStatus
	,TokenCreated
	,DateCreated)
Values('Recolección','Recolección',1,'SYS-CAQUINO',GETDATE())
	,('Linehaul','Linehaul',1,'SYS-CAQUINO',GETDATE())
	,('Devolución','Devolución',1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.CatTypeRoute  