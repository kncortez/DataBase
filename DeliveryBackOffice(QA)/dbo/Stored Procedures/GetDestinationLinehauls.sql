CREATE PROCEDURE [dbo].[GetDestinationLinehauls]
@IdRoute AS INT 
AS
BEGIN

	SELECT ISNULL(hl_destino.HubAbbreviation ,'N/A') FROM CatLinehaul cl
	JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino
			ON cl.IdHubDestination = hl_destino.IdHubLogistic
	WHERE cl.IdRoute = @IdRoute 

END


