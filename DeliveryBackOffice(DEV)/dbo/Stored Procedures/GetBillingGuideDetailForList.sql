-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-11-25>
-- Description: <Obtenemos la informacion de guias para facturarlas>
-- =============================================
CREATE PROCEDURE [dbo].[GetBillingGuideDetailForList]
(
 @BillingGuideTable TblBillingGuideDetail READONLY
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- Valores si membresia o suscripción fue aplicado
    DECLARE @BreakdownOfPayment AS TABLE
    (
        IdVisitPointClient INT,
        Guide_Serie        NVARCHAR(2),
        Guide_Number       INT,
        [Description]      VARCHAR(100) NULL,
        Amount             DECIMAL(18, 2) NULL,
        AmountCollect      DECIMAL(18, 2) NULL,
        AmountWeight       DECIMAL(18, 2) NULL,
        AmountSecure       DECIMAL(18, 2) NULL
    );

    -- Validar si la tabla temporal existe y eliminarla
    IF OBJECT_ID('tempdb..#TempDetailsMembership') IS NOT NULL
        DROP TABLE #TempDetailsMembership;

    -- Crear la tabla temporal
    CREATE TABLE #TempDetailsMembership (
        IdVisitPointClient   INT,
        Guide_Serie          NVARCHAR(2),
        Guide_Number         INT,
        AppliedMembership    INT DEFAULT 0,
        SalesPackageType     INT DEFAULT 0,
        IsFixedValueDiscount BIT,
        Amount               DECIMAL(18, 2),
        ValueType            NVARCHAR(50) DEFAULT N'',
        PromoValue           DECIMAL(5, 2) DEFAULT 0,
        DiscountType         NVARCHAR(10) DEFAULT N''
    );

    -- Validar si la tabla temporal existe y eliminarla
    IF OBJECT_ID('tempdb..#TempDetailsSubscription') IS NOT NULL
        DROP TABLE #TempDetailsSubscription;

    -- Crear la tabla temporal
    CREATE TABLE #TempDetailsSubscription (
        IdVisitPointClient   INT,
        Guide_Serie          NVARCHAR(2),
        Guide_Number         INT,
        AppliedSubscription  INT DEFAULT 0,
        SalesPackageType     INT DEFAULT 0,
        IsFixedValueDiscount BIT,
        Amount               DECIMAL(18, 2),
        ValueType            NVARCHAR(50) DEFAULT N'',
        PromoValue           DECIMAL(5, 2) DEFAULT 0,
        DiscountType         NVARCHAR(10) DEFAULT N''
    );

    DECLARE @GuideDetail AS TABLE
    (
        IdVisitPointClient INT,
        Guide_Serie        NVARCHAR(2),
        Guide_Number       INT,
        SAPCode NVARCHAR(50) NULL,
        Name NVARCHAR(100) NULL,
        Description NVARCHAR(100) NULL,
        Price DECIMAL(14, 2) NULL,
        Category VARCHAR(50) NULL,
        SendToInvoice BIT NULL
    );

    -- Validar si la tabla temporal existe y eliminarla
    IF OBJECT_ID('tempdb..#TempServiceDetails') IS NOT NULL
        DROP TABLE #TempServiceDetails;

    -- Crear la tabla temporal
    CREATE TABLE #TempGuidesDetails (
        IdVisitPointClient INT,
        Guide_Serie        NVARCHAR(2),
        Guide_Number       INT,
        IsCOD              BIT,
        TypeService        VARCHAR(3),
        CountryByGuide     NVARCHAR(2),
        Segment            VARCHAR(MAX),
        CostId             INT,
        IsLastMileReturn   INT,
        NameArticle        NVARCHAR(100),
        NameArticleWeight  NVARCHAR(100),
        NameArticleCollect NVARCHAR(100),
        DescriptionReturn  NVARCHAR(3000),
        AppliedCoupon      INT,
        NameArticleSecure  NVARCHAR(3000)
    );

    INSERT INTO #TempGuidesDetails
    SELECT bgd.IdVisitPointClient,
           bgd.GuideSerie,
           bgd.GuideNumber,
           (CASE 
                WHEN do.Collect_OnDelivery > 0 
                   THEN 1 
                ELSE 0 
            END) AS IsCOD,
           ISNULL(do.TypeService, 'STD') AS TypeService,
           SenderCountryId,
           ISNULL(fn_segm.segment,'LOC'),
           IdCost.valueCost,
           ISNULL(do.IsLastMileReturn,0) AS IsLastMileReturn,
           CASE
               WHEN ISNULL(do.TypeService, 'STD') = 'FDD'
                   THEN 'TARIFA DE ENVIO FRESH'
               WHEN ISNULL(do.TypeService, 'STD') = 'COD'
                    OR do.Collect_OnDelivery > 0 
                   THEN 'TARIFA DE ENVIO COD'
               ELSE 'TARIFA DE ENVIO ESTANDAR'
           END AS NameArticle,
           CASE
               WHEN ISNULL(do.TypeService, 'STD') = 'FDD'
                   THEN 'RECARGO POR PESO FRESH'
               WHEN ISNULL(do.TypeService, 'STD') = 'COD'
                    OR do.Collect_OnDelivery > 0 
                   THEN 'RECARGO POR PESO COD'
               ELSE 'RECARGO POR PESO ESTANDAR'
           END AS NameArticleWeight,
           CASE
               WHEN ISNULL(do.TypeService, 'STD') = 'FDD'
                   THEN 'TARIFA COLLECT FRESH'
               WHEN ISNULL(do.TypeService, 'STD') = 'COD'
                    OR do.Collect_OnDelivery > 0 
                   THEN 'TARIFA COLLECT COD'
               ELSE 'TARIFA COLLECT ESTANDAR'
           END AS NameArticleCollect,
           CASE
               WHEN ISNULL(do.IsLastMileReturn,0) = 1
                   THEN descReturn.descValor
               ELSE ''
           END AS descReturn,
           promoCupon.CouponId,
           'GARANTIA MERCANCIAS'
    FROM DeliveryOrder do WITH (NOLOCK)
         INNER JOIN @BillingGuideTable bgd
            ON do.Guide_Serie = bgd.GuideSerie
           AND do.Guide_Number = bgd.GuideNumber
         OUTER APPLY (
                      SELECT dbo.[fn_get_segment](do.Guide_Serie, do.Guide_Number) AS segment
                     ) fn_segm
         OUTER APPLY (
                      SELECT TOP 1
                             Co.IdCost valueCost
                        FROM [DeliveryBackOffice].[dbo].[Cost] Co WITH(NOLOCK)
                       WHERE co.GuideNumber = do.Guide_Number
                         AND co.GuideSerie = do.Guide_Serie
                       ORDER BY IdCost DESC
                     ) IdCost
         OUTER APPLY (
                     SELECT TOP 1 IIF
                            (
                                 [UD].[IdUndefinedDescriptions] = 1, 
                                 REPLACE([Description],'+++',CONCAT(do.Guide_Serie,do.Guide_Number,'. +++ ')),
                                 IIF
                                 (
                                      [UD].[IdUndefinedDescriptions] = 2,
                                      REPLACE([Description],'Q ##',CONCAT(do.Guide_Serie,do.Guide_Number,'. Q ##')),
                                      REPLACE([Description],'Q',CONCAT(do.Guide_Serie,do.Guide_Number,'. Q'))
                                 )
                            ) AS descValor
                       FROM [DeliveryBackOffice].[dbo].[UndefinedDescriptions] UD  WITH(NOLOCK) 
                      ) AS descReturn
             -- Busca cupón aplicado
         OUTER APPLY (
                       SELECT TOP 1
                              ISNULL(BOP.PromoCouponId, 0) AS CouponId
                         FROM [DeliveryBackOffice].[dbo].[BreakdownOfPayment] BOP WITH (NOLOCK)
                        WHERE BOP.IdCost = IdCost.valueCost
                          AND BOP.PromoCouponId IS NOT NULL
                     ) AS promoCupon

    INSERT INTO @BreakdownOfPayment
    SELECT tgd.IdVisitPointClient,
           tgd.Guide_Serie,
           tgd.Guide_Number,
           bdp.[Description],
           bdp.Amount,
           NULL,
           NULL,
           NULL
      FROM [DeliveryBackOffice].[dbo].[BreakdownOfPayment] bdp WITH (NOLOCK)
           INNER JOIN #TempGuidesDetails tgd WITH(NOLOCK)
                   ON bdp.IdCost = tgd.CostId

   ---APLLID CUPON

    -- Busca membresía aplicada
    INSERT INTO #TempDetailsMembership
    SELECT bgt.IdVisitPointClient,
           bgt.GuideSerie,
           bgt.GuideNumber,
           1 AS AppliedMembership,
           1 AS SalesPackageType,
           (
            CASE
                WHEN [MSL].[LogServiceNumber] <= [M].[MembershipMaxServiceFixedValue] THEN
                    1
                ELSE
                    0
             END
           ) AS IsFixedValueDiscount,
           (
            CASE
                WHEN [MSL].[LogServiceNumber] <= [M].[MembershipMaxServiceFixedValue] THEN
                    [MSL].[LogGuideNewValue]
                ELSE
                    [MSL].[LogGuideOriginalValue]
            END
           ) AS Amount,
           (CASE
                WHEN [MSL].[LogServiceNumber] <= [M].[MembershipMaxServiceFixedValue] THEN
                    'Porcentaje'
                ELSE
                    (
                        SELECT TOP 1
                               ISNULL(CVT.ValueTypeName, 'Porcentaje')
                        FROM [DeliveryBackOffice].[dbo].[MembershipDiscountRange] MDR WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[CatValueType] CVT WITH (NOLOCK)
                                ON MDR.ValueTypeId = CVT.IdCatValueType
                        WHERE MDR.MembershipId = [M].[IdMembership]
                              AND MSL.LogServiceNumber
                              BETWEEN MDR.DiscountLowServiceRange AND ISNULL(MDR.DiscountTopServiceRange, 1000000000)
                    )
                END
           ) AS ValueType,
           (CASE
                WHEN [MSL].[LogServiceNumber] <= [M].[MembershipMaxServiceFixedValue] THEN
                    0
                ELSE
                (
                    SELECT TOP 1
                           ISNULL(MDR.DiscountValue, 0)
                    FROM [DeliveryBackOffice].[dbo].[MembershipDiscountRange] MDR WITH (NOLOCK)
                    WHERE MDR.MembershipId = [M].[IdMembership]
                          AND MSL.LogServiceNumber
                          BETWEEN MDR.DiscountLowServiceRange AND ISNULL(MDR.DiscountTopServiceRange, 1000000000)
                )
            END) AS PromoValue,
           N'TOT' AS DiscountType
      FROM [dbo].[MembershipSubscriptionLog] MSL WITH (NOLOCK)
           INNER JOIN [dbo].[Membership] M
                 ON [MSL].[MembershipId] = [M].[IdMembership]
           INNER JOIN @BillingGuideTable bgt
                  ON bgt.GuideSerie = [MSL].[LogGuideSerie]
                 AND bgt.GuideNumber = [MSL].[LogGuideNumber]
     WHERE [MSL].[SubscriptionId] IS NULL
           AND [MSL].[RowStatus] = 1;

    -- Busca suscripción aplicada
    INSERT INTO #TempDetailsSubscription
    SELECT bgt.IdVisitPointClient,
           bgt.GuideSerie,
           bgt.GuideNumber,
           1 AS AppliedSubscription,
           2 AS SalesPackageType,
           (
            CASE
                WHEN [MSL].[LogServiceNumber] <= [S].[SubscriptionMaxServiceFixedValue] THEN
                    1
                ELSE
                    0
            END
           ) AS IsFixedValueDiscount,
           (CASE
                WHEN [MSL].[LogServiceNumber] <= [S].[SubscriptionMaxServiceFixedValue] THEN
                    [MSL].[LogGuideNewValue]
                ELSE
                    [MSL].[LogGuideOriginalValue]
            END
           ) AS Amount,
           (CASE
                WHEN [MSL].[LogServiceNumber] <= [S].[SubscriptionMaxServiceFixedValue] THEN
                    'Porcentaje'
                ELSE
                    (
                        SELECT TOP 1
                               ISNULL(CVT.ValueTypeName, 'Porcentaje')
                        FROM [DeliveryBackOffice].[dbo].[SubscriptionDiscountRange] SDR WITH (NOLOCK)
                            INNER JOIN [DeliveryBackOffice].[dbo].[CatValueType] CVT WITH (NOLOCK)
                                ON SDR.ValueTypeId = CVT.IdCatValueType
                        WHERE SDR.SubscriptionId = [S].[IdSubscription]
                              AND MSL.LogServiceNumber
                              BETWEEN SDR.DiscountLowServiceRange AND ISNULL(SDR.DiscountTopServiceRange, 1000000000)
                    )
             END) AS ValueType,
           (CASE
                WHEN [MSL].[LogServiceNumber] <= [S].[SubscriptionMaxServiceFixedValue] THEN
                    0
                ELSE
                    (
                     SELECT TOP 1
                            ISNULL(SDR.DiscountValue, 0)
                     FROM [DeliveryBackOffice].[dbo].[SubscriptionDiscountRange] SDR WITH (NOLOCK)
                     WHERE SDR.SubscriptionId = [S].[IdSubscription]
                           AND MSL.LogServiceNumber
                           BETWEEN SDR.DiscountLowServiceRange AND ISNULL(SDR.DiscountTopServiceRange, 1000000000)
                    )
            END) AS PromoValue,
            N'TOT' AS DiscountType
    FROM [dbo].[MembershipSubscriptionLog] MSL WITH (NOLOCK)
         INNER JOIN [dbo].[Subscription] S
             ON [MSL].[SubscriptionId] = [S].[IdSubscription]
         INNER JOIN @BillingGuideTable bgt
                ON bgt.GuideSerie = [MSL].[LogGuideSerie]
               AND bgt.GuideNumber = [MSL].[LogGuideNumber]
   WHERE [MSL].[SubscriptionId] IS NOT NULL
     AND [MSL].[RowStatus] = 1

    UPDATE dbop
       SET dbop.Amount = CASE 
                            WHEN tgd.AppliedCoupon > 0 THEN PromoC.OriginalAmount
                            ELSE amountPrice.PriceShippment
                        END
      FROM @BreakdownOfPayment dbop
           INNER JOIN #TempGuidesDetails tgd WITH(NOLOCK)
                 ON tgd.Guide_Serie = dbop.Guide_Serie
                 AND tgd.Guide_Number = dbop.Guide_Number
           LEFT JOIN [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
                            ON tgd.Guide_Serie = PromoC.GuideSerieDestination
                 AND tgd.Guide_Number = PromoC.GuideNumberDestination
           INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD WITH (NOLOCK)
                 ON PromoC.CatDiscountTypeId = CTD.IdCatTypeDiscount
           INNER JOIN [DeliveryBackOffice].[dbo].[CatValueType] CVT WITH (NOLOCK)
                 ON PromoC.CatValueTypeId = CVT.IdCatValueType
           LEFT JOIN #TempDetailsSubscription tds WITH(NOLOCK)
                 ON PromoC.GuideSerieDestination = tds.Guide_Serie
                 AND PromoC.GuideNumberDestination = tds.Guide_Number
           OUTER APPLY (
                        SELECT TOP 1
                               DO.PriceShippment
                          FROM [DeliveryBackOffice].[dbo].DeliveryOrder DO WITH (NOLOCK)
                         WHERE DO.Guide_Serie = tgd.Guide_Serie
                           AND DO.Guide_Number = tgd.Guide_Number
                       ) AS amountPrice

    UPDATE tds
       SET tds.DiscountType = CASE 
                                 WHEN tgd.AppliedCoupon > 0 THEN CTD.ShortName
                                 ELSE tds.DiscountType
                              END,
           tds.ValueType = CASE 
                              WHEN tgd.AppliedCoupon > 0 THEN CVT.ValueTypeName
                              ELSE tds.ValueType
                           END,
           tds.PromoValue = CASE 
                              WHEN tgd.AppliedCoupon > 0 THEN PromoC.CouponValue
                              ELSE tds.PromoValue
                           END
      FROM @BreakdownOfPayment dbop
           INNER JOIN #TempGuidesDetails tgd WITH(NOLOCK)
                 ON tgd.Guide_Serie = dbop.Guide_Serie
                 AND tgd.Guide_Number = dbop.Guide_Number
           LEFT JOIN [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
                            ON tgd.Guide_Serie = PromoC.GuideSerieDestination
                 AND tgd.Guide_Number = PromoC.GuideNumberDestination
           INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD WITH (NOLOCK)
                 ON PromoC.CatDiscountTypeId = CTD.IdCatTypeDiscount
           INNER JOIN [DeliveryBackOffice].[dbo].[CatValueType] CVT WITH (NOLOCK)
                 ON PromoC.CatValueTypeId = CVT.IdCatValueType
           LEFT JOIN #TempDetailsSubscription tds WITH(NOLOCK)
                 ON PromoC.GuideSerieDestination = tds.Guide_Serie
                 AND PromoC.GuideNumberDestination = tds.Guide_Number
           OUTER APPLY (
                        SELECT TOP 1
                               DO.PriceShippment
                          FROM [DeliveryBackOffice].[dbo].DeliveryOrder DO WITH (NOLOCK)
                         WHERE DO.Guide_Serie = tgd.Guide_Serie
                           AND DO.Guide_Number = tgd.Guide_Number
                       ) AS amountPrice

    UPDATE dbop
       SET dbop.Amount = CASE 
                            WHEN tgd.AppliedCoupon > 0 THEN PromoC.OriginalAmount
                            ELSE amountPrice.PriceShippment
                        END
      FROM @BreakdownOfPayment dbop
           INNER JOIN #TempGuidesDetails tgd WITH(NOLOCK)
                 ON tgd.Guide_Serie = dbop.Guide_Serie
                 AND tgd.Guide_Number = dbop.Guide_Number
           LEFT JOIN [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
                            ON tgd.Guide_Serie = PromoC.GuideSerieDestination
                 AND tgd.Guide_Number = PromoC.GuideNumberDestination
           INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD WITH (NOLOCK)
                 ON PromoC.CatDiscountTypeId = CTD.IdCatTypeDiscount
           INNER JOIN [DeliveryBackOffice].[dbo].[CatValueType] CVT WITH (NOLOCK)
                 ON PromoC.CatValueTypeId = CVT.IdCatValueType
           LEFT JOIN #TempDetailsMembership tdm WITH(NOLOCK)
                 ON PromoC.GuideSerieDestination = tdm.Guide_Serie
                 AND PromoC.GuideNumberDestination = tdm.Guide_Number
           OUTER APPLY (
                        SELECT TOP 1
                               DO.PriceShippment
                          FROM [DeliveryBackOffice].[dbo].DeliveryOrder DO WITH (NOLOCK)
                         WHERE DO.Guide_Serie = tgd.Guide_Serie
                           AND DO.Guide_Number = tgd.Guide_Number
                       ) AS amountPrice

    UPDATE tdm
       SET tdm.DiscountType = CASE 
                                 WHEN tgd.AppliedCoupon > 0 THEN CTD.ShortName
                                 ELSE tdm.DiscountType
                              END,
           tdm.ValueType = CASE 
                              WHEN tgd.AppliedCoupon > 0 THEN CVT.ValueTypeName
                              ELSE tdm.ValueType
                           END,
           tdm.PromoValue = CASE 
                              WHEN tgd.AppliedCoupon > 0 THEN PromoC.CouponValue
                              ELSE tdm.PromoValue
                           END
      FROM @BreakdownOfPayment dbop
           INNER JOIN #TempGuidesDetails tgd WITH(NOLOCK)
                 ON tgd.Guide_Serie = dbop.Guide_Serie
                 AND tgd.Guide_Number = dbop.Guide_Number
           LEFT JOIN [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
                            ON tgd.Guide_Serie = PromoC.GuideSerieDestination
                 AND tgd.Guide_Number = PromoC.GuideNumberDestination
           INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD WITH (NOLOCK)
                 ON PromoC.CatDiscountTypeId = CTD.IdCatTypeDiscount
           INNER JOIN [DeliveryBackOffice].[dbo].[CatValueType] CVT WITH (NOLOCK)
                 ON PromoC.CatValueTypeId = CVT.IdCatValueType
           LEFT JOIN #TempDetailsMembership tdm WITH(NOLOCK)
                 ON PromoC.GuideSerieDestination = tdm.Guide_Serie
                 AND PromoC.GuideNumberDestination = tdm.Guide_Number
           OUTER APPLY (
                        SELECT TOP 1
                               DO.PriceShippment
                          FROM [DeliveryBackOffice].[dbo].DeliveryOrder DO WITH (NOLOCK)
                         WHERE DO.Guide_Serie = tgd.Guide_Serie
                           AND DO.Guide_Number = tgd.Guide_Number
                       ) AS amountPrice

    IF
    (
      SELECT COUNT(*)
        FROM @BreakdownOfPayment
    ) > 0
    BEGIN

        -- Pago collect
        UPDATE bdop
           SET bdop.AmountCollect = valAmount.Amount
          FROM @BreakdownOfPayment bdop
               OUTER APPLY (
                            SELECT TOP 1 Amount 
                              FROM @BreakdownOfPayment bo
                             WHERE [Description] LIKE '%PAGO%DESTINO%'
                              AND bo.Guide_Serie = bdop.Guide_Serie
                              AND bo.Guide_Number = bdop.Guide_Number
                           ) AS valAmount

        -- Pago collect
        UPDATE bdop
           SET bdop.amount = bdop.amount - bdop.AmountCollect
          FROM @BreakdownOfPayment bdop
         WHERE bdop.AmountCollect IS NOT NULL
           AND bdop.AmountCollect > 0 

        --Subscription
        UPDATE bdop
           SET bdop.AmountCollect = CASE 
                                        WHEN ts.ValueType = 'Porcentaje'
                                            THEN (CASE
                                                      WHEN ts.DiscountType = 'TOT'
                                                          THEN bdop.AmountCollect - ROUND(((bdop.AmountCollect  * ts.PromoValue) / 100), 1)
                                                      ELSE bdop.AmountCollect
                                                  END)
                                        ELSE bdop.AmountCollect
                                    END
          FROM @BreakdownOfPayment bdop
               INNER JOIN #TempGuidesDetails tg WITH(NOLOCK)
                       ON bdop.Guide_Serie = tg.Guide_Serie
                       AND bdop.Guide_Number = tg.Guide_Number
               LEFT JOIN #TempDetailsSubscription ts WITH(NOLOCK)
                       ON ts.Guide_Serie = tg.Guide_Serie
                       AND ts.Guide_Number = tg.Guide_Number
         WHERE bdop.AmountCollect IS NOT NULL 
           AND bdop.AmountCollect > 0 
           AND tg.AppliedCoupon > 0

        --Membership
        UPDATE bdop
           SET bdop.AmountCollect = CASE 
                                        WHEN tm.ValueType = 'Porcentaje'
                                            THEN (CASE
                                                      WHEN tm.DiscountType = 'TOT'
                                                          THEN bdop.AmountCollect - ROUND(((bdop.AmountCollect  * tm.PromoValue) / 100), 1)
                                                      ELSE bdop.AmountCollect
                                                  END)
                                        ELSE bdop.AmountCollect
                                    END
          FROM @BreakdownOfPayment bdop
               INNER JOIN #TempGuidesDetails tg WITH(NOLOCK)
                       ON bdop.Guide_Serie = tg.Guide_Serie
                       AND bdop.Guide_Number = tg.Guide_Number
               LEFT JOIN #TempDetailsMembership tm WITH(NOLOCK)
                       ON tm.Guide_Serie = tg.Guide_Serie
                      AND tm.Guide_Number = tg.Guide_Number
         WHERE bdop.AmountCollect IS NOT NULL
           AND bdop.AmountCollect > 0
           AND tg.AppliedCoupon > 0

        -- Excendente de peso
        UPDATE bdop
           SET bdop.AmountWeight = valAmount.Amount
          FROM @BreakdownOfPayment bdop
               OUTER APPLY (
                            SELECT TOP 1 Amount 
                              FROM @BreakdownOfPayment bo
                             WHERE [Description] LIKE '%PESO%'
                               AND bo.Guide_Serie = bdop.Guide_Serie
                               AND bo.Guide_Number = bdop.Guide_Number
                           ) AS valAmount

        UPDATE bdop
           SET bdop.amount = bdop.amount - bdop.AmountWeight
          FROM @BreakdownOfPayment bdop
         WHERE bdop.AmountWeight IS NOT NULL
           AND bdop.AmountWeight > 0

        --Subscription
        UPDATE bdop
           SET bdop.AmountWeight = CASE 
                                        WHEN ts.ValueType = 'Porcentaje'
                                            THEN (CASE
                                                      WHEN ts.DiscountType = 'TOT'
                                                          THEN bdop.AmountWeight - ROUND(((bdop.AmountWeight * ts.PromoValue) / 100), 1)
                                                      ELSE bdop.AmountWeight
                                                  END)
                                        ELSE bdop.AmountWeight
                                    END
          FROM @BreakdownOfPayment bdop
               INNER JOIN #TempGuidesDetails tg WITH(NOLOCK)
                       ON bdop.Guide_Serie = tg.Guide_Serie
                       AND bdop.Guide_Number = tg.Guide_Number
               LEFT JOIN #TempDetailsSubscription ts WITH(NOLOCK)
                       ON ts.Guide_Serie = tg.Guide_Serie
                       AND ts.Guide_Number = tg.Guide_Number
         WHERE bdop.AmountWeight IS NOT NULL 
           AND bdop.AmountWeight > 0 
           AND tg.AppliedCoupon > 0

        --Membership
        UPDATE bdop
           SET bdop.AmountWeight = CASE 
                                        WHEN tm.ValueType = 'Porcentaje'
                                            THEN (CASE
                                                      WHEN tm.DiscountType = 'TOT'
                                                          THEN bdop.AmountWeight - ROUND(((bdop.AmountWeight  * tm.PromoValue) / 100), 1)
                                                      ELSE bdop.AmountWeight
                                                  END)
                                        ELSE bdop.AmountWeight
                                    END
          FROM @BreakdownOfPayment bdop
               INNER JOIN #TempGuidesDetails tg WITH(NOLOCK)
                       ON bdop.Guide_Serie = tg.Guide_Serie
                       AND bdop.Guide_Number = tg.Guide_Number
               LEFT JOIN #TempDetailsMembership tm WITH(NOLOCK)
                       ON tm.Guide_Serie = tg.Guide_Serie
                      AND tm.Guide_Number = tg.Guide_Number
         WHERE bdop.AmountWeight IS NOT NULL
           AND bdop.AmountWeight > 0
           AND tg.AppliedCoupon > 0

        -- Seguro
        UPDATE bdop
           SET bdop.AmountSecure = valAmount.Amount
          FROM @BreakdownOfPayment bdop
               OUTER APPLY (
                            SELECT TOP 1 Amount 
                              FROM @BreakdownOfPayment bo
                             WHERE [Description] LIKE '%SEGURO%'
                               AND bo.Guide_Serie = bdop.Guide_Serie
                               AND bo.Guide_Number = bdop.Guide_Number
                           ) AS valAmount

        UPDATE bdop
           SET bdop.amount = bdop.amount - bdop.AmountSecure
          FROM @BreakdownOfPayment bdop
         WHERE bdop.AmountSecure IS NOT NULL 
           AND bdop.AmountSecure > 0

        --Subscription
        UPDATE bdop
           SET bdop.AmountSecure = CASE 
                                        WHEN ts.ValueType = 'Porcentaje'
                                            THEN (CASE
                                                      WHEN ts.DiscountType = 'TOT'
                                                          THEN bdop.AmountSecure - ROUND(((bdop.AmountSecure * ts.PromoValue) / 100), 1)
                                                      ELSE bdop.AmountSecure
                                                  END)
                                        ELSE bdop.AmountSecure
                                    END
          FROM @BreakdownOfPayment bdop
               INNER JOIN #TempGuidesDetails tg WITH(NOLOCK)
                       ON bdop.Guide_Serie = tg.Guide_Serie
                       AND bdop.Guide_Number = tg.Guide_Number
               LEFT JOIN #TempDetailsSubscription ts WITH(NOLOCK)
                       ON ts.Guide_Serie = tg.Guide_Serie
                       AND ts.Guide_Number = tg.Guide_Number
         WHERE bdop.AmountSecure IS NOT NULL 
           AND bdop.AmountSecure > 0 
           AND tg.AppliedCoupon > 0

       --Membership
        UPDATE bdop
           SET bdop.AmountSecure = CASE 
                                        WHEN tm.ValueType = 'Porcentaje'
                                            THEN (CASE
                                                      WHEN tm.DiscountType = 'TOT'
                                                          THEN bdop.AmountSecure - ROUND(((bdop.AmountSecure  * tm.PromoValue) / 100), 1)
                                                      ELSE bdop.AmountSecure
                                                  END)
                                        ELSE bdop.AmountSecure
                                    END
          FROM @BreakdownOfPayment bdop
               INNER JOIN #TempGuidesDetails tg WITH(NOLOCK)
                       ON bdop.Guide_Serie = tg.Guide_Serie
                       AND bdop.Guide_Number = tg.Guide_Number
               LEFT JOIN #TempDetailsMembership tm WITH(NOLOCK)
                       ON tm.Guide_Serie = tg.Guide_Serie
                      AND tm.Guide_Number = tg.Guide_Number
         WHERE bdop.AmountSecure IS NOT NULL
           AND bdop.AmountSecure > 0
           AND tg.AppliedCoupon > 0

       --Otras condciones
        UPDATE bdop
           SET bdop.Amount = CASE 
                                 WHEN tm.ValueType = 'Porcentaje'
                                     THEN (CASE
                                               WHEN tm.DiscountType = 'TOT'
                                                   THEN bdop.Amount - ROUND(((bdop.Amount  * tm.PromoValue) / 100), 1)
                                               ELSE bdop.Amount
                                           END)
                                 ELSE bdop.Amount
                             END
          FROM @BreakdownOfPayment bdop
               INNER JOIN #TempGuidesDetails tg WITH(NOLOCK)
                       ON bdop.Guide_Serie = tg.Guide_Serie
                       AND bdop.Guide_Number = tg.Guide_Number
               LEFT JOIN #TempDetailsMembership tm WITH(NOLOCK)
                       ON tm.Guide_Serie = tg.Guide_Serie
                      AND tm.Guide_Number = tg.Guide_Number
         WHERE bdop.Amount IS NOT NULL
           AND bdop.Amount > 0
           AND tg.AppliedCoupon > 0
           AND tm.IsFixedValueDiscount = 0

       --Otras condciones
        UPDATE bdop
           SET bdop.Amount = CASE 
                                 WHEN ts.ValueType = 'Porcentaje'
                                     THEN (CASE
                                               WHEN ts.DiscountType = 'TOT'
                                                   THEN bdop.Amount - ROUND(((bdop.Amount  * ts.PromoValue) / 100), 1)
                                               ELSE bdop.Amount
                                           END)
                                 ELSE bdop.Amount
                             END
          FROM @BreakdownOfPayment bdop
               INNER JOIN #TempGuidesDetails tg WITH(NOLOCK)
                       ON bdop.Guide_Serie = tg.Guide_Serie
                       AND bdop.Guide_Number = tg.Guide_Number
               LEFT JOIN #TempDetailsSubscription ts WITH(NOLOCK)
                       ON ts.Guide_Serie = tg.Guide_Serie
                      AND ts.Guide_Number = tg.Guide_Number
         WHERE bdop.Amount IS NOT NULL
           AND bdop.Amount > 0
           AND tg.AppliedCoupon > 0
           AND ts.IsFixedValueDiscount = 0

           --Amount
           INSERT INTO @GuideDetail
           SELECT tgd.IdVisitPointClient, 
                  tgd.Guide_Serie,
                  tgd.Guide_Number,
                  ca.SAPCode,
                  ca.[Name],
                  CONCAT(ca.[Description], '. ', tgd.Guide_Serie, tgd.Guide_Number),
                  ISNULL(bdop.Amount, 0),
                  ca.Category,
                  1
             FROM CatArticleSAP ca
                  INNER JOIN #TempGuidesDetails tgd WITH(NOLOCK)
                          ON ca.[Name] = tgd.NameArticle
                         AND ISNULL(ca.IdCountry,'GT') = tgd.CountryByGuide
                  INNER JOIN @BreakdownOfPayment bdop
                         ON tgd.Guide_Serie = bdop.Guide_Serie
                        AND tgd.Guide_Number = bdop.Guide_Number
            WHERE bdop.Amount IS NOT NULL
              AND bdop.Amount > 0

           --Amount
           INSERT INTO @GuideDetail
           SELECT tgd.IdVisitPointClient, 
                  tgd.Guide_Serie,
                  tgd.Guide_Number,
                  ca.SAPCode,
                  ca.[Name],
                  CONCAT(ca.[Description], '. ', tgd.Guide_Serie, tgd.Guide_Number),
                  ISNULL(bdop.AmountCollect, 0),
                  ca.Category,
                  1
             FROM CatArticleSAP ca
                  INNER JOIN #TempGuidesDetails tgd WITH(NOLOCK)
                          ON ca.[Name] = tgd.NameArticle
                         AND ISNULL(ca.IdCountry,'GT') = tgd.CountryByGuide
                  INNER JOIN @BreakdownOfPayment bdop
                         ON tgd.Guide_Serie = bdop.Guide_Serie
                        AND tgd.Guide_Number = bdop.Guide_Number
            WHERE bdop.AmountCollect IS NOT NULL
              AND bdop.AmountCollect > 0

           --AmountWeight
           INSERT INTO @GuideDetail
           SELECT tgd.IdVisitPointClient, 
                  tgd.Guide_Serie,
                  tgd.Guide_Number,
                  ca.SAPCode,
                  ca.[Name],
                  CONCAT(ca.[Description], '. ', tgd.Guide_Serie, tgd.Guide_Number),
                  ISNULL(bdop.AmountWeight, 0),
                  ca.Category,
                  1
             FROM CatArticleSAP ca
                  INNER JOIN #TempGuidesDetails tgd WITH(NOLOCK)
                          ON ca.[Name] = tgd.NameArticle
                         AND ISNULL(ca.IdCountry,'GT') = tgd.CountryByGuide
                  INNER JOIN @BreakdownOfPayment bdop
                         ON tgd.Guide_Serie = bdop.Guide_Serie
                        AND tgd.Guide_Number = bdop.Guide_Number
            WHERE bdop.AmountWeight IS NOT NULL
              AND bdop.AmountWeight > 0

           --AmountSecure
           INSERT INTO @GuideDetail
           SELECT tgd.IdVisitPointClient, 
                  tgd.Guide_Serie,
                  tgd.Guide_Number,
                  ca.SAPCode,
                  ca.[Name],
                  CONCAT(ca.[Description], '. ', tgd.Guide_Serie, tgd.Guide_Number),
                  ISNULL(bdop.AmountSecure, 0),
                  ca.Category,
                  1
             FROM CatArticleSAP ca
                  INNER JOIN #TempGuidesDetails tgd WITH(NOLOCK)
                          ON ca.[Name] = tgd.NameArticle
                         AND ISNULL(ca.IdCountry,'GT') = tgd.CountryByGuide
                  INNER JOIN @BreakdownOfPayment bdop
                         ON tgd.Guide_Serie = bdop.Guide_Serie
                        AND tgd.Guide_Number = bdop.Guide_Number
            WHERE bdop.AmountSecure IS NOT NULL
              AND bdop.AmountSecure > 0
    END

     SELECT tgd.IdVisitPointClient,
            tgd.Guide_Serie,
            tgd.Guide_Number,
            cCt.CountryNameES,
            gd.SAPCode,
            [Name],
            CASE
               WHEN tgd.IsLastMileReturn = 1 THEN REPLACE(REPLACE ( tgd.DescriptionReturn, '##' , gd.Price ),'+++',+ char(10))
               ELSE gd.[Description] 
            END [Description] ,
            gd.Price,
            gd.Category,
            gd.SendToInvoice
       FROM @GuideDetail gd
            INNER JOIN #TempGuidesDetails tgd WITH(NOLOCK) 
                    ON tgd.Guide_Serie = gd.Guide_Serie
                   AND tgd.Guide_Number = gd.Guide_Number
            INNER JOIN CatCountry cCt WITH(NOLOCK)
                    ON cCt.IdCountry = tgd.CountryByGuide
   SET NOCOUNT OFF;
END