	ALTER TABLE DeliveryBackOffice.dbo.CatVehicle  
	ADD CatVehicleCategoriesId int null
	,CatVehicleBrandId int null
	
	ALTER TABLE CatVehicle 
	ADD FOREIGN KEY (CatVehicleCategoriesId) REFERENCES CatVehicleCategories(IdCatVehicleCategories);

	ALTER TABLE CatVehicle 
	ADD FOREIGN KEY (CatVehicleBrandId) REFERENCES CatVehicleBrand(IdCatVehicleBrand);