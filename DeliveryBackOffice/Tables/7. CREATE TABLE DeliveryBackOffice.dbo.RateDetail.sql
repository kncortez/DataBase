USE [DeliveryBackOffice]
GO
 
CREATE TABLE DeliveryBackOffice.dbo.RateDetail  
   (RdtId bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	RdtIdRate int NOT NULL,
	RdtIdCatService int NOT NULL,
	RdtIdRateSegment int  NULL,
	RdtRate decimal(14,2) NOT null,
	RdtFragileRate decimal(14,2) null,
	RdtInsuranceRate decimal(14,2) null,
	RdtCollectedRate decimal(14,2) null,
	RdtWeightAdditionalRate decimal(14,2) null,
	RdtWeightLimit int null,
	RdtWeightMeasure nvarchar(3) null,
	RdtDeliveryAttempts int null,
	RdtCurrency nvarchar(3) not null,
	RdtRowStatus bit NOT NULL,
	RdtTokenCreated varchar(50)  NOT NULL,
	RdtDateCreated datetime  NOT NULL,
	RdtTokenUpdated varchar(50)   NULL,
	RdtDateUpdated datetime   NULL,
	COnSTRAINT FKRdtRate FOREIGN KEY (RdtIdRate) REFERENCES RateHeader(RheId),
	CONSTRAINT FKRdtCatSerivice FOREIGN KEY (RdtIdCatService) REFERENCES CatTypeService(CtsId),
	CONSTRAINT FKRdtRateSegment FOREIGN KEY (RdtIdRateSegment) REFERENCES CatRateSegment(CrsId)
	)

GO  

insert into DeliveryBackOffice.dbo.RateDetail  
	(RdtIdRate
	,RdtIdCatService
	,RdtIdRateSegment
	,RdtRate
	,RdtFragileRate
	,RdtInsuranceRate
	,RdtCollectedRate
	,RdtWeightAdditionalRate
	,RdtWeightLimit
	,RdtWeightMeasure
	,RdtDeliveryAttempts
	,RdtCurrency
	,RdtRowStatus
	,RdtTokenCreated
	,RdtDateCreated
	)
Values(1,1,1,23,0,0,0,1,10,'LBS',2,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(1,1,2,28,0,0,0,1,10,'LBS',2,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(1,2,1,23,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(1,2,2,28,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(1,2,3,32,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(1,2,4,35,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(2,1,1,23,0,0,0,1,10,'LBS',2,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(2,1,2,28,0,0,0,1,10,'LBS',2,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(2,2,1,23,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(2,2,2,28,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(2,2,3,32,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(2,2,4,35,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE())


select * from DeliveryBackOffice.dbo.RateDetail  