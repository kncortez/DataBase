

CREATE PROCEDURE [dbo].[GetCatSeries]
  @Status varchar(50) = null
 
AS 
BEGIN 
  DECLARE @jsonOutput NVARCHAR(MAX) 
    SET @jsonOutput =  
  ( 
 
SELECT ''+ STUFF(( 

SELECT 
    ',{"IdSerie":"' +  Convert(varchar, IdSerie) +  '",'  +   
      '"Status":"' + Convert(varchar, SerieStatus) + + '"}'

      from DeliveryBackOffice.dbo.CatSeries WITH(NOLOCK)
	  --where  SerieStatus =   @Status  

  FOR XML PATH(''), TYPE 
  ) 
  .value('.', 'varchar(max)'),1,1,'' 
              ) + '' 
  ) 
 
	select ('[' + @jsonOutput +  ']') jsonOutput
 
END