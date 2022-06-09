
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-04-25>
-- Description:	< Obtiene los los courier candidatos para poder realizar servicios de recolección basado en la proximidad entre el courier y el servicio >
-- =============================================
CREATE PROCEDURE [dbo].[GetPickupsWithCourierCandidate]
	@DateSchedulePickups DATETIME = NULL,
	@MaxDistance FLOAT = 3000,
	@CourierLocations TblCourierLocation READONLY
AS
BEGIN
	-- Limpiar tablas temporales
	IF OBJECT_ID('tempdb.dbo.#PickupCouriers', 'U') IS NOT NULL DROP TABLE #PickupCouriers;
	IF OBJECT_ID('tempdb.dbo.#ServiceLocation', 'U') IS NOT NULL DROP TABLE #ServiceLocation;
	IF OBJECT_ID('tempdb.dbo.#ServiceByCourierDistance', 'U') IS NOT NULL DROP TABLE #ServiceByCourierDistance;
	IF OBJECT_ID('tempdb.dbo.#ServiceByCourierCandidate', 'U') IS NOT NULL DROP TABLE #ServiceByCourierCandidate;
	IF OBJECT_ID('tempdb.dbo.#ServiceWithCandidate', 'U') IS NOT NULL DROP TABLE #ServiceWithCandidate;

	-- Asignar por defecto la fecha actual
	IF(@DateSchedulePickups IS NULL)
		SET @DateSchedulePickups = CAST(GETDATE() AS DATE); -- Fecha actual desde hora inicial 00:00:00

	SELECT
		CL.*
	INTO #PickupCouriers
	FROM
		@CourierLocations CL
		JOIN
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR
			ON
				SR.Phone LIKE CONCAT('%', CL.CourierPhone, '%')
				AND 
				SR.Estatus = 1
		JOIN
			[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
			ON
				RA.IdCurrierMan = SR.ID
				AND
				RA.RowStatus = 1
		JOIN
			[DeliveryBackOffice].[dbo].[CatRoute] CR
			ON
				RA.IdRoute = CR.IdRoute
				AND
				CR.IdTypeRoute = 1
				AND
				CR.CodeRoute LIKE 'R%'
				AND
				CR.RowStatus = 1
	WHERE
		RA.DateOfRoute = CAST(GETDATE() AS DATE)
			
	UPDATE
		CL
	SET
		CL.VehicleType = CTV.IdTypeVehicle
	FROM
		#PickupCouriers CL
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatForzaDriverVehicleType] CFDVT
			ON
				CFDVT.ForzaDriverVehicleTypeId = CL.VehicleType
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatTypeVehicle] CTV
			ON
				CTV.IdTypeVehicle = CFDVT.CatTypeVehicleId

	SELECT
		SP.SchedulePickupId 'idSchedulePickUp'
		,SP.TypeVehicleId
		,VPC.Latitude
		,VPC.Longitude
	INTO #ServiceLocation
	FROM 
		DeliveryBackOffice.dbo.SchedulePickup SP WITH(NOLOCK)
		LEFT JOIN 
			[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
			ON 
				SP.SenderId = VPC.CodeOfReference 
				AND 
				VPC.StatusClient = 1
	WHERE 
	-- Condiciones para recolecciones no asignadas de la fecha indicada
	(
		(
			@DateSchedulePickups >= CONVERT(DATE, SP.startDate)
			AND 
			CONVERT(DATE, SP.EndDate) >= @DateSchedulePickups
		)
		OR 
			(@DateSchedulePickups = '')
	)
	AND 
	(
			(SP.AssigmentStatus = 0)
		OR 
			(SP.AssigmentStatus IS NULL)
	)
	AND 
	SP.RowStatus = 1
	-- Revisar condiciones para poder ser asignado de forma automatizada
	AND
	SP.TypeVehicleId IS NOT NULL
	AND
	LTRIM(RTRIM(ISNULL(VPC.Latitude,''))) <> ''
	AND
	LTRIM(RTRIM(ISNULL(VPC.Longitude,''))) <> ''
	
	SELECT
		DISTINCT
			SL.idSchedulePickUp
			,SL.Latitude
			,SL.Longitude
			,CL.CourierPhone
			,CL.CourierLatitude
			,CL.CourierLongitude
			,IIF(CL.CourierPhone IS NULL, NULL, GEOGRAPHY::STPointFromText (CONCAT('POINT (', SL.Longitude, ' ', SL.Latitude, ')'), 4326).STDistance(GEOGRAPHY::STPointFromText (CONCAT('POINT (', CL.CourierLongitude, ' ', CL.CourierLatitude, ')'), 4326)) ) 'Distance'
	INTO #ServiceByCourierDistance
	FROM
		#ServiceLocation SL
		LEFT JOIN
			#PickupCouriers CL
			ON
				CL.VehicleType = SL.TypeVehicleId

	SELECT
		ROW_NUMBER() OVER (PARTITION BY IdSchedulePickUp ORDER BY Distance ASC) 'PositionCandidate'
		,SBCD.idSchedulePickUp
		,SBCD.Latitude
		,SBCD.Longitude
		,SBCD.CourierPhone
		,SBCD.CourierLatitude
		,SBCD.CourierLongitude
		,SBCD.Distance
		,SR.ID
		,RA.IdRoute
	INTO #ServiceByCourierCandidate
	FROM
		#ServiceByCourierDistance SBCD
		JOIN
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR
			ON
				SR.Phone LIKE CONCAT('%', SBCD.CourierPhone, '%')
		JOIN
			[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
			ON
				RA.IdCurrierMan = SR.ID
	WHERE
		SBCD.CourierPhone IS NOT NULL
		AND
		SBCD.Distance <= @MaxDistance

	SELECT
		SBCC.idSchedulePickUp 'PickupId'
		,SBCC.Latitude 'PickupLatitude'
		,SBCC.Longitude 'PickupLongitude'
		,SBCC.ID 'CourierId'
		,SBCC.CourierPhone 'CourierPhone'
		,SBCC.CourierLatitude 
		,SBCC.CourierLongitude
		,SBCC.IdRoute 'RouteId'
		,SBCC.Distance
	INTO #ServiceWithCandidate
	FROM
		#ServiceByCourierCandidate SBCC
	WHERE
		SBCC.PositionCandidate = 1

	SELECT
		SWC.PickupId
		,SWC.PickupLatitude
		,SWC.PickupLongitude
		,SWC.RouteId
		,SWC.CourierId
		,SWC.CourierPhone
		,SWC.CourierLatitude
		,SWC.CourierLongitude
		,SWC.Distance
	FROM
		#ServiceWithCandidate SWC

	-- Destriur tablas temporales
	IF OBJECT_ID('tempdb.dbo.#PickupCouriers', 'U') IS NOT NULL DROP TABLE #PickupCouriers;
	IF OBJECT_ID('tempdb.dbo.#ServiceLocation', 'U') IS NOT NULL DROP TABLE #ServiceLocation;
	IF OBJECT_ID('tempdb.dbo.#ServiceByCourierDistance', 'U') IS NOT NULL DROP TABLE #ServiceByCourierDistance;
	IF OBJECT_ID('tempdb.dbo.#ServiceByCourierCandidate', 'U') IS NOT NULL DROP TABLE #ServiceByCourierCandidate;
	IF OBJECT_ID('tempdb.dbo.#ServiceWithCandidate', 'U') IS NOT NULL DROP TABLE #ServiceWithCandidate;
END
