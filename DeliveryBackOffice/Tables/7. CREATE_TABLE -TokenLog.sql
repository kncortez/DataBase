USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.TokenLog  
   (TknIdToken nvarchar(75)  PRIMARY KEY NOT NULL,  
	TknIdUser bigint NOT NULL,
	TknIdSystem int NOT NULL,
	TknIdHub int  NULL,
	TknIdModule int  NULL,
	TknIdCountry  nvarchar(2)   NULL,
	TknIP nvarchar(30)  NULL,
	TknRowStatus bit NOT NULL,
	TknTokenCreated varchar(50)  NOT NULL,
	TknDateCreated datetime  NOT NULL,
	TknTokenUpdated varchar(50)   NULL,
	TknDateUpdated datetime   NULL,
	CONSTRAINT FKTokenUser FOREIGN KEY (TknIdUser) REFERENCES RegisterUser(UsrIdUser),
	CONSTRAINT FKTokenSystem FOREIGN KEY (TknIdSystem) REFERENCES CatSystem(SysIdSystem)
	)
GO  


