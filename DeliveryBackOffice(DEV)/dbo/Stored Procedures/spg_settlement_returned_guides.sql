

-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-11-24>
-- Description:	<Recupera detalle para generar manifiesto de liquidación (devoluciones)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_returned_guides]
		@IdManifest INT
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	    --Flujo nuevo devoluciones
    IF OBJECT_ID('tempdb.dbo.#GuideReturnService', 'U') IS NOT NULL
        DROP TABLE #GuideReturnService;

    CREATE TABLE #GuideReturnService
    (
        GuideSerie NVARCHAR(2),
        GuideNumber INT
    );
    CREATE NONCLUSTERED INDEX IDX_TMP_GuideReturnService_Guide ON #GuideReturnService (GuideSerie, GuideNumber);

    INSERT INTO #GuideReturnService
    (
        GuideSerie,
        GuideNumber
    )
    SELECT 
        DISTINCT
            do.Guide_Serie,
            do.Guide_Number
    FROM 
        [DeliveryBackOffice].[dbo].DeliveryOrder do WITH(NOLOCK)
    INNER JOIN 
        DeliverySettlementDetail dsd WITH(NOLOCK)
        ON 
            do.Guide_Serie = dsd.Guide_Serie 
            AND 
            do.Guide_Number = dsd.Guide_Number
            AND
            do.[IsLastMileReturn] = 1
            AND 
            dsd.ID_DeliveryOrderBySettlement = @IdManifest 
            AND 
            dsd.RowStatus = 1

    DECLARE @ConcatReturnGuides NVARCHAR(MAX) = (
        SELECT STUFF
        (
            (
                SELECT ',' + CONCAT(GuideSerie, GuideNumber)
                FROM #GuideReturnService
                FOR XML PATH('')
            ),
            1,
            1,
            ''
        )
    );

    DECLARE @TempReturnPrice AS TABLE
    (
        GuideSerie NVARCHAR(25) NULL,
        GuideNumber NVARCHAR(25) NULL,
        IsCollect NVARCHAR(25) NULL,
        Price DECIMAL(14, 2) NULL,
        COD DECIMAL(14, 2) NULL,
        AmountPaid DECIMAL(14, 2) NULL,
        CODPaid DECIMAL(14, 2) NULL,
        CODIsPaid DECIMAL(14, 2) NULL,
        PaymentTime INT NULL,
        TimeSequence INT NULL,
        FelNumber NVARCHAR(50) NULL,
        IsPaid INT NULL,
        IsCustomer INT NULL,
        ConditionPayment NVARCHAR(200) NULL,
        HaveCredit NVARCHAR(50) NULL,
        CollectCOD NVARCHAR(50) NULL,
        ReturnRate DECIMAL(14, 2) NULL,
        AmountToPay DECIMAL(14, 2) NULL,
        CODAmount DECIMAL(14, 2) NULL,
        ReturnRates DECIMAL(14, 2) NULL,
        INDEX IDX_VAR_GuideReturnService_Guide NONCLUSTERED(GuideSerie, GuideNumber)
    );

    INSERT INTO @TempReturnPrice
    (
        GuideSerie,
        GuideNumber,
        IsCollect,
        Price,
        COD,
        AmountPaid,
        CODPaid,
        CODIsPaid,
        PaymentTime,
        TimeSequence,
        FelNumber,
        IsPaid,
        IsCustomer,
        ConditionPayment,
        HaveCredit,
        CollectCOD,
        ReturnRate,
        AmountToPay,
        CODAmount,
        ReturnRates
    )
    EXEC [dbo].[spws_get_guide_pending_payment] @InGuides = @ConcatReturnGuides,        -- Guías
                                                @InTime = 3,                            -- Entrega
                                                @IsReturn = 1,                            -- Devolución
                                                @CodeApp = 'SIFDCECOM300720201459',        -- CodeApp
                                                @IdModule = 1,
                                                @Token = '';

    IF OBJECT_ID('tempdb.dbo.#GuideReturnService', 'U') IS NOT NULL
        DROP TABLE #GuideReturnService;

    --Fin flujo devoluciones

	DECLARE @temp TABLE (
		Guide_Code	NVARCHAR(MAX),
		Pieces_Cold INT,
		Pieces_Dry INT,
		Receiver_Fullname NVARCHAR(201),
		Receiver_Address NVARCHAR(600),
		Receiver_Zone NVARCHAR(100),
		Receiver_Town NVARCHAR(100),
		Receiver_Departament NVARCHAR(100),
		Preparation_Date NVARCHAR(50),
		Shipping_Date NVARCHAR(50),
		Max_Date NVARCHAR(50),
		Receiver_Phone NVARCHAR(100),
		Rack_Position NVARCHAR(MAX),
		Collect_on_Delivery DECIMAL(16,2)
	)

    -- tablix content
	INSERT INTO @temp
	SELECT
	do.Guide_Serie + ISNULL(CONVERT(NVARCHAR,do.Guide_Number),'') AS Guide_Code
	,(SELECT SUM(CAST([Cold] AS INT)) FROM DeliveryBackOffice.dbo.DeliveryAttempt WHERE Guide_Serie = do.Guide_Serie AND Guide_Number = do.Guide_Number AND ID_DeliveryOrderBySettlement = @IdManifest GROUP BY Guide_Serie, Guide_Number, ID_DeliveryOrderBySettlement) AS Pieces_Cold
	,(SELECT SUM(CAST([Dry] AS INT)) FROM DeliveryBackOffice.dbo.DeliveryAttempt WHERE Guide_Serie = do.Guide_Serie AND Guide_Number = do.Guide_Number AND ID_DeliveryOrderBySettlement = @IdManifest GROUP BY Guide_Serie, Guide_Number, ID_DeliveryOrderBySettlement) AS Pieces_Dry
	,(CASE WHEN [do].[IsLastMileReturn] = 1 THEN isnull(do.[Sender_FirstName],'') + ' ' + isnull(do.[Sender_LastName],'') ELSE isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') END) as Receiver_Fullname
	,(CASE WHEN [do].[IsLastMileReturn] = 1 THEN do.[Sender_Address] ELSE do.Receiver_Address END) AS Receiver_Address
	,CONVERT(nvarchar, ISNULL((CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Zone] ELSE do.Receiver_Zone END),0)) AS Receiver_Zone
	,(CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Town] ELSE do.Receiver_Town END) AS Receiver_Town
	,(CASE WHEN do.[IsLastMileReturn] = 1 THEN do.[Sender_Department] ELSE do.Receiver_Department END) AS  Receiver_Departament
	,CONVERT(VARCHAR, do.Preparation_Date, 103) + ' ' + CONVERT(VARCHAR(5), do.Preparation_Date, 108) AS Preparation_Date
	,CONVERT(VARCHAR, do.Shipping_Date, 103) AS Shipping_Date
	,ISNULL(CONVERT(VARCHAR, do.Delivery_Max_Date, 103),'') AS Max_Date
	,do.Receiver_Phone AS Receiver_Phone
	,(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)) AS Rack_Position
	--,Collect_OnDelivery
	,(CASE WHEN do.IsCollect = 'TRUE' THEN 
	isnull((CASE WHEN do.[IsLastMileReturn] = 1 THEN 0 ELSE do.Collect_OnDelivery END ),0)+isnull((CASE WHEN [do].[IsLastMileReturn] = 1 THEN [TRP].[AmountToPay] ELSE do.PriceShippment END),0)
	ELSE 
	isnull((CASE WHEN do.[IsLastMileReturn] = 1 THEN 0 ELSE do.Collect_OnDelivery END),0) 
	END
	) AS  Collect_OnDelivery
	FROM [DeliveryBackOffice].[dbo].DeliveryOrder do  WITH(NOLOCK) 
	INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd  WITH(NOLOCK)  ON dsd.Guide_Serie = do.Guide_Serie AND dsd.Guide_Number = do.Guide_Number AND dsd.ID_DeliveryOrderBySettlement = @IdManifest AND dsd.RowStatus = 1
	LEFT JOIN
    @TempReturnPrice TRP
    ON
        TRP.[GuideSerie] = do.[Guide_Serie]
        AND
        TRP.[GuideNumber] = do.[Guide_Number]
	WHERE do.Guide_Serie = (SELECT DISTINCT TOP 1 Guide_Serie FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] WHERE ID_DeliveryOrderBySettlement = @IdManifest)
	AND do.Guide_Number IN (SELECT Guide_Number FROM [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] WHERE ID_DeliveryOrderBySettlement = @IdManifest AND RowStatus = 1)
	AND dsd.Guide_Settlement = 1 -- guía liquidada en bodega
	AND dsd.Guide_Returned = 1  -- guía liquidada vía material devuelto
	AND dsd.Guide_Delivered = 0  -- guía liquidada vía comprobante de entrega

	SELECT * FROM @temp
	order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END