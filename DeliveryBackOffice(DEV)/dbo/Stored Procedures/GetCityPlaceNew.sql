-- =============================================  
-- Author:  <Cristian Suazo  
-- Update date: <2025-02-21>  
-- Description: <Se pasa a entidades el json>  
-- ============================================= 

CREATE PROCEDURE [dbo].[GetCityPlaceNew]
  @IdCityPlace varchar(50) = null,
  @CityPlace varchar(50) = null,
  @IdCountry nvarchar(2) = 'GT'
AS 
BEGIN 


SELECT TOP 5
      COALESCE(CONVERT(varchar,IdCityPlace),'') AS Id,         
      COALESCE(CityPlace,'') AS Description
      FROM DeliveryBackOffice.dbo.CatCityPlace
	  WHERE CityPlaceRowStatus = 1
	  AND OrderCityPlace IS NOT NULL
      AND IdCountry = @IdCountry
	  ORDER BY OrderCityPlace asc 
 
END