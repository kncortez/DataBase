USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatRoute 
   (IdRoute int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	CodeRoute varchar(100) NOT NULL,
	Description varchar(200) NOT NULL,
	IdTownship int  null,
	IdTypeRoute int null,
	Zone varchar(50) null,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL,
	CONSTRAINT FKRouteTypeR FOREIGN KEY (IdTypeRoute) REFERENCES CatTypeRoute(IdTypeRoute),
	CONSTRAINT FKRouteTownship FOREIGN KEY (IdTownship) REFERENCES Township(IdTownship)
	)
GO  

insert into CatRoute 
values('GUA001','RUTA LOCAL',66,1,12,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	,('METRO002','RUTA METRO',99,1,21,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	,('FOR001','RUTA FORANEA',343,1,21,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)

SELECT * FROM dbo.CatRoute