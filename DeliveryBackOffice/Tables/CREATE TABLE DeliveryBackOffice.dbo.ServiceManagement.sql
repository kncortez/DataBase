CREATE TABLE DeliveryBackOffice.dbo.ServiceManagement  
   (IdServiceManagement int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	IdPuCourrier int NULL,
	IdDlCourrier int NULL,
	CiPuDate date null,
	CoPuDate date null,
	CiDlDate date null,
	CoDlDate date null,
	IdPuRouteAssigment int NULL,
	IdDlRouteAssigment int NULL,
	IdSchedulePickup Bigint null,
	IdProofOnDelivery int null,
	RowStatus bit NOT NULL,
	TokenCreated varchar(50)  NOT NULL,
	DateCreated datetime  NOT NULL,
	TokenUpdated varchar(50)   NULL,
	DateUpdated datetime   NULL,
	CONSTRAINT FKService_CurrierIn FOREIGN KEY (IdPuCourrier) REFERENCES SenderReceiver(ID),
	CONSTRAINT FKService_CurrierOut FOREIGN KEY (IdDlCourrier) REFERENCES SenderReceiver(ID),

	CONSTRAINT FKService_RouteIn FOREIGN KEY (IdPuRouteAssigment) REFERENCES RouteAssigment(IdRouteAssigment),
	CONSTRAINT FKService_RoutOut FOREIGN KEY (IdDlRouteAssigment) REFERENCES RouteAssigment(IdRouteAssigment),

	CONSTRAINT FKService_Pickup FOREIGN KEY (IdSchedulePickup) REFERENCES SchedulePickup(SchedulePickupId),
	CONSTRAINT FKService_Proof FOREIGN KEY (IdProofOnDelivery) REFERENCES DeliveryProof(ID),
	)

	insert into ServiceManagement
	values(3,3,null,null,null,null,4,4,null,null,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)
		,(5,5,null,null,null,null,5,5,null,null,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)
		,(10,10,null,null,null,null,6,6,null,null,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	
	select * from dbo.SenderReceiver


