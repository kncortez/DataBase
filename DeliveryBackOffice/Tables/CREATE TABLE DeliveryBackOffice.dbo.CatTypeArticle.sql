USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatTypeArticle
   (TarId int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	TarIdPackage int NOT NULL,
	TarName varchar(50) NOT NULL,
	TarRowStatus bit NOT NULL,
	TarTokenCreated varchar(50)  NOT NULL,
	TarDateCreated datetime  NOT NULL,
	TarTokenUpdated varchar(50)   NULL,
	TarDateUpdated datetime   NULL,
	FOREIGN KEY (TarIdPackage) REFERENCES CatPackage(PckId)
	)
GO  

insert into  DeliveryBackOffice.dbo.CatTypeArticle  
	(TarIdPackage
	,TarName
	,TarRowStatus
	,TarTokenCreated
	,TarDateCreated
	)
Values(3,'Televisor',1,'SYS-CAQUINO',GETDATE()),
      (3,'Cama',1,'SYS-CAQUINO',GETDATE()),
	  (3,'Escritorio',1,'SYS-CAQUINO',GETDATE()),
	  (3,'Calzado',1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.CatTypeArticle 
