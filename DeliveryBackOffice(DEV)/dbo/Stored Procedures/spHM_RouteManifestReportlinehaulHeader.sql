-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-04>
-- Description:	<encabezado de reporte Ruta  LineHauls>
-- =============================================
CREATE procedure [dbo].[spHM_RouteManifestReportlinehaulHeader] 

@IdLinehaulRoutePreparation as int 
as
begin
	
	set nocount on;




select distinct
	    LRP.IdLinehaulRoutePreparation,
	    format(LRP.DateLinehaulRoutePreparation,'dd/MM/yyyy HH:mm:ss') DateLinehaulRoutePreparation,
        CR.CodeRoute,
		case
		  when 
				LRP.CatVehicleId is null 
		   then LRP.VehicleID else cast(LRP.CatVehicleId as varchar) end as CatVehicleId,
		case
		  when 
				CV.Plate is null 
		   then LRP.VehicleID else CV.Plate end as Plate,
		case 
		   when LRP.DriverName is null then (select top 1 First_Name 
		                                     from dbo.SenderReceiver  with (nolock)
											 where ID = LRP.SenderReceiverId )   
			else LRP.DriverName end as DriverName,
		LRP.ContainerQuantity
	--	LRP.GuideQuantity,
	--	LRP.ColdPieceQuantity + LRP.DryPieceQuantity as PieceQuantity,

	,count(lrpcd.GuideNumber) GuideQuantity
		,sum(LRPCD.GuideDryPieceTotal + LRPCD.GuideColdPieceTotal)PieceQuantity,
		LRPCM.CustomsMarkSerie,
	--	HL.HubAbbreviation as HubName
	 HubName.HubAbbreviation as HubName
 from [DeliveryBackOffice].[dbo].[LinehaulRoutePreparation] LRP with (nolock)
      LEFT JOIN [DeliveryBackOffice].[dbo].[CatVehicle] CV		WITH (NOLOCK)
			ON LRP.CatVehicleId = CV.IdVehicle
	  LEFT JOIN [DeliveryBackOffice].[dbo].[CatRoute] CR		WITH (NOLOCK)
			ON LRP.CatRouteId= CR.IdRoute
	  LEFT JOIN LinehaulRoutePreparationCustomsMark LRPCM WITH (NOLOCK)
	        ON  LRP.IdLinehaulRoutePreparation = LRPCM.LinehaulRoutePreparationId
	  --LEFT JOIN dbo.LinehaulCoverage LC WITH (NOLOCK)
	  --      ON LRP.CatRouteId = LC.CatRouteId
	  --LEFT JOIN HubLogistics HL WITH (NOLOCK)
	  --      ON LC.HubOriginId = HL.IdHubLogistic

	  inner join dbo.LinehaulRoutePreparationContainer lrpc on lrpc.LinehaulRoutePreparationId = LRP.IdLinehaulRoutePreparation
		inner join dbo.LinehaulRoutePreparationContainerDetail LRPCD on LRPCD.LinehaulRoutePreparationContainerId = lrpc.IdLinehaulRoutePreparationContainer

		outer apply(select  top 1 hll.HubAbbreviation from dbo.LinehaulCoverage lcc with(nolock)
			inner join dbo.HubLogistics hll with(nolock) on hll.IdHubLogistic = lcc.HubOriginId
		where lcc.CatRouteId = LRP.CatRouteId and lcc.RowStatus = 1)  as HubName
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
			--HL.HubAbbreviation,
			HubName.HubAbbreviation,
			LRP.VehicleID,
			LRP.SenderReceiverId


   
END