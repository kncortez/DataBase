USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.RateBySalePipeLine
   (IdRatePipeLine int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	RateId int NOT NULL,
	SalePipeLineId int not null,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL,
	CONSTRAINT FKRatePipeLIne FOREIGN KEY (RateId) REFERENCES RateHeader(RheId),
	CONSTRAINT FKRatePipeLine2 FOREIGN KEY (SalePipeLineId) REFERENCES  CatSalePipelines(IdSalePipeLine)
	)
GO  



insert into dbo.RateBySalePipeLine
values(3,3,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)
, (3,5,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)


SELECT * FROM DBO.RateBySalePipeLine