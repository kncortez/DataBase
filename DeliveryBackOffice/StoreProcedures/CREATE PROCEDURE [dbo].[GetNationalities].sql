USE [DeliveryBackOffice]
GO
ALTER PROCEDURE [dbo].[GetNationalities]
  @IdCountry varchar(50) = null,
  @CountryAlpha3Code varchar(50) = null, 
  @CountryNationality varchar(50) = null
AS 
BEGIN 
  DECLARE @jsonOutput NVARCHAR(MAX) 
    SET @jsonOutput =  
  ( 
 
SELECT ''+ STUFF(( 

SELECT 
      ',{"Id":"' +  COALESCE(IdCountry,'') + '",'+            
      '"Description":"' + COALESCE(CountryNationality,'') + '"}'
      from DeliveryBackOffice.dbo.CatCountry
	  where CountryRowStatus = 1
	  and (@IdCountry is null or IdCountry = @IdCountry)
	  and (@CountryAlpha3Code is null or CountryAlpha3Code = @CountryAlpha3Code)
	  and (@CountryNationality is null or CountryNationality = @CountryNationality)
	   
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
