USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.RolByModuleBySystem  
   (RmsIdRol int NOT NULL,
	RmsIdSystem int NOT NULL,
	RmsIdModule int not null,
	RmsRowStatus bit NOT NULL,
	RmsTokenCreated varchar(50)  NOT NULL,
	RmsDateCreated datetime  NOT NULL,
	RmsTokenUpdated varchar(50)   NULL,
	RmsDateUpdated datetime   NULL,
	 primary key (RmsIdRol, RmsIdSystem,RmsIdModule) ,
	CONSTRAINT FKRolms FOREIGN KEY (RmsIdRol) REFERENCES CatRol(RolIdRol),
	CONSTRAINT FKSystemrm FOREIGN KEY (RmsIdSystem) REFERENCES  CatSystem(SysIdSystem),
	CONSTRAINT FKModulers FOREIGN KEY (RmsIdModule) REFERENCES  CatModule(ModIdModule)
	)
GO  
/*
insert into DeliveryBackOffice.dbo.RolByModuleBySystem  
	(RmsIdRol
	,RmsIdSystem
	,RmsIdModule
	,RmsRowStatus
	,RmsTokenCreated
	,RmsDateCreated)
values (1,1,1,1,'SYS-CAQUINO',GETDATE()),
       (1,1,2,1,'SYS-CAQUINO',GETDATE()),
       (1,1,3,1,'SYS-CAQUINO',GETDATE()),
       (1,1,4,1,'SYS-CAQUINO',GETDATE()),
       (1,1,5,1,'SYS-CAQUINO',GETDATE()),
       (2,1,1,1,'SYS-CAQUINO',GETDATE()),
       (2,1,2,1,'SYS-CAQUINO',GETDATE()),
       (2,1,3,1,'SYS-CAQUINO',GETDATE()),
       (2,1,4,1,'SYS-CAQUINO',GETDATE()),
       (2,1,5,1,'SYS-CAQUINO',GETDATE())

SELECT * FROM  DeliveryBackOffice.dbo.RolByModuleBySystem  
*/