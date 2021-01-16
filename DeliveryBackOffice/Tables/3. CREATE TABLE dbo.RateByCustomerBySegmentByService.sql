USE [DeliveryBackOffice]
GO
 
CREATE TABLE DeliveryBackOffice.dbo.RateByCustomerBySegmentByService  
   (RcdId bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	RcdIdCustomer int NOT NULL,
	RcdIdCatService int NOT NULL,
	RcdIdRateSegment int  NULL,
	RcdRate decimal(14,2) NOT null,
	RcdFragileRate decimal(14,2) null,
	RcdInsuranceRate decimal(14,2) null,
	RcdCollectedRate decimal(14,2) null,
	RcdWeightAdditionalRate decimal(14,2) null,
	RcdWeightLimit int null,
	RcdWeightMeasure nvarchar(3) null,
	RcdDeliveryAttempts int null,
	RcdCurrency nvarchar(3) not null,
	RcdRowStatus bit NOT NULL,
	RcdTokenCreated varchar(50)  NOT NULL,
	RcdDateCreated datetime  NOT NULL,
	RcdTokenUpdated varchar(50)   NULL,
	RcdDateUpdated datetime   NULL,
	CONSTRAINT FKRcdCustomer FOREIGN KEY (RcdIdCustomer) REFERENCES Customer(IdCustomer),
	CONSTRAINT FKRcdCatSerivice FOREIGN KEY (RcdIdCatService) REFERENCES CatTypeService(CtsId),
	CONSTRAINT FKRcdRateSegment FOREIGN KEY (RcdIdRateSegment) REFERENCES CatRateSegment(CrsId)
	)

GO  

insert into DeliveryBackOffice.dbo.RateByCustomerBySegmentByService  
	(RcdIdCustomer
	,RcdIdCatService
	,RcdIdRateSegment
	,RcdRate
	,RcdFragileRate
	,RcdInsuranceRate
	,RcdCollectedRate
	,RcdWeightAdditionalRate
	,RcdWeightLimit
	,RcdWeightMeasure
	,RcdDeliveryAttempts
	,RcdCurrency
	,RcdRowStatus
	,RcdTokenCreated
	,RcdDateCreated
	)
Values(6,1,1,23,0,0,0,1,10,'LBS',2,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(6,1,2,28,0,0,0,1,10,'LBS',2,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(6,2,1,23,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(6,2,2,28,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(6,2,3,32,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE()),
	(6,2,4,35,0,0,0,1,10,'LBS',3,'GTQ',1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.RateByCustomerBySegmentByService  