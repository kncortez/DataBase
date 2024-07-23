
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-08-18>
-- Description:	< Método dinamico para obtener datos para Widgets del lado de portal web  >
-- =============================================
/*
	Actualización: Actualizar texto de íconos quemados en estructura de respuesta
	Autor: Jerson Ochoa - 30-12-2022
*/
CREATE PROCEDURE [dbo].[GetWidgetData]
	
	@AccoundId BIGINT,
	@StartFilterDate DATETIME = NULL,
	@EndFilterDate DATETIME = NULL,
	@WidgetName NVARCHAR(50)

AS
BEGIN
     DECLARE @Currency AS NVARCHAR(3)   
		DECLARE @IdCountry NVARCHAR(3)= (   
										   Select top 1 ISNULL(B.CountryID,'GT') 
										         From [dbo].[Account] A WITH(NOLOCK) 
										         INNER JOIN 
												      [dbo].[Customer] B WITH(NOLOCK)
										         ON  A.IdCustomer = B.IdCustomer
										   WHERE A.AccIdAccount =@AccoundId)

		SET @Currency = (SELECT TOP 1  CodeISO 
		                       FROM [dbo].[CatCurrencyCOD] 
							       WHERE CodeISO LIKE '%'+@IdCountry+'%')

	-- Limpieza y corrección de datos de fecha
	IF(@EndFilterDate IS NULL)
		SET @EndFilterDate = DATEADD(SECOND,-1,CAST(DATEADD(DAY,1,CAST(GETDATE() AS DATE)) AS DATETIME))
	ELSE
		SET @EndFilterDate = DATEADD(SECOND,-1,CAST(DATEADD(DAY,1,CAST(@EndFilterDate AS DATE)) AS DATETIME))

	IF(@StartFilterDate IS NULL)
		SET @StartFilterDate = CAST(DATEADD(DAY, -7, @EndFilterDate) AS DATE)
	ELSE
		SET @StartFilterDate = CAST(@StartFilterDate AS DATE)

	IF(DATEDIFF(DAY, @StartFilterDate, @EndFilterDate) > 30)
		SET @StartFilterDate = CAST(DATEADD(DAY, -30, @EndFilterDate) AS DATE)
	
	-- Variables de control de flujo
	DECLARE @CustomerId INT;
	SET @CustomerId = ISNULL((SELECT TOP 1 Acc.IdCustomer FROM [DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK) WHERE Acc.AccIdAccount = @AccoundId),0)
		
	-- Limpieza de tablas
	IF OBJECT_ID('tempdb.dbo.#FilteredGuides', 'U') IS NOT NULL
			DROP TABLE #FilteredGuides
	IF OBJECT_ID('tempdb.dbo.#FilteredServices', 'U') IS NOT NULL
			DROP TABLE #FilteredServices

	-- De requerir datos para nuevos filtros, adicionar a esta tabla para minimizar el consumo de DeliveryOrder
	CREATE TABLE #FilteredGuides (
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		GuideStatus INT,
		GuideDryPieces INT,
		GuideColdPieces INT,
		GuideTotalPieces INT,
		GuideCoDAmountPaid DECIMAL(18,2),
		GuideCoDAmountToPay DECIMAL(18,2),
		INDEX INDX_FilteredGuides_Guide NONCLUSTERED(GuideSerie, GuideNumber)
	);
	CREATE TABLE #FilteredServices (
		ServiceManagement INT,
		SchedulePickup BIGINT,
		ServiceStatus INT,
		ServiceDate DATETIME,
		ServiceExpectedDate DATETIME,
		ServicePickupDate DATETIME,
		INDEX INDX_FilteredServices_ServiceManagement NONCLUSTERED(ServiceManagement),
		INDEX INDX_FilteredServices_SchedulePickup NONCLUSTERED(SchedulePickup)
	);

	BEGIN TRY
		IF(@WidgetName = 'EnviosRealizados' COLLATE Latin1_General_CI_AI)
		BEGIN

			INSERT INTO #FilteredGuides
				(GuideSerie, GuideNumber, GuideStatus, GuideDryPieces, GuideColdPieces, GuideTotalPieces)
			SELECT
				DO.Guide_Serie, DO.Guide_Number, DO.StatusOrderId, ISNULL(DO.Pieces_Dry,0), ISNULL(DO.Pieces_Cold,0), (ISNULL(DO.Pieces_Dry,0) + ISNULL(DO.Pieces_Cold,0))
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			WHERE
				DO.DateCreated BETWEEN @StartFilterDate AND @EndFilterDate
				AND
				DO.IdCustomer = @CustomerId

			IF( EXISTS(SELECT TOP 1 1 FROM #FilteredGuides) )
			BEGIN

				DECLARE @ResponseTable AS TABLE(
					TotalGuidePieces INT,
					TotalGuideDelivered INT,
					TotalGuide INT
				);

				INSERT INTO @ResponseTable
					(TotalGuidePieces, TotalGuideDelivered, TotalGuide)
				SELECT
					SUM((CASE WHEN FG.GuideStatus != 7 THEN FG.GuideTotalPieces ELSE 0 END)),
					SUM((CASE WHEN FG.GuideStatus IN (5, 22, 24, 25) THEN 1 ELSE 0 END)),
					SUM((CASE WHEN FG.GuideStatus != 7 THEN 1 ELSE 0 END))
				FROM
					#FilteredGuides FG

				IF( EXISTS(SELECT TOP 1 1 FROM @ResponseTable))
				BEGIN
					SELECT
						CAST(1 AS BIT) [blnResult]

					SELECT
						ISNULL(TotalGuidePieces,0) 'TopValue',
						'Piezas' 'TopText',
						ISNULL(TotalGuide,0) 'BottomValue',
						'Envíos realizados' 'BottomText',
						'bi bi-box-seam' 'WidgetIcon'
					FROM
						@ResponseTable
				END
				ELSE
				BEGIN
					SELECT
						CAST(0 AS BIT) [blnResult]

					SELECT
						0 'TopValue',
						'Piezas' 'TopText',
						0 'BottomValue',
						'Envíos realizados' 'BottomText',
						'bi bi-box-seam' 'WidgetIcon'
				END

			END
			ELSE
			BEGIN
				SELECT
					CAST(0 AS BIT) [blnResult]

				SELECT
					0 'TopValue',
					'Piezas' 'TopText',
					0 'BottomValue',
					'Envíos realizados' 'BottomText',
					'bi bi-box-seam' 'WidgetIcon'
			END
		END
		ELSE IF(@WidgetName = 'MontosCoD' COLLATE Latin1_General_CI_AI)
		BEGIN

			INSERT INTO #FilteredGuides
				(GuideSerie, GuideNumber, GuideStatus, GuideCoDAmountPaid, GuideCoDAmountToPay)
			SELECT
				DO.Guide_Serie, DO.Guide_Number, DO.StatusOrderId, (CASE WHEN DO.StatusOrderId IN (24, 25) THEN ISNULL(DO.Collect_OnDelivery,0) ELSE 0 END), (CASE WHEN DO.StatusOrderId NOT IN (SELECT SO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) WHERE SO.CatCheckpointTypeId = 3) OR DO.StatusOrderId = 5 THEN ISNULL(DO.Collect_OnDelivery,0) ELSE 0 END)
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			WHERE
				DO.DateCreated BETWEEN @StartFilterDate AND @EndFilterDate
				AND
				DO.IdCustomer = @CustomerId

			IF( EXISTS(SELECT TOP 1 1 FROM #FilteredGuides) )
			BEGIN

				DECLARE @ResponseCoDTable AS TABLE(
					TotalPaidCoD DECIMAL(18,2),
					TotalPendingCoD DECIMAL(18,2)
				);

				INSERT INTO @ResponseCoDTable
					(TotalPaidCoD, TotalPendingCoD)
				SELECT
					SUM(FG.GuideCoDAmountPaid) 'TotalPaidCoD', -- Estados terminales Cod liquidado y Cod pagado
					SUM(FG.GuideCoDAmountToPay) 'TotalPendingCoD' -- Estados no terminales sin incluir entregado
				FROM
					#FilteredGuides FG
					
				IF( EXISTS(SELECT TOP 1 1 FROM @ResponseCoDTable))
				BEGIN
					SELECT
						CAST(1 AS BIT) [blnResult]

					SELECT
						ISNULL(TotalPaidCoD,0) 'TopValue',
						'Monto pagado COD' 'TopText',
						ISNULL(TotalPendingCoD,0) 'BottomValue',
						'Total por cobrar' 'BottomText',
						'bi bi-cash' 'WidgetIcon'
					FROM
						@ResponseCoDTable
				END
				ELSE
				BEGIN
					SELECT
						CAST(0 AS BIT) [blnResult]

					SELECT
						0 'TopValue',
						'Monto pagado COD' 'TopText',
						0 'BottomValue',
						'Total por cobrar' 'BottomText',
						'bi bi-cash' 'WidgetIcon'
				END
			END
			ELSE
			BEGIN
				SELECT
					CAST(0 AS BIT) [blnResult]

				SELECT
					0 'TopValue',
					'Monto pagado COD' 'TopText',
					0 'BottomValue',
					'Total por cobrar' 'BottomText',
					'bi bi-cashSettlement' 'WidgetIcon'
			END

		END
		ELSE IF(@WidgetName = 'VelocidadEntrega' COLLATE Latin1_General_CI_AI)
		BEGIN
		
			INSERT INTO #FilteredGuides
				(GuideSerie, GuideNumber, GuideStatus)
			SELECT
				DO.Guide_Serie, DO.Guide_Number, DO.StatusOrderId
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			WHERE
				DO.DateCreated BETWEEN @StartFilterDate AND @EndFilterDate
				AND
				DO.IdCustomer = @CustomerId
				

			IF( EXISTS(SELECT TOP 1 1 FROM #FilteredGuides) )
			BEGIN

				CREATE TABLE #DeliveryDataOfGuide (
					GuideSerie NVARCHAR(2),
					GuideNumber INT,
					DateArrivedOnForza DATE,
					DateDelivered DATE,
					INDEX INDX_DeliveryDataOfGuide_Guide NONCLUSTERED(GuideSerie, GuideNumber)
				);

				INSERT INTO #DeliveryDataOfGuide
					(GuideSerie, GuideNumber, DateArrivedOnForza, DateDelivered)
				SELECT
					FG.GuideSerie
					, FG.GuideNumber
					, (
						SELECT 
							TOP 1
								DOD.DateCreated
						FROM
							[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK)
						WHERE
							DOD.Guide_Serie = FG.GuideSerie
							AND
							DOD.Guide_Number = FG.GuideNumber
							AND
							DOD.StatusOrderId IN (2, 11, 21) -- Recolectado, arribó a las instalaciones, recibido en express center
						ORDER BY
							DOD.DateCreated ASC
					)
					, (
						SELECT 
							TOP 1
								DOD.DateCreated
						FROM
							[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK)
						WHERE
							DOD.Guide_Serie = FG.GuideSerie
							AND
							DOD.Guide_Number = FG.GuideNumber
							AND
							DOD.StatusOrderId IN (5,22) -- Entregadas, entregadas en express center
						ORDER BY
							DOD.DateCreated DESC
					)
				FROM 
					#FilteredGuides FG

				IF( EXISTS(SELECT TOP 1 1 FROM #DeliveryDataOfGuide) )
				BEGIN

					DECLARE @ResponseVelTable AS TABLE(
						VelocidadEntregaDia DECIMAL(5,2),
						PorcentajentregaTotal DECIMAL(5,2)
					);

					INSERT INTO @ResponseVelTable
						(VelocidadEntregaDia, PorcentajentregaTotal)
					SELECT
						-- Promedio de días desde arribo hasta entrega por guía                                         Días dentro del filtro de fechas indicado
						(CAST(AVG(DATEDIFF(DAY,DDOG.DateArrivedOnForza, DDOG.DateDelivered)) AS DECIMAL) / CAST( DATEDIFF(DAY, @StartFilterDate, @EndFilterDate) AS DECIMAL)) 'VelocidadEntregaDia',
						(ROUND(((CAST(SUM((CASE WHEN DDOG.DateDelivered IS NOT NULL THEN 1 ELSE 0 END)) AS DECIMAL) / CAST(COUNT(FG.GuideNumber) AS DECIMAL)) * 100), 2))  'PorcentajEntregaTotal'
					FROM
						#FilteredGuides FG
						LEFT JOIN
							#DeliveryDataOfGuide DDOG
							ON
								FG.GuideSerie = DDOG.GuideSerie
								AND
								FG.GuideNumber = DDOG.GuideNumber
								AND
								DDOG.DateArrivedOnForza IS NOT NULL
								AND
								DDOG.DateDelivered IS NOT NULL

					IF( EXISTS(SELECT TOP 1 1 FROM @ResponseVelTable) )
					BEGIN
						SELECT
							CAST(1 AS BIT) [blnResult]

						SELECT
							ISNULL(VelocidadEntregaDia,0) 'TopValue',
							'Velocidad de entrega' 'TopText',
							ISNULL(PorcentajentregaTotal,0) 'BottomValue',
							'Entregas' 'BottomText',
							'fas fa-paper-plane' 'WidgetIcon'
						FROM
							@ResponseVelTable
					END
					ELSE 
					BEGIN
						SELECT
							CAST(0 AS BIT) [blnResult]

						SELECT
							0 'TopValue',
							'Velocidad de entrega/día' 'TopText',
							0 'BottomValue',
							'Entregas' 'BottomText',
							'fas fa-paper-plane' 'WidgetIcon'
					END

				END
				ELSE 
				BEGIN
					SELECT
						CAST(0 AS BIT) [blnResult]

					SELECT
						0 'TopValue',
						'Velocidad de entrega/día' 'TopText',
						0 'BottomValue',
						'Entregas' 'BottomText',
						'fas fa-paper-plane' 'WidgetIcon'
				END

			END
			ELSE
			BEGIN
				SELECT
					CAST(0 AS BIT) [blnResult]

				SELECT
					0 'TopValue',
					'Velocidad de entrega/día' 'TopText',
					0 'BottomValue',
					'% de entregas' 'BottomText',
					'fas fa-paper-plane' 'WidgetIcon'
			END

		END
		ELSE IF(@WidgetName = 'RecoleccionesRealizados' COLLATE Latin1_General_CI_AI)
		BEGIN

			DECLARE @PickupServiceStatusId INT = (SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK) WHERE CSS.[Name] = 'Recolectado' COLLATE Latin1_General_CI_AI)
			DECLARE @CancelServiceStatusId INT = (SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK) WHERE CSS.[Name] = 'Cancelado' COLLATE Latin1_General_CI_AI)

			INSERT INTO #FilteredServices
				(ServiceManagement, SchedulePickup, ServiceStatus, ServiceDate, ServicePickupDate)
			SELECT
				SM.IdServiceManagement
				,SP.SchedulePickupId
				,SM.ServiceStatusId
				,SP.DateCreated
				,(SELECT TOP 1 ES.DateCreated FROM [DeliveryBackOffice].[dbo].[EventService] ES WITH(NOLOCK) WHERE ES.ServiceManagementId = SM.IdServiceManagement AND ES.ServiceStatusId = @PickupServiceStatusId ORDER BY ES.DateCreated ASC)
			FROM
				[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH(NOLOCK)
					ON
						SM.IdSchedulePickup = SP.SchedulePickupId
			WHERE
				SP.DateCreated BETWEEN @StartFilterDate AND @EndFilterDate
				AND
				SP.AccountId = @AccoundId

			IF( EXISTS(SELECT TOP 1 1 FROM #FilteredServices) )
			BEGIN

				DECLARE @ResponseServicesTable AS TABLE(
					TotalPickupServices INT,
					TotalCompletedPickups INT,
					TotalPendingPickups INT
				);

				INSERT INTO @ResponseServicesTable
					(TotalPickupServices, TotalCompletedPickups, TotalPendingPickups)
				SELECT
					COUNT(1),
					SUM((CASE WHEN FS.ServicePickupDate IS NOT NULL THEN 1 ELSE 0 END)),
					SUM((CASE WHEN FS.ServicePickupDate IS NULL THEN 1 ELSE 0 END))
				FROM
					#FilteredServices FS

				IF( EXISTS(SELECT TOP 1 1 FROM @ResponseServicesTable))
				BEGIN
					SELECT
						CAST(1 AS BIT) [blnResult]

					SELECT
						ISNULL(TotalPendingPickups,0) 'TopValue',
						'Recolecciones pendientes' 'TopText',
						ISNULL(TotalCompletedPickups,0) 'BottomValue',
						'Recolecciones completadas' 'BottomText',
						'fa fa-shipping-fast' 'WidgetIcon'
					FROM
						@ResponseServicesTable
				END
				ELSE
				BEGIN
					SELECT
						CAST(0 AS BIT) [blnResult]

					SELECT
						0 'TopValue',
						'Recolecciones pendientes' 'TopText',
						0 'BottomValue',
						'Recolecciones completadas' 'BottomText',
						'fa fa-shipping-fast' 'WidgetIcon'
				END

			END
			ELSE
			BEGIN
				SELECT
					CAST(0 AS BIT) [blnResult]

				SELECT
					0 'TopValue',
					'Recolecciones pendientes' 'TopText',
					0 'BottomValue',
					'Recolecciones completadas' 'BottomText',
					'fa fa-shipping-fast' 'WidgetIcon'
			END
		END
		ELSE
		BEGIN

			SELECT
				CAST(0 AS BIT) [blnResult]

			SELECT
				0 'TopValue',
				'' 'TopText',
				0 'BottomValue',
				'' 'BottomText',
				'' 'WidgetIcon'

		END
	END TRY
	BEGIN CATCH
		SELECT
			CAST(0 AS BIT) [blnResult],
			ERROR_MESSAGE() [responseMessage]

		SELECT
			0 'TopValue',
			'' 'TopText',
			0 'BottomValue',
			'' 'BottomText',
			'' 'WidgetIcon'
	END CATCH
	
	IF OBJECT_ID('tempdb.dbo.#FilteredGuides', 'U') IS NOT NULL
			DROP TABLE #FilteredGuides
	IF OBJECT_ID('tempdb.dbo.#FilteredServices', 'U') IS NOT NULL
			DROP TABLE #FilteredServices

END