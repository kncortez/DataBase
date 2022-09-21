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




SELECT DISTINCT
	    LRP.IdLinehaulRoutePreparation,
	    FORMAT(LRP.DateLinehaulRoutePreparation,'dd/MM/yyyy HH:mm:ss') DateLinehaulRoutePreparation,
        CR.CodeRoute,
		CASE
		  WHEN 
				LRP.CatVehicleId IS NULL 
		   THEN LRP.VehicleID ELSE CAST(LRP.CatVehicleId AS VARCHAR) END AS Vehicle,
		CV.Plate,
		LRP.DriverName,
		LRP.ContainerQuantity,
		LRP.GuideQuantity,
		LRP.ColdPieceQuantity + LRP.DryPieceQuantity as PieceQuantity,
		LRPCM.CustomsMarkSerie,
		HL.HubAbbreviation
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
			HL.HubAbbreviation,
			LRP.VehicleID


   
END