USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_get_RouteZone]    Script Date: 24/03/2021 12:23:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-24>
-- Description:	<Devuelve los valores de las rutas con sus detalles de zonas y vehículos>
-- =============================================
ALTER PROCEDURE [dbo].[spg_get_RouteCategoryZone]
@Route as int = 1


AS
BEGIN

		select  IdRoute, CodeRoute, cr.Description, cr.IdTypeRoute, ct.Name from CatRoute cr
			inner join CatTypeRoute ct on (ct.IdTypeRoute = cr.IdTypeRoute)
		where IdRoute = @Route and cr.RowStatus = 1
			
			
		select RouteId, TownshipId, ts.IdProvince , ProvinceName, TownshipName, zr.Zone, cr.IdTypeRoute from ZoneByRoute zr
			inner join Township ts on (ts.IdTownship = zr.TownshipId)
			inner join Province pv on (pv.IdProvince = ts.IdProvince)
			inner join CatRoute cr on (cr.IdRoute = zr.RouteId)
		where RouteId = @Route and RowStauts = 1
			
		select RouteId, CatVehicleCategoriesId, cv.Name, sum(cv.High * cv.Length * cv.Width) Capacity from VehicleCategoryByRoute vc
			inner join CatVehicleCategories cv on (cv.IdCatVehicleCategories = vc.CatVehicleCategoriesId)
		where RouteId = @Route and RowStauts = 1
		group by RouteId, CatVehicleCategoriesId, cv.Name

END