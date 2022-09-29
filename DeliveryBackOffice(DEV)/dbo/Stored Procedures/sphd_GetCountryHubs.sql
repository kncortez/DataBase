-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-16>
-- Description:	<Regresa una lista del País, asociado al que corresponde el HUB>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetCountryHubs] 
@IdCountry AS NVARCHAR(2)=''
AS
BEGIN

 IF @IdCountry =''
	SELECT  
	        
	        CC.IdCountry,
	       (CC.CountryNameES) AS Country
	FROM [DeliveryBackOffice].[dbo].[CatCountry] CC WITH (NOLOCK)
	WHERE LEN(CountryNameES)>0 
	ORDER BY CountryNameES
ELSE
	SELECT  CC.IdCountry,
	       (CC.CountryNameES) AS Country
	FROM [DeliveryBackOffice].[dbo].[CatCountry] CC WITH (NOLOCK)
	WHERE LEN(CountryNameES)>0 AND CC.IdCountry = @IdCountry
	ORDER BY CountryNameES
	
END