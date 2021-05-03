USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.VisitPointCoverage
   (IdVpbySegment int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	VisitPointId int NOT NULL,
	HubLogisticId int not null,
	SegmentId int NOT NULL,
	RowStatus bit not null,
	TokenCreated varchar(50) not null,
	DateCreated datetime not null,
	TokenUpdated varchar(50) null,
	DateUpdated datetime null
	CONSTRAINT FKVpSegment FOREIGN KEY (VisitPointId) REFERENCES VisitPointClient(CodeOfReference),
	CONSTRAINT FKSegmentVP FOREIGN KEY (SegmentId) REFERENCES CatRateSegment(CrsId),
	CONSTRAINT FKHubVP FOREIGN KEY (HubLogisticId) REFERENCES HubLogistics(IdHubLogistic)
	)
GO  

insert into dbo.VisitPointCoverage 
(VisitPointId,HubLogisticId,SegmentId,RowStatus,TokenCreated,DateCreated)
select 13330, hb.IdHubLogistic, 1, 1,'SYS-CAQUINO', GETDATE()
from dbo.HubLogistics hb
where hb.HubStatus ='true' and hb.HubAbbreviation = 'GUA'

insert into dbo.VisitPointCoverage 
(VisitPointId,HubLogisticId,SegmentId,RowStatus,TokenCreated,DateCreated)
select 13330, hb.IdHubLogistic, 2,  1,'SYS-CAQUINO', GETDATE()
from dbo.HubLogistics hb
where hb.HubStatus ='true' and hb.HubAbbreviation = 'GMT'

insert into dbo.VisitPointCoverage 
(VisitPointId,HubLogisticId,SegmentId,RowStatus,TokenCreated,DateCreated)
select 13330, hb.IdHubLogistic, 3,  1,'SYS-CAQUINO', GETDATE()
from dbo.HubLogistics hb
where hb.HubStatus ='true' and hb.HubAbbreviation NOT IN('GUA', 'GMT')



