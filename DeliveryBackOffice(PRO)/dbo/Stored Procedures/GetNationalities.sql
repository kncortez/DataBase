CREATE PROCEDURE [dbo].[GetNationalities]
  @IdCountry varchar(50) = null,
  @CountryAlpha3Code varchar(50) = null, 
  @CountryNationality varchar(50) = null
AS 
BEGIN 

 DECLARE @jsonResult NVARCHAR(MAX) 
  SET @jsonResult = (
	 SELECT STUFF((
		SELECT  
	  ',{"Id":"' + CONVERT(varchar,IdCountry)  + '",' +
	  '"Description":"' + CONVERT(varchar,CountryNationality) + '"}' 
	  from DeliveryBackOffice.dbo.CatCountry
	  where CountryRowStatus = 1  
	  and (@IdCountry is null or IdCountry = @IdCountry or LTRIM(RTRIM(@IdCountry)) = '' )
	  and (@CountryAlpha3Code is null or CountryAlpha3Code = @CountryAlpha3Code OR LTRIM(RTRIM(@CountryAlpha3Code)) = '')
	  and (@CountryNationality is null or CountryNationality = @CountryNationality OR LTRIM(RTRIM(@CountryNationality)) = '')
	  FOR XML PATH(''), TYPE
	 ).value('.', 'varchar(max)'),1,1,''
				  ) 
)

select '['+ @jsonResult + ']' FormatJson
 
END
