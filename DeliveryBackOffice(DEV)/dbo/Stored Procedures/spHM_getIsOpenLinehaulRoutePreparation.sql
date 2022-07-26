-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <26-07-2022>
-- Description:	<Check if LinehaulRoutePreparation is open for add more guides>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getIsOpenLinehaulRoutePreparation]
	@IdLinehaulRoutePreparation AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT	[LRP].[IdLinehaulRoutePreparation],
			[LRP].[StationDispatchedId],
			[LRP].[CatLinehaulStatusId],
			[LRP].[CatRouteId],
			COALESCE([LRP].[SenderReceiverId], 0) AS SenderReceiverId,
			[LRP].[CatVehicleId],
			[LRP].[DateLinehaulRoutePreparation],
			[LRP].[ContainerQuantity],
			[LRP].[GuideQuantity],
			[LRP].[DryPieceQuantity],
			[LRP].[ColdPieceQuantity]
	FROM	[dbo].[LinehaulRoutePreparation] LRP
	WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation
		AND [LRP].[CatLinehaulStatusId] = (	SELECT	[CLS].[IdCatLinehaulStatus]
											FROM	[dbo].[CatLinehaulStatus] CLS
											WHERE	[CLS].[StatusName] = 'GENERATED')
		AND [LRP].[RowStatus] = 1;
END