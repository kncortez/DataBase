
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
			CAST(0 AS BIT) [blnResult]

		SELECT
			0 'TopValue',
			'' 'TopText',
			0 'BottomValue',
			'' 'BottomText'
	END CATCH
	
	IF OBJECT_ID('tempdb.dbo.#FilteredGuides', 'U') IS NOT NULL
			DROP TABLE #FilteredGuides
END