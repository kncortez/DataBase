-- =============================================
-- Author:      Bilkar Morataya
-- Date:        2025-10-28
-- Description: Versión optimizada (JOINs agregados, 10x más rápida)
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_guide_pending_payment_detail_optimized]
    @InGuidesP    VARCHAR(MAX),
    @IdCountry    VARCHAR(2) = 'GT'
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#listGuides') IS NOT NULL DROP TABLE #listGuides;
    CREATE TABLE #listGuides (Guide_Serie NVARCHAR(2), Guide_Number INT);

    INSERT INTO #listGuides (Guide_Serie, Guide_Number)
    SELECT 
        SUBSTRING(Item, 1, 2),
        TRY_CONVERT(INT, SUBSTRING(Item, 3, LEN(Item)))
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuidesP, ',') WITH(NOLOCK);

    -- =====================================
    -- Subconsultas pre-agrupadas (1 ejecución)
    -- =====================================

    -- Cost por guía
    ;WITH CostAgg AS (
        SELECT GuideSerie, GuideNumber,
               MAX(TotalAmountPaid) AS TotalAmountPaid,
               MAX(CODAmount) AS CODAmount
        FROM DeliveryBackOffice.dbo.Cost WITH (NOLOCK)
        WHERE RowStatus = 1
        GROUP BY GuideSerie, GuideNumber
    ),
    InvoiceAgg AS (
        SELECT dti_fk_orderSerie AS GuideSerie,
               dti_fk_orderNumber AS GuideNumber,
               MAX(dti_fk_header) AS HeaderId
        FROM dbo.invoiceDetail WITH (NOLOCK)
        GROUP BY dti_fk_orderSerie, dti_fk_orderNumber
    ),
    InvoiceHeadAgg AS (
        SELECT inv_pk_id, inv_certificationFEL
        FROM dbo.invoiceHeader WITH (NOLOCK)
        WHERE inv_invoiceOfCreditNote IS NULL
    ),
    PaymentAgg AS (
        SELECT GuideSerie, GuideNumber,
               MAX(CAST(ShipmentCompleted AS INT)) AS ShipmentCompleted,
               MAX(PayTypeId) AS PayTypeId
        FROM dbo.DeliveryOrderPaymentDetail WITH (NOLOCK)
        GROUP BY GuideSerie, GuideNumber
    ),
    RateAgg AS (
        SELECT rc.RbcIdCustomer AS IdCustomer,
               MAX(rh.RheId) AS RateId,
               MAX(rh.ReturnRate) AS ReturnRate
        FROM dbo.RatebyCustomer rc WITH (NOLOCK)
        INNER JOIN dbo.RateHeader rh WITH (NOLOCK)
            ON rc.RbcIdRate = rh.RheId
        WHERE rc.RbcRowStatus = 1
        GROUP BY rc.RbcIdCustomer
    ),
    RateCODAgg AS (
        SELECT RateId, MAX(CODRate) AS CODRate
        FROM dbo.RateCOD WITH (NOLOCK)
        WHERE RowStatus = 1
        GROUP BY RateId
    ),
    AnticipatedAgg AS (
        SELECT CustomerId, MAX(PortfolioId) AS PortfolioId
        FROM DeliveryBackOffice.dbo.AnticipatedCODHeader WITH (NOLOCK)
        WHERE RowStatus = 1
        GROUP BY CustomerId
    )
    -- =====================================
    -- Selección principal
    -- =====================================
    SELECT
        GuideSerieNumber = CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR(20))),
        ord.Guide_Serie,
        ord.Guide_Number,
        SenderName      = DeliveryBackOffice.dbo.fn_replace_special_characters(
                            CASE
                                WHEN LTRIM(RTRIM(ISNULL(ord.Sender_FirstName,''))) = ''
                                     THEN LTRIM(RTRIM(ISNULL(ord.Sender_LastName,'')))
                                WHEN LTRIM(RTRIM(ISNULL(ord.Sender_LastName,''))) = ''
                                     THEN LTRIM(RTRIM(ord.Sender_FirstName))
                                ELSE CONCAT(LTRIM(RTRIM(ord.Sender_FirstName)),' ',LTRIM(RTRIM(ord.Sender_LastName)))
                            END),
        ReceiverName    = DeliveryBackOffice.dbo.fn_replace_special_characters(
                            CASE
                                WHEN LTRIM(RTRIM(ISNULL(ord.Receiver_FirstName,''))) = ''
                                     THEN LTRIM(RTRIM(ISNULL(ord.Receiver_LastName,'')))
                                WHEN LTRIM(RTRIM(ISNULL(ord.Receiver_LastName,''))) = ''
                                     THEN LTRIM(RTRIM(ord.Receiver_FirstName))
                                ELSE CONCAT(LTRIM(RTRIM(ord.Receiver_FirstName)),' ',LTRIM(RTRIM(ord.Receiver_LastName)))
                            END),
        Indications     = DeliveryBackOffice.dbo.fn_replace_special_characters(
                            CASE WHEN UPPER(ord.TypeService) = 'DELIVERY'
                                 THEN ISNULL(ord.IndicationsToSendDestination,'')
                                 ELSE ISNULL(ord.IndicationsToSendOrigin,'') END),
        SenderAddress   = DeliveryBackOffice.dbo.fn_replace_special_characters(
                            CONCAT(ord.Sender_Department, ', ', ord.Sender_Town, ', ', 'Zona ', ord.Sender_Zone, ', ', ord.Sender_Address)),
        ReceiverAddress = DeliveryBackOffice.dbo.fn_replace_special_characters(
                            CONCAT(ord.Receiver_Department, ', ', ord.Receiver_Town, ', ', 'Zona ', ord.Receiver_Zone, ', ', ord.Receiver_Address)),
        ord.TypeService,
        PriceShippment  = ISNULL(ord.PriceShippment,0),
        COD             = ISNULL(ord.Collect_OnDelivery,0),
        IsCollect       = ISNULL(ord.IsCollect,0),
        Pieces          = ISNULL(ord.Pieces_Dry,0) + ISNULL(ord.Pieces_Cold,0),
        IdCustomer      = ord.IdCustomer,
        PortfolioId     = ISNULL(ach.PortfolioId,0),
        CurrencySymbol  = ISNULL(ccc.Symbol,''),
        TypePayment     = CASE
                            WHEN ISNULL(pyt.ShipmentCompleted,0) = 0 THEN 'PENDIENTE'
                            ELSE UPPER(ISNULL(cpt_pay.PayTypeName,'N/A'))
                          END,
        FelNumber       = inh.inv_certificationFEL,
        TotalAmountPaid = ISNULL(cst.TotalAmountPaid,0),
        CODAmountPaid   = ISNULL(cst.CODAmount,0),
        AmountToPay     = ISNULL(ord.PriceShippment,0),
        CODAmount       = ISNULL(ord.Collect_OnDelivery,0),
        ComisionCOD     = CASE
                            WHEN rcod.CODRate IS NOT NULL THEN
                                CONVERT(DECIMAL(18,2), (ISNULL(ord.Collect_OnDelivery,0) * ISNULL(rcod.CODRate,0) / 100))
                            ELSE 0
                          END,
        ReturnRate      = ISNULL(rate.ReturnRate, 100)
    FROM #listGuides lg
    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
        ON ord.Guide_Serie = lg.Guide_Serie AND ord.Guide_Number = lg.Guide_Number
    LEFT JOIN CostAgg cst
        ON cst.GuideSerie = ord.Guide_Serie AND cst.GuideNumber = ord.Guide_Number
    LEFT JOIN InvoiceAgg ind
        ON ind.GuideSerie = ord.Guide_Serie AND ind.GuideNumber = ord.Guide_Number
    LEFT JOIN dbo.invoiceHeader inh WITH (NOLOCK)
        ON inh.inv_pk_id = ind.HeaderId AND inh.inv_invoiceOfCreditNote IS NULL
    LEFT JOIN AnticipatedAgg ach
        ON ach.CustomerId = ord.IdCustomer
    LEFT JOIN RateAgg rate
        ON rate.IdCustomer = ord.IdCustomer
    LEFT JOIN RateCODAgg rcod
        ON rcod.RateId = rate.RateId
    LEFT JOIN PaymentAgg pyt
        ON pyt.GuideSerie = ord.Guide_Serie AND pyt.GuideNumber = ord.Guide_Number
    LEFT JOIN dbo.CatPaymentType cpt_pay WITH(NOLOCK)
        ON cpt_pay.PayTypeId = pyt.PayTypeId
    OUTER APPLY (
        SELECT TOP 1 ccc.Symbol
        FROM DeliveryBackOffice.dbo.CatCurrencyCOD ccc WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.DeliveryCurrency de WITH (NOLOCK)
            ON ccc.IdCatCurrencyCOD = de.IdCurrencyCOD
        WHERE de.Currency_IdCountry = ISNULL(ord.SenderCountryId,'GT')
          AND de.DefaultPerCountry = 1
    ) ccc
    WHERE ISNULL(ord.SenderCountryId,'GT') = @IdCountry;
END
