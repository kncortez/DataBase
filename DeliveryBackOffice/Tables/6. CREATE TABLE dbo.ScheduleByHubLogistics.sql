USE [DeliveryBackOffice]
GO
 
CREATE TABLE DeliveryBackOffice.dbo.ScheduleByHubLogistics  
   (SbhId bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	SbhIdCatService int NOT NULL,
	SbhIdRateSegment int not null,
	SbhIdIdHubLogistics int not NULL,
	SbhCollectionTimeLimit time null,
	SbhDeliveryTimeLimit time null,
	SbhRowStatus bit NOT NULL,
	SbhTokenCreated varchar(50)  NOT NULL,
	SbhDateCreated datetime  NOT NULL,
	SbhTokenUpdated varchar(50)   NULL,
	SbhDateUpdated datetime   NULL,
	CONSTRAINT FKSbhHubLogistic FOREIGN KEY (SbhIdIdHubLogistics) REFERENCES HubLogistics(IdHubLogistic),
	CONSTRAINT FKSbhIdCatServiceCatSerivice FOREIGN KEY (SbhIdCatService) REFERENCES CatTypeService(CtsId),
	CONSTRAINT FKSbhRateSegemnt FOREIGN KEY (SbhIdRateSegment) REFERENCES CatRateSegment(CrsId)
	)

GO  
INSERT INTO DeliveryBackOffice.dbo.ScheduleByHubLogistics (
SbhIdCatService,
SbhIdRateSegment,
SbhIdIdHubLogistics,
SbhCollectionTimeLimit,
SbhDeliveryTimeLimit,
SbhRowStatus,
SbhTokenCreated
,SbhDateCreated
)
select (select CtsId from CatTypeService where CtsShortName = 'SMD'), 
(select CrsId from dbo.CatRateSegment where CrsShortName ='LOC'),
hub.IdHubLogistic ,'13:30', '21:00',1,'SYS-CAQUINO',GETDATE() 
from HubLogistics hub
where hub.HubStatus = 1

INSERT INTO DeliveryBackOffice.dbo.ScheduleByHubLogistics (
SbhIdCatService,
SbhIdRateSegment,
SbhIdIdHubLogistics,
SbhCollectionTimeLimit,
SbhDeliveryTimeLimit,
SbhRowStatus,
SbhTokenCreated
,SbhDateCreated
)
select (select CtsId from CatTypeService where CtsShortName = 'SMD'), 
(select CrsId from dbo.CatRateSegment where CrsShortName ='MET'),
hub.IdHubLogistic ,'09:00', '17:00',1,'SYS-CAQUINO',GETDATE() 
from HubLogistics hub
where hub.HubStatus = 1


