-- =============================================
-- Author:		<Andrés,Ruíz>
-- Create date: <2023-04-04>
-- Description:	<Obtiene el detalle del módulo de manifiesto linehaul agrupado por hub en desktop>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_GetManifestLinehaulDetailByHub] 
	-- Add the parameters for the stored procedure here
	@IdLinehaulRoutePreparation INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		COUNT([LRPC].[ContainerId]) AS Containers,
		SUM([LRPC].[GuideQuantity]) AS Guides,
		SUM([LRPC].[DryPieceQuantity] + [LRPC].[ColdPieceQuantity]) AS Pieces
	FROM
		[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
		INNER JOIN
			[dbo].[HubLogistics] HL WITH (NOLOCK)
			ON
				[LRPC].[HubDestinyId] = [HL].[IdHubLogistic]
	WHERE
		[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation
	AND
		[LRPC].[RowStatus] = 1

	SELECT
		[LRPC].[HubDestinyId],
		[HL].[HubAbbreviation],
		COUNT([LRPC].[ContainerId]) AS Containers,
		SUM([LRPC].[GuideQuantity]) AS Guides,
		SUM([LRPC].[DryPieceQuantity] + [LRPC].[ColdPieceQuantity]) AS Pieces
	FROM
		[dbo].[LinehaulRoutePreparationContainer] LRPC WITH (NOLOCK)
		INNER JOIN
			[dbo].[HubLogistics] HL WITH (NOLOCK)
			ON
				[LRPC].[HubDestinyId] = [HL].[IdHubLogistic]
	WHERE
		[LRPC].[LinehaulRoutePreparationId] = @IdLinehaulRoutePreparation
	AND
		[LRPC].[RowStatus] = 1
	GROUP BY
			[LRPC].[HubDestinyId], [HL].[HubAbbreviation]

END