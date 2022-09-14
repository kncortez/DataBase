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

	SELECT DISTINCT 
	lrp.IdLinehaulRoutePreparation, 
	cr.CodeRoute, 
	cv.CodeName AS CodeVehicle, 
	(sr.First_Name+ ' '+sr.Last_Name) AS Courier, 
	cls.StatusName,
	cls.StatusDescription,
	lrp.DateCreated, 
	lrp.DateLinehaulRoutePreparation,
	ISNULL(lrp.ContainerQuantity,0) AS ContainerQuantity,
	ISNULL((select ISNULL(lrp.GuideQuantity,0)  Where ctc.TypeContainerSerie = 'BOX'),0) AS TotalGuideNoPiso,
	ISNULL((select ISNULL((lrp.ColdPieceQuantity+ lrp.DryPieceQuantity),0)  Where ctc.TypeContainerSerie = 'BOX'),0) AS TotalPiecesNoPiso,
	ISNULL((select ISNULL(lrp.GuideQuantity,0)  Where ctc.TypeContainerSerie = 'LH'),0) AS TotalGuidePiso,
	ISNULL((select ISNULL((lrp.ColdPieceQuantity+ lrp.DryPieceQuantity),0)   Where ctc.TypeContainerSerie = 'LH'),0) AS TotalPiecesPiso,
	(select ISNULL((lrpcd.GuideDryPieceTotal - lrpcd.DryPieceQuantity),0)) AS DifPiecesDry, 
	(select ISNULL((lrpcd.GuideColdPieceTotal - lrpcd.ColdPieceQuantity),0)) AS DifPiecesCold
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
		ON ctn.CatTypeContainerId = ctc.IdCatTypeContainer
		INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
		ON lrpc.IdLinehaulRoutePreparationContainer = lrpcd.LinehaulRoutePreparationContainerId
			WHERE CONVERT(DATE, lrp.DateCreated) = @DateFilter
			AND lrp.StationDispatchedId = @Station
		GROUP BY lrp.IdLinehaulRoutePreparation,
	            	cr.CodeRoute, 
	               cv.CodeName,
				   sr.First_Name,
				   sr.Last_Name,
				   cls.StatusName,
				   cls.StatusDescription,
	               lrp.DateCreated, 
	               lrp.DateLinehaulRoutePreparation,
				   lrp.GuideQuantity,
				   lrp.ContainerQuantity,
				   ctc.TypeContainerSerie,
				   lrp.ColdPieceQuantity,
				   lrp.DryPieceQuantity,
				   lrpcd.GuideDryPieceTotal,
				   lrpcd.DryPieceQuantity,
				   lrpcd.GuideColdPieceTotal,
				   lrpcd.ColdPieceQuantity
				   


	
	END