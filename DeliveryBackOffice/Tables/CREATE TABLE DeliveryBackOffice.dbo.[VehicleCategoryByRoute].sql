USE [DeliveryBackOffice]
GO

 
CREATE TABLE DeliveryBackOffice.dbo.[VehicleCategoryByRoute]  
   ([IdVehicleCatByRoute]  [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	[RouteId] [int] NOT NULL,
	[CatVehicleCategoriesId] [int] NOT NULL,
	[RowStauts] bit not null,
	[TokenCreated] [nvarchar](200) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](200)  NULL,
	[DateUpdated] [datetime]  NULL,
	

	CONSTRAINT FKRoutes FOREIGN KEY ([RouteId]) REFERENCES CatRoute(IdRoute),
	CONSTRAINT FKCatVehicleCategories FOREIGN KEY ([CatVehicleCategoriesId]) REFERENCES CatVehicleCategories(IdCatVehicleCategories)
	)
GO  

select * from dbo.VehicleCategoryByRoute