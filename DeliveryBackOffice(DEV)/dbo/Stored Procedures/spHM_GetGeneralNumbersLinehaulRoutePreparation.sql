-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <13-09-2022>
-- Description:	<Get general numbers from Linehaul Route Preparation>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetGeneralNumbersLinehaulRoutePreparation]
	@LinehaulRoutePreparationId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT	[LRP].[ContainerQuantity],
			[LRP].[GuideQuantity],
			[LRP].[DryPieceQuantity],
			[LRP].[ColdPieceQuantity]
	FROM	[dbo].[LinehaulRoutePreparation] LRP
	WHERE	[LRP].[IdLinehaulRoutePreparation] = @LinehaulRoutePreparationId;
END