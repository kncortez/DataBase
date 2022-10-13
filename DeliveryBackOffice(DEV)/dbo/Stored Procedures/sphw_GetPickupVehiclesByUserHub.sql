-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-09-22>
-- Description:	<Obtiene datos de vehículos asignados a hub de usuario>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetPickupVehiclesByUserHub]
	-- Add the parameters for the stored procedure here
	@IdUser BIGINT,
	@CourierLocations TblCourierLocation READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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
	INNER JOIN Township tw WITH (NOLOCK)
		ON tw.IdTownship = cr.IdTownship
	WHERE ra.DateOfRoute = CAST(GETDATE() AS DATE)
	AND (
	 (SELECT TOP 1
			dsc.Hub
		FROM DumpServiceCoverage dsc WITH (NOLOCK)
		WHERE dsc.HeaderCode = tw.HeaderCode) IN
		(SELECT
			hl.HubAbbreviation
		FROM HubLogisticByUser hlbu WITH (NOLOCK)
		INNER JOIN HubLogistics hl
			ON hl.IdHubLogistic = hlbu.HubLogisticId
		WHERE UserId = @IdUser)
	)
	AND sr.Estatus = 1
	AND ra.RowStatus = 1
	AND cr.IdTypeRoute = 1
	AND cr.RowStatus = 1
	AND tw.TownshipStatus = 1
END