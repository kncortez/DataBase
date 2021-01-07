USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatRol  
   (RolIdRol int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	RolIdSystem int NOT NULL,
	RolName varchar(50) NOT NULL,
	RolDescription varchar(100) NOT  NULL,
	RolAdminBrothers  bit   NULL,
	RolAdminClient bit NOT NULL,
	RolRowStatus bit NOT NULL,
	RolTokenCreated varchar(50)  NOT NULL,
	RolDateCreated datetime  NOT NULL,
	RolokenUpdated varchar(50)   NULL,
	RolDateUpdated datetime   NULL,
	FOREIGN KEY (RolIdSystem) REFERENCES CatSystem(SysIdSystem)
	)
GO  

insert into  DeliveryBackOffice.dbo.CatRol  
	(RolIdSystem
	,RolName
	,RolDescription
	,RolAdminBrothers
	,RolAdminClient
	,RolRowStatus
	,RolTokenCreated
	,RolDateCreated
	)
Values(1,'Administrador','Administrador de portal web',1,1,1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.CatRol 
