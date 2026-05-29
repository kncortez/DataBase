

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-17>
-- Description:	<Devuelve el listado de GUIAS asiganadas a una cuenta>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-22>
-- Description:	< Mejora para que clientes corporativos solo se muestren registros por punto y no en general >
-- =============================================
-- =============================================
-- Author:		<Cristian, Suazo>
-- Create date: <2024-06-26>
-- Description:	< Se muestra el simbolo de la moneda origen si es GT Q y si es HN L >
-- =============================================
-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <2025-04-03>
-- Description:	< Se modifico moneda para soportar multipaís.>
-- =============================================
-- =============================================
-- Author:		<José Chuy>
-- Create date: <2025-12-10>
-- Description:	<Devuelve el listado de GUIAS asiganadas a una cuenta>
-- Optimización - Diciembre 2025
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_services_NEW]
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
    SET NOCOUNT ON;
    SET ARITHABORT OFF;

    -- =========================================
    -- 1. VARIABLES Y DATOS INICIALES
    -- =========================================
    DECLARE @IdUser BIGINT = (
        SELECT TOP 1 TknIdUser 
        FROM TokenLog WITH(NOLOCK) 
        WHERE TknIdToken = @Token
    );
    
    DECLARE @idCustomer INT = (
        SELECT TOP 1 IdCustomer 
        FROM Account WITH(NOLOCK) 
        WHERE AccIdAccount = @IdAccount
    );

    -- Determinar tipo de usuario una sola vez
    DECLARE @TypeUser NVARCHAR(20) = (
        SELECT TOP 1 ctp.Description
        FROM TokenLog tl WITH(NOLOCK)
        INNER JOIN RolByUserByAccount bya WITH(NOLOCK) ON bya.RuaIdUser = tl.TknIdUser
        INNER JOIN Account acc WITH(NOLOCK) ON acc.AccIdAccount = bya.RuaIdAccount
        INNER JOIN Customer cs WITH(NOLOCK) ON cs.IdCustomer = acc.IdCustomer
        INNER JOIN CustomerType ctp WITH(NOLOCK) ON ctp.IdCustomerType = cs.IdCustomerType
        WHERE tl.TknIdToken = @Token
    );

    -- =========================================
    -- 2. CREAR TEMP TABLE CON INDICES
    -- =========================================
    IF OBJECT_ID('tempdb.dbo.#temp', 'U') IS NOT NULL
        DROP TABLE #temp;

    CREATE TABLE #temp (
        CodeOfReference INT NOT NULL PRIMARY KEY CLUSTERED
    );

    INSERT INTO #temp (CodeOfReference)
    SELECT DISTINCT ua.CodeOfReference
    FROM RolByUserByAccount rua WITH(NOLOCK)
    INNER JOIN UserAddress ua WITH(NOLOCK) ON ua.UadIdAccount = rua.RuaIdAccount
    WHERE rua.RuaIdAccount = @IdAccount
        AND rua.RuaIdUser = @IdUser
        AND rua.RuaRowStatus = 1
        AND ua.CodeOfReference IS NOT NULL
    UNION
    SELECT DISTINCT vpc.CodeOfReference
    FROM VisitPointByUser vpu WITH(NOLOCK)
    INNER JOIN VisitPointClient vpc WITH(NOLOCK) ON vpu.IdVisitPointClient = vpc.IdVisitPointClient
    WHERE vpu.RegisterUserID = @IdUser;

    -- =========================================
    -- 3. CONSTRUCCIÓN DE WHERE DINÁMICO
    -- =========================================
    DECLARE @WhereClause NVARCHAR(MAX) = '';
    DECLARE @IsCorporativo BIT = CASE WHEN @TypeUser = 'CORPORATIVO' THEN 1 ELSE 0 END;

    -- Configurar WHERE según el filtro
    IF @Filter = -1
    BEGIN
        IF @IsCorporativo = 1
            SET @WhereClause = 'ord.Sender_ID IN (SELECT CodeOfReference FROM #temp)';
        ELSE
            SET @WhereClause = '(ord.Sender_ID IN (SELECT CodeOfReference FROM #temp) 
                               OR ord.OriginSenderId IN (SELECT CodeOfReference FROM #temp) 
                               OR ord.IdCustomer = @idCustomer)';
        
        IF @CancelGuides = 0
            SET @WhereClause = @WhereClause + ' AND ISNULL(ord.StatusOrderId, 15) != 7';
        ELSE
            SET @WhereClause = @WhereClause + ' AND ord.StatusOrderId IS NOT NULL';
    END
    ELSE IF @Filter = 1
    BEGIN
        IF @IsCorporativo = 1
            SET @WhereClause = 'ord.StatusOrderId = 15 AND ord.Sender_ID IN (SELECT CodeOfReference FROM #temp)';
        ELSE
            SET @WhereClause = 'ord.StatusOrderId = 15 AND (ord.Sender_ID IN (SELECT CodeOfReference FROM #temp) 
                               OR ord.OriginSenderId IN (SELECT CodeOfReference FROM #temp) 
                               OR ord.IdCustomer = @idCustomer)';
    END
    ELSE IF @Filter = 2
    BEGIN
        IF @IsCorporativo = 1
            SET @WhereClause = 'ISNULL(ord.StatusOrderId, 15) NOT IN (15, 5, 7, 22) 
                               AND ord.Sender_ID IN (SELECT CodeOfReference FROM #temp)';
        ELSE
            SET @WhereClause = 'ISNULL(ord.StatusOrderId, 15) NOT IN (15, 5, 7, 22) 
                               AND (ord.Sender_ID IN (SELECT CodeOfReference FROM #temp) 
                               OR ord.OriginSenderId IN (SELECT CodeOfReference FROM #temp) 
                               OR ord.IdCustomer = @idCustomer)';
    END
    ELSE IF @Filter = 3
    BEGIN
        IF @IsCorporativo = 1
            SET @WhereClause = 'ord.StatusOrderId IN (5, 22) 
                               AND ord.Sender_ID IN (SELECT CodeOfReference FROM #temp)';
        ELSE
            SET @WhereClause = 'ord.StatusOrderId IN (5, 22) 
                               AND (ord.Sender_ID IN (SELECT CodeOfReference FROM #temp) 
                               OR ord.OriginSenderId IN (SELECT CodeOfReference FROM #temp) 
                               OR ord.IdCustomer = @idCustomer)';
    END;

    -- =========================================
    -- 4. QUERY PRINCIPAL CON CTE Y JSON NATIVO
    -- =========================================
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @RegistrosPerPage INT = 10;
    DECLARE @Offset BIGINT = @Pagina * @RegistrosPerPage;

    -- Agregar filtro de fechas si aplica
    DECLARE @DateFilter NVARCHAR(200) = '';
    IF @Pagina = -1 AND @StartDate IS NOT NULL AND @EndDate IS NOT NULL
        SET @DateFilter = ' AND CONVERT(DATE, ord.DateCreated) BETWEEN @StartDate AND @EndDate';

    SET @SQL = N'
    ;WITH OrderData AS (
        SELECT 
            CONCAT(ord.Guide_Serie, ord.Guide_Number) AS Guide,
            ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0) AS Pieces,
            ISNULL(ord.Ticket_Number, '''') AS Reference,
            ISNULL(ord.Receiver_Phone, '''') AS ReceiverPhone,
            ISNULL(gb.IdBatch, '''') AS IdBatch,
            ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), ''N/A'') AS RequestDate,
            ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), ''N/A'') AS Source,
            ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), ''N/A'') AS Destiny,
            ISNULL(
                UPPER(ISNULL(ord.Sender_FirstName, '''')) + '' '' + UPPER(ISNULL(ord.Sender_LastName, '''')),
                ''N/A''
            ) AS NameofSender,
            ISNULL(
                UPPER(ISNULL(ord.Receiver_FirstName, ''N/A'')) + '' '' + UPPER(ISNULL(ord.Receiver_LastName, '''')),
                ''N/A''
            ) AS NameReceiver,
            ISNULL(dbo.fnt_String_Escape(UPPER(ISNULL(ord.Sender_Address, ''N/A'')), ''json''), ''N/A'') AS AddresofSender,
            CASE WHEN ord.Sender_ID <> ISNULL(ord.OriginSenderId, 0) THEN 1 ELSE 0 END AS Impersonate,
            ISNULL(CONVERT(VARCHAR, ord.Preparation_Date, 20), ''N/A'') AS DateRecoleccion,
            ISNULL(CONVERT(VARCHAR, ord.Shipping_Date, 20), ''N/A'') AS DateProgramadaEntrega,
            ISNULL(CCC.Symbol, '''') AS CurrencySymbol,
            CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, ''0'') AS MONEY), 1) AS PrecioServicio,
            CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, ''0'') AS MONEY), 1) AS CollectOnDelivery,
            COALESCE(paydord.ShipmentCompleted, 0) AS ShippmentComplete,
            COALESCE(sto.StatusOrderId, 0) AS IdStatus,
            ISNULL(sto.OrderDescription, ''N/A'') AS Status,
            CASE 
                WHEN ISNULL(paydord.ShipmentCompleted, 0) = 0 THEN ''PENDIENTE''
                WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN ''PUNTOS''
                WHEN paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
                WHEN paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
                WHEN paydord.TypeofInOutMoneyId = 8 THEN ''CREDITO''
                WHEN ord.IsCollect = 1 THEN ''COLLECT''
                ELSE ''CONTADO''
            END AS WayToPay,
            ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '''') AS TimePayment,
            ISNULL((
                SELECT TimePlaName 
                FROM CatPaymentTime TMD WITH(NOLOCK) 
                WHERE paydord.TimePlaId = TMD.TimePlaId
            ), '''') AS TimePaymentDescription,
            CASE 
                WHEN PBSL.IdPointsByServiceLog IS NOT NULL THEN ''PAGO CON PUNTOS FORZA''
                WHEN paydord.TypeofInOutMoneyId IN (1,2,3,4) THEN UPPER(ctgmon.tio_pk_name)
                WHEN paydord.TypeofInOutMoneyId = 6 THEN ''TARJETA''
                WHEN ord.IsCollect = 1 THEN ''EFECTIVO''
                ELSE ''TARJETA''
            END AS TypePayment,
            CASE WHEN ord.IsCollect = 1 THEN ''SI'' ELSE ''NO'' END AS CollectDelivery,
            ISNULL(CAST(ord.TypeService AS VARCHAR), '''') AS TypeService,
            ROW_NUMBER() OVER (ORDER BY ord.Guide_Number DESC) AS RowNum
        FROM DeliveryOrder ord WITH(NOLOCK)
        INNER JOIN StatusOrder sto WITH(NOLOCK) ON sto.StatusOrderId = ord.StatusOrderId
        LEFT JOIN DeliveryOrderPaymentDetail paydord WITH(NOLOCK) 
            ON ord.Guide_Serie = paydord.GuideSerie AND ord.Guide_Number = paydord.GuideNumber
        LEFT JOIN CatPaymentType catpay WITH(NOLOCK) ON catpay.PayTypeId = paydord.PayTypeId
        LEFT JOIN ctgTypeOfInOutOfMoney ctgmon WITH(NOLOCK) ON ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId
        LEFT JOIN Township twn WITH(NOLOCK) ON twn.IdTownship = ord.SenderIdTownship
        LEFT JOIN Province pr WITH(NOLOCK) ON pr.IdProvince = twn.IdProvince
        LEFT JOIN Township twd WITH(NOLOCK) ON twd.IdTownship = ord.ReceiverIdTownship
        LEFT JOIN Province prd WITH(NOLOCK) ON prd.IdProvince = twd.IdProvince
        LEFT JOIN Cost C WITH(NOLOCK) ON ord.Guide_Serie = C.GuideSerie AND ord.Guide_Number = C.GuideNumber
        LEFT JOIN CatCurrencyCOD CCC WITH(NOLOCK) ON C.ShippingCurrency = CCC.IdCatCurrencyCOD
        LEFT JOIN GuideBatch gb WITH(NOLOCK) ON gb.GuideSeries = ord.Guide_Serie 
            AND gb.GuideNumber = ord.Guide_Number AND gb.RowStatus = 1
        LEFT JOIN PointsByServiceLog PBSL WITH(NOLOCK) ON ord.Guide_Serie = PBSL.GuideSerie 
            AND ord.Guide_Number = PBSL.GuideNumber 
            AND PBSL.PointsConsumed > 0 AND PBSL.PointsReceived = 0
        WHERE ' + @WhereClause + @DateFilter + '
    ),
    TotalCount AS (
        SELECT COUNT(*) AS Total FROM OrderData
    )
    SELECT 
        (SELECT Total FROM TotalCount) AS Registros,
        *
    FROM OrderData
    ' + CASE WHEN @Pagina > -1 THEN 'WHERE RowNum BETWEEN @Offset + 1 AND @Offset + @RegistrosPerPage' ELSE '' END + '
    ORDER BY RowNum
    FOR JSON PATH;';

    -- =========================================
    -- 5. EJECUTAR Y RETORNAR JSON
    -- =========================================
    DECLARE @Result NVARCHAR(MAX);
    
    EXEC sp_executesql @SQL, 
        N'@IdUser BIGINT, @idCustomer INT, @StartDate DATE, @EndDate DATE, @Offset BIGINT, @RegistrosPerPage INT',
        @IdUser = @IdUser,
        @idCustomer = @idCustomer,
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @Offset = @Offset,
        @RegistrosPerPage = @RegistrosPerPage;

    -- Si no hay resultados, retornar mensaje
    IF @Result IS NULL OR LEN(@Result) = 0
    BEGIN
        SELECT '[{"IdResult":500,"Message":"No se encontraron registros"}]' AS jsonResult;
    END
    ELSE
    BEGIN
        SELECT @Result AS jsonResult;
    END

    -- Limpiar
    IF OBJECT_ID('tempdb.dbo.#temp', 'U') IS NOT NULL
        DROP TABLE #temp;
END