
-- =============================================
-- Author:		<Andre, Ruiz>
-- Create date: <2022-01-21>
-- Description:	<Recupera información para generar manifiesto de despacho tomando en cuenta las piezas escaneadas en la preparación>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2022-08-05>
-- Description:	< Corrección de datos e indice de tabla >
-- =============================================
-- Author:		<Cristian, Suazo>
-- Update date: <2024-06-18>
-- Description:	< Se agrega el pais destino de la guia >
-- =============================================
CREATE PROCEDURE [dbo].[GetDeliveryOrderSettlementDataUnderRoutePrepration]
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
		CurrencyPrice_CODCodeISO ,
	  	CurrencyPrice_CODSymbol  ,
	    CurrencyPriceCodeISO     ,
	    CurrencyPriceSymbol      ,
        AmountToPay,
        CODAmount,
        ReturnRates
    )
    EXEC [dbo].[spws_get_guide_pending_payment] @InGuides = @ConcatReturnGuides,		-- Guías
                                                @InTime = 3,							-- Entrega
                                                @IsReturn = 1,							-- Devolución
                                                @CodeApp = 'SIFDCECOM300720201459',		-- CodeApp
                                                @IdModule = 1,
                                                @Token = '';

	IF OBJECT_ID('tempdb.dbo.#GuideReturnService', 'U') IS NOT NULL
		DROP TABLE #GuideReturnService;

	--Fin flujo devoluciones

	DECLARE @temp TABLE (
		GuideOrder decimal(5,2),
		GuideETA TIME(7),
		Guide_Code	nvarchar(max),
		Pieces_Cold int,
		Pieces_Dry int,
		Receiver_Fullname nvarchar(201),
		Receiver_Address nvarchar(600),
		Receiver_Zone NVARCHAR(50),
		Receiver_Town nvarchar(100),
		Receiver_Departament nvarchar(100),
		Preparation_Date nvarchar(50),
		Shipping_Date nvarchar(50),
		Max_Date nvarchar(50),
		Receiver_Phone nvarchar(100),
		Rack_Position nvarchar(MAX),
		Price decimal(16,2),
		Collect_on_Delivery decimal(16,2),
		Total decimal(16,2),
		ReceiverCountry NVARCHAR(2)

	)

	INSERT INTO @temp
	SELECT
		dsd.GuideOrder
		,dsd.GuideETA AS GuideETA
		, do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') as Guide_Code
		,(
			do.Pieces_Cold
		) AS Pieces_Cold
		,(
			do.Pieces_Dry
		) as Pieces_Dry
		,(CASE WHEN [do].[IsLastMileReturn] = 1 THEN isnull(do.[Sender_FirstName],'') + ' ' + isnull(do.[Sender_LastName],'') ELSE isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') END) as Receiver_Fullname
		,(CASE WHEN [do].[IsLastMileReturn] = 1 THEN do.[Sender_Address] ELSE do.Receiver_Address END) AS Receiver_Address
		--,CONVERT(INT, ISNULL(do.Receiver_Zone,0)) AS Receiver_Zone
		,CONVERT(NVARCHAR,ISNULL(REPLACE(RTRIM((CASE WHEN [do].[IsLastMileReturn] = 1 THEN do.[Sender_Zone] ELSE do.Receiver_Zone END)),CHAR(160),''),0)) AS Receiver_Zone
		,(CASE WHEN [do].[IsLastMileReturn] = 1 THEN do.[Sender_Town] ELSE do.Receiver_Town END) AS Receiver_Town
		,(CASE WHEN [do].[IsLastMileReturn] = 1 THEN do.[Sender_Department] ELSE do.Receiver_Department END) AS  Receiver_Departament
		,CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as Preparation_Date
		,CONVERT(varchar, do.Shipping_Date, 103) as Shipping_Date
		,isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as Max_Date
		,do.Receiver_Phone as Receiver_Phone
		,(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)) as Rack_Position
		--,Collect_OnDelivery
		,ISNULL((CASE WHEN [do].[IsLastMileReturn] = 1 THEN TRP.[AmountToPay] ELSE (CASE WHEN do.IsCollect = 'TRUE' THEN do.PriceShippment ELSE 0 END) END), 0) Price
		,ISNULL((CASE WHEN [do].[IsLastMileReturn] = 1 THEN 0 ELSE do.Collect_OnDelivery END), 0) Collect_on_Delivery
		,(CASE WHEN do.IsCollect = 'TRUE' THEN 
		ISNULL((CASE WHEN [do].[IsLastMileReturn] = 1 THEN 0 ELSE do.Collect_OnDelivery END), 0) + ISNULL((CASE WHEN [do].[IsLastMileReturn] = 1 THEN TRP.[AmountToPay] ELSE (CASE WHEN do.IsCollect = 'TRUE' THEN do.PriceShippment ELSE 0 END) END),0)
		ELSE 
		ISNULL((CASE WHEN [do].[IsLastMileReturn] = 1 THEN 0 ELSE do.Collect_OnDelivery END), 0)
		END
		) AS  Total
		, do.ReceiverCountryId AS ReceiverCountry
	from 
		[DeliveryBackOffice].[dbo].DeliveryOrder do WITH(NOLOCK)
	INNER JOIN 
		DeliverySettlementDetail dsd WITH(NOLOCK)
		ON 
			do.Guide_Serie = dsd.Guide_Serie 
			AND 
			do.Guide_Number = dsd.Guide_Number
			AND 
			dsd.ID_DeliveryOrderBySettlement = @IdManifest 
			AND 
			dsd.RowStatus = 1
	LEFT JOIN
		@TempReturnPrice TRP
		ON
			TRP.[GuideSerie] = do.[Guide_Serie]
			AND
			TRP.[GuideNumber] = do.[Guide_Number]

	SELECT 
		GuideOrder
		,GuideETA
		,Guide_Code
		,Pieces_Cold
		,Pieces_Dry
		,Receiver_Fullname
		,Receiver_Address
		,Receiver_Zone
		,Receiver_Town
		,Receiver_Departament
		,Preparation_Date
		,Shipping_Date
		,Max_Date
		,Receiver_Phone
		,Rack_Position
		,Price
		,Collect_on_Delivery
		,Total
		,ReceiverCountry
	FROM 
		@temp tmp
	ORDER BY 
		COALESCE(GuideOrder,0) ASC
		,tmp.Receiver_Departament asc
		,tmp.Receiver_Town asc
		,tmp.Receiver_Zone asc
		,tmp.Receiver_Address asc

END
