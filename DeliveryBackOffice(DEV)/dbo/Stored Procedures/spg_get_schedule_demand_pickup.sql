-- =============================================
-- Author:		<Oscar Rodriguez>
-- Update date: <2024-04-t01>
-- Description:	<Obtiene la informacion sobre recolecciones a demanda y programadas, para integración con DispatchTrack>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Update date: <2024-06-17>
-- Description: <Se agrega filtro >
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_schedule_demand_pickup]
	@CollectionProvince AS NVARCHAR(200),
	@TypePickup AS INT, -- 1 es a demanda, 2 programado
	@AssignDate AS DATE,
	@StartDate AS TIME,
	@EndDate AS TIME,
    @IdCountry VARCHAR(2) = 'GT'
AS
BEGIN

IF @CollectionProvince = '-1' BEGIN

	IF @TypePickup = 1 BEGIN
          print 'acas'
	SELECT	IIF(sp.IsScheduled = 0, CONCAT('RDG', sm.IdServiceManagement), CONCAT('RPG', sm.IdServiceManagement) ) [ORDEN DE RECOLECCION], 
			'' [RUTA], 
			IIF(ctv.Name = 'Camión', 'Paquete grande', IIF(ctv.Name = 'Panel', 'Paquete mediano', IIF(ctv.Name = 'Motocicleta', 'Paquete pequeño', ''))) [DESCRIPCION DEL PAQUETE], 
			IIF(sp.QuantityRegularPackages is null, '', sp.QuantityRegularPackages) [CANTIDAD DE PIEZAS], 
			'' [CODIGO DE ITEM], sp.SenderId [CODIGO DE PUNTO DE VISITA], 
			vpc.DescriptionOfClient [NOMBRE DE REMITENTE], 
			IIF(vpc.Phone is null, '', vpc.Phone ) [TELEFONO DE REMITENTE], 
			IIF(sp.AccountId is null, IIF(vpc.Email is null, '', vpc.Email), ru.UsrEmail ) [EMAIL REMITENTE], 
			IIF(vpc.Address is null, '', vpc.Address) [DIRECCION REMITENTE], 
			IIF(vpc.Latitude is null, '', vpc.Latitude) [LATITUD], 
			IIF(vpc.Longitude is null, '', vpc.Longitude ) [LONGITUD], 
			CAST(ra.DateOfRoute AS DATETIME) + CAST(CAST(
				(Select distinct top 1 es.DateCreated
				from deliveryBackOffice.dbo.EventService es
				where es.ServiceManagementId = sm.IdServiceManagement
				AND es.ServiceStatusId = 2
				order by es.DateCreated desc)
			AS TIME) AS DATETIME) [FECHA Y HORA MINIMA DE RECOLECCION], 
			DATEADD(HOUR,2,CAST(ra.DateOfRoute AS DATETIME) + CAST(CAST(
				(Select distinct top 1 es.DateCreated
				from deliveryBackOffice.dbo.EventService es
				where es.ServiceManagementId = sm.IdServiceManagement
				AND es.ServiceStatusId = 2
				order by es.DateCreated desc)
			AS TIME) AS DATETIME)) [FECHA Y HORA MAXIMA DE RECOLECCION], 
			'' [CT DESTINO], 
			'Solo Recogida' [MODO]
	FROM		[DeliveryBackOffice].dbo.ServiceManagement	sm		WITH (NOLOCK)
	INNER  JOIN	[DeliveryBackOffice].dbo.SchedulePickup		sp		WITH (NOLOCK) ON sm.IdSchedulePickup = sp.SchedulePickupId
	INNER  JOIN	[DeliveryBackOffice].dbo.VisitPointClient	vpc		WITH (NOLOCK) ON vpc.CodeOfReference = sp.SenderId
	INNER  JOIN	[DeliveryBackOffice].dbo.Township			tw		WITH (NOLOCK) ON tw.IdTownShip = sp.TownshipId 
	LEFT   JOIN	[DeliveryBackOffice].dbo.CatTypeVehicle		ctv		WITH (NOLOCK) ON ctv.IdTypeVehicle = sp.TypeVehicleId
	LEFT   JOIN	[DeliveryBackOffice].dbo.RolByUserByAccount rbuba	WITH (NOLOCK) ON rbuba.RuaIdAccount = sp.AccountId
	LEFT   JOIN	[DeliveryBackOffice].dbo.RegisterUser		ru		WITH (NOLOCK) ON ru.UsrIdUser = rbuba.RuaIdUser
	LEFT   JOIN	[DeliveryBackOffice].dbo.Province			pv		WITH (NOLOCK) ON pv.IdProvince = tw.IdProvince
	INNER  JOIN	[DeliveryBackOffice].dbo.RouteAssigment		ra		WITH (NOLOCK) ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
	WHERE	sp.IsScheduled = 0
	AND		sm.IdPuCourrier is not null 
	AND		ra.IdVehicle is not null
	AND		ra.DateOfRoute = @AssignDate
	AND		CAST(
				(Select distinct top 1 es.DateCreated
				from deliveryBackOffice.dbo.EventService es
				where es.ServiceManagementId = sm.IdServiceManagement
				AND es.ServiceStatusId = 2
				order by es.DateCreated desc)
			AS TIME) BETWEEN @StartDate AND @EndDate
    AND IIF(pv.IdCountry IS NULL, 'GT', pv.IdCountry) = @IdCountry
	ORDER BY [ORDEN DE RECOLECCION] DESC;

	END

	ELSE BEGIN
            PRINT 'ACA'
	SELECT	IIF(sp.IsScheduled = 0, CONCAT('RDG', sm.IdServiceManagement), CONCAT('RPG', sm.IdServiceManagement) ) [ORDEN DE RECOLECCION], 
			IIF(cr.CodeRoute is null, '',cr.CodeRoute) [RUTA],		
			'Caja' [DESCRIPCION DEL PAQUETE], 
			'' [CANTIDAD DE PIEZAS], 
			'' [CODIGO DE ITEM], 
			sp.SenderId [CODIGO DE PUNTO DE VISITA], 
			vpc.DescriptionOfClient [NOMBRE DE REMITENTE], 
			IIF(vpc.Phone is null, '', vpc.Phone ) [TELEFONO DE REMITENTE], 
			IIF(sp.AccountId is null, IIF(vpc.Email is null, '', vpc.Email), ru.UsrEmail ) [EMAIL REMITENTE], 
			IIF(vpc.Address is null, '', vpc.Address) [DIRECCION REMITENTE], 
			IIF(vpc.Latitude is null, '', vpc.Latitude) [LATITUD], 
			IIF(vpc.Longitude is null, '', vpc.Longitude ) [LONGITUD], 
			CAST(ra.DateOfRoute AS DATETIME) + CAST(CAST(sp.StartDate AS TIME) AS DATETIME) [FECHA Y HORA MINIMA DE RECOLECCION], 
			CAST(ra.DateOfRoute AS DATETIME) + CAST(CAST(sp.EndDate AS TIME) AS DATETIME) [FECHA Y HORA MAXIMA DE RECOLECCION], 
			'' [CT DESTINO], 
			'Solo Recogida' [MODO]
	FROM		[DeliveryBackOffice].dbo.ServiceManagement	sm		WITH (NOLOCK)
	INNER  JOIN	[DeliveryBackOffice].dbo.SchedulePickup		sp		WITH (NOLOCK) ON sm.IdSchedulePickup = sp.SchedulePickupId
	INNER  JOIN	[DeliveryBackOffice].dbo.VisitPointClient	vpc		WITH (NOLOCK) ON vpc.CodeOfReference = sp.SenderId
	INNER  JOIN	[DeliveryBackOffice].dbo.Township			tw		WITH (NOLOCK) ON tw.IdTownShip = sp.TownshipId 
	LEFT   JOIN	[DeliveryBackOffice].dbo.CatTypeVehicle		ctv		WITH (NOLOCK) ON ctv.IdTypeVehicle = sp.TypeVehicleId
	LEFT   JOIN	[DeliveryBackOffice].dbo.RolByUserByAccount rbuba	WITH (NOLOCK) ON rbuba.RuaIdAccount = sp.AccountId
	LEFT   JOIN	[DeliveryBackOffice].dbo.RegisterUser		ru		WITH (NOLOCK) ON ru.UsrIdUser = rbuba.RuaIdUser
	LEFT   JOIN	[DeliveryBackOffice].dbo.Province			pv		WITH (NOLOCK) ON pv.IdProvince = tw.IdProvince
	LEFT   JOIN	[DeliveryBackOffice].dbo.RouteAssigment		ra		WITH (NOLOCK) ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
	LEFT   JOIN	[DeliveryBackOffice].dbo.CatRoute			cr		WITH (NOLOCK) ON cr.IdRoute = ra.IdRoute
	WHERE	sp.IsScheduled = 1
	AND		sm.IdPuCourrier is not null 
	AND		ra.IdVehicle is not null
	AND		CAST(ra.DateOfRoute AS DATE) = @AssignDate
    AND IIF(pv.IdCountry IS NULL, 'GT', pv.IdCountry) = @IdCountry
	ORDER BY [ORDEN DE RECOLECCION] DESC;

	END

END

ELSE BEGIN

	DECLARE @tblCollectionProvinceId 
	TABLE (ProvinceId INT)

	INSERT INTO @tblCollectionProvinceId (ProvinceId)
	SELECT SUBSTRING(Item, 1, LEN(Item)) ItemNumber
	FROM DeliveryBackOffice.dbo.SplitUnlimited(@CollectionProvince, ',')

	IF @TypePickup = 1 BEGIN

	SELECT	IIF(sp.IsScheduled = 0, CONCAT('RDG', sm.IdServiceManagement), CONCAT('RPG', sm.IdServiceManagement) ) [ORDEN DE RECOLECCION], 
			'' [RUTA], 
			IIF(ctv.Name = 'Camión', 'Paquete grande', IIF(ctv.Name = 'Panel', 'Paquete mediano', IIF(ctv.Name = 'Motocicleta', 'Paquete pequeño', ''))) [DESCRIPCION DEL PAQUETE], 
			IIF(sp.QuantityRegularPackages is null, '', sp.QuantityRegularPackages) [CANTIDAD DE PIEZAS], 
			'' [CODIGO DE ITEM], sp.SenderId [CODIGO DE PUNTO DE VISITA], 
			vpc.DescriptionOfClient [NOMBRE DE REMITENTE], 
			IIF(vpc.Phone is null, '', vpc.Phone ) [TELEFONO DE REMITENTE], 
			IIF(sp.AccountId is null, IIF(vpc.Email is null, '', vpc.Email), ru.UsrEmail ) [EMAIL REMITENTE], 
			IIF(vpc.Address is null, '', vpc.Address) [DIRECCION REMITENTE], 
			IIF(vpc.Latitude is null, '', vpc.Latitude) [LATITUD], 
			IIF(vpc.Longitude is null, '', vpc.Longitude ) [LONGITUD], 
			CAST(ra.DateOfRoute AS DATETIME) + CAST(CAST(
				(Select distinct top 1 es.DateCreated
				from deliveryBackOffice.dbo.EventService es
				where es.ServiceManagementId = sm.IdServiceManagement
				AND es.ServiceStatusId = 2
				order by es.DateCreated desc)
			AS TIME) AS DATETIME) [FECHA Y HORA MINIMA DE RECOLECCION], 
			DATEADD(HOUR,2,CAST(ra.DateOfRoute AS DATETIME) + CAST(CAST(
				(Select distinct top 1 es.DateCreated
				from deliveryBackOffice.dbo.EventService es
				where es.ServiceManagementId = sm.IdServiceManagement
				AND es.ServiceStatusId = 2
				order by es.DateCreated desc)
			AS TIME) AS DATETIME)) [FECHA Y HORA MAXIMA DE RECOLECCION], 
			'' [CT DESTINO], 
			'Solo Recogida' [MODO]
	FROM		[DeliveryBackOffice].dbo.ServiceManagement	sm		WITH (NOLOCK)
	INNER  JOIN	[DeliveryBackOffice].dbo.SchedulePickup		sp		WITH (NOLOCK) ON sm.IdSchedulePickup = sp.SchedulePickupId
	INNER  JOIN	[DeliveryBackOffice].dbo.VisitPointClient	vpc		WITH (NOLOCK) ON vpc.CodeOfReference = sp.SenderId
	INNER  JOIN	[DeliveryBackOffice].dbo.Township			tw		WITH (NOLOCK) ON tw.IdTownShip = sp.TownshipId 
	LEFT   JOIN	[DeliveryBackOffice].dbo.CatTypeVehicle		ctv		WITH (NOLOCK) ON ctv.IdTypeVehicle = sp.TypeVehicleId
	LEFT   JOIN	[DeliveryBackOffice].dbo.RolByUserByAccount rbuba	WITH (NOLOCK) ON rbuba.RuaIdAccount = sp.AccountId
	LEFT   JOIN	[DeliveryBackOffice].dbo.RegisterUser		ru		WITH (NOLOCK) ON ru.UsrIdUser = rbuba.RuaIdUser
	LEFT   JOIN	[DeliveryBackOffice].dbo.Province			pv		WITH (NOLOCK) ON pv.IdProvince = tw.IdProvince
	INNER  JOIN	[DeliveryBackOffice].dbo.RouteAssigment		ra		WITH (NOLOCK) ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
	WHERE	pv.IdProvince IN (SELECT ProvinceId FROM @tblCollectionProvinceId)
	AND		sp.IsScheduled = 0
	AND		sm.IdPuCourrier is not null 
	AND		ra.IdVehicle is not null
	AND		CAST(ra.DateOfRoute AS DATE) = @AssignDate
	AND		CAST(
				(Select distinct top 1 es.DateCreated
				from deliveryBackOffice.dbo.EventService es
				where es.ServiceManagementId = sm.IdServiceManagement
				AND es.ServiceStatusId = 2
				order by es.DateCreated desc)
			AS TIME) BETWEEN @StartDate AND @EndDate
    AND IIF(pv.IdCountry IS NULL, 'GT', pv.IdCountry) = @IdCountry
	ORDER BY [ORDEN DE RECOLECCION] DESC;

	END

	ELSE BEGIN

	SELECT	IIF(sp.IsScheduled = 0, CONCAT('RDG', sm.IdServiceManagement), CONCAT('RPG', sm.IdServiceManagement) ) [ORDEN DE RECOLECCION], 
			IIF(cr.CodeRoute is null, '',cr.CodeRoute) [RUTA],		
			'Caja' [DESCRIPCION DEL PAQUETE], 
			'' [CANTIDAD DE PIEZAS], 
			'' [CODIGO DE ITEM], 
			sp.SenderId [CODIGO DE PUNTO DE VISITA], 
			vpc.DescriptionOfClient [NOMBRE DE REMITENTE], 
			IIF(vpc.Phone is null, '', vpc.Phone ) [TELEFONO DE REMITENTE], 
			IIF(sp.AccountId is null, IIF(vpc.Email is null, '', vpc.Email), ru.UsrEmail ) [EMAIL REMITENTE], 
			IIF(vpc.Address is null, '', vpc.Address) [DIRECCION REMITENTE], 
			IIF(vpc.Latitude is null, '', vpc.Latitude) [LATITUD], 
			IIF(vpc.Longitude is null, '', vpc.Longitude ) [LONGITUD], 
			CAST(ra.DateOfRoute AS DATETIME) + CAST(CAST(sp.StartDate AS TIME) AS DATETIME) [FECHA Y HORA MINIMA DE RECOLECCION], 
			CAST(ra.DateOfRoute AS DATETIME) + CAST(CAST(sp.EndDate AS TIME) AS DATETIME) [FECHA Y HORA MAXIMA DE RECOLECCION], 
			'' [CT DESTINO], 
			'Solo Recogida' [MODO]
	FROM		[DeliveryBackOffice].dbo.ServiceManagement	sm		WITH (NOLOCK)
	INNER  JOIN	[DeliveryBackOffice].dbo.SchedulePickup		sp		WITH (NOLOCK) ON sm.IdSchedulePickup = sp.SchedulePickupId
	INNER  JOIN	[DeliveryBackOffice].dbo.VisitPointClient	vpc		WITH (NOLOCK) ON vpc.CodeOfReference = sp.SenderId
	INNER  JOIN	[DeliveryBackOffice].dbo.Township			tw		WITH (NOLOCK) ON tw.IdTownShip = sp.TownshipId 
	LEFT   JOIN	[DeliveryBackOffice].dbo.CatTypeVehicle		ctv		WITH (NOLOCK) ON ctv.IdTypeVehicle = sp.TypeVehicleId
	LEFT   JOIN	[DeliveryBackOffice].dbo.RolByUserByAccount rbuba	WITH (NOLOCK) ON rbuba.RuaIdAccount = sp.AccountId
	LEFT   JOIN	[DeliveryBackOffice].dbo.RegisterUser		ru		WITH (NOLOCK) ON ru.UsrIdUser = rbuba.RuaIdUser
	LEFT   JOIN	[DeliveryBackOffice].dbo.Province			pv		WITH (NOLOCK) ON pv.IdProvince = tw.IdProvince
	LEFT   JOIN	[DeliveryBackOffice].dbo.RouteAssigment		ra		WITH (NOLOCK) ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
	LEFT   JOIN	[DeliveryBackOffice].dbo.CatRoute			cr		WITH (NOLOCK) ON cr.IdRoute = ra.IdRoute
	WHERE	pv.IdProvince IN (SELECT ProvinceId FROM @tblCollectionProvinceId)
	AND		sp.IsScheduled = 1
	AND		sm.IdPuCourrier is not null 
	AND		ra.IdVehicle is not null
	AND		CAST(ra.DateOfRoute AS DATE) = @AssignDate
    AND IIF(pv.IdCountry IS NULL, 'GT', pv.IdCountry) = @IdCountry
	ORDER BY [ORDEN DE RECOLECCION] DESC;

	END
END
END;