
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-08-18>
-- Description:	< Método dinamico para obtener datos para Widgets del lado de portal web  >
-- =============================================

CREATE PROCEDURE [dbo].[GetWidgetData]
	
	@AccoundId BIGINT,
	@StartFilterDate DATETIME = NULL,
	@EndFilterDate DATETIME = NULL,
	@WidgetName NVARCHAR(50)

AS
BEGIN

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
					COUNT(FG.GuideNumber)
				FROM
					#FilteredGuides FG

				IF( EXISTS(SELECT TOP 1 1 FROM @ResponseTable))
				BEGIN
					SELECT
						CAST(1 AS BIT) [blnResult]

					SELECT
						TotalGuidePieces 'TopValue',
						'Piezas' 'TopText',
						TotalGuideDelivered 'BottomValue',
						'Envios realizados' 'BottomText'
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
						'Envios realizados' 'BottomText'
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
					'Envios realizados' 'BottomText'
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
						TotalPaidCoD 'TopValue',
						'Monto pagado COD' 'TopText',
						TotalPendingCoD 'BottomValue',
						'Total por cobrar' 'BottomText'
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
						'Total por cobrar' 'BottomText'
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
					'Total por cobrar' 'BottomText'
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
							VelocidadEntregaDia 'TopValue',
							'Velocidad de entrega' 'TopText',
							PorcentajentregaTotal 'BottomValue',
							'Porcentaje de entregas' 'BottomText'
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
							'Porcentaje de entregas realizadas' 'BottomText'
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
						'Porcentaje de entregas realizadas' 'BottomText'
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
					'Porcentaje de entregas realizadas' 'BottomText'
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
				'' 'BottomText'

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
			'' 'BottomText'
	END CATCH
	
	IF OBJECT_ID('tempdb.dbo.#FilteredGuides', 'U') IS NOT NULL
			DROP TABLE #FilteredGuides
END