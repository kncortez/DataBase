USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spwsGetFavoritiesCOD]    Script Date: 27/01/2021 20:29:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




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
      ',{"Alias":"' +  isnull(CAST(upper(fav.AliasFavCOD) AS VARCHAR), 'N/A') + '",'+
	   '"NameAccount":"' +  isnull(CAST(upper(fav.NameAccountFavCOD) AS VARCHAR), 'N/A') + '",'+
	  '"IdFavCOD":"' +  isnull(CAST(upper(fav.IdDeliveryFavCOD) AS VARCHAR), 'N/A') + '",'+
	  '"TypeAccount":"' +  isnull(CAST(upper(fav.TypeAccountFavCOD) AS VARCHAR), 'N/A') + '",'+
	  '"DocumentID":"' +   isnull(CAST(convert(varchar, fav.DocumentIdFavCOD) AS varchar), 'N/A')+ '",' +
	   '"TokenCreate":"' +   isnull(convert(varchar, fav.TokenCreated ), 'N/A') + '",' +
	   '"IdBank":"' +   isnull(CAST(fav.IdBank AS varchar), 'N/A') + '",'+
	   '"NumberAccount":"' +    isnull(CAST(fav.NumberAccFavCOD AS varchar), 'N/A') + '",'+
	    '"BankDescription":"' +   isnull(CAST( bn.Name AS VARCHAR), 'N/A') + '"}'
      FROM dbo.DeliveryFavCOD  fav
	  join dbo.DeliveryBank bn on (bn.Id_bank = fav.IdBank)
		Where StatusFavCOD = @Status  and IdAccountFavCOD = @IdAccount
 FOR XML PATH(''), TYPE
	 ).value('.', 'varchar(max)'),1,1,''
				  )
			) 
 
  select  '['+ @jsonResult + ']' FormatJson


END
GO


