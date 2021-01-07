USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.UserSystemRestriction  
   (UstIdRestriction bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	UstIdUser bigint NOT NULL,
	UstIdSystem int NOT NULL,
	UstAccessRetries int not null,
	UstRetries int not null,
	UstStatus varchar(10) not null,
	UstRowStatus bit not null,
	UstTokenCreated varchar(50)  NOT NULL,
	UstDateCreated date  NOT NULL,
	UstOperationDate date  NOT NULL,
	CONSTRAINT FKUserRestriction FOREIGN KEY (UstIdUser) REFERENCES RegisterUser(UsrIdUser),
	CONSTRAINT FKSystemRestriction FOREIGN KEY (UstIdSystem) REFERENCES CatSystem(SysIdSystem)
	)
GO  
/*
insert into DeliveryBackOffice.dbo.UserSystemRestriction  
(UstIdUser
,UstIdSystem
,UstAccessRetries
,UstRetries
,UstStatus
,UstRowStatus
,UstTokenCreated
,UstDateCreated
,UstOperationDate)
values (1,1,10,0,'ACTIVE', 1,'SYS-CAQUINO',GETDATE(),GETDATE())

SELECT * FROM DeliveryBackOffice.dbo.UserSystemRestriction  
*/