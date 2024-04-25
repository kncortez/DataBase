-- =============================================
-- Author:		<Oscar Rodriguez>
-- Update date: <2024-03-21>
-- Description:	<Obtiene la informacion sobre recolecciones a demanda y programadas, para integración con DispatchTrack>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_programmed_demand_recolection_semana_santa]
	--@CollectionProvince AS NVARCHAR(200),
	--@TypePickup AS INT, -- 1 es a demanda, 2 programado
	--@AssignDate AS DATE,
	--@StartDate AS DATETIME,
	--@EndDate AS DATETIME
AS
BEGIN

SELECT	TOP 100IIF(sp.IsScheduled = 0, CONCAT('RDG', sm.IdServiceManagement), CONCAT('RPG', sm.IdServiceManagement) ) [ORDEN DE RECOLECCION], '' [RUTA], 
		IIF(ctv.IdTypeVehicle = 1, 'Paquete grande', IIF(ctv.IdTypeVehicle = 2, 'Paquete mediano', IIF(ctv.IdTypeVehicle = 3, 'Paquete pequeño', 'Paquete mediano'))) [DESCRIPCION DEL PAQUETE], 
		sp.QuantityRegularPackages [CANTIDAD DE PIEZAS], '' [CODIGO DE ITEM], sp.SenderId [CODIGO DE PUNTO DE VISITA], vpc.DescriptionOfClient [NOMBRE DE REMITENTE], 
		IIF(vpc.Phone is null, '', vpc.Phone ) [TELEFONO DE REMITENTE], IIF(sp.AccountId is null, IIF(vpc.Email is null, '', vpc.Email), ru.UsrEmail ) [EMAIL REMITENTE], 
		vpc.Address [DIRECCION REMITENTE], IIF(vpc.Latitude is null, '', vpc.Latitude) [LATITUD], IIF(vpc.Longitude is null, '', vpc.Longitude ) [LONGITUD], 
		sp.StartDate [FECHA Y HORA MINIMA DE RECOLECCION], DATEADD(HOUR, 2, sp.StartDate) [FECHA Y HORA MAXIMA DE RECOLECCION], '' [CT DESTINO], 'Solo Recogida' [MODO]
FROM		[DeliveryBackOffice].dbo.ServiceManagement sm		WITH (NOLOCK)
INNER JOIN	[DeliveryBackOffice].dbo.SchedulePickup sp			WITH (NOLOCK) ON sm.IdSchedulePickup = sp.SchedulePickupId 
LEFT  JOIN	[DeliveryBackOffice].dbo.CatTypeVehicle ctv			WITH (NOLOCK) ON ctv.IdTypeVehicle = sp.TypeVehicleId
LEFT  JOIN	[DeliveryBackOffice].dbo.VisitPointClient vpc		WITH (NOLOCK) ON vpc.CodeOfReference = sp.SenderId
LEFT  JOIN	[DeliveryBackOffice].dbo.RolByUserByAccount rbuba	WITH (NOLOCK) ON rbuba.RuaIdAccount = sp.AccountId
LEFT  JOIN	[DeliveryBackOffice].dbo.RegisterUser ru			WITH (NOLOCK) ON ru.UsrIdUser = rbuba.RuaIdUser
LEFT  JOIN	[DeliveryBackOffice].dbo.Township tw				WITH (NOLOCK) ON tw.IdTownShip = sp.TownshipId
LEFT  JOIN	[DeliveryBackOffice].dbo.Province pv				WITH (NOLOCK) ON pv.IdProvince = tw.IdProvince
WHERE	pv.IdProvince in (7,2,3)
AND		sp.IsScheduled = 0
AND sp.SchedulePickupId IN (601583, 601584);

END