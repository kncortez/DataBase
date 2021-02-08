USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatArticle
   (ArtId int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	ArtIdTypeArticle int NOT NULL,
	ArtName varchar(50) NOT NULL,
	ArtShowDefault bit NOT NULL,
	ArtRowStatus bit NOT NULL,
	ArtTokenCreated varchar(50)  NOT NULL,
	ArtDateCreated datetime  NOT NULL,
	ArtTokenUpdated varchar(50)   NULL,
	ArtDateUpdated datetime   NULL,
	FOREIGN KEY (ArtIdTypeArticle) REFERENCES CatTypeArticle(TarId)
	)
GO  

insert into  DeliveryBackOffice.dbo.CatArticle  
	(ArtIdTypeArticle
	,ArtName
	,ArtShowDefault
	,ArtRowStatus
	,ArtTokenCreated
	,ArtDateCreated
	)
Values(1,'Tv 32',1,1,'SYS-CAQUINO',GETDATE()),
      (2,'Cama Imperial',1,1,'SYS-CAQUINO',GETDATE()),
	  (4,'Zapatos',1,1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.CatArticle 
