-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <04-08-2022>
-- Description:	<Get and check tag in linehaulRoutePreparationCustomsMark>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getLinehaulRoutePreparationCustomsMark]
	@LinehaulRoutePreparationId AS INT,
	@Tag as NVARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	[LRPCM].[IdLinehaulRoutePreparationCustomsMark], 
			[LRPCM].[LinehaulRoutePreparationId],
			[LRPCM].[CustomsMarkSerie]
	FROM	[dbo].[LinehaulRoutePreparationCustomsMark] LRPCM
	WHERE	[LRPCM].[LinehaulRoutePreparationId] = @LinehaulRoutePreparationId
		AND	[LRPCM].[CustomsMarkSerie] = @Tag
		AND [LRPCM].[RowStatus] = 1;
    
END