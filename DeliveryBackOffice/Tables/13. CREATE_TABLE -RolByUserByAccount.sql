USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.RolByUserByAccount  
   (RuaIdRol int NOT NULL,
	RuaIdUser bigint NOT NULL,
	RuaIdAccount bigint NOT NULL,
	RuaRowStatus bit NOT NULL,
	RuaTokenCreated varchar(50)  NOT NULL,
	RuaDateCreated datetime  NOT NULL,
	RuaTokenUpdated varchar(50)   NULL,
	RuaDateUpdated datetime   NULL
	 primary key (RuaIdRol, RuaIdUser,RuaIdAccount) ,
	CONSTRAINT FKRolRUA FOREIGN KEY (RuaIdRol) REFERENCES CatRol(RolIdRol),
	CONSTRAINT FKUserRUA FOREIGN KEY (RuaIdUser) REFERENCES RegisterUser(UsrIdUser),
	CONSTRAINT FKAccountRUA FOREIGN KEY (RuaIdAccount) REFERENCES  Account(AccIdAccount)
	)
GO  
/*
insert into DeliveryBackOffice.dbo.RolByUserByAccount  
	(RuaIdRol,
	RuaIdUser
	,RuaIdAccount
	,RuaRowStatus
	,RuaTokenCreated
	,RuaDateCreated)
	values (1,1,1,1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.RolByUserByAccount  

*/