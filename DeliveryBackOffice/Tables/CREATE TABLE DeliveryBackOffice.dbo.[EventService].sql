

USE [DeliveryBackOffice]
GO

 
CREATE TABLE DeliveryBackOffice.dbo.[EventService]  
   (IdEventService  int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	[ServiceManagementId] [int] NOT NULL,
	[ServiceStatusId] [int] NOT NULL,
	RowStauts bit not null,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[Observations] [nvarchar](200) NULL,

	CONSTRAINT FKEventService FOREIGN KEY ([ServiceManagementId]) REFERENCES ServiceManagement(IdServiceManagement),
	CONSTRAINT FKEventStatus FOREIGN KEY ([ServiceStatusId]) REFERENCES CatServiceStatus(IdServiceStatus)
	)
GO  



select * from dbo.EventService