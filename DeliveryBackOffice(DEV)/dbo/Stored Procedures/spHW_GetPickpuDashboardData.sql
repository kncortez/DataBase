-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <04/08/2022>
-- Description:	<SP para obtener datos y pintarlos en grid de modulo de impresion y visor de manifiestos de Linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetPickpuDashboardData]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@UserId BIGINT,
	@CourierId INT = NULL,
	@CourierLocations TblCourierLocation READONLY,
	@UbicaCourierLocations TblCourierLocation READONLY
AS
BEGIN

	-- Manejo de fechas
	IF(@EndDate IS NULL)
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))

	END
	ELSE 
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(@EndDate AS DATE) AS DATETIME)))

	END

	IF(@StartDate IS NULL)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,-7,@EndDate) AS DATE) AS DATETIME)

	END
	ELSE
	BEGIN

		SET @StartDate = CAST(CAST(@StartDate AS DATE) AS DATETIME)

	END

	IF(DATEDIFF(DAY,@StartDate, @EndDate) > 30)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,-30,@EndDate) AS DATE) AS DATETIME)

	END

	-- Variables de apoyo
	DECLARE @PickupRouteTypeId INT = (SELECT TOP 1 CTR.IdTypeRoute FROM [DeliveryBackOffice].[dbo].[CatTypeRoute] CTR WITH(NOLOCK) WHERE CTR.[Name] = 'Recolección' COLLATE Latin1_General_CI_AI);
	DECLARE @PickupServiceSubTypeId INT = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH(NOLOCK) WHERE STSM.[Name] = 'Recolección' COLLATE Latin1_General_CI_AI)

	DECLARE @PickedupServiceStatusId INT = (SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK) WHERE CSS.[Name] = 'Recolectado' COLLATE Latin1_General_CI_AI)
	DECLARE @IncidenceServiceStatusId INT = (SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK) WHERE CSS.[Name] = 'Incidencia' COLLATE Latin1_General_CI_AI)
	DECLARE @CanceledServiceStatusId INT = (SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK) WHERE CSS.[Name] = 'Cancelado' COLLATE Latin1_General_CI_AI)

	-- Variables de retorno de datos
	DECLARE @CourierData TABLE(
		CourierId INT,
		CourierName NVARCHAR(200),
		CourierFirstName NVARCHAR(100),
		CourierLastName NVARCHAR(100),
		CourierLatitude NVARCHAR(20),
		CourierLongitude NVARCHAR(20),
		TotalServices INT,
		TotalScheduled INT,
		TotalOnDemand INT,
		TotalSuccessfulScheduled INT,
		TotalSuccessfulOnDemand INT,
		TotalFailedScheduled INT,
		TotalFailedOnDemand INT,
		TotalPendingScheduled INT,
		TotalPendingOnDemand INT,
		TotalPickedPieces INT
	);
	
	BEGIN TRY

		INSERT INTO @CourierData
			(
				CourierId,
				CourierFirstName,
				CourierLastName,
				TotalServices,
				TotalScheduled,
				TotalOnDemand,
				TotalSuccessfulScheduled,
				TotalSuccessfulOnDemand,
				TotalFailedScheduled,
				TotalFailedOnDemand,
				TotalPendingScheduled,
				TotalPendingOnDemand,
				TotalPickedPieces
			)
		SELECT
			SR.ID 'CourierId'
			,SR.First_Name 'CourierFirstName'
			,SR.Last_Name 'CourierLastName'
			,COUNT(SM.IdServiceManagement) 'TotalServices'
			,SUM(CASE WHEN SM.IdServiceManagement IS NOT NULL AND ISNULL(SP.IsScheduled,1) = 1 THEN 1 ELSE 0 END) 'TotalScheduled'
			,SUM(CASE WHEN SM.IdServiceManagement IS NOT NULL AND ISNULL(SP.IsScheduled,1) = 0 THEN 1 ELSE 0 END) 'TotalOnDemand'
			,SUM(CASE WHEN SM.IdServiceManagement IS NOT NULL AND SM.ServiceStatusId = @PickedupServiceStatusId AND ISNULL(SP.IsScheduled,1) = 1 THEN 1 ELSE 0 END) 'TotalSuccessfulScheduled'
			,SUM(CASE WHEN SM.IdServiceManagement IS NOT NULL AND SM.ServiceStatusId = @PickedupServiceStatusId AND ISNULL(SP.IsScheduled,1) = 0 THEN 1 ELSE 0 END) 'TotalSuccessfulOnDemand'
			,SUM(CASE WHEN SM.IdServiceManagement IS NOT NULL AND SM.ServiceStatusId IN (@IncidenceServiceStatusId, @CanceledServiceStatusId) AND ISNULL(SP.IsScheduled,1) = 1 THEN 1 ELSE 0 END) 'TotalFailedScheduled'
			,SUM(CASE WHEN SM.IdServiceManagement IS NOT NULL AND SM.ServiceStatusId IN (@IncidenceServiceStatusId, @CanceledServiceStatusId) AND ISNULL(SP.IsScheduled,1) = 0 THEN 1 ELSE 0 END) 'TotalFailedOnDemand'
			,SUM(CASE WHEN SM.IdServiceManagement IS NOT NULL AND SM.ServiceStatusId NOT IN (@PickedupServiceStatusId, @IncidenceServiceStatusId, @CanceledServiceStatusId) AND ISNULL(SP.IsScheduled,1) = 1 THEN 1 ELSE 0 END) 'TotalPendingScheduled'
			,SUM(CASE WHEN SM.IdServiceManagement IS NOT NULL AND SM.ServiceStatusId NOT IN (@PickedupServiceStatusId, @IncidenceServiceStatusId, @CanceledServiceStatusId) AND ISNULL(SP.IsScheduled,1) = 0 THEN 1 ELSE 0 END) 'TotalPendingOnDemand'
			,SUM(CASE WHEN SM.IdServiceManagement IS NOT NULL AND SM.ServiceStatusId = @PickedupServiceStatusId AND ISNULL(SP.IsScheduled,1) = 1 THEN DOP.TotalGuidePieces ELSE 0 END) 'TotalPickedPieces'
		FROM
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[HubLogisticByUser] HLBU WITH(NOLOCK)
				ON
					SR.HubLogisticId = HLBU.HubLogisticId
					AND
					HLBU.UserId = @UserId
			INNER JOIN
				[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
				ON
					SR.ID = RA.IdCurrierMan
					AND
					RA.DateOfRoute BETWEEN @StartDate AND @EndDate
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatRoute] CR WITH(NOLOCK)
				ON
					RA.IdRoute = CR.IdRoute
					AND
					CR.IdTypeRoute = @PickupRouteTypeId
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
				ON
					RA.IdRouteAssigment = SM.IdPuRouteAssigment
					AND
					ISNULL(SM.SubTypeServiceManagmentId, @PickupServiceSubTypeId) = @PickupServiceSubTypeId
					AND
					SM.RowStatus = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH(NOLOCK)
				ON
					SM.IdSchedulePickup = SP.SchedulePickupId
					AND
					SP.RowStatus = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH(NOLOCK)
				ON
					DOPD.IdHeaderRecolection = SP.SchedulePickupId
			OUTER APPLY
				(
					SELECT
						COUNT(DISTINCT CHECKSUM(DOP.GuideSerie, DOP.GuideNumber, DOP.NoPiece)) 'TotalGuidePieces'
					FROM
						[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
					WHERE
						DOPD.GuideSerie = DOP.GuideSerie
						AND
						DOPD.GuideNumber = DOP.GuideNumber
					GROUP BY
						DOP.GuideSerie
						,DOP.GuideNumber
				) DOP
		WHERE
			@CourierId IS NULL OR SR.ID = @CourierId
		GROUP BY
			SR.ID
			,SR.First_Name
			,SR.Last_Name

		IF (EXISTS(SELECT TOP 1 1 FROM @CourierData))
		BEGIN

			UPDATE
				@CourierData
			SET
				CourierName = LTRIM(RTRIM(CONCAT(CourierFirstName,' ', CourierLastName)))

			-- Actualización con ubicaciones
			UPDATE
				CD
			SET
				CourierLatitude = ISNULL(UCL.CourierLatitude, '')
				,CourierLongitude = ISNULL(UCL.CourierLongitude, '')
			FROM
				@CourierData CD
				INNER JOIN
					[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
					ON
						CD.CourierId = SR.ID
				INNER JOIN
					[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
					ON
						CD.CourierId = RA.IdCurrierMan
						AND
						RA.DateOfRoute = CAST(GETDATE() AS DATE)
						AND
						RA.RowStatus = 1
				INNER JOIN
					[DeliveryBackOffice].[dbo].[CatRoute] CR WITH(NOLOCK)
					ON
						RA.IdRoute = CR.IdRoute
						AND
						CR.IdTypeRoute = @PickupRouteTypeId
				-- Ubicación por ubica
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[CatVehicle] CV WITH(NOLOCK)
					ON
						RA.IdVehicle = CV.IdVehicle
				LEFT JOIN
					@UbicaCourierLocations UCL
					ON
						REPLACE(UCL.VehicleTypeDescription,' ','') = REPLACE(CV.Plate,' ','')
			WHERE
				ISNULL(CD.CourierLatitude,'') = ''
				AND
				ISNULL(CD.CourierLongitude,'') = ''
				
			-- Actualización con ubicaciones
			UPDATE
				CD
			SET
				CourierLatitude = ISNULL(CL.CourierLatitude, '')
				,CourierLongitude = ISNULL(CL.CourierLongitude, '')
			FROM
				@CourierData CD
				INNER JOIN
					[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
					ON
						CD.CourierId = SR.ID
				INNER JOIN
					[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
					ON
						CD.CourierId = RA.IdCurrierMan
						AND
						RA.DateOfRoute = CAST(GETDATE() AS DATE)
						AND
						RA.RowStatus = 1
				INNER JOIN
					[DeliveryBackOffice].[dbo].[CatRoute] CR WITH(NOLOCK)
					ON
						RA.IdRoute = CR.IdRoute
						AND
						CR.IdTypeRoute = @PickupRouteTypeId
				-- Ubicación por forza driver
				LEFT JOIN
					@CourierLocations CL
					ON 
						sr.Phone LIKE CONCAT('%', cl.CourierPhone, '%')
			WHERE
				ISNULL(CD.CourierLatitude,'') = ''
				AND
				ISNULL(CD.CourierLongitude,'') = ''

			SELECT
				200 'ResultCode',
				'Datos obtenidos correctamente' 'ResultMessage'

			SELECT
				CD.CourierId,
				CD.CourierName,
				CD.CourierFirstName,
				CD.CourierLastName,
				CD.TotalServices,
				CD.TotalScheduled,
				CD.TotalOnDemand,
				CD.TotalSuccessfulScheduled,
				CD.TotalSuccessfulOnDemand,
				CD.TotalFailedScheduled,
				CD.TotalFailedOnDemand,
				CD.TotalPendingScheduled,
				CD.TotalPendingOnDemand,
				CD.TotalPickedPieces
			FROM
				@CourierData CD

		END
		ELSE
		BEGIN

			SELECT
				204 'ResultCode',
				'Sin datos bajo los parametros indicados.' 'ResultMessage'
				
			SELECT
				CD.CourierId,
				CD.CourierName,
				CD.CourierFirstName,
				CD.CourierLastName,
				CD.TotalServices,
				CD.TotalScheduled,
				CD.TotalOnDemand,
				CD.TotalSuccessfulScheduled,
				CD.TotalSuccessfulOnDemand,
				CD.TotalFailedScheduled,
				CD.TotalFailedOnDemand,
				CD.TotalPendingScheduled,
				CD.TotalPendingOnDemand,
				CD.TotalPickedPieces
			FROM
				@CourierData CD

		END

	END TRY
	BEGIN CATCH

		SELECT
			500 'ResultCode',
			ERROR_MESSAGE() 'ResultMessage'

	END CATCH
END