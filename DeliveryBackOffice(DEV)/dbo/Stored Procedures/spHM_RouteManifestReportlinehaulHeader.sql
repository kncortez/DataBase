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

SELECT 
	    LRP.IdLinehaulRoutePreparation,
	    SUBSTRING(CONVERT(VARCHAR,LRP.DateLinehaulRoutePreparation,103),0,11) DateLinehaulRoutePreparation,
        CR.CodeRoute,
		LRP.CatVehicleId,
		CV.Plate,
		LRP.DriverName
 FROM [DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP WITH (NOLOCK)
      LEFT JOIN [DeliveryBackOffice].[dbo].[CatVehicle] CV		WITH (NOLOCK)
			ON LRP.CatVehicleId = CV.IdVehicle
	  LEFT JOIN [DeliveryBackOffice].[dbo].[CatRoute] CR		WITH (NOLOCK)
			ON LRP.CatRouteId= CR.IdRoute
 WHERE IdLinehaulRoutePreparation =  @IdLinehaulRoutePreparation

   
END