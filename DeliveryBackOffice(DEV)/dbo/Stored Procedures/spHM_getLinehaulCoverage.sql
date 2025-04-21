-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <14-07-2022>
-- Description:	<Get list of linehaul coverage by CatRouteId, HubDestiny and Township Destiny>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getLinehaulCoverage]
	@CatRouteId AS INT,
	@IdHub AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set arithabort on;

	SELECT		[LC].[IdLinehaulCoverage], 
				[LC].[CatRouteId], 
				[LC].[HubOriginId],
				[LC].[HubDestinyId],
				[HL].[HubAbbreviation] AS HubDestinyAbbreviation,
				[DSC].[HeaderCode],
				[TS].[IdTownship],
				[TS].[TownshipName]
	FROM		[dbo].[LinehaulCoverage] LC WITH(NOLOCK)
	INNER JOIN	[dbo].[HubLogistics] HL
		ON		[LC].[HubDestinyId] = [HL].[IdHubLogistic]
	INNER JOIN	[dbo].[DumpServiceCoverage] DSC
		ON		[HL].[HubAbbreviation] = [DSC].[Hub]
	INNER JOIN	[dbo].[Township] TS
		ON		[DSC].[HeaderCode] = [TS].[HeaderCode]
	WHERE 		[LC].[HubDestinyId] = @IdHub
		AND		[LC].[CatRouteId] = @CatRouteId
	
END