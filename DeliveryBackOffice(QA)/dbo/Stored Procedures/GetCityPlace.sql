

CREATE PROCEDURE [dbo].[GetCityPlace]
  @IdCityPlace varchar(50) = null,
  @CityPlace varchar(50) = null
AS 
BEGIN 
  DECLARE @jsonOutput NVARCHAR(MAX) 
    SET @jsonOutput =  
  (  
SELECT ''+ STUFF(( 

SELECT TOP 5
      ',{"Id":"' +  COALESCE(CONVERT(varchar,IdCityPlace),'') + '",'+            
      '"Description":"' + COALESCE(CityPlace,'') + '"}'
      from DeliveryBackOffice.dbo.CatCityPlace
	  where CityPlaceRowStatus = 1
	  /*and (@IdCityPlace is null or IdCityPlace = @IdCityPlace)
	  and (@CityPlace is null or CityPlace = @CityPlace)*/
	  and OrderCityPlace is not null
	  ORDER BY OrderCityPlace asc 
  
  FOR XML PATH(''), TYPE 
  ) 
  .value('.', 'varchar(max)'),1,1,'' 
              ) + '' 
  ) 
 
  select  
  '[' +   
  @jsonOutput +
  ']' 
  FormatJson 
 
END