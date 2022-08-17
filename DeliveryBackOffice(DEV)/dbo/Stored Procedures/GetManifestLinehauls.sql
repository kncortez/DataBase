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
	cv.CodeName AS CodeVehicle, 
	(sr.First_Name+ ' '+sr.Last_Name) AS Courier, 
	cls.StatusName,
	cls.StatusDescription,
	lrp.DateCreated, 
	lrp.DateLinehaulRoutePreparation,
	lrp.ContainerQuantity,
	(select lrp.GuideQuantity  Where ctc.TypeContainerSerie = 'BOX') AS TotalGuideNoPiso,
	(select (lrp.ColdPieceQuantity+ lrp.DryPieceQuantity)  Where ctc.TypeContainerSerie = 'BOX') AS TotalPiecesNoPiso,
	(select lrp.GuideQuantity  Where ctc.TypeContainerSerie = 'LH') AS TotalGuidePiso,
	(select (lrp.ColdPieceQuantity+ lrp.DryPieceQuantity)   Where ctc.TypeContainerSerie = 'LH') AS TotalPiecesPiso,
	(select (lrpcd.GuideDryPieceTotal - lrpcd.DryPieceQuantity)) AS DifPiecesDry, 
	(select (lrpcd.GuideColdPieceTotal - lrpcd.ColdPieceQuantity)) AS DifPiecesCold
		FROM LinehaulRoutePreparation lrp WITH (NOLOCK)
		INNER JOIN CatRoute cr WITH (NOLOCK)
		ON lrp.CatRouteId = cr.IdRoute
		INNER JOIN CatVehicle cv WITH (NOLOCK)
		ON lrp.CatVehicleId = cv.IdVehicle
		INNER JOIN SenderReceiver sr WITH (NOLOCK)
		ON lrp.SenderReceiverId = sr.ID
		INNER JOIN CatLinehaulStatus cls WITH (NOLOCK)
		ON lrp.CatLinehaulStatusId = cls.IdCatLinehaulStatus
		INNER JOIN LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
		ON lrp.IdLinehaulRoutePreparation = lrpc.LinehaulRoutePreparationId
		INNER JOIN Container ctn WITH (NOLOCK)
		ON lrpc.ContainerId = ctn.IdContainer 
		INNER JOIN CatTypeContainer ctc WITH (NOLOCK)
		ON ctn.IdContainer = ctc.IdCatTypeContainer
		INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
		ON lrpc.IdLinehaulRoutePreparationContainer = lrpcd.LinehaulRoutePreparationContainerId
			WHERE CONVERT(DATE, lrp.DateCreated) = @DateFilter
			AND lrp.StationDispatchedId = @Station


	
	END