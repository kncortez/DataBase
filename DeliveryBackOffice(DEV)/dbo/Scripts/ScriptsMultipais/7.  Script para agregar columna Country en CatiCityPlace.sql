--screjecutado 7

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

