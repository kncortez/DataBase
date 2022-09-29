-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-16>
-- Description:	<Regresa una lista de los hubs solo abreviatura correspondiente>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_getHubsOnly] 
AS
BEGIN
	SELECT  HL.IdHubLogistic as Id,
	        HL.IdCountry,
			HL.HubName,
	       (HL.HubAbbreviation) Abbreviation,
		   ISNULL(HL.HubLatitude,0)  AS Lat,
		   ISNULL(HL.HubLongitude,0) AS Lon	  
	FROM [DeliveryBackOffice].[dbo].[HubLogistics] HL WITH (NOLOCK)
	WHERE HL.HubAbbreviation IS NOT NULL 
	
END