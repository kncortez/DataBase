-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <19-07-2022>
-- Description:	<Get a list of Destiny Hubs in LinehaulCoverage by RouteId>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getDestinyHubsByRouteId]
	@CatRouteId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT		[LC].[HubDestinyId],
				[HL].[HubAbbreviation]
	FROM		[dbo].[LinehaulCoverage] LC
	INNER JOIN	[dbo].[HubLogistics] HL
		ON		[LC].[HubDestinyId] = [HL].[IdHubLogistic] and hl.HubStatus = 1
	WHERE		[LC].[CatRouteId] = @CatRouteId and lc.RowStatus = 1;
END