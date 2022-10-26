
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
	@CourierLocations TblCourierLocation READONLY,
	@UbicaCourierLocations TblCourierLocation READONLY
AS
BEGIN
	/*
		Para la tabla @UbicaCourierLocations
		Se reutiliza la existente para ubicaciones de courier
		y se mapean los campos de la siguietne forma:
			CourierPhone = Codigo de unidad del vehículo
			VehicleTypeDescription = Placas del vehículo
		Esto servira para poder realacionarlo con los datos almacenados
	*/

	-- Tabla de respuesta
	DECLARE @FinalCourierCandidates AS TABLE(
		CourierId INT,
		CourierLatitude NVARCHAR(20),
		CourierLongitude NVARCHAR(20),
		VehicleType INT,
		RouteId INT,
		RouteDate DATE,
		RouteAssignmentId INT,
		CourierDistance FLOAT
	);

	-- Tablas temporales 
	DECLARE @CouriersWithPickupVehicleAssignment AS TABLE(
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

	-- De las ubicaciones de Ubica, obtener datos de vehiculo y asignaciones de courier
	INSERT INTO @CouriersWithPickupVehicleAssignment
		(CourierId, CourierLatitude, CourierLongitude, CourierPhone, VehicleType, RouteId, RouteDate, RouteAssignmentId)
	SELECT
		RA.IdCurrierMan, UCL.CourierLatitude, UCL.CourierLongitude, SR.Phone, CV.IdTypeVehicle, RA.IdRoute, RA.DateOfRoute, RA.IdRouteAssigment
	FROM
		@UbicaCourierLocations UCL
		INNER JOIN
			[DeliveryBackOffice].[dbo].[CatVehicle] CV WITH(NOLOCK)
			ON
				UCL.VehicleTypeDescription = CV.Plate
		INNER JOIN
			[DeliveryBackOffice].[dbo].[CatTypeVehicle] CTV WITH(NOLOCK)
			ON
				CV.IdTypeVehicle = CTV.IdTypeVehicle
		INNER JOIN
			[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
			ON
				CV.IdVehicle = RA.IdVehicle
				AND
				RA.DateOfRoute = CAST(GETDATE() AS DATE)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[CatRoute] CR WITH(NOLOCK)
			ON
				RA.IdRoute = CR.IdRoute
				AND
				CR.IdTypeRoute = 1
				AND
				CR.RowStatus = 1
		INNER JOIN
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
			ON
				RA.IdCurrierMan = SR.ID

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
		@CouriersWithPickupVehicleAssignment
	SET
		CourierDistance = IIF(CL.CourierPhone IS NULL, NULL, GEOGRAPHY::STPointFromText (CONCAT('POINT (', @OriginLongitude, ' ', @OriginLatitude, ')'), 4326).STDistance(GEOGRAPHY::STPointFromText (CONCAT('POINT (', CL.CourierLongitude, ' ', CL.CourierLatitude, ')'), 4326)) )
	FROM
		@CouriersWithPickupVehicleAssignment CL

	UPDATE
		@CouriersWithPickupRoute
	SET
		CourierDistance = IIF(CL.CourierPhone IS NULL, NULL, GEOGRAPHY::STPointFromText (CONCAT('POINT (', @OriginLongitude, ' ', @OriginLatitude, ')'), 4326).STDistance(GEOGRAPHY::STPointFromText (CONCAT('POINT (', CL.CourierLongitude, ' ', CL.CourierLatitude, ')'), 4326)) )
	FROM
		@CouriersWithPickupRoute CL

	INSERT INTO @FinalCourierCandidates
		(CourierId,CourierLatitude,CourierLongitude,VehicleType,RouteId,RouteDate,RouteAssignmentId,CourierDistance)
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
		@CouriersWithPickupVehicleAssignment CL
		INNER JOIN
			[DeliveryBackOffice].[dbo].[TypeVehicleGroup] TVG WITH(NOLOCK)
			ON
				CL.VehicleType = TVG.TypeVehicleValid
				AND
				TVG.TypeVehicleOrigin = @VehicleType
	WHERE
		CL.CourierDistance <= @MaxDistance
	
	
	INSERT INTO @FinalCourierCandidates
		(CourierId,CourierLatitude,CourierLongitude,VehicleType,RouteId,RouteDate,RouteAssignmentId,CourierDistance)
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
		LEFT JOIN
			@FinalCourierCandidates FCD
			ON
				CL.CourierId = FCD.CourierId
		INNER JOIN
			[DeliveryBackOffice].[dbo].[TypeVehicleGroup] TVG WITH(NOLOCK)
			ON
				CL.VehicleType = TVG.TypeVehicleValid
				AND
				TVG.TypeVehicleOrigin = @VehicleType
	WHERE
		CL.CourierDistance <= @MaxDistance
		AND
		FCD.CourierId IS NULL
	ORDER BY
		CL.CourierDistance ASC

	SELECT
		FCD.CourierId,
		FCD.CourierLatitude,
		FCD.CourierLongitude,
		FCD.VehicleType,
		FCD.RouteId,
		FCD.RouteDate,
		FCD.RouteAssignmentId,
		FCD.CourierDistance
	FROM
		@FinalCourierCandidates FCD

END