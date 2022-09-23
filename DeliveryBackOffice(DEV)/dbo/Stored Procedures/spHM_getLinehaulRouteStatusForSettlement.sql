-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <04-08-2022>
-- Description:	<Get status from LinehaulRouteSettlement>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_getLinehaulRouteStatusForSettlement] 
	@CatRouteId AS INT,
	@DateLinehaul AS DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT		[LRP].[IdLinehaulRoutePreparation],
				[LRP].[StationDispatchedId],
				[LRP].[CatLinehaulStatusId],
				[CLS].[StatusName],
				[LRP].[CatRouteId],
				[CR].[CodeRoute],
				COALESCE([LRP].[SenderReceiverId], 0) AS SenderReceiverId,
				CONCAT([SR].[First_Name], ' ', [SR].[Last_Name]) AS SenderReceiverName,
				COALESCE([LRP].[CatVehicleId], 0) AS CatVehicleId,
				[CV].[UnitNumber],
				[LRP].[DriverCUI],
				[LRP].[DriverName],
				[LRP].[DriverPhone],
				[LRP].[VehicleID], 
				[LRP].[VehicleDescription],
				[LRP].[SecurityManCUI],
				[LRP].[SecurityManName],
				[LRP].[SecurityManPhone],
				[LRP].[DateLinehaulRoutePreparation],
				[LRP].[ContainerQuantity],
				[LRP].[GuideQuantity],
				[LRP].[DryPieceQuantity],
				[LRP].[ColdPieceQuantity]
	FROM		[dbo].[LinehaulRoutePreparation] LRP
	INNER JOIN	[dbo].[CatLinehaulStatus] CLS
		ON		[LRP].[CatLinehaulStatusId] = [CLS].[IdCatLinehaulStatus]
		AND		[CLS].[StatusName] = 'IN TRANSIT'
	INNER JOIN	[dbo].[CatRoute] CR
		ON		[LRP].[CatRouteId] = [CR].[IdRoute]
	LEFT JOIN	[dbo].[SenderReceiver] SR
		ON		[LRP].[SenderReceiverId] = [SR].[ID]
	LEFT JOIN	[dbo].[CatVehicle] CV
		ON		[LRP].[CatVehicleId] = [CV].[IdVehicle]
	WHERE		[LRP].[CatRouteId] = @CatRouteId
		AND		[LRP].[DateLinehaulRoutePreparation] = @DateLinehaul
		AND		[LRP].[RowStatus] = 1;

END