-- =============================================
-- Author:      <Bilkar Morataya>
-- Create date: <2025-09-26>
-- Description: <Se muestran las guías según el estatus de pago por Zigi>
-- =============================================
CREATE PROCEDURE spws_get_guide_pending_payment_exc    
    @InGuidesP VARCHAR(MAX)
AS
BEGIN
    -- Crear tabla temporal para almacenar las guías individuales
    DECLARE @GuideTable TABLE (GuideSerieNumber NVARCHAR(50));
    DECLARE @Guide NVARCHAR(50), @Pos INT;

    -- Bucle para dividir las guías en @InGuidesP
    SET @InGuidesP = LTRIM(RTRIM(@InGuidesP)) + ','; -- Agregar una coma final para procesar la última guía
    SET @Pos = CHARINDEX(',', @InGuidesP);

    WHILE @Pos > 0
    BEGIN
        SET @Guide = LTRIM(RTRIM(LEFT(@InGuidesP, @Pos - 1))); -- Extraer una guía
        INSERT INTO @GuideTable (GuideSerieNumber) VALUES (@Guide); -- Insertar en la tabla temporal
        SET @InGuidesP = SUBSTRING(@InGuidesP, @Pos + 1, LEN(@InGuidesP)); -- Remover la guía extraída
        SET @Pos = CHARINDEX(',', @InGuidesP); -- Buscar la próxima coma
    END;

    -- Crear tabla temporal para almacenar los resultados
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
        IsPayZigi_COD_Exclude BIT -- Corregido: Añadido para que coincida con la tabla de inserción
    );

    -- Consultar en la tabla PaymentZigi
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
        CASE WHEN pz.CODValue > 0 THEN 1 ELSE 0 END AS IsPayZigi_COD_Exclude -- Corregido: Añadido para que coincida con la tabla
    FROM PaymentZigi pz
    INNER JOIN @GuideTable GTBL ON CONCAT(pz.GuideSerie, pz.GuideNumber) = GTBL.GuideSerieNumber
    WHERE pz.RowStatus = 1; -- Filtrar por filas activas

    -- Consultar en la tabla PaymentZigiMulti
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
        pzm.exclude_COD AS IsPayZigi_COD_Exclude -- Corregido: Añadido para que coincida con la tabla
    FROM PaymentZigiMulti pzm
    INNER JOIN PaymentZigi pz ON pz.ZigiPaymentId = pzm.Id_PaymentZigi
    INNER JOIN @GuideTable GTBL ON CONCAT(pzm.GuideSerie, pzm.GuideNumber) = GTBL.GuideSerieNumber
    WHERE pzm.RowStatus = 1 -- Filtrar por filas activas
        AND NOT EXISTS (
            SELECT 1
            FROM PaymentZigi pz_check
            WHERE CONCAT(pz_check.GuideSerie, pz_check.GuideNumber) = CONCAT(pzm.GuideSerie, pzm.GuideNumber)
        );

    -- Devolver resultados en el mismo orden del parámetro original
    -- Actualizamos los valores desde las guías hijas de PaymentZigiMulti cuando la guía en PaymentZigi sea una madre
    UPDATE r
    SET
        r.PaidAmount = ISNULL(pm.Amount, r.PaidAmount),
        r.CollectValue = ISNULL(pm.CollectValue, r.CollectValue),
        r.CODValue = ISNULL(pm.CODValue, r.CODValue),
        r.IsPayZigi_COD_Exclude = ISNULL(pm.exclude_COD, r.IsPayZigi_COD_Exclude)
    FROM @Result r
    INNER JOIN PaymentZigi pz ON CONCAT(pz.GuideSerie, pz.GuideNumber) = r.GuideSerieNumber
    INNER JOIN PaymentZigiMulti pm ON pz.ZigiPaymentId = pm.Id_PaymentZigi
    WHERE pz.IsGroup = 1 AND pz.RowStatus = 1 AND pm.RowStatus = 1;

    -- Eliminar guías madre duplicadas si existe un registro correspondiente en las guías hijas
    DELETE r
    FROM @Result r
    WHERE r.IsGroup = 1 -- Es guía madre
      AND EXISTS (
          SELECT 1
          FROM @Result r_hija
          WHERE r_hija.GuideSerieNumber = r.GuideSerieNumber
            AND r_hija.IsGroup = 0 -- Es una guía hija
      );

    -- Devolver resultados en el mismo orden del parámetro original
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
        r.IsPayZigi_COD_Exclude
    FROM @Result r
    INNER JOIN @GuideTable GTBL ON r.GuideSerieNumber = GTBL.GuideSerieNumber
    ORDER BY CHARINDEX(r.GuideSerieNumber, @InGuidesP);
END