--USE DeliveryBackOffice
-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <12-04-2023>
-- Description:	<Get route and CatTypeRoute data>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetRouteData]
	@CodeRoute AS NVARCHAR(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT		[CR].[IdRoute],
				[CR].[CodeRoute],
				[CR].[Description],
				[CR].[IdTownship],
				[T].[TownshipName],
				[CR].[IdTypeRoute],
				[CTR].[Name] [Type]
	FROM		[dbo].[CatRoute] CR
	INNER JOIN	[dbo].[Township] T
		ON		[CR].[IdTownship] = [T].[IdTownship]
	INNER JOIN	[dbo].[CatTypeRoute] CTR
		ON		[CR].[IdTypeRoute] = [CTR].[IdTypeRoute]
	WHERE	[CR].[CodeRoute] = @CodeRoute 
		AND [CR].[RowStatus] = 1;
END