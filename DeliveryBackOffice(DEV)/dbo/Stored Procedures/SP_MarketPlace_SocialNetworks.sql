-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <29-07-2024>
-- Description:	<Devuelve las redes sociales por pais>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MarketPlace_SocialNetworks]
				 @IdCountry NVARCHAR(2) = 'GT'
AS
	BEGIN
	SELECT ConfigParamsId AS NetWorkId,
		  Description,
		  Value AS Link
	FROM ConfigParams 
	WHERE Name IN ( 'UrlNetWork', 'PBX')
	AND ISNULL(IdCountry,'GT') = @IdCountry
END