
CREATE PROCEDURE [dbo].[spwsGetFavoritiesCOD]
  @IdAccount int ,
  @Status int
 
AS 

BEGIN

  DECLARE @jsonResult NVARCHAR(MAX) 
    SET @jsonResult =  
  ( 
 
SELECT STUFF((
SELECT
      ',{"Alias":"' +  isnull(CAST(upper(fav.AliasFavCOD) AS VARCHAR (200)), 'N/A') + '",'+
	   '"NameAccount":"' +  isnull(CAST(upper(fav.NameAccountFavCOD) AS VARCHAR (200)), 'N/A') + '",'+
	  '"IdFavCOD":"' +  isnull(CAST(upper(fav.IdDeliveryFavCOD) AS VARCHAR (200)), 'N/A') + '",'+
	  '"TypeAccount":"' +  isnull(CAST(upper(fav.TypeAccountFavCOD) AS VARCHAR (200)), 'N/A') + '",'+
	  '"DocumentID":"' +   isnull(CAST(convert(varchar (200), fav.DocumentIdFavCOD) AS varchar (200)), 'N/A')+ '",' +
	   '"TokenCreate":"' +   isnull(convert(varchar (200), fav.TokenCreated  ), 'N/A') + '",' +
	   '"IdBank":"' +   isnull(CAST(fav.IdBank AS varchar (200) ), 'N/A') + '",'+
	   '"NumberAccount":"' +    isnull(REPLACE(CAST(fav.NumberAccFavCOD AS varchar (200)),'-',''), 'N/A') + '",'+
	   '"Acronym":"' +    isnull(CAST(bn.Acronym AS varchar (200)), 'N/A') + '",'+
	    '"BankDescription":"' +   isnull(CAST( bn.Name AS VARCHAR (200)), 'N/A') + '",' +
		'"IsDefault":"' +   isnull(iif(fav.IsDefault = 1, 'true', 'false'), 'N/A') +'"}'
      FROM dbo.DeliveryFavCOD  fav
	  join dbo.DeliveryBank bn on (bn.Id_bank = fav.IdBank)
		Where StatusFavCOD = 1  and IdAccountFavCOD = @IdAccount
 FOR XML PATH(''), TYPE
	 ).value('.', 'varchar(max)'),1,1,''
				  )
			) 
 
  select  '['+ @jsonResult + ']' FormatJson


END
