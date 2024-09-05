
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-24>
-- Description:	<Devuelve los valores de las rutas con sus detalles de zonas y vehículos>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-03>
-- Description: <Se agrega filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RouteZone]
(
 @IdCountry NVARCHAR(2) = 'GT'
)
AS
BEGIN

		select distinct cr.CodeRoute, cr.IdRoute, ctr.Name,
			ProvincesNames=STUFF((
							 SELECT Distinct ',' + ISNULL(  prv.ProvinceName , '')
							 FROM  ZoneByRoute zbt inner join 
							 Township  tws on zbt.TownshipId = tws.IdTownship inner join
							 Province prv on (prv.IdProvince = tws.IdProvince) 
							 where zbt.RouteId = cr.IdRoute 
							 FOR XML PATH('')
							 ), 1, 1, '') 
			, 
			TownshipNames=STUFF((
							 SELECT Distinct ',' + ISNULL( tws.TownshipName , '')
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
							 INNER join CatVehicleCategories cv on (cv.IdCatVehicleCategories = vcb.CatVehicleCategoriesId)
							 where vcb.RouteId = cr.IdRoute
							 FOR XML PATH('')
							 ), 1, 1, ''),
			cr.DateCreated
		from CatRoute cr
		full outer join ZoneByRoute zbr on (cr.IdRoute = zbr.RouteId)
		full outer join Township tw on (tw.IdTownship = zbr.TownshipId)
		full outer join Province pv on (pv.IdProvince = tw.IdProvince)
		left join CatTypeRoute ctr on (ctr.IdTypeRoute = cr.IdTypeRoute)
		where cr.RowStatus = 1
        AND IIF(pv.IdCountry IS NULL, 'GT', pv.IdCountry) = @IdCountry
		group by cr.CodeRoute, ctr.Name,cr.Description,cr.IdRoute ,tw.IdTownship, cr.DateCreated
		order by cr.IdRoute desc

END
