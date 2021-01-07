USE [DeliveryBackOffice]
GO



CREATE TABLE DeliveryBackOffice.dbo.RolByUserBySystem  
   (RusIdRol int NOT NULL,
	RusIdSystem int NOT NULL,
	RusIdUser bigint not null,
	RusRowStatus bit NOT NULL,
	RusTokenCreated varchar(50)  NOT NULL,
	RusDateCreated datetime  NOT NULL,
	RusTokenUpdated varchar(50)   NULL,
	RusDateUpdated datetime   NULL,
	 primary key (RusIdRol, RusIdSystem,RusIdUser) ,
	CONSTRAINT FKRolRMS FOREIGN KEY (RusIdRol) REFERENCES CatRol(RolIdRol),
	CONSTRAINT FKSystemRMS FOREIGN KEY (RusIdSystem) REFERENCES  CatSystem(SysIdSystem),
	CONSTRAINT FKUserRMS FOREIGN KEY (RusIdUser) REFERENCES  RegisterUser(UsrIdUser)
	)
GO  

insert into DeliveryBackOffice.dbo.RolByUserBySystem  
	(RusIdRol
	,RusIdSystem
	,RusIdUser
	,RusRowStatus
	,RusTokenCreated
	,RusDateCreated)
values (1,1,1,1,'SYS-CAQUINO',GETDATE())

SELECT * FROM  DeliveryBackOffice.dbo.RolByUserBySystem  
