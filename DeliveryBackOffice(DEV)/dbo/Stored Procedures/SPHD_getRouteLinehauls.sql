
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-21>
-- Description:	<Devuelve  rutas Linehauls por estación asociada >
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_getRouteLinehauls]
@IdStation as int
AS
BEGIN
		SELECT DISTINCT 
		   CS.HubLogisticId,
		   CS.IdStation, 
		   CS.StationName,
		   HL.HubAbbreviation, 
		   HL.HubName,
		   LC.IdRoute,
		   CR.CodeRoute
	FROM [dbo].[CatStation] CS WITH (NOLOCK)
		INNER JOIN [dbo].[HubLogistics] HL WITH (NOLOCK)
	ON CS.HubLogisticId= HL.IdHubLogistic
		INNER JOIN [dbo].[CatLinehaul] LC WITH (NOLOCK)
	ON HL.IdHubLogistic = LC.IdHubOrigin
		INNER JOIN [dbo].[CatRoute] CR WITH (NOLOCK)
	ON LC.IdRoute = CR.IdRoute
    WHERE CS.IdStation   = @IdStation
       AND 
       CR.RowStatus   = 1 
	   AND 
	   CR.IdTypeRoute = 2
ORDER BY LC.IdRoute


END