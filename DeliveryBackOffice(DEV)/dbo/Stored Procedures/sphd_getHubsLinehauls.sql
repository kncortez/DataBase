-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <2021-12-08>
-- Description:	<Regresa una lista de los hubs con su abreviatura correspondiente para rutas linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_getHubsLinehauls] 

AS
BEGIN
	SELECT IdHubLogistic Id,
	       HubAbbreviation, 
		   HubName [Name],
		   IdStation
	FROM DeliveryBackOffice.dbo.HubLogistics WITH (NOLOCK)
	
	
END