
CREATE PROCEDURE [dbo].[GetHubsbyLinehauls] @IdRoute AS INT
AS
BEGIN

	SELECT
		hl_destino.HubAbbreviation AS HUB_DESTINO
	FROM DeliveryBackOffice.dbo.HubLogistics hl_destino
	JOIN CatLinehaul cl
		ON hl_destino.IdHublogistic = cl.IdHubDestination
	WHERE cl.IdRoute = @IdRoute


END



