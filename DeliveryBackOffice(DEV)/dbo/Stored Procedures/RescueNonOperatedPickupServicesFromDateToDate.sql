
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-03-22>
-- Description:	< Revisa servicios asignados a rutas de Rabbit de una fecha y las reactiva para otra fecha indicada >
-- =============================================
CREATE PROCEDURE [dbo].[RescueNonOperatedPickupServicesFromDateToDate]
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@Token NVARCHAR(50) = NULL
AS
BEGIN

	-- Variable de control para tipo Reprogramado
	DECLARE @ReprogrammedId INT = (SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WHERE CSS.[Name] = 'Reprogramado');

	IF(@FromDate IS NULL)
		SET @FromDate = CONVERT(DATE, DATEADD(DAY,-1,CONVERT(DATE, GETDATE())))
	IF(@ToDate IS NULL)
		SET @ToDate = CONVERT(DATE, DATEADD(DAY,0,CONVERT(DATE, GETDATE())))
	IF(@Token IS NULL)
		SET @Token = 'SYS-HermesServiceRescuer'

	-- LIMPIAR TABLA TEMPORAL
	IF OBJECT_ID('tempdb.dbo.#ServicesToRestore', 'U') IS NOT NULL DROP TABLE #ServicesToRestore;

	-- OBTENER SERVICIOS LOS CUALES:
	-- Hayan sido asignados a una ruta Rabbit y posean registros en la tabla SettlementPickupStationDetail
	-- Su registro en la tabla SettlementPickupStationDetail tenga NULL en el campo que registra su liquidación
	-- El registro es del día indicado por @FromDate (Usualmente el día de ayer)
	-- Su estado lógico en la tabla SettlementPickupStationDetail este activo
	SELECT -- Los datos de la asignación de la recolección
		SPS.IdSettlementPickupStation
		,SPSD.IdSettlementPickupStationDetail
		,SPSD.ServiceManagementId
		,SM.IdSchedulePickup
		,RA.IdRouteAssigment
	INTO #ServicesToRestore
	FROM
		[DeliveryBackOffice].[dbo].[SettlementPickupStation] SPS WITH(NOLOCK) -- Si un servicio se incluye en esta tabla, es porque esta en una ruta Rabbit
		INNER JOIN
			[DeliveryBackOffice].[dbo].[SettlementPickupStationDetail] SPSD WITH(NOLOCK)
			ON
				SPS.IdSettlementPickupStation = SPSD.SettlementPickupStationId
				AND
				SPSD.RowStatus = 1 -- Registro en la tabla de detalle debe estar activo
		INNER JOIN
			[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
			ON
				SPSD.ServiceManagementId = SM.IdServiceManagement
		INNER JOIN
			[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
			ON
				RA.IdRouteAssigment = SM.IdPuRouteAssigment
	WHERE
		SM.ServiceStatusId IN (2,4) -- Que solo este asignado a ruta o tuviese una incidencia
		AND
		SPSD.SettlementDate IS NULL -- Que no haya sido liquidado de la ruta de rabbit
		AND
		SPS.TransactionDate = CONVERT(DATE, @FromDate) -- De el día indicado a rescatar
		AND
		SPS.RowStatus = 1

	-- Si existen datos para rescatar
	IF ( ((SELECT COUNT(*) FROM #ServicesToRestore) > 0) AND (@FromDate < @ToDate)) -- La fecha de donde se va a rescatar debe ser menor a la de transferencia
	BEGIN
		BEGIN TRY
	
			-- Con los datos recopilados entonces actualizamos los registros para anularlos y cambiarles la fecha y datos de la asignación del servicio
			-- ACTUALIZAR [SchedulePickup]
			-- Se actualiza el servicio de recolección para la fecha indicada y se marca como 'No asignada'
			UPDATE
				SP
			SET
				SP.StartDate = DATEADD( DAY, DATEDIFF(DAY, 0, @ToDate), '06:00:00' )
				,SP.EndDate = DATEADD( DAY, DATEDIFF(DAY, 0, @ToDate), '18:00:00' )
				,SP.AssigmentStatus = 0
				,SP.TokenUpdated = @Token
				,SP.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH(NOLOCK)
				INNER JOIN
					#ServicesToRestore PSTR
					ON
						SP.SchedulePickupId = PSTR.IdSchedulePickup

			-- ACTUALIZAR [ServiceManagement]
			-- Remover de Service Management los datos del courier y asignación de ruta, se mantiene el servicio de recolección
			UPDATE
				SM
			SET
				SM.IdPuCourrier = NULL
				,SM.IdPuRouteAssigment = NULL
				,SM.ServiceStatusId = @ReprogrammedId -- SERVICIO Reprogramado
				,SM.TokenUpdated = @Token
				,SM.DateUpdated = GETDATE() 
			FROM
				[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
				INNER JOIN
					#ServicesToRestore PSTR
					ON
						PSTR.ServiceManagementId = SM.IdServiceManagement

			INSERT INTO
				[DeliveryBackOffice].[dbo].[EventService]
				(ServiceManagementId, ServiceStatusId, RowStauts, DateCreated, TokenCreated, Observations)
			SELECT
				DISTINCT
					SM.IdServiceManagement
					,@ReprogrammedId
					,1
					,GETDATE()
					,@Token
					,NULL
			FROM
				[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
				INNER JOIN
					#ServicesToRestore PSTR
					ON
						PSTR.ServiceManagementId = SM.IdServiceManagement

			-- ACTUALIZAR [SettlementPickupStation] y [SettlementPickupStationDetail]
			-- Se anula el registro del manifiesto general
			UPDATE
				SPS
			SET
				SPS.RowStatus = 0
				,SPS.TokenUpdated = @Token
				,SPS.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[SettlementPickupStation] SPS WITH(NOLOCK)
				INNER JOIN
					#ServicesToRestore PSTR
					ON
						PSTR.IdSettlementPickupStation = SPS.IdSettlementPickupStation

			-- Se anula el registro del servicio en el detalle del manifiesto general
			UPDATE
				SPSD
			SET
				SPSD.RowStatus = 0
				,SPSD.TokenUpdated = @Token
				,SPSD.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[SettlementPickupStationDetail] SPSD WITH(NOLOCK)
				INNER JOIN
					#ServicesToRestore PSTR
					ON
						PSTR.IdSettlementPickupStationDetail = SPSD.IdSettlementPickupStationDetail

			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION

			SELECT
				1 [blnResult],
				CONCAT('Servicios rescatados exitosamente del día: ', CONVERT(NVARCHAR, @FromDate), '. Asignados para el día:', CONVERT(NVARCHAR, @ToDate)) 'Message'
		
		END TRY
		BEGIN CATCH

			SELECT 0 [blnResult],
					ERROR_NUMBER() AS [ErrorNumber],
					ERROR_SEVERITY() AS [ErrorSeverity],
					ERROR_STATE() AS [ErrorState],
					ERROR_PROCEDURE() AS [ErrorProcedure],
					ERROR_LINE() AS [ErrorLine],
					ERROR_MESSAGE() AS [ErrorMessage];

			ROLLBACK TRANSACTION
		END CATCH
	END

	IF OBJECT_ID('tempdb.dbo.#ServicesToRestore', 'U') IS NOT NULL DROP TABLE #ServicesToRestore;
END