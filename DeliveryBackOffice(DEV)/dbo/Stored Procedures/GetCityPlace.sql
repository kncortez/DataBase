CREATE PROCEDURE [dbo].[GetCityPlace]
  @IdCityPlace varchar(50) = null,
  @CityPlace varchar(50) = null,
  @IdCountry nvarchar(2) = 'GT'
AS 
BEGIN 
  DECLARE @jsonOutput NVARCHAR(MAX) 
    SET @jsonOutput =  
  (  
SELECT ''+ STUFF(( 

SELECT TOP 5
      ',{"Id":"' +  COALESCE(CONVERT(varchar,IdCityPlace),'') + '",'+            
      '"Description":"' + COALESCE(CityPlace,'') + '"}'
      FROM DeliveryBackOffice.dbo.CatCityPlace
	  WHERE CityPlaceRowStatus = 1
	  AND OrderCityPlace IS NOT NULL
	  AND IdCountry = @IdCountry
	  ORDER BY OrderCityPlace ASC 
  
  FOR XML PATH(''), TYPE 
  ) 
  .value('.', 'varchar(max)'),1,1,'' 
              ) + '' 
  ) 
 
  SELECT  
  '[' +   
  @jsonOutput +
  ']' 
  FormatJson 
 
END