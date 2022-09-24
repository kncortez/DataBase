
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-09-14>
-- Description:	< Obtiene los los courier candidatos cercanos al punto de origen indicado >
-- =============================================
CREATE PROCEDURE [dbo].[GetNearestCourierCandidates]
	@OriginLatitude NVARCHAR(20),
	@OriginLongitude NVARCHAR(20),
	@VehicleType INT,
	@MaxDistance FLOAT = 3000,
	@CourierLocations TblCourierLocation READONLY
AS
BEGIN

	-- Tablas temporales 
	DECLARE @CouriersWithPickupRoute AS TABLE (
		CourierId INT,
		CourierLatitude NVARCHAR(20),
		CourierLongitude NVARCHAR(20),
		CourierPhone NVARCHAR(20),
		VehicleType INT,
		RouteId INT,
		RouteDate DATE,
		RouteAssignmentId INT,
		CourierDistance FLOAT
	);

	-- De los couriers activos encontrados, tomar aquellos que tienen una ruta de recolección para el día actual
	INSERT INTO @CouriersWithPickupRoute
		(CourierId, CourierLatitude, CourierLongitude, CourierPhone, VehicleType, RouteId, RouteDate, RouteAssignmentId)
	SELECT
		RA.IdCurrierMan
		,CL.CourierLatitude
		,CL.CourierLongitude
		,CL.CourierPhone
		,CL.VehicleType
		,RA.IdRoute
		,RA.DateOfRoute
		,RA.IdRouteAssigment
	FROM
		@CourierLocations CL
		INNER JOIN
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
			ON
				SR.Phone LIKE CONCAT('%', CL.CourierPhone, '%')
				AND 
				SR.Estatus = 1
		INNER JOIN
			[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
			ON
				RA.IdCurrierMan = SR.ID
				AND
				RA.RowStatus = 1
		INNER JOIN
			[DeliveryBackOffice].[dbo].[CatRoute] CR WITH(NOLOCK)
			ON
				RA.IdRoute = CR.IdRoute
				AND
				CR.IdTypeRoute = 1
				AND
				CR.RowStatus = 1
	WHERE
		RA.DateOfRoute = CAST(GETDATE() AS DATE)
			
	-- Actualizar identificador de tipo de vehículo en registros de tabla temporal 
	UPDATE
		CL
	SET
		CL.VehicleType = CTV.IdTypeVehicle
	FROM
		@CouriersWithPickupRoute CL
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatForzaDriverVehicleType] CFDVT WITH(NOLOCK)
			ON
				CFDVT.ForzaDriverVehicleTypeId = CL.VehicleType
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatTypeVehicle] CTV WITH(NOLOCK)
			ON
				CTV.IdTypeVehicle = CFDVT.CatTypeVehicleId

	-- Obtener distancia entre punto indicado y courier
	UPDATE
		@CouriersWithPickupRoute
	SET
		CourierDistance = IIF(CL.CourierPhone IS NULL, NULL, GEOGRAPHY::STPointFromText (CONCAT('POINT (', @OriginLongitude, ' ', @OriginLatitude, ')'), 4326).STDistance(GEOGRAPHY::STPointFromText (CONCAT('POINT (', CL.CourierLongitude, ' ', CL.CourierLatitude, ')'), 4326)) )
	FROM
		@CouriersWithPickupRoute CL

	SELECT
		CL.CourierId,
		CL.CourierLatitude,
		CL.CourierLongitude,
		CL.VehicleType,
		CL.RouteId,
		CONVERT(NVARCHAR, CL.RouteDate, 23) 'RouteDate',
		CL.RouteAssignmentId,
		ROUND(CL.CourierDistance, 2) 'CourierDistance'
	FROM
		@CouriersWithPickupRoute CL
	WHERE
		CL.VehicleType = @VehicleType
		AND
		CL.CourierDistance <= @MaxDistance
	ORDER BY
		CL.CourierDistance ASC

END