USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spHM_getIsOpenLinehaulRoutePreparation]    Script Date: 26/11/2024 18:58:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Ochoa, Jerson>
-- Create date: <26-07-2022>
-- Description:	<Check if LinehaulRoutePreparation is open for add more guides>
-- =============================================
ALTER PROCEDURE [dbo].[spHM_getIsOpenLinehaulRoutePreparation]
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
			COALESCE([LRP].[CatVehicleId], 0) AS CatVehicleId,
			COALESCE([LRP].[DriverCUI], '') AS DriverCUI,
			COALESCE([LRP].[DriverName], '') AS DriverName,
			COALESCE([LRP].[DriverPhone], '') AS DriverPhone,
			COALESCE([LRP].[VehicleID], '') AS VehicleID,
			COALESCE([LRP].[VehicleDescription], '') AS VehicleDescription,
			COALESCE([LRP].[SecurityManName], '') AS SecurityManName,
			COALESCE([LRP].[SecurityManPhone], '') AS SecurityManPhone,
			COALESCE([LRP].[SecurityManCUI], '') AS SecurityManCUI,
			[LRP].[DateLinehaulRoutePreparation],
			[LRP].[ContainerQuantity],
			[LRP].[GuideQuantity],
			[LRP].[DryPieceQuantity],
			[LRP].[ColdPieceQuantity]
	FROM	[dbo].[LinehaulRoutePreparation] LRP WITH(NOLOCK)
	WHERE	[LRP].[IdLinehaulRoutePreparation] = @IdLinehaulRoutePreparation
		AND [LRP].[CatLinehaulStatusId] = (	SELECT	[CLS].[IdCatLinehaulStatus]
											FROM	[dbo].[CatLinehaulStatus] CLS
											WHERE	[CLS].[StatusName] = 'GENERATED')
		AND [LRP].[RowStatus] = 1;
END