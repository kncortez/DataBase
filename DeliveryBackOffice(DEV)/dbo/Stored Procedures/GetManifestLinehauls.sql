-- =============================================
-- Author:		<Eduardo Lòpez>
-- Create date: <04/08/2022>
-- Description:	<SP para obtener datos y pintarlos en grid de modulo de impresion y visor de manifiestos de Linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[GetManifestLinehauls]
@DateFilter AS DATE = '',
@Station INT

AS

	BEGIN
	SELECT DISTINCT lrp.IdLinehaulRoutePreparation, 
	cr.CodeRoute, 
	IIF((lrp.CatVehicleId IS NULL), lrp.VehicleID, cv.CodeName) CodeVehicle,
	IIF((lrp.SenderReceiverId IS NULL), lrp.DriverName, sr.First_Name+ ' '+sr.Last_Name) Courier,
	cls.StatusName,
	cls.StatusDescription,
	CONVERT(VARCHAR, lrp.DateLinehaulRoutePreparation, 103) DateRoute,
	lrp.DateCreated DateCreated,
	lrp.DateUpdated DateUpdated,
	lrp.ContainerQuantity,
	(select sum(lrpc2.GuideQuantity) from LinehaulRoutePreparation lrp2 WITH (NOLOCK)
	inner join LinehaulRoutePreparationContainer lrpc2 WITH (NOLOCK)
	on lrp2.IdLinehaulRoutePreparation = lrpc2.LinehaulRoutePreparationId
	inner join Container ctn2 WITH (NOLOCK)
	on lrpc2.ContainerId = ctn2.IdContainer where ctn2.CatTypeContainerId = 1 and CONVERT(DATE, lrp2.DateCreated) = @DateFilter
			AND lrp2.StationDispatchedId = @Station) AS TotalGuideNoPiso,

	(select top 1 ((sum(lrpc2.ColdPieceQuantity))+(sum(lrpc2.DryPieceQuantity))) from LinehaulRoutePreparation lrp2 WITH (NOLOCK)
	inner join LinehaulRoutePreparationContainer lrpc2 WITH (NOLOCK)
	on lrp2.IdLinehaulRoutePreparation = lrpc2.LinehaulRoutePreparationId
	inner join Container ctn2 WITH (NOLOCK)
	on lrpc2.ContainerId = ctn2.IdContainer where ctn2.CatTypeContainerId = 1 and CONVERT(DATE, lrp2.DateCreated) = @DateFilter
			AND lrp2.StationDispatchedId = @Station) AS TotalPiecesNoPiso,

	(select sum(lrpc2.GuideQuantity) from LinehaulRoutePreparation lrp2 WITH (NOLOCK)
	inner join LinehaulRoutePreparationContainer lrpc2 WITH (NOLOCK)
	on lrp2.IdLinehaulRoutePreparation = lrpc2.LinehaulRoutePreparationId
	inner join Container ctn2 WITH (NOLOCK)
	on lrpc2.ContainerId = ctn2.IdContainer where ctn2.CatTypeContainerId = 2 and CONVERT(DATE, lrp2.DateCreated) = @DateFilter
			AND lrp2.StationDispatchedId = @Station) AS TotalGuidePiso,

	(select top 1 ((sum(lrpc2.ColdPieceQuantity))+(sum(lrpc2.DryPieceQuantity))) from LinehaulRoutePreparation lrp2 WITH (NOLOCK)
	inner join LinehaulRoutePreparationContainer lrpc2 WITH (NOLOCK)
	on lrp2.IdLinehaulRoutePreparation = lrpc2.LinehaulRoutePreparationId
	inner join Container ctn2 WITH (NOLOCK)
	on lrpc2.ContainerId = ctn2.IdContainer where ctn2.CatTypeContainerId = 2 and CONVERT(DATE, lrp2.DateCreated) = @DateFilter
			AND lrp2.StationDispatchedId = @Station) AS TotalPiecesPiso,
	(select sum(lrpcd.GuideDryPieceTotal) - sum(lrpcd.DryPieceQuantity)) AS DifPiecesDry, 
	(select sum(lrpcd.GuideColdPieceTotal) - sum(lrpcd.ColdPieceQuantity)) AS DifPiecesCold
		FROM LinehaulRoutePreparation lrp WITH (NOLOCK)
		INNER JOIN CatRoute cr WITH (NOLOCK)
		ON lrp.CatRouteId = cr.IdRoute
		LEFT JOIN CatVehicle cv WITH (NOLOCK)
		ON lrp.CatVehicleId = cv.IdVehicle
		LEFT JOIN SenderReceiver sr WITH (NOLOCK)
		ON lrp.SenderReceiverId = sr.ID
		INNER JOIN CatLinehaulStatus cls WITH (NOLOCK)
		ON lrp.CatLinehaulStatusId = cls.IdCatLinehaulStatus
		INNER JOIN LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
		ON lrp.IdLinehaulRoutePreparation = lrpc.LinehaulRoutePreparationId
		INNER JOIN Container ctn WITH (NOLOCK)
		ON lrpc.ContainerId = ctn.IdContainer 
		INNER JOIN CatTypeContainer ctc WITH (NOLOCK)
		ON ctn.CatTypeContainerId = ctc.IdCatTypeContainer
		INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
		ON lrpc.IdLinehaulRoutePreparationContainer = lrpcd.LinehaulRoutePreparationContainerId
			WHERE lrp.DateLinehaulRoutePreparation = @DateFilter
			AND lrp.StationDispatchedId = @Station
			AND lrpcd.RowStatus = 1
					Group by lrp.IdLinehaulRoutePreparation, 
					 cr.CodeRoute, 
					 lrp.CatVehicleId,
					 lrp.VehicleID,
					 lrp.SenderReceiverId,
					 lrp.DriverName,
					 cv.CodeName, 
					 sr.First_Name, 
					 sr.Last_Name, 
					 cls.StatusName, 
					 cls.StatusDescription,
					 lrp.DateCreated,
					 lrp.DateUpdated,
					 lrp.DateLinehaulRoutePreparation,
					 lrp.ContainerQuantity,
					 lrp.GuideQuantity,
					 lrp.ColdPieceQuantity,
					 lrp.DryPieceQuantity


	
	END