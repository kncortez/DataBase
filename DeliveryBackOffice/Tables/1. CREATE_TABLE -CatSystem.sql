USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatSystem  
   (SysIdSystem int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	SysNameSystem varchar(100) NOT NULL,
	SysPlataform varchar(50) NOT NULL,
	SysDescription varchar(50)  NULL,
	SysRowStatus bit NOT NULL,
	SysTokenCreated varchar(50)  NOT NULL,
	SysDateCreated datetime  NOT NULL,
	SysTokenUpdated varchar(50)   NULL,
	SysDateUpdated datetime   NULL)
GO  

insert into DeliveryBackOffice.dbo.CatSystem  
	(SysNameSystem
	,SysPlataform
	,SysDescription
	,SysRowStatus
	,SysTokenCreated
	,SysDateCreated)
Values('Hermes Web','forzadelivery.com', 'Portal Web',1,'SYS-DEVELOP',GETDATE())

select * from DeliveryBackOffice.dbo.CatSystem  