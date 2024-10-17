-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-12-2>
-- Description:	<Obtiene información del manifiesto de rutas linehaul>
-- =============================================
CREATE PROCEDURE [dbo].[spg_detail_linehaul_routes]
	-- Add the parameters for the stored procedure here
	@IdLinehaulRoutePreparation INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
	DECLARE @companyName NVARCHAR(500) =(
	                                      Select TOP 1 companyName
												 From [InvoiceBatchDetailLinehaul] IBDL WITH(NOLOCK)
														  INNER JOIN 
													  [InvoiceBatchHeader] IBH WITH(NOLOCK)
													   ON IBDL.IdBatch = IBH.Id_Lote
												 Where LinehaulRoutePreparationId  = @IdLinehaulRoutePreparation);
		
	DECLARE @CAI NVARCHAR(500) =(
	                                      Select TOP 1  IBH.CAI
												 From [InvoiceBatchDetailLinehaul] IBDL WITH(NOLOCK)
														  INNER JOIN 
													  [InvoiceBatchHeader] IBH WITH(NOLOCK)
													   ON IBDL.IdBatch = IBH.Id_Lote
												 Where LinehaulRoutePreparationId  = @IdLinehaulRoutePreparation);
   DECLARE @Numero NVARCHAR(250) =(
      
									Select TOP 1 CAST([IBH].Establishment AS nvarchar) + '-' + CAST([IBH].Emision_Point AS nvarchar) + '-' + CAST([IBH].TypeDocument AS nvarchar) + '-' + CAST([IBDL].ProcessedCorrelative AS nvarchar)
									From [InvoiceBatchDetailLinehaul] IBDL WITH(NOLOCK)
									INNER JOIN 
									[InvoiceBatchHeader] IBH WITH(NOLOCK)
									ON IBDL.IdBatch = IBH.Id_Lote
									Where LinehaulRoutePreparationId = @IdLinehaulRoutePreparation);

	DECLARE @LimiteDate NVARCHAR(10) =(
	                                    Select TOP 1 FORMAT(IBH.LimitDateEmision, 'dd-MM-yyyy')
										From [InvoiceBatchDetailLinehaul] IBDL WITH(NOLOCK)
										INNER JOIN 
										[InvoiceBatchHeader] IBH WITH(NOLOCK)
										ON IBDL.IdBatch = IBH.Id_Lote
										Where LinehaulRoutePreparationId = @IdLinehaulRoutePreparation);
	
	
    -- Insert statements for procedure here
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
	   ,cr.CodeRoute RouteCode
	   ,IIF(sr.Id IS NULL, lrp.DriverName, CONCAT(sr.First_Name, ' ', sr.Last_Name)) CourierName
	   ,IIF(cv.IdVehicle IS NULL, CONCAT(lrp.VehicleID, ' - ', lrp.VehicleDescription), CONCAT(cv.UnitNumber, ' ', cv.Plate)) Vehicle
	   ,ISNULL((SELECT TOP 1
				lrpcd.DateCreated
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
				ON lrpc.IdLinehaulRoutePreparationContainer = lrpcd.LinehaulRoutePreparationContainerId
				AND lrpc.RowStatus = 1
			WHERE lrpc.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
			AND lrpc.RowStatus = 1
			ORDER BY lrpcd.DateCreated)
		, lrp.DateCreated) DateCreated
	   ,ISNULL((SELECT TOP 1
				lrpcd.DateCreated
			FROM LinehaulRoutePreparationContainer lrpc WITH (NOLOCK)
			INNER JOIN LinehaulRoutePreparationContainerDetail lrpcd WITH (NOLOCK)
				ON lrpc.IdLinehaulRoutePreparationContainer = lrpcd.LinehaulRoutePreparationContainerId
				AND lrpc.RowStatus = 1
			WHERE lrpc.LinehaulRoutePreparationId = @IdLinehaulRoutePreparation
			AND lrpc.RowStatus = 1
			ORDER BY lrpcd.DateCreated DESC)
		, lrp.DateLinehaulRoutePreparation)  DateRoutePreparation
		, ISNULL(lrpcm.CustomsMarkSerie, '') CustomMark
		, hl.HubAbbreviation HubAbbreviation
		,@companyName CompanyName
		,@CAI CAI 
		,@Numero Numero
		,@LimiteDate LimiteDate
	FROM LinehaulRoutePreparation lrp WITH (NOLOCK)
	LEFT JOIN CatRoute cr WITH (NOLOCK)
		ON cr.IdRoute = lrp.CatRouteId
	LEFT JOIN SenderReceiver sr WITH (NOLOCK)
		ON sr.Id = lrp.SenderReceiverId
	LEFT JOIN CatVehicle cv WITH (NOLOCK)
		ON cv.IdVehicle = lrp.CatVehicleId
	LEFT JOIN LinehaulRoutePreparationCustomsMark lrpcm WITH(NOLOCK)
		ON lrp.IdLinehaulRoutePreparation = lrpcm.LinehaulRoutePreparationId
		AND lrpcm.RowStatus = 1
	LEFT JOIN CatStation cs WITH (NOLOCK)
		ON lrp.StationDispatchedId = cs.IdStation
	LEFT JOIN HubLogistics hl WITH (NOLOCK)
		ON cs.HubLogisticId = hl.IdHubLogistic
	WHERE lrp.IdLinehaulRoutePreparation = @IdLinehaulRoutePreparation
	AND lrp.RowStatus = 1
END