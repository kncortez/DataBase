/* =================================================
   SP:        [<dbo>].[<spws_get_services_v2>]
   Propósito: <Se hizo una copia del sp spws_get_services donde se eliminó la respuesta JSON y se devuelve una consulta con datatable>
   Autor:     <Randy López>
   Historia:  <FDAPI-5606>
   Fecha:     2026-03-05
============================================
=== CHANGELOG ================================
2026-06-08 | Historia/épica: FDAPI-5606 | Autor: Keila Cortéz 
=========================================== */
CREATE PROCEDURE [dbo].[spws_get_services_v2]
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Pagina BIGINT = 0,
    @Token VARCHAR(200),
    @IdAccount BIGINT,
    @GuideNumber AS NVARCHAR(50) = '-1',
    @Filter INT,
    @CancelGuides TINYINT = 1
AS
BEGIN    
set arithabort off
    DECLARE @IdUser BIGINT =
            (
                SELECT TOP 1 t.TknIdUser FROM TokenLog t WITH(NOLOCK) WHERE t.TknIdToken = @Token
            );
    IF OBJECT_ID('tempdb.dbo.#temp', 'U') IS NOT NULL
        DROP TABLE #temp;
    SELECT *
    INTO #temp
    FROM
    (
        SELECT ua.CodeOfReference
        FROM DeliveryBackOffice.dbo.RolByUserByAccount rua WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.UserAddress ua WITH(NOLOCK)
                ON ua.UadIdAccount = rua.RuaIdAccount
        WHERE rua.RuaIdAccount = @IdAccount
              AND rua.RuaIdUser = @IdUser
              AND rua.RuaRowStatus = 1
              AND ua.CodeOfReference IS NOT NULL
        UNION
        SELECT vpc.CodeOfReference
        FROM DeliveryBackOffice.dbo.VisitPointByUser vpu WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK)
                ON vpu.IdVisitPointClient = vpc.IdVisitPointClient
        WHERE RegisterUserID = @IdUser
    ) AS t;

    CREATE NONCLUSTERED INDEX idx_codeofreference ON #temp (CodeOfReference);

    DECLARE @idCustomer INT =
            (
                SELECT TOP 1 IdCustomer FROM DeliveryBackOffice.dbo.Account WITH(NOLOCK) WHERE AccIdAccount = @IdAccount
            );

	-- Revisar tipo de usuario
	DECLARE @TypeUser NVARCHAR(20) = ''

	SELECT TOP 1
		@TypeUser = ctp.Description
	FROM DeliveryBackOffice.dbo.InternalUser iu WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser rg WITH(NOLOCK)
		ON rg.UsrIdUser = iu.RegisterUserID
	INNER JOIN dbo.RolByUserByAccount bya WITH(NOLOCK)
		ON bya.RuaIdUser = rg.UsrIdUser
	INNER JOIN dbo.Account acc WITH(NOLOCK)
		ON acc.AccIdAccount = bya.RuaIdAccount
	INNER JOIN dbo.Customer cs WITH(NOLOCK)
		ON cs.IdCustomer = acc.IdCustomer
	INNER JOIN dbo.CustomerType ctp WITH(NOLOCK)
		ON ctp.IdCustomerType = cs.IdCustomerType
	INNER JOIN dbo.TokenLog tl WITH(NOLOCK)
		ON tl.TknIdUser = bya.RuaIdUser
	WHERE tl.TknIdToken = @Token

    IF (@Pagina > -1)
    BEGIN
        IF (@Filter = -1)
        BEGIN
			SET NOCOUNT ON;

			DECLARE @CantidadRegistrosTabla INT = 10;
			DECLARE @SkipTabla BIGINT = @Pagina * @CantidadRegistrosTabla;

			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					INNER JOIN #temp tp
						ON ord.Sender_ID = tp.CodeOfReference
				WHERE
					(
						@CancelGuides = 0
						AND ISNULL(ord.StatusOrderId, 15) != 7
						OR @CancelGuides = 1
						   AND ord.StatusOrderId IS NOT NULL
					)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC
				OFFSET @SkipTabla ROWS FETCH NEXT @CantidadRegistrosTabla ROWS ONLY;
			END
			ELSE
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
				WHERE
					(
						ord.Sender_ID IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.OriginSenderId IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.IdCustomer = @idCustomer
					)
					AND
					(
						@CancelGuides = 0
						AND ISNULL(ord.StatusOrderId, 15) != 7
						OR @CancelGuides = 1
						   AND ord.StatusOrderId IS NOT NULL
					)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC
				OFFSET @SkipTabla ROWS FETCH NEXT @CantidadRegistrosTabla ROWS ONLY;
			END;

			RETURN;
        END;

        IF (@Filter = 1)
        BEGIN
			SET NOCOUNT ON;

			DECLARE @CantidadRegistrosTabla1 INT = 10;
			DECLARE @SkipTabla1 BIGINT = @Pagina * @CantidadRegistrosTabla1;

			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					INNER JOIN #temp tp
						ON ord.Sender_ID = tp.CodeOfReference
				WHERE ord.StatusOrderId = 15
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC
				OFFSET @SkipTabla1 ROWS FETCH NEXT @CantidadRegistrosTabla1 ROWS ONLY;
			END
			ELSE
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					LEFT JOIN DeliveryBackOffice.dbo.PointsByServiceLog PBSL WITH (NOLOCK)
						ON ord.Guide_Serie = PBSL.GuideSerie
						AND ord.Guide_Number = PBSL.GuideNumber
						AND PBSL.PointsConsumed > 0
						AND PBSL.PointsReceived = 0
				WHERE ord.StatusOrderId = 15
					AND
					(
						ord.Sender_ID IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.OriginSenderId IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.IdCustomer = @idCustomer
					)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC
				OFFSET @SkipTabla1 ROWS FETCH NEXT @CantidadRegistrosTabla1 ROWS ONLY;
			END;

			RETURN;
        END;

        IF (@Filter = 2)
        BEGIN
			SET NOCOUNT ON;

			DECLARE @CantidadRegistrosTabla2 INT = 10;
			DECLARE @SkipTabla2 BIGINT = @Pagina * @CantidadRegistrosTabla2;

			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					INNER JOIN #temp tp
						ON ord.Sender_ID = tp.CodeOfReference
				WHERE ISNULL(ord.StatusOrderId, 15) NOT IN (15, 5, 7, 22)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC
				OFFSET @SkipTabla2 ROWS FETCH NEXT @CantidadRegistrosTabla2 ROWS ONLY;
			END
			ELSE
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					LEFT JOIN DeliveryBackOffice.dbo.PointsByServiceLog PBSL WITH (NOLOCK)
						ON ord.Guide_Serie = PBSL.GuideSerie
						AND ord.Guide_Number = PBSL.GuideNumber
						AND PBSL.PointsConsumed > 0
						AND PBSL.PointsReceived = 0
				WHERE
					(
						ord.Sender_ID IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.OriginSenderId IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.IdCustomer = @idCustomer
					)
					AND ISNULL(ord.StatusOrderId, 15) NOT IN (15, 5, 7, 22)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC
				OFFSET @SkipTabla2 ROWS FETCH NEXT @CantidadRegistrosTabla2 ROWS ONLY;
			END;

			RETURN;
        END;


        IF (@Filter = 3)
        BEGIN

            SET NOCOUNT ON;

			DECLARE @CantidadRegistrosTabla3 INT = 10;
			DECLARE @SkipTabla3 BIGINT = @Pagina * @CantidadRegistrosTabla3;

			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					INNER JOIN #temp tp
						ON ord.Sender_ID = tp.CodeOfReference
				WHERE ord.StatusOrderId IN (5, 22)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC
				OFFSET @SkipTabla3 ROWS FETCH NEXT @CantidadRegistrosTabla3 ROWS ONLY;
			END
			ELSE
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					LEFT JOIN DeliveryBackOffice.dbo.PointsByServiceLog PBSL WITH (NOLOCK)
						ON ord.Guide_Serie = PBSL.GuideSerie
						AND ord.Guide_Number = PBSL.GuideNumber
						AND PBSL.PointsConsumed > 0
						AND PBSL.PointsReceived = 0
				WHERE
					(
						ord.Sender_ID IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.OriginSenderId IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.IdCustomer = @idCustomer
					)
					AND ord.StatusOrderId IN (5, 22)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC
				OFFSET @SkipTabla3 ROWS FETCH NEXT @CantidadRegistrosTabla3 ROWS ONLY;
			END;

			RETURN;
        END;

    END;
    ELSE
    BEGIN
        IF (@Filter = -1)
        BEGIN
			SET NOCOUNT ON;

			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					INNER JOIN #temp tp
						ON ord.Sender_ID = tp.CodeOfReference
				WHERE CONVERT(DATE, ord.DateCreated) >= @StartDate AND CONVERT(DATE, ord.DateCreated) <= @EndDate
					AND ord.StatusOrderId <> IIF(@CancelGuides = 0, 7, 0)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC;
			END
			ELSE
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
				WHERE CONVERT(DATE, ord.DateCreated) >= @StartDate AND CONVERT(DATE, ord.DateCreated) <= @EndDate
					AND
					(
						ord.Sender_ID IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.OriginSenderId IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.IdCustomer = @idCustomer
					)
					AND ord.StatusOrderId <> IIF(@CancelGuides = 0, 7, 0)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC;
			END;

			RETURN;

        END;
        IF (@Filter = 1)
        BEGIN
			SET NOCOUNT ON;

			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					INNER JOIN #temp tp
						ON ord.Sender_ID = tp.CodeOfReference
				WHERE CONVERT(DATE, ord.DateCreated) >= @StartDate AND CONVERT(DATE, ord.DateCreated) <= @EndDate
					AND ord.StatusOrderId = 15
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC;
			END
			ELSE
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					LEFT JOIN DeliveryBackOffice.dbo.PointsByServiceLog PBSL WITH (NOLOCK)
						ON ord.Guide_Serie = PBSL.GuideSerie
						AND ord.Guide_Number = PBSL.GuideNumber
						AND PBSL.PointsConsumed > 0
						AND PBSL.PointsReceived = 0
				WHERE CONVERT(DATE, ord.DateCreated) >= @StartDate AND CONVERT(DATE, ord.DateCreated) <= @EndDate
					AND
					(
						ord.Sender_ID IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.OriginSenderId IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.IdCustomer = @idCustomer
					)
					AND ord.StatusOrderId = 15
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC;
			END;

			RETURN;

        END;
        IF (@Filter = 2)
        BEGIN
			SET NOCOUNT ON;

			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					INNER JOIN #temp tp
						ON ord.Sender_ID = tp.CodeOfReference
				WHERE CONVERT(DATE, ord.DateCreated) >= @StartDate AND CONVERT(DATE, ord.DateCreated) <= @EndDate
					AND ISNULL(ord.StatusOrderId, 15) NOT IN (15, 5, 7, 22)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC;
			END
			ELSE
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					LEFT JOIN DeliveryBackOffice.dbo.PointsByServiceLog PBSL WITH (NOLOCK)
						ON ord.Guide_Serie = PBSL.GuideSerie
						AND ord.Guide_Number = PBSL.GuideNumber
						AND PBSL.PointsConsumed > 0
						AND PBSL.PointsReceived = 0
				WHERE CONVERT(DATE, ord.DateCreated) >= @StartDate AND CONVERT(DATE, ord.DateCreated) <= @EndDate
					AND
					(
						ord.Sender_ID IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.OriginSenderId IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.IdCustomer = @idCustomer
					)
					AND ISNULL(ord.StatusOrderId, 15) NOT IN (15, 5, 7, 22)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC;
			END;

			RETURN;
            

        END;
        IF (@Filter = 3)
        BEGIN
			SET NOCOUNT ON;

			IF(@TypeUser = 'CORPORATIVO')
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					INNER JOIN #temp tp
						ON ord.Sender_ID = tp.CodeOfReference
				WHERE CONVERT(DATE, ord.DateCreated) >= @StartDate AND CONVERT(DATE, ord.DateCreated) <= @EndDate
					AND ord.StatusOrderId IN (5, 22)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC;
			END
			ELSE
			BEGIN
				SELECT
					COUNT(1) OVER() AS Registros,
					ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') AS Guide,
					ISNULL((ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)), 0) AS Pieces,
					ISNULL(ord.Ticket_Number, '') AS Reference,
					ISNULL(ord.Receiver_Phone, '') AS ReceiverPhone,
					ISNULL(gb.IdBatch, 0) AS IdBatch,
					ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A') AS RequestDate,
					ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') AS Source,
					ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') AS Destiny,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Sender_FirstName, '')), ' ', UPPER(ISNULL(ord.Sender_LastName, ''))))), 'N/A'), ' ') AS NameofSender,
					CONCAT(ISNULL(LTRIM(RTRIM(CONCAT(UPPER(ISNULL(ord.Receiver_FirstName, '')), ' ', UPPER(ISNULL(ord.Receiver_LastName, ''))))), 'N/A'), ' ') AS NameReceiver,
					LEFT(UPPER(ISNULL(ord.Sender_Address, 'N/A')), 30) AS AddresofSender,
					CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 'true' ELSE 'false' END AS Impersonate,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A') AS DateRecoleccion,
					ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') AS DateProgramadaEntrega,
					ISNULL(CCC.Symbol, '') AS CurrencySymbol,
					CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) AS PrecioServicio,
					CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1) AS CollectOnDelivery,
					CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) AS ShippmentComplete,
					COALESCE(sto.StatusOrderId, 0) AS IdStatus,
					ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') AS Status,
					IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
						'PENDIENTE',
						ISNULL(CONVERT(VARCHAR,
							CASE
								WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN 'PUNTOS'
								WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
								WHEN paydord.TypeofInOutMoneyId = 8 THEN UPPER('credito')
								ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END
							END),
						'N/A')) AS WayToPay,
					ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') AS TimePayment,
					ISNULL(CONVERT(VARCHAR, cattime.TimePlaName), '') AS TimePaymentDescription,
					ISNULL(CONVERT(VARCHAR,
						CASE
							WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN UPPER('Pago con puntos forza')
							WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
							WHEN paydord.TypeofInOutMoneyId = 6 THEN UPPER('tarjeta')
							ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
						END),
					'N/A') AS TypePayment,
					ISNULL(CONVERT(VARCHAR, CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') AS CollectDelivery,
					ISNULL(CAST(ord.TypeService AS VARCHAR), '') AS TypeService
				FROM dbo.DeliveryOrder ord WITH (NOLOCK)
					INNER JOIN dbo.StatusOrder sto WITH (NOLOCK)
						ON sto.StatusOrderId = ord.StatusOrderId
					LEFT JOIN dbo.DeliveryOrderPaymentDetail paydord WITH (NOLOCK)
						ON ord.Guide_Serie = paydord.GuideSerie
						AND ord.Guide_Number = paydord.GuideNumber
					LEFT JOIN dbo.CatPaymentType catpay WITH (NOLOCK)
						ON catpay.PayTypeId = paydord.PayTypeId
					LEFT JOIN dbo.CatPaymentTime cattime WITH (NOLOCK)
						ON cattime.TimePlaId = paydord.TimePlaId
					LEFT JOIN dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
						ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
					LEFT JOIN dbo.Township twn WITH (NOLOCK)
						ON twn.IdTownship = ord.SenderIdTownship
					LEFT JOIN dbo.Province pr WITH (NOLOCK)
						ON pr.IdProvince = twn.IdProvince
					LEFT JOIN dbo.Township twd WITH (NOLOCK)
						ON twd.IdTownship = ord.ReceiverIdTownship
					LEFT JOIN dbo.Province prd WITH (NOLOCK)
						ON prd.IdProvince = twd.IdProvince
					LEFT JOIN dbo.Cost C WITH (NOLOCK)
						ON ord.Guide_Serie = C.GuideSerie
						AND ord.Guide_Number = C.GuideNumber
					LEFT JOIN dbo.CatCurrencyCOD CCC WITH (NOLOCK)
						ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
					LEFT JOIN DeliveryBackOffice.dbo.GuideBatch gb WITH (NOLOCK)
						ON gb.GuideSeries = ord.Guide_Serie
						AND gb.GuideNumber = ord.Guide_Number
						AND gb.RowStatus = 1
					LEFT JOIN DeliveryBackOffice.dbo.PointsByServiceLog PBSL WITH (NOLOCK)
						ON ord.Guide_Serie = PBSL.GuideSerie
						AND ord.Guide_Number = PBSL.GuideNumber
						AND PBSL.PointsConsumed > 0
						AND PBSL.PointsReceived = 0
				WHERE CONVERT(DATE, ord.DateCreated) >= @StartDate AND CONVERT(DATE, ord.DateCreated) <= @EndDate
					AND
					(
						ord.Sender_ID IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.OriginSenderId IN (SELECT tp.CodeOfReference FROM #temp tp)
						OR ord.IdCustomer = @idCustomer
					)
					AND ord.StatusOrderId IN (5, 22)
				ORDER BY ord.Guide_Serie DESC, ord.Guide_Number DESC;
			END;

			RETURN;
        END;

    END;

END;