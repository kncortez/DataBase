USE [DeliveryBackOffice]
GO

 
CREATE TABLE DeliveryBackOffice.dbo.[ZoneByRoute]  
   ([IdZoneByRoute]  [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	[RouteId] [int] NOT NULL,
	[TownshipId] [int] NOT NULL,
	[Zone] [nvarchar](50)  NULL,
	[RowStauts] bit not null,
	[TokenCreated] [nvarchar](200) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](200)  NULL,
	[DateUpdated] [datetime]  NULL,
	

	CONSTRAINT FKRoute FOREIGN KEY ([RouteId]) REFERENCES CatRoute(IdRoute),
	CONSTRAINT FKTownship FOREIGN KEY ([TownshipId]) REFERENCES Township(IdTownship)
	)
GO  

select * from dbo.ZoneByRoute