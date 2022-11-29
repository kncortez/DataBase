
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-10-21>
-- Description:	<Devuelve todos los couriers basado en los hubs del usuario interno>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetRoutePreparationDeliveryByUserHub]
	@TargetDate DATE = NULL,
	@UserId BIGINT,
	@CourierId INT = NULL
AS
BEGIN

	IF OBJECT_ID('tempdb.dbo.#DeliveryServiceList', 'U') IS NOT NULL DROP TABLE #DeliveryServiceList;

	-- Manejo de fechas
	IF(@TargetDate IS NULL)
	BEGIN

		SET @TargetDate = CAST(GETDATE() AS DATE);

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
		DateStatus DATETIME,
		IncidenceDescription NVARCHAR(200),
		ServiceLatitude NVARCHAR(50),
		ServiceLongitude NVARCHAR(50)
	);

	-- Variables de apoyo
	DECLARE @TransferedToExcStatusId INT = (SELECT TOP 1 SO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) WHERE SO.OrderDescription = 'Traslado a Express Center' COLLATE Latin1_General_CI_AI)

	BEGIN TRY

	INSERT INTO #DeliveryServiceList
		(IdCourier, CourierName, RouteCode, DispatchDate, GuideSerie, GuideNumber, Guide, IsReturn, GuideFlow, StatusDescription, DateStatus, IncidenceDescription, ServiceLatitude, ServiceLongitude)
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
		,(
			CASE
				WHEN DA.Delivered = 0 AND DA.ID_Incident IS NOT NULL THEN CTI.NameIncidence
				ELSE ''
			END
		) 'IncidenceDescription',
		DA.Latitude 'ServiceLatitude',
		DA.Longitude 'ServiceLongitude'
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
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH(NOLOCK)
			ON
				DA.ID_Incident = CTI.IdIncidenceType
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
		CAST(DA.Date_Created AS DATE) = @TargetDate
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
			DSL.DateStatus,
			DSL.IncidenceDescription,
			DSL.ServiceLatitude,
			DSL.ServiceLongitude
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
			DSL.DateStatus,
			DSL.IncidenceDescription,
			DSL.ServiceLatitude,
			DSL.ServiceLongitude
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