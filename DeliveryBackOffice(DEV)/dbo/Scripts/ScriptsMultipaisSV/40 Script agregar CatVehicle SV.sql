--SELECT * FROM DeliveryBackOffice.dbo.CatVehicle
--WHERE IdCountry = 'HN'

BEGIN TRY
    BEGIN TRANSACTION;

	DECLARE @TypeVehicle INT = (SELECT IdTypeVehicle FROM DeliveryBackOffice.dbo.CatTypeVehicle
								WHERE IdCountry = 'SV' AND Name = 'Panel')

	DECLARE @VehicleCategorie INT = (SELECT IdCatVehicleCategories FROM DeliveryBackOffice.dbo.CatVehicleCategories
									 WHERE IdCountry = 'SV' AND Name = 'ALTO 800 GA')

	DECLARE @VehicleBrand INT = (SELECT IdCatVehicleBrand FROM DeliveryBackOffice.dbo.CatVehicleBrand
								 WHERE IdCountry = 'SV' AND Name = 'TOYOTA')

	DECLARE @Hub INT = (SELECT IdHubLogistic FROM DeliveryBackOffice.dbo.HubLogistics 
								 WHERE IdCountry = 'SV' AND HubName = 'SANTA ANA')
    
	--información de prueba, no ingresarla para ambientes productivos
    INSERT INTO [dbo].[CatVehicle]
           ([UnitNumber],[CodeName],[IdTypeVehicle],[Plate],[Year],[Capacity],[WhiteLineCapacity],[IrregularCapacity],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CatVehicleCategoriesId],[CatVehicleBrandId],[Long],[Width],[High],[CubicMeters],[CapabilityEcomerce],[HubLogisticId],[LastLatitude],[LastLongitude],[IdCountry])
     VALUES
           ('15001','15001Prueba01',@TypeVehicle,'P537485',2025,0.00,1.0,1.0,1,'SYS-WOROZCO',GETDATE(),NULL,NULL,@VehicleCategorie,@VehicleBrand,1.00,1.00,1.00,1.00,1.00,@Hub,NULL,NULL,'SV')
    
	SET @Hub = (SELECT IdHubLogistic FROM DeliveryBackOffice.dbo.HubLogistics 
								 WHERE IdCountry = 'SV' AND HubName = 'SAN SALVADOR')

	INSERT INTO [dbo].[CatVehicle]
           ([UnitNumber],[CodeName],[IdTypeVehicle],[Plate],[Year],[Capacity],[WhiteLineCapacity],[IrregularCapacity],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CatVehicleCategoriesId],[CatVehicleBrandId],[Long],[Width],[High],[CubicMeters],[CapabilityEcomerce],[HubLogisticId],[LastLatitude],[LastLongitude],[IdCountry])
     VALUES
           ('15002','15002Prueba02',@TypeVehicle,'P537486',2025,0.00,1.0,1.0,1,'SYS-WOROZCO',GETDATE(),NULL,NULL,@VehicleCategorie,@VehicleBrand,1.00,1.00,1.00,1.00,1.00,@Hub,NULL,NULL,'SV')
    
	SET @Hub = (SELECT IdHubLogistic FROM DeliveryBackOffice.dbo.HubLogistics 
								 WHERE IdCountry = 'SV' AND HubName = 'SAN MIGUEL')

	INSERT INTO [dbo].[CatVehicle]
           ([UnitNumber],[CodeName],[IdTypeVehicle],[Plate],[Year],[Capacity],[WhiteLineCapacity],[IrregularCapacity],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CatVehicleCategoriesId],[CatVehicleBrandId],[Long],[Width],[High],[CubicMeters],[CapabilityEcomerce],[HubLogisticId],[LastLatitude],[LastLongitude],[IdCountry])
     VALUES
           ('15003','15003Prueba03',@TypeVehicle,'P537487',2025,0.00,1.0,1.0,1,'SYS-WOROZCO',GETDATE(),NULL,NULL,@VehicleCategorie,@VehicleBrand,1.00,1.00,1.00,1.00,1.00,@Hub,NULL,NULL,'SV')
    
	SET @Hub = (SELECT IdHubLogistic FROM DeliveryBackOffice.dbo.HubLogistics 
								 WHERE IdCountry = 'SV' AND HubName = 'LA LIBERTAD')

	INSERT INTO [dbo].[CatVehicle]
           ([UnitNumber],[CodeName],[IdTypeVehicle],[Plate],[Year],[Capacity],[WhiteLineCapacity],[IrregularCapacity],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[CatVehicleCategoriesId],[CatVehicleBrandId],[Long],[Width],[High],[CubicMeters],[CapabilityEcomerce],[HubLogisticId],[LastLatitude],[LastLongitude],[IdCountry])
     VALUES
           ('15004','15004Prueba04',@TypeVehicle,'P537488',2025,0.00,1.0,1.0,1,'SYS-WOROZCO',GETDATE(),NULL,NULL,@VehicleCategorie,@VehicleBrand,1.00,1.00,1.00,1.00,1.00,@Hub,NULL,NULL,'SV')
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
