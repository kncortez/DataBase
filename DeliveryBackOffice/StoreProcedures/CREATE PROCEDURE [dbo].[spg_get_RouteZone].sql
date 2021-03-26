USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_update_CatVehicle]    Script Date: 24/03/2021 09:44:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-24>
-- Description:	<Devuelve los valores de las rutas con sus detalles de zonas y vehículos>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RouteZone]



AS
BEGIN

		select distinct cr.CodeRoute, ctr.Name,
			ProvincesNames=STUFF((
							 SELECT ',' + ISNULL( prv.ProvinceName , '')
							 FROM  ZoneByRoute zbt inner join 
							 Township  tws on zbt.TownshipId = tws.IdTownship inner join
							 Province prv on (prv.IdProvince = tws.IdProvince) 
							 where zbt.RouteId = cr.IdRoute 
							 FOR XML PATH('')
							 ), 1, 1, '') 
			, 
			TownshipNames=STUFF((
							 SELECT ',' + ISNULL( tws.TownshipName , '')
							 FROM  ZoneByRoute zbt inner join 
							 Township  tws on zbt.TownshipId = tws.IdTownship
							 where zbt.RouteId = cr.IdRoute 
							 FOR XML PATH('')
							 ), 1, 1, '') , 
			Zones=STUFF((
							 SELECT ',' + ISNULL( Zone, '')
							 FROM ZoneByRoute zb
							 where zb.RouteId = cr.IdRoute 
							 FOR XML PATH('')
							 ), 1, 1, '') 
			, cr.Description,
			Vehicles=STUFF((
							 SELECT ',' + isnull( cv.Name, ' ')
							 FROM VehicleCategoryByRoute vcb
							 join CatVehicleCategories cv on (cv.IdCatVehicleCategories = vcb.CatVehicleCategoriesId)
							 where vcb.RouteId = cr.IdRoute
							 FOR XML PATH('')
							 ), 1, 1, ''),
			cr.DateCreated
		from CatRoute cr
		left join ZoneByRoute zbr on (cr.IdRoute = zbr.RouteId)
		left join Township tw on (tw.IdTownship = zbr.TownshipId)
		left join Province pv on (pv.IdProvince = tw.IdProvince)
		left join CatTypeRoute ctr on (ctr.IdTypeRoute = cr.IdTypeRoute)
		group by cr.CodeRoute, ctr.Name,cr.Description,cr.IdRoute ,tw.IdTownship, cr.DateCreated
		order by cr.DateCreated desc

END