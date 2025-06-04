--SELECT * FROM DeliveryBackOffice.dbo.DefaultValuesPerCountry WITH(NOLOCK)

BEGIN TRY
    BEGIN TRANSACTION;
    
	ALTER TABLE DeliveryBackOffice.dbo.DefaultValuesPerCountry
	ADD Latitude DECIMAL(9,6)
		CONSTRAINT CHK_DefaultValuesPerCountry_Latitude_ValidRange CHECK (Latitude BETWEEN -90 AND 90);

	ALTER TABLE DeliveryBackOffice.dbo.DefaultValuesPerCountry
	ADD Longitude DECIMAL(9,6)
		CONSTRAINT CHK_DefaultValuesPerCountry_Longitude_ValidRange CHECK (Longitude BETWEEN -180 AND 180);

	EXEC sp_addextendedproperty 
		@name = N'MS_Description', 
		@value = N'Coordenada geográfica que especifica la posición norte-sur.', 
		@level0type = N'SCHEMA', @level0name = 'dbo',
		@level1type = N'TABLE',  @level1name = 'DefaultValuesPerCountry',
		@level2type = N'COLUMN', @level2name = 'Latitude';

	EXEC sp_addextendedproperty 
		@name = N'MS_Description', 
		@value = N'Coordenada geográfica que especifica la posición este-oeste.', 
		@level0type = N'SCHEMA', @level0name = 'dbo',  
		@level1type = N'TABLE',  @level1name = 'DefaultValuesPerCountry',
		@level2type = N'COLUMN', @level2name = 'Longitude';

	--Valores que ya existian en Hermes Desktop
	UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry
	SET Latitude = 14.6349 , Longitude = -90.5069
	WHERE IdCountry = 'GT'

	UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry
	SET Latitude = 14.0818 , Longitude = -87.20681
	WHERE IdCountry = 'HN'

	UPDATE DeliveryBackOffice.dbo.DefaultValuesPerCountry
	SET Latitude = 13.6956 , Longitude =  -89.1968
	WHERE IdCountry = 'SV'

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
