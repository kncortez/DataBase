	ALTER TABLE SchedulePickup
	ADD SenderId int null
	, SenderName varchar(200) null
	, SenderPhone varchar(50) null
	,IdHubLogistics int null
	, AmountPickup decimal(12,2) null
	,IdSourcePlataform int null
	,AddressPickup [varchar](500) NULL,
	,AssigmentStatus [bit] NULL
	ALTER TABLE SchedulePickup
	ADD FOREIGN KEY (SenderId) REFERENCES VisitPointClient(CodeOfReference);
	ALTER TABLE SchedulePickup
	ADD FOREIGN KEY (IdHubLogistics) REFERENCES HubLogistics(IdHubLogistic);
	ALTER TABLE SchedulePickup
	ADD FOREIGN KEY (IdSourcePlataform) REFERENCES CatSystem(SysIdSystem);
	ALTER TABLE SchedulePickup ALTER COLUMN [AccountId] bigint  NULL

	ALTER TABLE SchedulePickup  
	ADD AddressPickup varchar(500) null
	
	
