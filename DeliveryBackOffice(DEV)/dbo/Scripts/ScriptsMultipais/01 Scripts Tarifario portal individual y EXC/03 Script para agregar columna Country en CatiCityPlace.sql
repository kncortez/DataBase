BEGIN TRY
    BEGIN TRANSACTION;

	--SCRIPT PARA AGREGAR COLUMNA NUEVA DE COUNTRY EN LA TABLA CatCityPlace

	ALTER TABLE DeliveryBackOffice.dbo.CatCityPlace
	ADD IdCountry VARCHAR(2);

	ALTER TABLE DeliveryBackOffice.dbo.CatCityPlace
	ADD CONSTRAINT FK_CatCityPlace_CatCountry FOREIGN KEY (IdCountry)
	REFERENCES DeliveryBackOffice.dbo.CatCountry(IdCountry);


	--SCRIPT PARA INGRESAR DATOS DE HN

	--UPDATE PARA LOS DATOS DE GT, UNICAMENTE SE REALIZA EL UPDATE SI NO SE A INSERTADO NINGUN VALOR DE HONDURAS

	UPDATE DeliveryBackOffice.dbo.CatCityPlace
	SET IdCountry = 'GT'

	INSERT INTO [dbo].[CatCityPlace]
		([CityPlace]
		,[CityPlaceRowStatus]
		,[CityPlaceTokenCreated]
		,[CityPlaceDateCreated]
		,[CityPlaceTokenUpdated]
		,[CityPlaceDateUpdate]
		,[OrderCityPlace]
		,[IdCountry])
	SELECT 
		CityPlace,
		CityPlaceRowStatus,
		'SYS-WOROZCO',
		GETDATE(),
		NULL,
		NULL,
		OrderCityPlace,
		'HN'
	FROM DeliveryBackOffice.dbo.CatCityPlace

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;