-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-09-29>
-- Description:	<Obtiene el detalle del módulo de manifiesto linehaul desktop>
-- =============================================
CREATE PROCEDURE [dbo].[GetManifestLinehaulDetail] 
	-- Add the parameters for the stored procedure here
	@IdLinehaulRoutePreparation INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Table 0 Información del manifiesto
	SELECT
		lrp.IdLinehaulRoutePreparation IdLinehaulRoutePreparation
	   ,lrp.ContainerQuantity ContainerTotal
	   ,ISNULL((SELECT
				SUM(lrpc.GuideQuantity)
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN Container c
				ON lrpc.ContainerId = c.IdContainer
				AND c.RowStatus = 1
			INNER JOIN CatTypeContainer ctc
				ON ctc.IdCatTypeContainer = c.CatTypeContainerId
			WHERE lrpc.LinehaulRoutePreparationId = lrp.IdLinehaulRoutePreparation
			AND ctc.TypeContainerSerie = 'BOX'
			AND lrpc.RowStatus = 1)
		, 0)
		ContainerGuideTotal
	   ,ISNULL((SELECT
				SUM(lrpc.DryPieceQuantity + lrpc.DryPieceQuantity)
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN Container c
				ON lrpc.ContainerId = c.IdContainer
				AND c.RowStatus = 1
			INNER JOIN CatTypeContainer ctc
				ON ctc.IdCatTypeContainer = c.CatTypeContainerId
			WHERE lrpc.LinehaulRoutePreparationId = lrp.IdLinehaulRoutePreparation
			AND ctc.TypeContainerSerie = 'BOX'
			AND lrpc.RowStatus = 1)
		, 0)
		ContainerPiecesTotal
	   ,ISNULL((SELECT
				SUM(lrpc.GuideQuantity)
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN Container c WITH (NOLOCK)
				ON lrpc.ContainerId = c.IdContainer
				AND c.RowStatus = 1
			INNER JOIN CatTypeContainer ctc WITH (NOLOCK)
				ON ctc.IdCatTypeContainer = c.CatTypeContainerId
			WHERE lrpc.LinehaulRoutePreparationId = lrp.IdLinehaulRoutePreparation
			AND ctc.TypeContainerSerie = 'LH'
			AND lrpc.RowStatus = 1)
		, 0)
		FloorGuideTotal
	   ,cr.CodeRoute RouteCode
	   ,IIF(sr.Id IS NULL, lrp.DriverName, CONCAT(sr.First_Name, ' ', sr.Last_Name)) CourierName
	   ,IIF(cv.IdVehicle IS NULL, CONCAT(lrp.VehicleID, ' - ', lrp.VehicleDescription), cv.Plate) Vehicle
	   ,cls.StatusName StatusName
	   ,cls.StatusDescription StatusDescription
	   ,FORMAT(lrp.DateCreated, 'dd/MM/yyyy') DateCreated
	   ,FORMAT(lrp.DateLinehaulRoutePreparation, 'dd/MM/yyyy') DateRoutePreparation
	FROM LinehaulRoutePreparation lrp WITH (NOLOCK)
	LEFT JOIN CatRoute cr WITH (NOLOCK)
		ON cr.IdRoute = lrp.CatRouteId
	LEFT JOIN SenderReceiver sr WITH (NOLOCK)
		ON sr.Id = lrp.SenderReceiverId
	LEFT JOIN CatVehicle cv WITH (NOLOCK)
		ON cv.IdVehicle = lrp.CatVehicleId
	INNER JOIN CatLinehaulStatus cls WITH (NOLOCK)
		ON cls.IdCatLinehaulStatus = lrp.CatLinehaulStatusId
	WHERE lrp.IdLinehaulRoutePreparation = @IdLinehaulRoutePreparation
	AND lrp.RowStatus = 1

	-- Table 1 Detalle manifiesto
	SELECT
		CONCAT(lrpcd.GuideSerie, lrpcd.GuideNumber) Guide
	   ,CONCAT((lrpcd.DryPieceQuantity + lrpcd.ColdPieceQuantity), '/', (lrpcd.GuideDryPieceTotal + lrpcd.GuideColdPieceTotal)) Pieces
	   ,c.ContainerNumber ContainerNumber
	   ,c.ContainerDescription ContainerDescription
	   ,hl.HubName
	   ,hl.HubAbbreviation
	   ,(SELECT TOP 1
				p.ProvinceName
			FROM DumpServiceCoverage dsc WITH (NOLOCK)
			INNER JOIN Settlement s WITH (NOLOCK)
				ON s.IdSettlement = dsc.IdSettlement
			INNER JOIN Province p WITH (NOLOCK)
				ON s.IdProvince = p.IdProvince
			WHERE dsc.Hub = hl.HubAbbreviation)
		Department
	   ,IIF((lrpcd.DryPieceQuantity + lrpcd.ColdPieceQuantity) = (lrpcd.GuideDryPieceTotal + lrpcd.GuideColdPieceTotal), 0, 1) IsParcial
	FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
	INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
		ON lrpcd.LinehaulRoutePreparationContainerId = lrpc.IdLinehaulRoutePreparationContainer
			AND lrpcd.RowStatus = 1
	INNER JOIN Container c WITH (NOLOCK)
		ON c.IdContainer = lrpc.ContainerId
	INNER JOIN HubLogistics hl WITH (NOLOCK)
		ON hl.IdHubLogistic = lrpc.HubDestinyId
	WHERE lrpc.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
	AND lrpc.RowStatus = 1

END