
CREATE PROCEDURE [dbo].[GetHubsByRouteLinehauls]
	@IdRoute INT
AS
BEGIN

--DECLARE @IdRoute INT = -1;
DECLARE @FlagEnabledLinehaul INT = 1;
DECLARE @FlagEnabledHub INT = 1;
DECLARE @IdCountry VARCHAR(2) = 'GT';
DECLARE @FlagAll INT = -1;

IF @IdRoute IS NULL
BEGIN
	SET @IdRoute = -1;
END

SELECT hl.IdHubLogistic Id, hl.HubAbbreviation Name
FROM DeliveryBackOffice.dbo.CatLinehaul cl
INNER JOIN DeliveryBackOffice.dbo.HubLogistics hl
	ON cl.IdHubDestination = hl.IdHubLogistic
	AND hl.HubStatus = @FlagEnabledHub
	AND hl.IdCountry = @IdCountry
WHERE cl.RowStatus = @FlagEnabledLinehaul
AND (cl.IdRoute = @IdRoute
	 OR @FlagAll = @IdRoute)
GROUP BY hl.IdHubLogistic, hl.HubAbbreviation;

END


