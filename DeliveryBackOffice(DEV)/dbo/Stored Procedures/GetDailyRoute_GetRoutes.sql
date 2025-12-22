/****** Object:  StoredProcedure [dbo].[spws_get_daily_route]    Script Date: 10/3/2025 4:24:40 PM ******/

-- =============================================
-- Author:		<Eduardo Gonzalez>
-- Create date: <2025-11-12>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================
CREATE PROCEDURE [dbo].[GetDailyRoute_GetRoutes]
    @Token VARCHAR(200) = '',
    @IdCourier BIGINT,
    @DateRoute DATE
AS
BEGIN
    SET ANSI_NULLS ON
    SET QUOTED_IDENTIFIER ON

-- ============================ IDS de busqueda===============================
	DECLARE 
		@PickUpTypeId BIGINT,
		@DeliveryTypeId BIGINT,
		@ReturnTypeId BIGINT,
		@IdDeliveryOption BIGINT;

	WITH RecicleIDs AS (
		SELECT STSM.IdSubTypeServiceManagment AS id, STSM.Name AS idName
		FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH (NOLOCK)
		WHERE STSM.Name IN (N'Devolución', N'Entrega', N'Recolección')
		AND STSM.RowStatus = 1
		UNION ALL
		SELECT TOP 1 IdDeliveryOption AS id, Name AS idName
		FROM [DeliveryBackOffice].[dbo].[CatDeliveryOptions] WITH (NOLOCK)
		WHERE [Name] = 'Express Center'
	)
	SELECT
		@PickUpTypeId = MAX(CASE WHEN idName = 'Recolección' THEN id END),
		@DeliveryTypeId = MAX(CASE WHEN idName = 'Entrega' THEN id END),
		@ReturnTypeId = MAX(CASE WHEN idName = 'Devolución' THEN id END),
		@IdDeliveryOption = MAX(CASE WHEN idName = 'Express Center' THEN id END)
	FROM RecicleIDs;
	SELECT @PickUpTypeId AS id, 'Recolección' AS idName
	UNION
	SELECT @DeliveryTypeId AS id, 'Entrega' AS idName
	UNION 
	SELECT @ReturnTypeId AS id, 'Devolución' AS idName
	UNION
	SELECT @IdDeliveryOption AS id, 'Express Center' AS idName
-- =========================== FIN IDS ==========================================

-- ========================== DELIVERY PRICE INFO ===============================

     DECLARE @ConcatReturnGuides NVARCHAR(MAX)
   ;with Attemps as(
        SELECT  MAX(ID_DeliveryOrderBySettlement) ID_DeliveryOrderBySettlement,
				Guide_Serie,
				Guide_Number,
				ID_Courier
        FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] WITH (NOLOCK)
        WHERE	CAST(Date_Created AS DATE) = @DateRoute
			AND ID_Courier = @IdCourier
			AND Guide_Piece = 1
		GROUP BY
				Guide_Serie,
				Guide_Number,
				ID_Courier
   )
   SELECT
    @ConcatReturnGuides = STRING_AGG(CONVERT(NVARCHAR(MAX), CONCAT(DAT.Guide_Serie, DAT.Guide_Number)), ',')
    FROM Attemps                                                              DAT
	LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder]           DOR WITH (NOLOCK)
        ON DAT.Guide_Serie = DOR.Guide_Serie
        AND DAT.Guide_Number = DOR.Guide_Number
        AND DOR.IsLastMileReturn = 1
        AND DOR.StatusOrderId IN ( 4, 5, 12,  14, 20, 25, 45, 50 )
	LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]  DSD WITH (NOLOCK)
        ON DSD.Guide_Serie = DAT.Guide_Serie
        AND DSD.Guide_Number = DAT.Guide_Number
        AND DSD.RowStatus = 1
    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOS WITH (NOLOCK)
        ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
        AND DOS.ID_Courier = DAT.ID_Courier
    WHERE DAT.ID_Courier = @IdCourier
    
	DECLARE
    @_InGuides VARCHAR(MAX),
    @_InTime INT,
    @_IsReturn BIT
	set @_InGuides = @ConcatReturnGuides
	set @_InTime = 3
    DECLARE @InSequenceTime INT;
    DECLARE @TimeShortName VARCHAR(10);
    DECLARE @InCollectCOD BIT;
    DECLARE @MaxTime INT;
    DECLARE @MaxSequenceTime INT;
    DECLARE @MinTime INT;
    DECLARE @MinSequenceTime INT;
    DECLARE @CollectTime INT;
    DECLARE @CollectSequence INT;

SELECT
    @InSequenceTime   = ISNULL(cpt_in.TimeSequence, 0),
    @TimeShortName    = ISNULL(cpt_in.TimePlaAbrev, ''),
    @InCollectCOD     = ISNULL(cpt_in.CollectCOD, 0),

    @MaxTime          = ISNULL(cpt_max.TimePlaId, 1),
    @MaxSequenceTime  = ISNULL(cpt_max.TimeSequence, 0),

    @MinTime          = ISNULL(cpt_min.TimePlaId, 1),
    @MinSequenceTime  = ISNULL(cpt_min.TimeSequence, 0),

    @CollectTime      = ISNULL(cpt_dest.TimePlaId, 1),
    @CollectSequence  = ISNULL(cpt_dest.TimeSequence, 0)
FROM dbo.CatPaymentTime AS base WITH (NOLOCK)
CROSS APPLY (
    SELECT TOP 1 TimeSequence, TimePlaAbrev, CollectCOD
    FROM dbo.CatPaymentTime WITH (NOLOCK)
    WHERE TimePlaId = @_InTime
) AS cpt_in
CROSS APPLY (
    SELECT TOP 1 TimePlaId, TimeSequence
    FROM dbo.CatPaymentTime WITH (NOLOCK)
    ORDER BY TimeSequence DESC
) AS cpt_max
CROSS APPLY (
    SELECT TOP 1 TimePlaId, TimeSequence
    FROM dbo.CatPaymentTime WITH (NOLOCK)
    ORDER BY TimeSequence ASC
) AS cpt_min
CROSS APPLY (
    SELECT TOP 1 TimePlaId, TimeSequence
    FROM dbo.CatPaymentTime WITH (NOLOCK)
    WHERE TimePlaAbrev = 'DEST'
) AS cpt_dest;


;WITH listGuidesBrain AS (
    SELECT DISTINCT
        CAST(SUBSTRING(Item, 1, 2) AS NVARCHAR(50)) AS ItemSerie,
        CAST(SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, LEN(Item), CHARINDEX('-', Item) - 3)) AS INT) AS ItemNumber,
        CAST(SUBSTRING(Item, 1, 2) AS VARCHAR(50)) +
        CAST(SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, LEN(Item), CHARINDEX('-', Item) - 3)) AS VARCHAR(50)) AS GuideNumber
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@_InGuides, ',')
),CTE_Orders AS (
    SELECT DISTINCT
        ord.Guide_Serie       AS GuideSerie,
        ord.Guide_Number      AS GuideNumber,
        ord.IdCustomer,
        ord.Sender_Id,
        ord.SenderCountryId,
        ord.IsCollect,
        ord.PriceShippment    AS Price,
        ord.Collect_OnDelivery AS COD,
        ord.Collect_OnDelivery AS Collect_OnDelivery,
        cst.TotalAmountPaid   AS AmountPaid,
        cst.TotalAmountPaid   AS TotalAmountPaid,
        cst.CODAmount         AS CODPaid,
        cst.CODAmount         AS CODAmount,
        ccc.CodeISO           AS CurrencyPrice_CODCodeISO,
        ccc.Symbol            AS CurrencyPrice_CODSymbol,
        ccc.CodeISO           AS CurrencyPriceCodeISO,
        ccc.Symbol            AS CurrencyPriceSymbol
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] ord WITH (NOLOCK)
    LEFT JOIN [DeliveryBackOffice].[dbo].[Cost] cst WITH (NOLOCK)
        ON  cst.GuideSerie  = ord.Guide_Serie
        AND cst.GuideNumber = ord.Guide_Number
        AND cst.RowStatus = 1
    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryCurrency] de WITH (NOLOCK)
        ON  de.Currency_IdCountry = ISNULL(ord.SenderCountryId, 'GT')
        AND de.DefaultPerCountry = 1
    LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD] ccc WITH (NOLOCK)
        ON  ccc.IdCatCurrencyCOD = de.IdCurrencyCOD
)

SELECT 
    ord20.GuideSerie,
    ord20.GuideNumber,
    ord20.IsCollect,
    ord20.Price,
    ord20.COD,
    ord20.AmountPaid,
    ord20.CODPaid,
    ord20.CODAmount AS CODIsPaid,
    pyt.TimePlaId AS PaymentTime,
    tim.TimeSequence AS TimeSequence,
    inh.inv_certificationFEL AS FelNumber,
    inh.inv_certificationFEL AS IsPaid,
    cus.IdCustomer AS IsCustomer,
    cdp.ConditionOfPaymenDescription AS ConditionPayment,
    cdp.ConditionOfPaymenAbbreviation AS HaveCredit,
    @InCollectCOD AS CollectCOD,
    rh.ReturnRate AS ReturnRate,
    ord20.CurrencyPrice_CODCodeISO,
    ord20.CurrencyPrice_CODSymbol,
    ord20.CurrencyPriceCodeISO,
    ord20.CurrencyPriceSymbol,
	@_IsReturn as IsReturn, 
	@inSequenceTime as inSequenceTime,
	@timeShortName as timeShortName
into #TempDeliveryPriceInfo
FROM listGuidesBrain lg WITH (NOLOCK)
LEFT JOIN CTE_Orders ord20
    ON ord20.GuideSerie = lg.ItemSerie
   AND ord20.GuideNumber = lg.ItemNumber
LEFT JOIN dbo.DeliveryOrderPaymentDetail pyt WITH (NOLOCK)
    ON pyt.GuideSerie = lg.ItemSerie
   AND pyt.GuideNumber = lg.ItemNumber
LEFT JOIN dbo.invoiceDetail ind WITH (NOLOCK)
    ON ind.dti_fk_orderSerie = lg.ItemSerie
   AND ind.dti_fk_orderNumber = lg.ItemNumber
LEFT JOIN dbo.CatPaymentTime tim WITH (NOLOCK)
    ON tim.TimePlaId = pyt.TimePlaId
LEFT JOIN dbo.invoiceHeader inh WITH (NOLOCK)
    ON inh.inv_pk_id = ind.dti_fk_header
   AND inh.inv_invoiceOfCreditNote IS NULL
LEFT JOIN dbo.Customer cus WITH (NOLOCK)
    ON cus.IdCustomer = (
        SELECT TOP 1 ISNULL(ord20.IdCustomer, vpc.CustomerID)
        FROM dbo.VisitPointClient vpc WITH (NOLOCK)
        WHERE vpc.CodeOfReference = ord20.Sender_Id
    )
LEFT JOIN dbo.CatConditionOfPayment cdp WITH (NOLOCK)
    ON cdp.IdConditionOfPayment = cus.ConditionOfPaymentID
   AND cdp.IdConditionOfPayment > 1
LEFT JOIN dbo.RatebyCustomer rc WITH (NOLOCK)
    ON rc.RbcIdCustomer = cus.IdCustomer
   AND rc.RbcRowStatus = 'TRUE'
LEFT JOIN dbo.RatebyCustomer rcv WITH (NOLOCK)
    ON rcv.RbcIdCustomer = cus.IdCustomer
   AND rcv.RbcCodeOfReference = ord20.Sender_Id
   AND rcv.RbcRowStatus = 'true'
LEFT JOIN dbo.RateHeader rh WITH (NOLOCK)
    ON rh.RheId = ISNULL(rcv.RbcIdRate, rc.RbcIdRate)
LEFT JOIN dbo.RateHeader rhd WITH (NOLOCK)
    ON rhd.RheDefault = 'true'
   AND cdp.RowStatus = 1
WHERE ISNULL(rcv.RbcRowStatus, rc.RbcRowStatus) = 1
ORDER BY lg.ItemSerie, lg.ItemNumber

select distinct * from #TempDeliveryPriceInfo

-- =========================== FIN DELIVERY PRICE INFO ===================================

-- =========================== DELIVERY TABLE ============================================
;WITH CTE_DeliveryAttemp AS (
    SELECT
        MAX(ID_DeliveryOrderBySettlement) AS ID_DeliveryOrderBySettlement,
        Guide_Serie,
        Guide_Number,
        ID_Courier
    FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt] WITH (NOLOCK)
    WHERE CAST(Date_Created AS DATE) = @DateRoute
        AND ID_Courier = @IdCourier
        AND Guide_Piece = 1
    GROUP BY Guide_Serie, Guide_Number, ID_Courier
),
CTE_DeliveryAttemp_WithTransaction AS (
    SELECT
        DAT.*,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] d
                INNER JOIN [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] cctbc WITH (NOLOCK)
                    ON cctbc.OrderNumber = d.Guide_Serie + CONVERT(VARCHAR, d.Guide_Number)
                WHERE d.Guide_Serie = DAT.Guide_Serie
                  AND d.Guide_Number = DAT.Guide_Number AND cctbc.ReasonCode = '00'
            ) THEN 1
            ELSE 0
        END AS HasValidTransaction
    FROM CTE_DeliveryAttemp DAT
),
CTE_PiecesDryCold AS (
    SELECT
        DAT.Guide_Serie,
        DAT.Guide_Number,
        SUM(ISNULL(DOR.Pieces_Dry, 0)) AS TotalPiecesDry,
        SUM(ISNULL(DOR.Pieces_Cold, 0)) AS TotalPiecesCold
    FROM CTE_DeliveryAttemp DAT
    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DOR WITH (NOLOCK)
        ON DOR.Guide_Serie = DAT.Guide_Serie
        AND DOR.Guide_Number = DAT.Guide_Number
    GROUP BY DAT.Guide_Serie, DAT.Guide_Number
),
CTE_Photo AS (
    SELECT
        CodeOfReference,
        PathImage
    FROM (
        SELECT 
            VPC.CodeOfReference,
            vpi.PathImage,
            ROW_NUMBER() OVER (PARTITION BY VPC.CodeOfReference ORDER BY vpi.DateCreated DESC) AS rn
        FROM CTE_DeliveryAttemp DAT
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DOR WITH (NOLOCK)
            ON DOR.Guide_Serie = DAT.Guide_Serie
            AND DOR.Guide_Number = DAT.Guide_Number
        INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
            ON VPC.CodeOfReference = DOR.Sender_ID
        INNER JOIN [DeliveryBackOffice].[dbo].[ImagesByVisitPoint] vpi WITH (NOLOCK)
            ON vpi.CodeOfReference = VPC.CodeOfReference
    ) t
    WHERE rn = 1
)
,CTE_Pickup AS (
    SELECT
        DAT.Guide_Serie,
        DAT.Guide_Number,
        MAX(IIF(ISNULL(dp.TimePlaId, 0) = 3, ISNULL(sc.AmountPickup, 0), 0)) AS PickupAmount
    FROM CTE_DeliveryAttemp DAT
    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] dp WITH (NOLOCK)
        ON dp.GuideNumber = DAT.Guide_Number AND dp.GuideSerie = DAT.Guide_Serie
    LEFT JOIN [DeliveryBackOffice].[dbo].[SchedulePickup] sc WITH (NOLOCK)
        ON sc.SchedulePickupId = dp.IdHeaderRecolection
    GROUP BY DAT.Guide_Serie, DAT.Guide_Number
)

    SELECT
	'Delivery' AS ServiceType,
	VPC.CodeOfReference,
    DOR.IdDeliveryOption AS DeliveryOption, -- base
    DOR.IsLastMileReturn AS DeliveryOption_IsLastMileReturn, -- for DeliveryOption
	DOR.IsLastMileReturn,
	DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) AS Id,
	DOR.Ticket_Number,
	0 AS ServiceManagementId,
	DOR.Sender_FirstName AS Sender,
    DOR.Receiver_FirstName AS Sender_ReceiverFirstName,
    VPC.DescriptionOfClient AS Sender_AltClientName,

    VPC.Address AS Address, -- base
    kvp.KindOfVPName AS Address_KindOfVPName, -- for Address
    DOR.Sender_Address AS Address_Sender,     -- for Address
    DOR.Receiver_Address AS Address_Receiver, -- for Address
    VPr.Address AS Address_VPReceiver,        -- for Address

    kvpori.KindOfVPName as Address_KindOfVPName_Sender,
    VPr.DescriptionOfClient as DescriptionOfClient_Receiver,
	DOR.Sender_Phone,
	DOR.Receiver_Phone AS Phone,
    DOR.Receiver_Alternant_Phone, -- for Phone (nuevo agregado)
	CPS.Value AS SenderAreaCode, -- for Sender_Phone (nuevo agregado desde tabla ConfigParams)
	CPR.Value AS ReceiverAreaCode, -- for Phone (nuevo agregado desde tabla ConfigParams)
    PDC.TotalPiecesDry AS PiecesDry,
    PDC.TotalPiecesCold AS PiecesCold,
	'' AS ScheduleStart,
	'' AS ScheduleEnd,
	Photo.PathImage AS Photo,
	isnull(DOR.Receiver_Lat, '0') AS Latitude,
	isnull(DOR.Receiver_Lng, '0') AS Longitude,
	VPC.Accuracy AS Precision,
	DOR.PriceShippment AS Price_COD,

	-- Price reemplazado
    DOR.PriceShippment AS Price, -- base
    DOR.IdDeliveryOption AS Price_IdDeliveryOption,         -- for Price
    kvp.KindOfVPName AS Price_KindOfVPName,                 -- for Price
    DOR.IsLastMileReturn AS Price_IsLastMileReturn,         -- for Price
    DOR.IsCollect AS Price_IsCollect,                       -- for Price
    DAT.HasValidTransaction AS Price_HasValidTransaction,   -- for Price

	Pick.PickupAmount as Pickup,
	DOR.Receiver_FirstName AS CustomerName,
	DOR.Receiver_Alternant_FullName AS AlterName,
    DFG.Latitude AS DFG_Latitude,
    DFG.Longitude AS DFG_Longitude,
    EPS.Latitude AS EPS_Latitude,
    EPS.Longitude AS EPS_Longitude,
    VPC.Longitude AS VPC_Longitude,
    VPr.Latitude AS VPr_Latitude,
	ISNULL(CUS.NumImgEvidence, 1) AS NumImageEvidence,
	DOR.StatusOrderId AS Status,
	HP.HighPriority AS HighPriority,
	'' AS Alerts,
	NULL AS CurrencyPrice_CodeISO,
	NULL AS CurrencyPrice_CODSymbol,
	NULL AS CurrencyPriceCodeISO,
	NULL AS CurrencyPriceSymbol,
	kvp.IdKindOfVPClient AS FlagEXP,
	DOR.IndicationsToSendDestination
FROM CTE_DeliveryAttemp_WithTransaction DAT
	INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DOR WITH (NOLOCK)
		ON DOR.Guide_Serie = DAT.Guide_Serie
		AND DOR.Guide_Number = DAT.Guide_Number
	INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
		ON DSD.Guide_Serie = DAT.Guide_Serie
		AND DSD.Guide_Number = DAT.Guide_Number
	INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOS WITH (NOLOCK)
		ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
		AND DOS.ID_Courier = DAT.ID_Courier
	LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
		ON VPC.CodeOfReference = DOR.Sender_ID
	LEFT JOIN [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
		ON DOR.Guide_Serie = C.GuideSerie
		AND DOR.Guide_Number = C.GuideNumber
	LEFT JOIN
	(
		SELECT
			EPSA.GuideSerie,
			EPSA.GuideNumber,
			EPS.Latitude,
			EPS.Longitude
		FROM DeliveryBackOffice.dbo.ExtPlatformService EPS WITH (NOLOCK)
		INNER JOIN
		(
			SELECT
				EPSRWG.GuideSerie,
				EPSRWG.GuideNumber,
				MAX(EPS.IdService) AS LastService
			FROM DeliveryBackOffice.dbo.ExtPlatServiceRelationshipWithGuide EPSRWG WITH (NOLOCK)
			LEFT JOIN DeliveryBackOffice.dbo.ExtPlatformService EPS WITH (NOLOCK)
				ON EPSRWG.ExtPlatServiceId = EPS.IdExtPlatformService
			GROUP BY EPSRWG.GuideSerie, EPSRWG.GuideNumber
		) EPSA
			ON EPS.IdService = EPSA.LastService
		WHERE CAST(EPS.EstimatedTimeArrival AS DATE) = CAST(@DateRoute AS DATE)
	) EPS
		ON DAT.Guide_Serie = EPS.GuideSerie
		AND DAT.Guide_Number = EPS.GuideNumber
	LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPr WITH (NOLOCK)
		ON VPr.CodeOfReference = DOR.Receiver_ID
	LEFT JOIN [DeliveryBackOffice].[dbo].[KindOfVPClient] kvpori WITH (NOLOCK)
		ON kvpori.IdKindOfVPClient = VPC.IdKindOfVPClient
	LEFT JOIN [DeliveryBackOffice].[dbo].[KindOfVPClient] kvp WITH (NOLOCK)
		ON kvp.IdKindOfVPClient = VPr.IdKindOfVPClient
	OUTER APPLY
	(
		SELECT TOP 1 vpi.PathImage
		FROM [DeliveryBackOffice].[dbo].[ImagesByVisitPoint] vpi WITH (NOLOCK)
		WHERE vpi.CodeOfReference = VPC.CodeOfReference
		ORDER BY DateCreated DESC
	) vpi
	OUTER APPLY
	(
		SELECT
			MAX(SDFG.Latitude) AS Latitude,
			MAX(SDFG.Longitude) AS Longitude
		FROM [DeliveryBackOffice].[dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
		WHERE DOR.Guide_Serie = SDFG.GuideSerie
		  AND DOR.Guide_Number = SDFG.GuideNumber
		  AND SDFG.IsDelivery = 1
		GROUP BY SDFG.GuideSerie, SDFG.GuideNumber
	) DFG
	LEFT JOIN [DeliveryBackOffice].[dbo].[ConfigParams] CPS WITH (NOLOCK)
		ON CPS.IdCountry = DOR.SenderCountryId
		AND CPS.Name = 'AreaCode'
	LEFT JOIN [DeliveryBackOffice].[dbo].[ConfigParams] CPR WITH (NOLOCK)
		ON CPR.IdCountry = DOR.ReceiverCountryId
		AND CPR.Name = 'AreaCode'
    LEFT JOIN CTE_PiecesDryCold PDC
    ON PDC.Guide_Serie = DOR.Guide_Serie AND PDC.Guide_Number = DOR.Guide_Number
    LEFT JOIN CTE_Photo Photo
    ON Photo.CodeOfReference = VPC.CodeOfReference
    LEFT JOIN CTE_Pickup Pick
    ON Pick.Guide_Serie = DOR.Guide_Serie AND Pick.Guide_Number = DOR.Guide_Number
LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] CUS WITH (NOLOCK)
    ON CUS.IdCustomer = DOR.IdCustomer
LEFT JOIN (
    SELECT
        doa.GuideSerie,
        doa.GuideNumber,
        doa.ServiceTypeId,
        IIF(COUNT(*) > 0, 1, 0) AS HighPriority
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] doa WITH (NOLOCK)
    WHERE doa.RowStatus = 1
      AND doa.ServiceTypeId IN (@ReturnTypeId, @DeliveryTypeId)
    GROUP BY doa.GuideSerie, doa.GuideNumber, doa.ServiceTypeId
) HP
    ON HP.GuideSerie = DOR.Guide_Serie
   AND HP.GuideNumber = DOR.Guide_Number
   AND HP.ServiceTypeId = IIF(DOR.IsLastMileReturn = 1, @ReturnTypeId, @DeliveryTypeId)
WHERE
	CAST(DSD.DateCreated AS DATE) = @DateRoute
	AND DSD.RowStatus = 1
	AND DOR.StatusOrderId IN (4, 5, 12, 14, 20, 25, 32, 45, 48, 50)
	AND DSD.RowStatus = 1

-- ===================================== FIN DELIVERY TABLE =================================

-- ===================================== PICK UP TABLE ======================================
SELECT
    'Pickup' AS [ServiceType],

    vpc.CodeOfReference,
    spk.SchedulePickupId AS [Id],
    sma.IdServiceManagement,
    cpt.TimePlaName AS [ServicePaymentTime],

    spk.SenderName,
    vpc.DescriptionOfClient,
    spk.AddressPickup,
    vpc.[Address],
    t.TownshipName,
    p.ProvinceName,
    vpc.Town,
    spk.TownshipId,
    vpc.Department,
    spk.SenderPhone,
    vpc.Phone,
    CP.Value,

    hp.HighPriority as HighPriority,

    filteredPieces.PiecesDry as Pieces_Dry,
    filteredPieces.PiecesCold as Pieces_Cold,

    spk.StartDate as ScheduleStart,
    spk.EndDate as ScheduleEnd,

    latestImage.PathImage as Photo,
    vpc.Latitude,
    vpc.Longitude,
    vpc.Accuracy as Precision,

    sma.ServiceStatusId as Status,

    de.IdCurrencyCOD,
    de.Currency_IdCountry,
    de.DefaultPerCountry,
    ce.ExchangeDate,
    ccc.CodeISO[CurrencyPriceCodeISO],
    ccc.Symbol[CurrencyPriceSymbol],
    ccc.CodeISO[PickupPriceCodeISO],
    ccc.Symbol[PickupPriceSymbol],

    ras.IdCurrierMan,
    ras.DateOfRoute,
    sma.SubTypeServiceManagmentId

FROM dbo.RouteAssigment ras WITH (NOLOCK)
INNER JOIN dbo.ServiceManagement sma WITH (NOLOCK)
    ON sma.IdPuRouteAssigment = ras.IdRouteAssigment
INNER JOIN dbo.SchedulePickup spk WITH (NOLOCK)
    ON spk.SchedulePickupId = sma.IdSchedulePickup
LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
    ON vpc.CodeOfReference = spk.SenderId
LEFT JOIN dbo.CatPaymentTime cpt WITH (NOLOCK)
    ON sma.CatPaymentTimeId = cpt.TimePlaId
LEFT JOIN dbo.Township t WITH (NOLOCK)
    ON spk.TownshipId = t.IdTownship
LEFT JOIN dbo.Province p WITH (NOLOCK)
    ON t.IdProvince = p.IdProvince
LEFT JOIN [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH (NOLOCK)
    ON CP.IdCountry = vpc.CountryId
    AND CP.[Name] = 'AreaCode'
LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryCurrency] de WITH (NOLOCK)
    ON de.Currency_IdCountry = vpc.CountryId
    AND de.DefaultPerCountry = 1
LEFT JOIN [DeliveryBackOffice].[dbo].[CurrencyExchangeRates] ce WITH (NOLOCK)
    ON ce.TargetCurrency = de.IdCurrencyCOD
    AND ce.ExchangeDate >= CAST(GETDATE() AS DATE)
    AND ce.ExchangeDate < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD] ccc WITH (NOLOCK)
    ON ccc.IdCatCurrencyCOD = de.IdCurrencyCOD
LEFT JOIN (
    SELECT
        pay.IdHeaderRecolection AS SchedulePickupId,
        PiecesDry = ISNULL(
            IIF(SUM(ISNULL(ord.Pieces_Dry, 0)) = 0,
                SUM(ISNULL(sc.QuantityOverDimensionedPackage, 0) + ISNULL(sc.QuantityRegularPackages, 0)),
                SUM(ISNULL(ord.Pieces_Dry, 0))
            ), 0),
        PiecesCold = ISNULL(SUM(ISNULL(ord.Pieces_Cold, 0)), 0)
    FROM dbo.DeliveryOrderPaymentDetail pay WITH (NOLOCK)
    LEFT JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
        ON ord.Guide_Serie = pay.GuideSerie
        AND ord.Guide_Number = pay.GuideNumber
    LEFT JOIN dbo.SchedulePickup sc WITH (NOLOCK)
        ON sc.SchedulePickupId = pay.IdHeaderRecolection
    GROUP BY pay.IdHeaderRecolection
) AS filteredPieces
    ON filteredPieces.SchedulePickupId = spk.SchedulePickupId
LEFT JOIN (
    SELECT
        VPC2.CodeOfReference,
        HighPriority =
            CASE WHEN COUNT(DOA2.GuideNumber) > 0 THEN 1 ELSE 0 END
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA2 WITH (NOLOCK)
    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO2 WITH (NOLOCK)
        ON DO2.Guide_Serie = DOA2.GuideSerie
        AND DO2.Guide_Number = DOA2.GuideNumber
    LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPC2 WITH (NOLOCK)
        ON VPC2.CodeOfReference = DO2.Sender_Id
    WHERE
        CAST(DOA2.DateCreated AS DATE) = @DateRoute
        AND DOA2.ServiceTypeId IN (@PickUpTypeId)
        AND DOA2.RowStatus = 1
        AND DOA2.ServiceManagementId IS NULL
    GROUP BY VPC2.CodeOfReference
) AS hp
    ON hp.CodeOfReference = vpc.CodeOfReference
LEFT JOIN (
    SELECT CodeOfReference, PathImage
    FROM (
        SELECT
            CodeOfReference,
            PathImage,
            ROW_NUMBER() OVER (PARTITION BY CodeOfReference ORDER BY DateCreated DESC) AS rn
        FROM dbo.ImagesByVisitPoint WITH (NOLOCK)
    ) AS ranked
    WHERE ranked.rn = 1
) latestImage
    ON latestImage.CodeOfReference = vpc.CodeOfReference

WHERE
    ras.IdCurrierMan = @IdCourier
    AND ras.DateOfRoute = @DateRoute
    AND ISNULL(sma.SubTypeServiceManagmentId, 1) = 1;

-- ===================================== FIN PICKUP TABLE =================================

-- ==================================== TMPALERT LIST TABLE ================================

	SELECT TAL.[ServiceManagementId],
		   TAL.[AlertTypeId],
		   TAL.[AlertDescription],
		   CONCAT(CONVERT(VARCHAR, TAL.[DateCreated], 24), ' - ', CONVERT(VARCHAR, TAL.[DateCreated], 103))[DateCreated]
	FROM(
		SELECT	DOA.[ServiceManagementId],
				DOA.AlertTypeId,
				DOA.AlertDescription,
				DOA.DateCreated
		FROM	[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] doa WITH (NOLOCK)
        WHERE   CONVERT( DATE, doa.DateCreated ) = @DateRoute
			AND DOA.RowStatus = 1
			AND DOA.ServiceManagementId IS NOT NULL
		UNION ALL
		SELECT  VPC.CodeOfReference	[ServiceManagementId],
				DOA.AlertTypeId,
				DOA.AlertDescription,
				DOA.DateCreated
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH (NOLOCK)
		LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH (NOLOCK)
			ON DO.Guide_Serie = DOA.GuideSerie
			AND DO.Guide_Number = DOA.GuideNumber
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
			ON VPC.CodeOfReference = DO.Sender_Id
		WHERE  doa.ServiceTypeId IN (@PickUpTypeId)
				AND CAST( doa.DateCreated AS DATE) = @DateRoute
				AND DOA.RowStatus = 1
				AND DOA.ServiceManagementId IS NULL
		UNION ALL
		SELECT	DOA.GuideNumber [ServiceManagementId],
				DOA.AlertTypeId,
				DOA.AlertDescription,
				DOA.DateCreated
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH (NOLOCK)
		LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH (NOLOCK)
			ON DO.Guide_Serie = DOA.GuideSerie
			AND DO.Guide_Number = DOA.GuideNumber
		WHERE  DOA.ServiceTypeId IN (@ReturnTypeId, @DeliveryTypeId)
		   AND CONVERT(DATE, DOA.DateCreated) = @DateRoute
		   AND DOA.RowStatus = 1
		   AND DOA.ServiceManagementId IS NULL
    ) AS TAL
	ORDER BY TAL.DateCreated DESC
-- ==================================== FIN TMPALERT LIST TABLE ============================
END