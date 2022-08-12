-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-08>
-- Description:	<Obtiene datos de liquidación de ruta Linehaul>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetLinehaulSettlementData]
	@RouteId INT,
	@DateLinehaulRoutePreparation DATE,
	@CustomsMarkSerie NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LinehaulRoutePreparationId INT 
	DECLARE @CatLinehaulStatusId INT 

	SELECT TOP 1
		@LinehaulRoutePreparationId = IdLinehaulRoutePreparation
	   ,@CatLinehaulStatusId = CatLinehaulStatusId
	FROM LinehaulRoutePreparation
	WHERE CatRouteId = @RouteId
	AND DateLinehaulRoutePreparation = @DateLinehaulRoutePreparation
	AND RowStatus = 1
	ORDER BY DateCreated DESC
	
	IF @LinehaulRoutePreparationId IS NOT NULL
	BEGIN 

		IF EXISTS (SELECT
			1
		FROM CatLinehaulStatus
		WHERE IdCatLinehaulStatus = @CatLinehaulStatusId
		AND StatusName = 'IN TRANSIT')
		BEGIN
			IF EXISTS (SELECT
					1
				FROM LinehaulRoutePreparationCustomsMark
				WHERE LinehaulRoutePreparationId = @LinehaulRoutePreparationId
				AND CustomsMarkSerie = @CustomsMarkSerie
				AND RowStatus = 1)
			BEGIN
				
				SELECT			  
					1 'StatusCode',
					'Records found' 'Description'

				--TABLE 0 MANIFEST HEADER
				SELECT
					IdLinehaulRoutePreparation
				   ,StationDispatchedId
				   ,CatLinehaulStatusId
				   ,CatRouteId
				   ,COALESCE(SenderReceiverId, 0) SenderReceiverId
				   ,COALESCE(CatVehicleId, 0) CatVehicleId
				   ,COALESCE(DriverCUI, '') DriverCUI
				   ,COALESCE(DriverName, '') DriverName
				   ,COALESCE(DriverPhone, '') DriverPhone
				   ,COALESCE(VehicleID, '') VehicleID
				   ,COALESCE(VehicleDescription, '') VehicleDescription
				   ,COALESCE(SecurityManName, '') SecurityManName
				   ,COALESCE(SecurityManPhone, '') SecurityManPhone
				   ,COALESCE(SecurityManCUI, '') SecurityManCUI
				   ,DateLinehaulRoutePreparation
				   ,ContainerQuantity
				   ,GuideQuantity
				   ,DryPieceQuantity
				   ,ColdPieceQuantity
				FROM LinehaulRoutePreparation
				WHERE IdLinehaulRoutePreparation = @LinehaulRoutePreparationId

				--TABLE 1 CONTAINER DATA
				SELECT 
					lrpc.IdLinehaulRoutePreparationContainer
					,lrpc.ContainerId 
					,c.ContainerDescription
					,c.ContainerNumber
					,ctc.TypeContainerSerie
					,lrpc.GuideQuantity
					,lrpc.DryPieceQuantity
					,lrpc.ColdPieceQuantity
					,lrpc.HubDestinyId
					,lrpcd.IdLinehaulRoutePreparationContainerDetail
					,lrpcd.GuideSerie
					,lrpcd.GuideNumber
					,lrpcd.DryPieceQuantity
					,lrpcd.ColdPieceQuantity
					,lrpcdp.IdLinehaulRoutePreparationContainerDetailPiece
					,lrpcdp.PieceNumber
					,lrpcdp.IsDryPiece
					,lrpcdp.ActCode
				FROM LinehaulRoutePreparationContainer lrpc
				INNER JOIN Container c
					ON c.IdContainer = lrpc.ContainerId
				INNER JOIN CatTypeContainer ctc
					ON ctc.IdCatTypeContainer = c.CatTypeContainerId
				LEFT JOIN LinehaulRoutePreparationContainerDetail lrpcd
					ON lrpcd.LinehaulRoutePreparationContainerId = lrpc.IdLinehaulRoutePreparationContainer
				LEFT JOIN LinehaulRoutePreparationContainerDetailPiece lrpcdp
					ON lrpcdp.LinehaulRoutePreparationContainerDetailId = lrpcd.IdLinehaulRoutePreparationContainerDetail
				WHERE lrpc.LinehaulRoutePreparationId = @LinehaulRoutePreparationId
				AND lrpc.RowStatus = 1 AND lrpcd.RowStatus = 1 AND lrpcdp.RowStatus = 1 AND lrpcdp.ActCode IS NULL
			END
			ELSE
			BEGIN
				SELECT			  
					4 'StatusCode',
					'Not found Marchamo' 'Description'
			END
		END
		ELSE 
		BEGIN
			SELECT			  
				3 'StatusCode',
				'Status isn''t in transit' 'Description'
		END
	END
	ELSE
	BEGIN
		SELECT			  
			2 'StatusCode',
			'Not found records' 'Description'
	END
END