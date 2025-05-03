BEGIN TRY
    BEGIN TRANSACTION;

	--SCRIPT PARA INGRESAR DATOS DE SV
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
		'SV'
	FROM DeliveryBackOffice.dbo.CatCityPlace
	WHERE IdCountry = 'HN' --Se insertan los mismos valores que HN.

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;