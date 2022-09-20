-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-04>
-- Description:	<encabezado de reporte Ruta  LineHauls>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_RouteManifestReportlinehaulHeader] 

@IdLinehaulRoutePreparation AS INT 
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT distinct
	    LRP.IdLinehaulRoutePreparation,
	    FORMAT(LRP.DateLinehaulRoutePreparation,'yyyy-MM-dd HH:mm:ss') DateLinehaulRoutePreparation,
        CR.CodeRoute,
		LRP.CatVehicleId,
		CV.Plate,
		LRP.DriverName,
		LRP.ContainerQuantity,
		LRP.GuideQuantity,
		LRP.ColdPieceQuantity + LRP.DryPieceQuantity as PieceQuantity,
		LRPCM.CustomsMarkSerie,
		HL.HubName
 FROM [DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
      LEFT JOIN [DeliveryBackOffice].[dbo].[CatVehicle] CV		WITH (NOLOCK)
			ON LRP.CatVehicleId = CV.IdVehicle
	  LEFT JOIN [DeliveryBackOffice].[dbo].[CatRoute] CR		WITH (NOLOCK)
			ON LRP.CatRouteId= CR.IdRoute
	  LEFT JOIN LinehaulRoutePreparationCustomsMark LRPCM WITH (NOLOCK)
	        ON  LRP.IdLinehaulRoutePreparation = LRPCM.LinehaulRoutePreparationId
	  LEFT JOIN dbo.LinehaulCoverage LC WITH (NOLOCK)
	        ON LRP.CatRouteId = LC.CatRouteId
	  LEFT JOIN HubLogistics HL WITH (NOLOCK)
	        ON LC.HubOriginId = HL.IdHubLogistic
 WHERE IdLinehaulRoutePreparation = @IdLinehaulRoutePreparation
 GROUP BY   LRP.IdLinehaulRoutePreparation,
            LRP.DateLinehaulRoutePreparation,
		    CR.CodeRoute,
			LRP.CatVehicleId,
			CV.Plate,
			LRP.DriverName,
			LRP.ContainerQuantity,
			LRP.GuideQuantity,
			LRP.ColdPieceQuantity,
			LRP.DryPieceQuantity,
			LRPCM.CustomsMarkSerie,
			HL.HubName


   
END