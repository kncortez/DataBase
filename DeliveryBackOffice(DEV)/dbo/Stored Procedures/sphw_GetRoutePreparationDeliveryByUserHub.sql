
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-10-21>
-- Description:	<Devuelve todos los couriers basado en los hubs del usuario interno>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetRoutePreparationDeliveryByUserHub]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@UserId BIGINT,
	@CourierId INT = NULL
AS
BEGIN

	IF OBJECT_ID('tempdb.dbo.#DeliveryServiceList', 'U') IS NOT NULL DROP TABLE #DeliveryServiceList;

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

	-- Tablas temporales
	CREATE TABLE #DeliveryServiceList (
		IdCourier INT,
		CourierName NVARCHAR(200),
		RouteCode NVARCHAR(50),
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		Guide NVARCHAR(50),
		DispatchDate DATETIME,
		IsReturn BIT,
		GuideFlow NVARCHAR(50),
		StatusDescription NVARCHAR(100),
		DateStatus DATETIME
	);

	-- Variables de apoyo
	DECLARE @TransferedToExcStatusId INT = (SELECT TOP 1 SO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) WHERE SO.OrderDescription = 'Traslado a Express Center' COLLATE Latin1_General_CI_AI)

	BEGIN TRY

	INSERT INTO #DeliveryServiceList
		(IdCourier, CourierName, RouteCode, DispatchDate, GuideSerie, GuideNumber, Guide, IsReturn, GuideFlow, StatusDescription, DateStatus)
	SELECT
		SR.ID 'IdCourier'
		,LTRIM(RTRIM(CONCAT(SR.First_Name, ' ', SR.Last_Name))) 'CourierName'
		,CR.CodeRoute 'RouteCode'
		,DOBS.Date_Dispatched 'DispatchDate'
		,DA.Guide_Serie 'GuideSerie'
		,DA.Guide_Number 'GuideNumber'
		,CONCAT(DA.Guide_Serie, DA.Guide_Number) 'Guide'
		,CAST(ISNULL(DO.IsLastMileReturn, 0) AS BIT) 'IsReturn'
		,(
			CASE
				WHEN ISNULL(DO.IsLastMileReturn, 0) = 1 THEN 'Devolución'
				ELSE 'Entrega'
			END
		) 'GuideFlow'
		,DODLast.StatusDescription
		,DODLast.DateStatus
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH(NOLOCK)
			ON
				DA.ID_DeliveryOrderBySettlement = DOBS.ID
				AND
				DA.ID_Courier = DOBS.ID_Courier
		INNER JOIN
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
			ON
				DA.ID_Courier = SR.ID
		INNER JOIN
			[DeliveryBackOffice].[dbo].[HubLogisticByUser] HLBU WITH(NOLOCK)
			ON
				HLBU.HubLogisticId = SR.HubLogisticId
				AND
				HLBU.UserId = @UserId
				AND
				HLBU.RowStatus = 1
		INNER JOIN
			[DeliveryBackOffice].[dbo].[CatRoute] CR WITH(NOLOCK)
			ON
				DOBS.CatRouteId = CR.IdRoute
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH(NOLOCK)
			ON
				DOBS.ID = DSD.ID_DeliveryOrderBySettlement
				AND
				DA.Guide_Serie = DSD.Guide_Serie
				AND
				DA.Guide_Number = DSD.Guide_Number
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			ON
				DA.Guide_Serie = DO.Guide_Serie
				AND
				DA.Guide_Number = DO.Guide_Number
		OUTER APPLY (
			SELECT
				TOP 1
					SO.OrderDescription 'StatusDescription'
					,CAST(ISNULL(DOD.DateCreated, DOD.DateCreatedInSystem) AS DATETIME) 'DateStatus'
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
				ON
					DOD.StatusOrderId = SO.StatusOrderId
			WHERE
				DA.Guide_Serie = DOD.Guide_Serie
				AND
				DA.Guide_Number = DOD.Guide_Number
				AND
				DOD.RowStatus = 1
			ORDER BY
				ISNULL(DOD.DateCreated, DOD.DateCreatedInSystem) DESC
		) DODLast
	WHERE
		CAST(DA.Date_Created AS DATE) BETWEEN @StartDate AND @EndDate
		AND
		(@CourierId IS NULL OR DA.ID_Courier = @CourierId)

	IF(EXISTS(SELECT TOP 1 1 FROM #DeliveryServiceList))
	BEGIN

		SELECT
			200 'ResultCode',
			'Registros encontrados.' 'ResultMessage'

		SELECT
			DSL.IdCourier,
			DSL.CourierName,
			DSL.RouteCode,
			DSL.GuideSerie,
			DSL.GuideNumber,
			DSL.Guide,
			DSL.DispatchDate,
			DSL.IsReturn,
			DSL.GuideFlow,
			DSL.StatusDescription,
			DSL.DateStatus
		FROM
			#DeliveryServiceList DSL

	END
	ELSE
	BEGIN

		SELECT
			204 'ResultCode',
			'No se encontraron datos bajo las condiciones indicadas.' 'ResultMessage'

		SELECT
			DSL.IdCourier,
			DSL.CourierName,
			DSL.RouteCode,
			DSL.GuideSerie,
			DSL.GuideNumber,
			DSL.Guide,
			DSL.DispatchDate,
			DSL.IsReturn,
			DSL.GuideFlow,
			DSL.StatusDescription,
			DSL.DateStatus
		FROM
			#DeliveryServiceList DSL

	END

	END TRY
	BEGIN CATCH

		SELECT
			500 'ResultCode',
			ERROR_MESSAGE() 'ResultMessage'

	END CATCH
		
	IF OBJECT_ID('tempdb.dbo.#DeliveryServiceList', 'U') IS NOT NULL DROP TABLE #DeliveryServiceList;
END