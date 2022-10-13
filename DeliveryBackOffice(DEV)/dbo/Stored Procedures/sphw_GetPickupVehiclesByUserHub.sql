-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-09-22>
-- Description:	<Obtiene datos de vehículos asignados a hub de usuario>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetPickupVehiclesByUserHub]
	-- Add the parameters for the stored procedure here
	@IdUser BIGINT,
	@CourierLocations TblCourierLocation READONLY,
	@UbicaCourierLocations TblCourierLocation READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ResponseTable AS TABLE(
		CourierId INT,
		CourierName NVARCHAR(200),
		CourierLatitude NVARCHAR(20),
		CourierLongitude NVARCHAR(20),
		CourierPhone NVARCHAR(50),

		VehicleTypeId INT,
		VehicleTypeName NVARCHAR(50),
		VehicleId INT,
		VehicleUnitNumber NVARCHAR(50),
		VehiclePlate NVARCHAR(50),

		TotalServices INT,
		TotalPiecesSuccessful INT,
		TotalGuidesSuccessful INT,
		TotalServicesSuccessful INT,
		TotalServicesIncidence INT,

		RouteId INT,
		RouteCode NVARCHAR(50),
		RouteDate DATE,
		RouteAssigmentId INT
	);

    -- Insert statements for procedure here
	
	INSERT INTO @ResponseTable
	SELECT
		ra.IdCurrierMan CourierId
	   ,CONCAT(sr.First_Name, ' ', SR.Last_Name) CourierName 
	   ,ucl.CourierLatitude CourierLatitude
	   ,ucl.CourierLongitude CourierLongitude
	   ,sr.Phone CourierPhone

	   ,ctv.IdTypeVehicle VehicleTypeId
	   ,ctv.Name VehicleTypeName
	   ,cv.IdVehicle VehicleId
	   ,cv.UnitNumber VehicleUnitNumber
	   ,cv.Plate VehiclePlate

	   ,(SELECT
				COUNT(1)
			FROM ServiceManagement sm WITH (NOLOCK)
			WHERE sm.IdPuRouteAssigment = ra.IdRouteAssigment
			AND sm.RowStatus = 1)
		TotalServices
	   ,(SELECT
				COUNT(1)
			FROM ServiceManagement sm WITH (NOLOCK)
			INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
				ON dopd.IdHeaderRecolection = sm.IdSchedulePickup
			INNER JOIN DeliveryOrderPiece dop WITH (NOLOCK)
				ON dop.GuideSerie = dopd.GuideSerie
				AND dop.GuideNumber = dopd.GuideNumber
			INNER JOIN CatServiceStatus css WITH (NOLOCK)
				ON css.IdServiceStatus = sm.ServiceStatusId
			WHERE sm.IdPuRouteAssigment = ra.IdRouteAssigment
			AND css.Name = 'Recolectado'
			AND sm.RowStatus = 1)
		TotalPiecesSuccessful
	   ,(SELECT
				COUNT(1)
			FROM ServiceManagement sm WITH (NOLOCK)
			INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
				ON dopd.IdHeaderRecolection = sm.IdSchedulePickup
			INNER JOIN CatServiceStatus css WITH (NOLOCK)
				ON css.IdServiceStatus = sm.ServiceStatusId
			WHERE sm.IdPuRouteAssigment = ra.IdRouteAssigment
			AND css.Name = 'Recolectado'
			AND sm.RowStatus = 1)
		TotalGuidesSuccessful
	   ,(SELECT
				COUNT(1)
			FROM ServiceManagement sm WITH (NOLOCK)
			INNER JOIN CatServiceStatus css WITH (NOLOCK)
				ON css.IdServiceStatus = sm.ServiceStatusId
			WHERE sm.IdPuRouteAssigment = ra.IdRouteAssigment
			AND css.Name = 'Recolectado'
			AND sm.RowStatus = 1)
		TotalServicesSuccessful
	   ,(SELECT
				COUNT(1)
			FROM ServiceManagement sm WITH (NOLOCK)
			INNER JOIN CatServiceStatus css WITH (NOLOCK)
				ON css.IdServiceStatus = sm.ServiceStatusId
			WHERE sm.IdPuRouteAssigment = ra.IdRouteAssigment
			AND css.Name = 'Incidencia'
			AND sm.RowStatus = 1)
		TotalServicesIncidence

	   ,ra.IdRoute RouteId
	   ,cr.CodeRoute RouteCode
	   ,ra.DateOfRoute RouteDate
	   ,ra.IdRouteAssigment RouteAssigmentId

	FROM @UbicaCourierLocations ucl
	INNER JOIN CatVehicle cv WITH (NOLOCK)
		ON ucl.VehicleTypeDescription = cv.Plate
	INNER JOIN RouteAssigment ra WITH (NOLOCK)
		ON ra.IdVehicle = cv.IdVehicle
	INNER JOIN SenderReceiver sr WITH (NOLOCK)
		ON ra.IdCurrierMan = sr.ID
	LEFT JOIN CatTypeVehicle ctv WITH (NOLOCK)
		ON ctv.IdTypeVehicle = cv.IdTypeVehicle
	INNER JOIN CatRoute cr WITH (NOLOCK)
		ON ra.IdRoute = cr.IdRoute
	WHERE ra.DateOfRoute = CAST(GETDATE() AS DATE)
	AND (
	 (CV.HubLogisticId) IN
		(SELECT
			hl.IdHubLogistic
		FROM HubLogisticByUser hlbu WITH (NOLOCK)
		INNER JOIN HubLogistics hl
			ON hl.IdHubLogistic = hlbu.HubLogisticId
		WHERE UserId = @IdUser)
	)
	AND sr.Estatus = 1
	AND ra.RowStatus = 1
	AND cr.IdTypeRoute = 1
	AND cr.RowStatus = 1
	
	INSERT INTO @ResponseTable
	SELECT
		ra.IdCurrierMan CourierId
	   ,CONCAT(sr.First_Name, ' ', SR.Last_Name) CourierName
	   ,cl.CourierLatitude CourierLatitude
	   ,cl.CourierLongitude CourierLongitude
	   ,cl.CourierPhone CourierPhone
	   ,ctv.IdTypeVehicle VehicleTypeId
	   ,ctv.Name VehicleTypeName
	   ,cv.IdVehicle VehicleId
	   ,cv.UnitNumber VehicleUnitNumber
	   ,cv.Plate VehiclePlate
	   ,(SELECT
				COUNT(1)
			FROM ServiceManagement sm WITH (NOLOCK)
			WHERE sm.IdPuRouteAssigment = ra.IdRouteAssigment
			AND sm.RowStatus = 1)
		TotalServices
	   ,(SELECT
				COUNT(1)
			FROM ServiceManagement sm WITH (NOLOCK)
			INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
				ON dopd.IdHeaderRecolection = sm.IdSchedulePickup
			INNER JOIN DeliveryOrderPiece dop WITH (NOLOCK)
				ON dop.GuideSerie = dopd.GuideSerie
				AND dop.GuideNumber = dopd.GuideNumber
			INNER JOIN CatServiceStatus css WITH (NOLOCK)
				ON css.IdServiceStatus = sm.ServiceStatusId
			WHERE sm.IdPuRouteAssigment = ra.IdRouteAssigment
			AND css.Name = 'Recolectado'
			AND sm.RowStatus = 1)
		TotalPiecesSuccessful
	   ,(SELECT
				COUNT(1)
			FROM ServiceManagement sm WITH (NOLOCK)
			INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
				ON dopd.IdHeaderRecolection = sm.IdSchedulePickup
			INNER JOIN CatServiceStatus css WITH (NOLOCK)
				ON css.IdServiceStatus = sm.ServiceStatusId
			WHERE sm.IdPuRouteAssigment = ra.IdRouteAssigment
			AND css.Name = 'Recolectado'
			AND sm.RowStatus = 1)
		TotalGuidesSuccessful
	   ,(SELECT
				COUNT(1)
			FROM ServiceManagement sm WITH (NOLOCK)
			INNER JOIN CatServiceStatus css WITH (NOLOCK)
				ON css.IdServiceStatus = sm.ServiceStatusId
			WHERE sm.IdPuRouteAssigment = ra.IdRouteAssigment
			AND css.Name = 'Recolectado'
			AND sm.RowStatus = 1)
		TotalServicesSuccessful
	   ,(SELECT
				COUNT(1)
			FROM ServiceManagement sm WITH (NOLOCK)
			INNER JOIN CatServiceStatus css WITH (NOLOCK)
				ON css.IdServiceStatus = sm.ServiceStatusId
			WHERE sm.IdPuRouteAssigment = ra.IdRouteAssigment
			AND css.Name = 'Incidencia'
			AND sm.RowStatus = 1)
		TotalServicesIncidence
	   ,ra.IdRoute RouteId
	   ,cr.CodeRoute RouteCode
	   ,ra.DateOfRoute RouteDate
	   ,ra.IdRouteAssigment RouteAssigmentId
	FROM @CourierLocations cl
	INNER JOIN SenderReceiver sr WITH (NOLOCK)
		ON sr.Phone LIKE CONCAT('%', cl.CourierPhone, '%')
	LEFT JOIN CatForzaDriverVehicleType cfdvt WITH (NOLOCK)
		ON cfdvt.ForzaDriverVehicleTypeId = cl.VehicleType
	LEFT JOIN CatTypeVehicle ctv WITH (NOLOCK)
		ON ctv.IdTypeVehicle = cfdvt.CatTypeVehicleId
	INNER JOIN RouteAssigment ra WITH (NOLOCK)
		ON ra.IdCurrierMan = sr.ID
	INNER JOIN CatVehicle cv WITH (NOLOCK)
		ON cv.IdVehicle = ra.IdVehicle
	INNER JOIN CatRoute cr WITH (NOLOCK)
		ON ra.IdRoute = cr.IdRoute
	LEFT JOIN @ResponseTable RT
		ON RT.CourierId = SR.ID
	WHERE ra.DateOfRoute = CAST(GETDATE() AS DATE)
	AND (
	 (CV.HubLogisticId) IN
		(SELECT
			hl.IdHubLogistic
		FROM HubLogisticByUser hlbu WITH (NOLOCK)
		INNER JOIN HubLogistics hl
			ON hl.IdHubLogistic = hlbu.HubLogisticId
		WHERE UserId = @IdUser)
	)
	AND sr.Estatus = 1
	AND ra.RowStatus = 1
	AND cr.IdTypeRoute = 1
	AND cr.RowStatus = 1
	AND RT.CourierId IS NULL

	SELECT
		 RT.CourierId
		,RT.CourierName
		,RT.CourierLatitude
		,RT.CourierLongitude
		,RT.CourierPhone
		,RT.VehicleTypeId
		,RT.VehicleTypeName
		,RT.vehicleid
		,RT.VehicleUnitNumber
		,RT.VehiclePlate
		,RT.TotalServices
		,RT.TotalPiecesSuccessful
		,RT.TotalGuidesSuccessful
		,RT.TotalServicesSuccessful
		,RT.TotalServicesIncidence
		,RT.RouteId
		,RT.RouteCode
		,RT.RouteDate
		,RT.RouteAssigmentId
	FROM
		@ResponseTable RT

END