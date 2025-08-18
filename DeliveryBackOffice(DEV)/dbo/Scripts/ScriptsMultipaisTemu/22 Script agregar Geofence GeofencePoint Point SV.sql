--SELECT * FROM [DeliveryBackOffice].[dbo].[Geofence] WITH(NOLOCK)

--SELECT * FROM [DeliveryBackOffice].[dbo].[GeofencePoint] WITH(NOLOCK)

--SELECT * FROM [DeliveryBackOffice].[dbo].[Point] WITH(NOLOCK)

DECLARE @Token NVARCHAR(25) = 'SYS-WOROZCO';
DECLARE @IdCountry NVARCHAR(2) = 'SV';
DECLARE @PointOrderNew INT;
DECLARE @IdGeofence INT;
DECLARE @IdPoint INT;

BEGIN TRY
    BEGIN TRANSACTION;
    
	DECLARE @CountryDescription NVARCHAR(55)= (SELECT CountryNameES FROM DeliveryBackOffice.dbo.CatCountry WITH(NOLOCK) WHERE IdCountry = @IdCountry)

	--Geofence
	INSERT INTO [dbo].[Geofence]
			   ([CountryId],[GeofenceDescription],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[Deparment],[Town],[Zone],[SettlementId])
		 VALUES
			   (@IdCountry,@CountryDescription,1,@Token,GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL)
	
	--Point
	INSERT INTO [dbo].[Point]
			   ([PointDescription],[PointLatitude],[PointLongitude],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
		 VALUES
			   ('Inferior Izquierda ' + @CountryDescription,13.14900000, -90.12810000,1,@Token,GETDATE(),NULL,NULL)
	
	INSERT INTO [dbo].[Point]
			   ([PointDescription],[PointLatitude],[PointLongitude],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
		 VALUES
			   ('Inferior Derecha ' + @CountryDescription,13.16330000, -87.68630000,1,@Token,GETDATE(),NULL,NULL)
	
	INSERT INTO [dbo].[Point]
			   ([PointDescription],[PointLatitude],[PointLongitude],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
		 VALUES
			   ('Superior Izquierda ' + @CountryDescription,14.44510000, -89.72300000,1,@Token,GETDATE(),NULL,NULL)
	
	INSERT INTO [dbo].[Point]
			   ([PointDescription],[PointLatitude],[PointLongitude],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
		 VALUES
			   ('Superior Derecha ' + @CountryDescription,14.42020000, -87.77810000,1,@Token,GETDATE(),NULL,NULL)
	
	--GeofencePoint
	SET @IdGeofence = (SELECT IdGeofence FROM [DeliveryBackOffice].[dbo].[Geofence] WITH(NOLOCK) WHERE CountryId = @IdCountry)
	
	SET @IdPoint = (SELECT IdPoint FROM [DeliveryBackOffice].[dbo].[Point] WITH(NOLOCK) WHERE PointDescription = 'Superior Izquierda ' + @CountryDescription)

	SET @PointOrderNew = 1 + (SELECT TOP 1 GeofencePointOrder FROM [DeliveryBackOffice].[dbo].[GeofencePoint] WITH(NOLOCK) ORDER BY GeofencePointOrder DESC)

	INSERT INTO [dbo].[GeofencePoint]
			   ([IdGeofence],[IdPoint],[GeofencePointOrder],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
		 VALUES
			   (@IdGeofence,@IdPoint,@PointOrderNew,1,@Token,GETDATE(),NULL,NULL)
	
	SET @IdPoint = (SELECT IdPoint FROM [DeliveryBackOffice].[dbo].[Point] WITH(NOLOCK) WHERE PointDescription = 'Superior Derecha ' + @CountryDescription)

	SET @PointOrderNew = 1 + @PointOrderNew

	INSERT INTO [dbo].[GeofencePoint]
			   ([IdGeofence],[IdPoint],[GeofencePointOrder],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
		 VALUES
			   (@IdGeofence,@IdPoint,@PointOrderNew,1,@Token,GETDATE(),NULL,NULL)

	SET @IdPoint = (SELECT IdPoint FROM [DeliveryBackOffice].[dbo].[Point] WITH(NOLOCK) WHERE PointDescription = 'Inferior Derecha ' + @CountryDescription)

	SET @PointOrderNew = 1 + @PointOrderNew

	INSERT INTO [dbo].[GeofencePoint]
			   ([IdGeofence],[IdPoint],[GeofencePointOrder],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
		 VALUES
			   (@IdGeofence,@IdPoint,@PointOrderNew,1,@Token,GETDATE(),NULL,NULL)
	
	SET @IdPoint = (SELECT IdPoint FROM [DeliveryBackOffice].[dbo].[Point] WITH(NOLOCK) WHERE PointDescription = 'Inferior Izquierda ' + @CountryDescription)

	SET @PointOrderNew = 1 + @PointOrderNew

	INSERT INTO [dbo].[GeofencePoint]
			   ([IdGeofence],[IdPoint],[GeofencePointOrder],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
		 VALUES
			   (@IdGeofence,@IdPoint,@PointOrderNew,1,@Token,GETDATE(),NULL,NULL)
	
	SET @IdPoint = (SELECT IdPoint FROM [DeliveryBackOffice].[dbo].[Point] WITH(NOLOCK) WHERE PointDescription = 'Superior Izquierda ' + @CountryDescription)

	SET @PointOrderNew = 1 + @PointOrderNew

	INSERT INTO [dbo].[GeofencePoint]
			   ([IdGeofence],[IdPoint],[GeofencePointOrder],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
		 VALUES
			   (@IdGeofence,@IdPoint,@PointOrderNew,1,@Token,GETDATE(),NULL,NULL)
	
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
