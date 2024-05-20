
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-11-03>
-- Description:	< Obtener guías por rango de fechas de un cliente, vajo distintos filtros>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-11-03>
-- Description:	< filtro para usuarios individuales para que meustre último estado externo>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerGuides]
	@AccountId INT, 
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,

	@GuideFilter NVARCHAR(50) = NULL,

	@ShowAll BIT = 0,
	@OnlyShowNotStarted BIT = 0,
	@OnlyShowInProgress BIT = 0,
	@OnlyShowCompleted BIT = 0,
	@OnlyShowCanceled BIT = 0,

	@DisplayRegistries INT = 10,
	@DisplayPage INT = 0

AS
BEGIN

	SET NOCOUNT ON;

    IF OBJECT_ID('tempdb.dbo.#AccountFilteredGuides', 'U') IS NOT NULL DROP TABLE #AccountFilteredGuides;

	DECLARE @NotStartCheckpontTypeId INT = (SELECT TOP 1 CCT.IdCatCheckpointType FROM [DeliveryBackOffice].[dbo].[CatCheckpointType] CCT WITH(NOLOCK) WHERE CCT.CheckpointTypeDescription = 'Checkpoint inicial' COLLATE Latin1_General_CI_AI);
	DECLARE @InProgessCheckpontTypeId INT = (SELECT TOP 1 CCT.IdCatCheckpointType FROM [DeliveryBackOffice].[dbo].[CatCheckpointType] CCT WITH(NOLOCK) WHERE CCT.CheckpointTypeDescription = 'Checkpoint de proceso' COLLATE Latin1_General_CI_AI);
	DECLARE @CompletedCheckpontTypeId INT = (SELECT TOP 1 CCT.IdCatCheckpointType FROM [DeliveryBackOffice].[dbo].[CatCheckpointType] CCT WITH(NOLOCK) WHERE CCT.CheckpointTypeDescription = 'Checkpoint final' COLLATE Latin1_General_CI_AI);
	DECLARE @IncidenceCheckpontTypeId INT = (SELECT TOP 1 CCT.IdCatCheckpointType FROM [DeliveryBackOffice].[dbo].[CatCheckpointType] CCT WITH(NOLOCK) WHERE CCT.CheckpointTypeDescription = 'Checkpoint de incidencia' COLLATE Latin1_General_CI_AI);

	DECLARE @CanceledStatusOrderId INT = (SELECT TOP 1 SO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) WHERE SO.OrderDescription = 'Anulado' COLLATE Latin1_General_CI_AI);
	DECLARE @GeneradoStatusOrderId INT = (SELECT TOP 1 SO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) WHERE SO.OrderDescription = 'Generado' COLLATE Latin1_General_CI_AI);
	DECLARE @SolicitadoStatusOrderId INT = (SELECT TOP 1 SO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) WHERE SO.OrderDescription = 'Solicitado' COLLATE Latin1_General_CI_AI);
	
	DECLARE @InmediatePaymentTime INT = (SELECT TOP 1 CPT.TimePlaId FROM [DeliveryBackOffice].[dbo].[CatPaymentTime] CPT WITH(NOLOCK) WHERE CPT.TimePlaName = 'Ahora' COLLATE Latin1_General_CI_AI)

	-- Configuraciones generales
	DECLARE @OffsetRegistries BIGINT = @DisplayPage * @DisplayRegistries;
	DECLARE @TotalServices BIGINT = 0;

	-- Variables de control de flujo
	DECLARE @CustomerId INT = NULL;
	DECLARE @CustomerTypeId INT = NULL;
	DECLARE @VisitPointByAccount INT = NULL;

	DECLARE @FilteredStatus AS TABLE (
		StatusOrderId INT
	);
	
		DECLARE @ExternalTypeId INT = (
				SELECT
					TOP 1
						CST.IdCatStatusType
				FROM
					[DeliveryBackOffice].[dbo].[CatStatusType] CST WITH (NOLOCK)
				WHERE
					CST.StatusType = 'Externo' COLLATE Latin1_General_CI_AI
			)
	-- Obtener datos de usuario
	SELECT
		@CustomerId = Cu.IdCustomer
		,@CustomerTypeId = Cu.IdCustomerType
		,@VisitPointByAccount = VPC.CodeOfReference
	FROM
		[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
			ON
				Acc.IdCustomer = Cu.IdCustomer
				AND
				ISNULL(Cu.RowSatus,1) = 1
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH(NOLOCK)
			ON
				RBUBA.RuaIdAccount = Acc.AccIdAccount
				AND
				RBUBA.RuaRowStatus = 1
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[VisitPointByUser] VPBU WITH(NOLOCK)
			ON
				RBUBA.RuaIdUser = VPBU.RegisterUserID
				AND
				VPBU.RowStatus = 1
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
			ON
				VPBU.IdVisitPointClient = VPC.IdVisitPointClient
				AND
				VPC.StatusClient = 1
	WHERE
		Acc.AccIdAccount = @AccountId
		AND
		Acc.AccRowStatus = 1

	-- Ingreso de filtros de estado
	INSERT INTO @FilteredStatus
		(StatusOrderId)
	SELECT
		SO.StatusOrderId
	FROM
		[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
	WHERE
		(@ShowAll = 1 AND SO.StatusOrderId != @CanceledStatusOrderId)
		OR
		(@OnlyShowNotStarted = 1 AND (SO.StatusOrderId = @GeneradoStatusOrderId OR SO.StatusOrderId = @SolicitadoStatusOrderId))
		OR
		(@OnlyShowInProgress = 1 AND SO.CatCheckpointTypeId = @InProgessCheckpontTypeId AND SO.CatStatusTypeId = 1)
		OR
		(@OnlyShowCompleted = 1 AND SO.CatCheckpointTypeId = @CompletedCheckpontTypeId AND SO.StatusOrderId != @CanceledStatusOrderId)
		OR
		(@OnlyShowCanceled = 1 AND SO.StatusOrderId = @CanceledStatusOrderId)

	-- Filtro de datos
	BEGIN TRY
		CREATE TABLE #AccountFilteredGuides (
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			StatusOrderId INT,
			Pieces_Dry INT,               
			Pieces_Cold INT,
			Ticket_Number NVARCHAR(50),
			Receiver_FirstName NVARCHAR(100),
			Receiver_LastName NVARCHAR(100),
			Receiver_Phone NVARCHAR(100),
			IsCollect BIT,
			PriceShippment DECIMAL(18,2),
			Collect_OnDelivery DECIMAL(18,2),
			TypeService NVARCHAR(5),
			DateCreated DATETIME
		);

		CREATE NONCLUSTERED INDEX IX_ProductVendor_Guide ON #AccountFilteredGuides (GuideSerie, GuideNumber);
		CREATE NONCLUSTERED INDEX IX_ProductVendor_Status ON #AccountFilteredGuides (StatusOrderId);
		
		IF(@CustomerTypeId = 3)
		BEGIN

			INSERT INTO #AccountFilteredGuides
				(
					GuideSerie
					,GuideNumber
					,StatusOrderId
					,Pieces_Dry
					,Pieces_Cold
					,Ticket_Number
					,Receiver_FirstName
					,Receiver_LastName
					,Receiver_Phone
					,IsCollect
					,PriceShippment
					,Collect_OnDelivery
					,TypeService
					,DateCreated
				)
			SELECT
				DISTINCT
					DO.Guide_Serie
					,DO.Guide_Number
					,LastExternalStatus.StatusOrderId
					,DO.Pieces_Dry
					,DO.Pieces_Cold
					,DO.Ticket_Number
					,DO.Receiver_FirstName
					,DO.Receiver_LastName
					,DO.Receiver_Phone
					,DO.IsCollect
					,DO.PriceShippment
					,DO.Collect_OnDelivery
					,DO.TypeService
					,DO.DateCreated
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				OUTER APPLY (
					SELECT
						TOP (1)
							SO.[StatusOrderId]
					FROM
						[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD  WITH(NOLOCK) 
						INNER JOIN
							[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
							ON
								[SO].[StatusOrderId] = [DOD].[StatusOrderId]
								AND
								[SO].[CatStatusTypeId] = @ExternalTypeId
					WHERE
						DOD.[Guide_Serie] = DO.[Guide_Serie]
						AND
						DOD.[Guide_Number] = DO.[Guide_Number]
						AND
						DOD.[RowStatus] = 1
					ORDER BY
						DOD.[DateCreated] DESC
				) LastExternalStatus
				INNER  JOIN
					@FilteredStatus FS
					ON
					LastExternalStatus.StatusOrderId = FS.StatusOrderId 

			WHERE
				-- Área de filtros
				(
					( @CustomerTypeId = 3 AND DO.IdCustomer = @CustomerId)
				)
				AND
				( (@StartDate IS NULL AND @EndDate IS NULL) OR DO.DateCreated BETWEEN @StartDate AND @EndDate )
				AND
				( @GuideFilter IS NULL OR CONCAT(DO.Guide_Serie, DO.Guide_Number) LIKE '%'+LTRIM(RTRIM(@GuideFilter))+'%' )
				

		END
		ELSE IF (@CustomerTypeId = 2)
		BEGIN

			INSERT INTO #AccountFilteredGuides
				(
					GuideSerie
					,GuideNumber
					,StatusOrderId
					,Pieces_Dry
					,Pieces_Cold
					,Ticket_Number
					,Receiver_FirstName
					,Receiver_LastName
					,Receiver_Phone
					,IsCollect
					,PriceShippment
					,Collect_OnDelivery
					,TypeService
					,DateCreated
				)
			SELECT
				DISTINCT
					DO.Guide_Serie
					,DO.Guide_Number
					,DO.StatusOrderId
					,DO.Pieces_Dry
					,DO.Pieces_Cold
					,DO.Ticket_Number
					,DO.Receiver_FirstName
					,DO.Receiver_LastName
					,DO.Receiver_Phone
					,DO.IsCollect
					,DO.PriceShippment
					,DO.Collect_OnDelivery
					,DO.TypeService
					,DO.DateCreated
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				INNER JOIN
					@FilteredStatus FS
					ON
						DO.StatusOrderId = FS.StatusOrderId
			WHERE
				-- Área de filtros
				(
					( @CustomerTypeId = 2 AND (DO.Sender_ID = @VisitPointByAccount OR do.OriginSenderId = @VisitPointByAccount) )
				)
				AND
				( (@StartDate IS NULL AND @EndDate IS NULL) OR DO.DateCreated BETWEEN @StartDate AND @EndDate )
				AND
				( @GuideFilter IS NULL OR CONCAT(DO.Guide_Serie, DO.Guide_Number) LIKE '%'+LTRIM(RTRIM(@GuideFilter))+'%' )

		END
		ELSE IF (@CustomerTypeId = 1)
		BEGIN

			INSERT INTO #AccountFilteredGuides
				(
					GuideSerie
					,GuideNumber
					,StatusOrderId
					,Pieces_Dry
					,Pieces_Cold
					,Ticket_Number
					,Receiver_FirstName
					,Receiver_LastName
					,Receiver_Phone
					,IsCollect
					,PriceShippment
					,Collect_OnDelivery
					,TypeService
					,DateCreated
				)
			SELECT
				DISTINCT
					DO.Guide_Serie
					,DO.Guide_Number
					,DO.StatusOrderId
					,DO.Pieces_Dry
					,DO.Pieces_Cold
					,DO.Ticket_Number
					,DO.Receiver_FirstName
					,DO.Receiver_LastName
					,DO.Receiver_Phone
					,DO.IsCollect
					,DO.PriceShippment
					,DO.Collect_OnDelivery
					,DO.TypeService
					,DO.DateCreated
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				INNER JOIN
					@FilteredStatus FS
					ON
						DO.StatusOrderId = FS.StatusOrderId
			WHERE
				-- Área de filtros
				(
					( @CustomerTypeId = 1 AND (DO.Sender_ID = @VisitPointByAccount)  )
				)
				AND
				( (@StartDate IS NULL AND @EndDate IS NULL) OR DO.DateCreated BETWEEN @StartDate AND @EndDate )
				AND
				( @GuideFilter IS NULL OR CONCAT(DO.Guide_Serie, DO.Guide_Number) LIKE '%'+LTRIM(RTRIM(@GuideFilter))+'%' )

		END

		IF( EXISTS(SELECT TOP 1 1 FROM #AccountFilteredGuides) )
		BEGIN

			SELECT
				200 'ResultCode',
				'Datos obtenidos correctamente' 'ResultMessage',
				(SELECT COUNT(1) FROM #AccountFilteredGuides) 'TotalGuides'

			SELECT
				CONCAT(DO.GuideSerie, DO.GuideNumber) 'Guide',
				(ISNULL(DO.Pieces_Dry,0) + ISNULL(DO.Pieces_Cold,0)) 'Pieces',
				ISNULL(DO.Ticket_Number,'') 'Reference',
				UPPER(LTRIM(RTRIM(CONCAT(DO.Receiver_FirstName,' ',DO.Receiver_LastName)))) 'ReceiverName',
				ISNULL(DO.Receiver_Phone, '') 'ReceiverPhone',
				(CASE
					WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 0
					ELSE ISNULL(DO.IsCollect, 0)
				END) 'IsCollect',
				CAST(CAST(ISNULL(DO.PriceShippment, 0) AS MONEY) AS NVARCHAR) 'PriceService',
				CAST(CAST(ISNULL(DO.Collect_OnDelivery, 0) AS MONEY) AS NVARCHAR) 'CollectOnDelivery',
				SO.StatusOrderId 'IdStatus',
				UPPER(SO.OrderDescription) 'StatusDescription',
				ISNULL(DOPD.ShipmentCompleted, 0) 'ShippmentComplete',
				ISNULL((
					CASE
						WHEN ISNULL(DOPD.ShipmentCompleted, 0) = 0 THEN 'PENDIENTE'
						WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
						WHEN DOPD.TimePlaId = 8 THEN 'CREDITO'
						WHEN DO.IsCollect = 1 THEN 'COLLECT'
						ELSE UPPER(CPType.PayTypeName)
					END
				), 'PENDIENTE') 'WayToPay',
				ISNULL((
					CASE
						WHEN ISNULL(DOPD.ShipmentCompleted, 0) = 0 THEN UPPER('pendiente de pago')
						WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
						WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
						WHEN DOPD.TypeofInOutMoneyId = 8 THEN UPPER('pago al crédito')
						ELSE UPPER(IOOMT.tio_pk_name)
					END
				), UPPER('pago en efectivo')) 'TypePayment',
				UPPER(ISNULL(DO.TypeService, '')) 'TypeService',
				(CASE 
					WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN CONVERT(VARCHAR, @InmediatePaymentTime)
					ELSE ISNULL(CONVERT(VARCHAR, DOPD.TimePlaId), '') 
				END) 'TimePayment',
				ISNULL(CPTime.TimePlaName, '') 'TimePaymentDescription',
				'Q.' 'CurrencySymbol'
			FROM
				#AccountFilteredGuides DO WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
					ON
						DO.StatusOrderId = SO.StatusOrderId
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH(NOLOCK)
					ON
						DOPD.GuideSerie = DO.GuideSerie
						AND
						DOPD.GuideNumber = DO.GuideNumber
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[CatPaymentType] CPType WITH(NOLOCK)
					ON
						DOPD.PayTypeId = CPType.PayTypeId
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[CatPaymentTime] CPTime WITH(NOLOCK)
					ON
						DOPD.TimePlaId = CPTime.TimePlaId
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[ctgTypeOfInOutOfMoney] IOOMT WITH(NOLOCK)
					ON
						DOPD.TypeofInOutMoneyId = IOOMT.tio_pk_id
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
					ON
						DO.GuideSerie = PBSL.GuideSerie
						AND
						DO.GuideNumber = PBSL.GuideNumber
						AND
						PBSL.PointsConsumed > 0
						AND
						PBSL.PointsReceived = 0
				ORDER BY
					DO.DateCreated DESC
				OFFSET @OffsetRegistries ROWS FETCH NEXT @DisplayRegistries ROWS ONLY

		END
		ELSE
		BEGIN

			SELECT
				204 'ResultCode',
				'No se encontraron datos' 'ResultMessage'

		END
	END TRY
	BEGIN CATCH

		SELECT
			500 'ResultCode',
			'Error en obtener datos' 'ResultMessage'

	END CATCH
	
    IF OBJECT_ID('tempdb.dbo.#AccountFilteredGuides', 'U') IS NOT NULL DROP TABLE #AccountFilteredGuides;

END