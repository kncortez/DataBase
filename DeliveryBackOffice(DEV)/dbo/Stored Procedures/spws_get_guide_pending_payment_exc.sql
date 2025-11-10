-- =============================================
-- Author:      <Bilkar Morataya>
-- Create date: <2025-09-26>
-- Description: <Se muestran las guías según el estatus de pago por Zigi,
--               incluyendo las guías relacionadas (madre e hijas).>
-- =============================================
CREATE PROCEDURE spws_get_guide_pending_payment_exc
    @InGuidesP VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    -- 1. Crear tabla temporal para almacenar las guías individuales
    -- =============================================
    DECLARE @GuideTable TABLE (GuideSerieNumber NVARCHAR(50));
    DECLARE @Guide NVARCHAR(50), @Pos INT;

    SET @InGuidesP = LTRIM(RTRIM(@InGuidesP)) + ','; -- Agregar coma final
    SET @Pos = CHARINDEX(',', @InGuidesP);

    WHILE @Pos > 0
    BEGIN
        SET @Guide = LTRIM(RTRIM(LEFT(@InGuidesP, @Pos - 1)));
        INSERT INTO @GuideTable (GuideSerieNumber) VALUES (@Guide);
        SET @InGuidesP = SUBSTRING(@InGuidesP, @Pos + 1, LEN(@InGuidesP));
        SET @Pos = CHARINDEX(',', @InGuidesP);
    END;

    -- =============================================
    -- 2. Crear tabla temporal de resultados
    -- =============================================
    DECLARE @Result TABLE (
        GuideSerieNumber NVARCHAR(50),
        PaidAmount DECIMAL(18, 2),
        CollectValue DECIMAL(18, 2),
        CODValue DECIMAL(18, 2),
        IsGroup BIT,
        IdGroup INT NULL,
        IsPayZigi BIT,
        IsPayZigi_CollectValue BIT,
        IsPayZigi_COD BIT,
        IsPayZigi_COD_Exclude BIT,
        ZigiTransactionId INT NULL,
        GuidesRelated NVARCHAR(MAX) NULL,
        OriginalServicePrice DECIMAL(18, 2) NULL,
        OriginalCODAmount DECIMAL(18, 2) NULL,
        OriginalAmountToCollect DECIMAL(18, 2) NULL
    );

    -- =============================================
    -- 3. Insertar desde PaymentZigi
    -- =============================================
    INSERT INTO @Result
    SELECT
        CONCAT(pz.GuideSerie, pz.GuideNumber) AS GuideSerieNumber,
        pz.PaidAmount,
        pz.CollectValue,
        pz.CODValue,
        pz.IsGroup,
        CASE WHEN pz.IsGroup = 1 THEN pz.ZigiPaymentId ELSE NULL END AS IdGroup,
        CASE WHEN pz.ZigiLinkStatus = 'PAID' THEN 1 ELSE 0 END AS IsPayZigi,
        CASE WHEN pz.ZigiLinkStatus = 'PAID' AND pz.CollectValue > 0 THEN 1 ELSE 0 END AS IsPayZigi_CollectValue,
        CASE WHEN pz.ZigiLinkStatus = 'PAID' AND pz.CODValue > 0 THEN 1 ELSE 0 END AS IsPayZigi_COD,
        CASE WHEN pz.CODValue > 0 THEN 0 ELSE 1 END AS IsPayZigi_COD_Exclude,
        pz.ZigiTransactionId,
        NULL AS GuidesRelated,
        ISNULL(do.PriceShippment, 0) AS OriginalServicePrice,
        ISNULL(do.Collect_OnDelivery, 0) AS OriginalCODAmount,
        (ISNULL(do.PriceShippment, 0) + ISNULL(do.Collect_OnDelivery, 0)) AS OriginalAmountToCollect
    FROM PaymentZigi pz WITH(NOLOCK)
    INNER JOIN @GuideTable GTBL ON CONCAT(pz.GuideSerie, pz.GuideNumber) = GTBL.GuideSerieNumber
    LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
        ON pz.GuideSerie = do.Guide_Serie AND pz.GuideNumber = do.Guide_Number
    WHERE pz.RowStatus = 1;

    -- =============================================
    -- 4. Insertar desde PaymentZigiMulti
    -- =============================================
    INSERT INTO @Result
    SELECT
        CONCAT(pzm.GuideSerie, pzm.GuideNumber) AS GuideSerieNumber,
        pzm.Amount AS PaidAmount,
        pzm.CollectValue,
        pzm.CODValue,
        CAST(0 AS BIT) AS IsGroup,
        pzm.Id_PaymentZigi AS IdGroup,
        CASE WHEN pz.ZigiLinkStatus = 'PAID' THEN 1 ELSE 0 END AS IsPayZigi,
        CASE WHEN pz.ZigiLinkStatus = 'PAID' AND pzm.CollectValue > 0 THEN 1 ELSE 0 END AS IsPayZigi_CollectValue,
        CASE WHEN pz.ZigiLinkStatus = 'PAID' AND pzm.CODValue > 0 THEN 1 ELSE 0 END AS IsPayZigi_COD,
        CASE WHEN pzm.CODValue > 0 THEN 0 ELSE 1 END AS IsPayZigi_COD_Exclude,
        pz.ZigiTransactionId,
        NULL AS GuidesRelated,
        ISNULL(do.PriceShippment, 0) AS OriginalServicePrice,
        ISNULL(do.Collect_OnDelivery, 0) AS OriginalCODAmount,
        (ISNULL(do.PriceShippment, 0) + ISNULL(do.Collect_OnDelivery, 0)) AS OriginalAmountToCollect
    FROM PaymentZigiMulti pzm WITH(NOLOCK)
    INNER JOIN PaymentZigi pz WITH(NOLOCK) ON pz.ZigiPaymentId = pzm.Id_PaymentZigi
    INNER JOIN @GuideTable GTBL ON CONCAT(pzm.GuideSerie, pzm.GuideNumber) = GTBL.GuideSerieNumber
    LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
        ON pzm.GuideSerie = do.Guide_Serie AND pzm.GuideNumber = do.Guide_Number
    WHERE pzm.RowStatus = 1
      AND NOT EXISTS (
          SELECT 1
          FROM PaymentZigi pz_check WITH(NOLOCK)
          WHERE CONCAT(pz_check.GuideSerie, pz_check.GuideNumber) = CONCAT(pzm.GuideSerie, pzm.GuideNumber)
      );

    -- =============================================
    -- 5. Actualizar valores de hijas si la madre es grupo
    -- =============================================
    UPDATE r
    SET
        r.PaidAmount = ISNULL(pm.Amount, r.PaidAmount),
        r.CollectValue = ISNULL(pm.CollectValue, r.CollectValue),
        r.CODValue = ISNULL(pm.CODValue, r.CODValue),
        r.IsPayZigi_COD = ISNULL(pm.CODValue, r.IsPayZigi_COD),
        r.IsPayZigi_COD_Exclude = IIF(pm.CODValue > 0, 0, 1)
    FROM @Result r
    INNER JOIN PaymentZigi pz ON CONCAT(pz.GuideSerie, pz.GuideNumber) = r.GuideSerieNumber
    INNER JOIN PaymentZigiMulti pm ON pz.ZigiPaymentId = pm.Id_PaymentZigi
    WHERE pz.IsGroup = 1 AND pz.RowStatus = 1 AND pm.RowStatus = 1;

    -- =============================================
    -- 6. Eliminar duplicados madre si existen hijas equivalentes
    -- =============================================
    DELETE r
    FROM @Result r
    WHERE r.IsGroup = 1
      AND EXISTS (
          SELECT 1
          FROM @Result r_hija
          WHERE r_hija.GuideSerieNumber = r.GuideSerieNumber
            AND r_hija.IsGroup = 0
      );

    -- =============================================
    -- 7. Actualizar campo GuidesRelated (madre + hijas + hermanas)
    -- =============================================
    UPDATE r
    SET r.GuidesRelated =
        STUFF((
            SELECT ',' + g.GuideSerieNumber
            FROM (
                SELECT CONCAT(pm.GuideSerie, pm.GuideNumber) AS GuideSerieNumber
                FROM PaymentZigiMulti pm
                WHERE pm.Id_PaymentZigi = r.IdGroup
                  AND pm.RowStatus = 1
            ) AS g
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
    FROM @Result r
    WHERE r.IdGroup IS NOT NULL;


    -- =============================================
    -- 8. Devolver resultados
    -- =============================================
    SELECT
        r.GuideSerieNumber,
        r.PaidAmount,
        r.CollectValue,
        r.CODValue,
        r.IsGroup,
        r.IdGroup,
        r.IsPayZigi,
        r.IsPayZigi_CollectValue,
        r.IsPayZigi_COD,
        r.IsPayZigi_COD_Exclude,
        r.ZigiTransactionId,
        r.GuidesRelated,
        r.OriginalServicePrice,
        r.OriginalCODAmount,
        r.OriginalAmountToCollect
    FROM @Result r
    INNER JOIN @GuideTable GTBL ON r.GuideSerieNumber = GTBL.GuideSerieNumber
    ORDER BY CHARINDEX(r.GuideSerieNumber, @InGuidesP);
END