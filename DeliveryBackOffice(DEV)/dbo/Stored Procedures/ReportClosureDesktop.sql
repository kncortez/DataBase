/* =================================================
   SP:        [dbo].[ReportClosureDesktop]
   Propósito: Sp para el detalle del reporte de cierres en desktop
   Autor:     Oscar Morales
   Historia:  <>
   Fecha:     2023-03-04

=== CHANGELOG ================================
2026-05-04 | Mario Herrarte  | Se soluciona inconveniente con envios internacionales y articulos.
2026-03-03 | Bilkar Morataya | Optimización: mejor manejo de rango de fechas, eliminación de OR en WHERE, OUTER APPLY sin OR para invoiceHeader
2025-11-04 | Bilkar Morataya | Se agrega método de paago Zigi
2025-10-10 | Walter Orozco   | Se agregan envios internacionales.
2024-07-08 | Cristian Suazo  | Se agrega el simbolo de la moneda, segun pais de origen, para el detalle del reporte
=========================================== */
CREATE PROCEDURE [dbo].[ReportClosureDesktop]
@StartDate datetime = null,
@EndDate datetime = null,
@VisitPointId NVARCHAR(3000) = null,
@IdCierre NVARCHAR(3000) = null,
@IdAccount NVARCHAR(3000) = null
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación de parámetros requeridos
    IF @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        RAISERROR('Las fechas de inicio y fin son requeridas', 16, 1);
        RETURN;
    END

    -- Variables para fechas SARGables (permite uso de índices)
    DECLARE @StartDateClean DATETIME = CAST(CAST(@StartDate AS DATE) AS DATETIME);
    DECLARE @EndDateClean DATETIME = DATEADD(DAY, 1, CAST(CAST(@EndDate AS DATE) AS DATETIME));
    -- Tablas temporales con índices
    DECLARE @tblVisitPointId TABLE(CodeOfReference int PRIMARY KEY);
    DECLARE @tblIdCierre TABLE(CierreId int PRIMARY KEY);
    DECLARE @tblIdAccount TABLE(AccountId int PRIMARY KEY);

    -- Poblar tablas de filtro (si '-1' = todos los valores, sino los específicos)
    IF @IdAccount = '-1'
        INSERT INTO @tblIdAccount
        SELECT DISTINCT AccountId
        FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction WITH(NOLOCK)
        WHERE AccountId > 0
          AND DateCreated >= @StartDateClean AND DateCreated < @EndDateClean;
    ELSE IF @IdAccount IS NOT NULL
        INSERT INTO @tblIdAccount
        SELECT DISTINCT CAST(Item AS int)
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@IdAccount, ',')
        WHERE TRY_CAST(Item AS int) IS NOT NULL;

    IF @IdCierre = '-1'
    INSERT INTO @tblIdCierre
    SELECT DISTINCT ACD.AccountingClosuresHeaderId
    FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)
        ON ACD.DopId = DOPD.DopId
        AND (
                ACD.GuideSerie = DOPD.GuideSerie
                OR (ACD.GuideSerie IS NULL AND DOPD.GuideSerie IS NULL)
            )
        AND (
                ACD.GuideNumber = DOPD.GuideNumber
                OR (ACD.GuideNumber IS NULL AND DOPD.GuideNumber IS NULL)
            )
    WHERE ACD.RowStatus = 1
      AND DOPD.DateCreated >= @StartDateClean AND DOPD.DateCreated < @EndDateClean;
    ELSE IF @IdCierre IS NOT NULL
        INSERT INTO @tblIdCierre
        SELECT DISTINCT CAST(Item AS int)
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@IdCierre, ',')
        WHERE TRY_CAST(Item AS int) IS NOT NULL;

    IF @VisitPointId = '-1'
        INSERT INTO @tblVisitPointId
        SELECT DISTINCT CodeOfReference
        FROM DeliveryBackOffice.dbo.VisitPointClient WITH(NOLOCK)
        WHERE CodeOfReference IS NOT NULL;
    ELSE IF @VisitPointId IS NOT NULL
        INSERT INTO @tblVisitPointId
        SELECT DISTINCT CAST(Item AS int)
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@VisitPointId, ',')
        WHERE TRY_CAST(Item AS int) IS NOT NULL;
    -- Tabla temporal para detalles de factura 
    DECLARE @TEMPLATEDETAIL TABLE
    (
        guideserie NVARCHAR(3000),
        guidenumber BIGINT,
        header BIGINT
    );
    INSERT INTO @TEMPLATEDETAIL (guideserie, guidenumber, header)
    SELECT
        IND.dti_fk_orderSerie,
        IND.dti_fk_orderNumber,
        MAX(IND.dti_fk_header)
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPT WITH(NOLOCK)
    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH(NOLOCK)
        ON IND.dti_fk_orderSerie = DOPT.GuideSerie
        AND IND.dti_fk_orderNumber = DOPT.GuideNumber
    WHERE DOPT.DateCreated >= @StartDateClean AND DOPT.DateCreated < @EndDateClean
    GROUP BY IND.dti_fk_orderSerie, IND.dti_fk_orderNumber
    OPTION (RECOMPILE);
    -- CONSULTA ÚNICA con lógica condicional (reemplaza los 3 UNION)
    SELECT DISTINCT 
        DOPD.AccountId,
        ACD.AccountingClosuresHeaderId AS ClosuresHeaderId,
        VPC.VisitPointId,
        VPC.DescriptionOfClient AS VisitPointDescription,
        ACH.UserId,
        REU.UsrNickName,
        DOPD.DateCreated,
        -- Cliente: usa DOR o INH según el caso
        CASE 
            WHEN DOR.Guide_Serie IS NOT NULL THEN DOR.Sender_FirstName + ' ' + DOR.Sender_LastName
            ELSE ISNULL(INH_Header.inv_UserName, INH_Fel.inv_UserName)
        END AS Client,
        ISNULL(INH_Header.inv_certificationFEL, INH_Fel.inv_certificationFEL) AS CertificationFEL,
        ISNULL(INH_Header.inv_serieFEL, INH_Fel.inv_serieFEL) AS SerieFel,
        ISNULL(INH_Header.inv_numberFEL, INH_Fel.inv_numberFEL) AS NumberFel,
        ISNULL(INH_Header.inv_SAPDocEntry, INH_Fel.inv_SAPDocEntry) AS DOCSAP,
        -- Status y Guide: usa DOR o '----' según el caso
        CASE 
            WHEN DOR.Guide_Serie IS NOT NULL THEN STO.OrderDescription
            ELSE '----'
        END AS Status,
        CASE 
            WHEN DOR.Guide_Serie IS NOT NULL THEN DOR.Guide_Serie + CONVERT(VARCHAR(20), DOR.Guide_Number)
            ELSE '----'
        END AS Guide,
        ISNULL(costd.Voucher, '') AS Voucher,
        CASE 
            WHEN ISNULL(DOR.SenderCountryId, 'GT') = 'GT' THEN 'GTQ' 
            ELSE 'HNL' 
        END AS CurrencySymbol,
        ISNULL(DOPD.amount, 0) AS PriceShippment,
        ISNULL(DOPD.CODAmountProcess, 0) AS COD,
        CASE
            WHEN DOPD.TypeofInOutMoneyId IN (1, 2, 3, 4, 7, 10) THEN UPPER(ctgmon.tio_pk_name)
            WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
            ELSE ''
        END AS PaymentType,
        CTS.NameTypeService AS ServiceType,
        ACHVP.IdAccountingClosuresHeaderVisitPoint AS CierreGeneral,
        REU1.UsrNickName AS Encargado,
        ISNULL(ACHVP.Voucher1, '') AS VoucherGeneral,
        ISNULL(ACHVP.Bag1, '') AS Bolsa,
        ISNULL(ACHVP.ClosurerPOS, '') AS CierrePOS
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)
    -- LEFT JOINs para los casos donde no hay DeliveryOrder
    LEFT JOIN [DeliveryBackOffice].[dbo].DeliveryOrder DOR WITH(NOLOCK)
        ON DOR.Guide_Serie = DOPD.GuideSerie
        AND DOR.Guide_Number = DOPD.GuideNumber
        AND DOR.StatusOrderId <> 7
    LEFT JOIN @TEMPLATEDETAIL IND
        ON IND.guideserie = DOR.Guide_Serie
        AND IND.guidenumber = DOR.Guide_Number
    -- OUTER APPLY para invoiceHeader por header
    OUTER APPLY (
        SELECT TOP 1 
            inv_pk_id, inv_certificationFEL, inv_serieFEL, 
            inv_numberFEL, inv_SAPDocEntry, inv_UserName
        FROM DeliveryBackOffice.dbo.invoiceHeader WITH(NOLOCK)
        WHERE inv_pk_id = IND.header
    ) INH_Header
    -- OUTER APPLY para invoiceHeader por FEL (cuando no hay header)
    OUTER APPLY (
        SELECT TOP 1 
            inv_pk_id, inv_certificationFEL, inv_serieFEL, 
            inv_numberFEL, inv_SAPDocEntry, inv_UserName
        FROM DeliveryBackOffice.dbo.invoiceHeader WITH(NOLOCK)
        WHERE INH_Header.inv_pk_id IS NULL
          AND CHARINDEX('-', DOPD.Fel) > 0
          AND inv_numberFEL = --TRY_CAST(SUBSTRING(DOPD.Fel, CHARINDEX('-', DOPD.Fel) + 1, LEN(DOPD.Fel)) AS BIGINT)
            SUBSTRING(DOPD.Fel, CHARINDEX('-', DOPD.Fel) + 1, LEN(DOPD.Fel))
    ) INH_Fel
    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder STO WITH(NOLOCK)
        ON STO.StatusOrderId = DOR.StatusOrderId
    -- JOINs principales
    INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
        ON ACD.DopId = DOPD.DopId
        AND (
                ACD.GuideSerie = DOPD.GuideSerie
                OR (ACD.GuideSerie IS NULL AND DOPD.GuideSerie IS NULL)
            )
        AND (
                ACD.GuideNumber = DOPD.GuideNumber
                OR (ACD.GuideNumber IS NULL AND DOPD.GuideNumber IS NULL)
            )
        AND ACD.RowStatus = 1
    INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH WITH(NOLOCK)
        ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
        ON VPC.CodeOfReference = COALESCE(DOPD.VisitPoint, ACH.VisitPoint)
    INNER JOIN [DeliveryBackOffice].[dbo].CatTypeServiceClosure CTS WITH(NOLOCK)
        ON CTS.IdTypeService = DOPD.TypeServiceId
        AND CTS.IdTypeService <> 23 -- Excluir tipo 23
    LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH(NOLOCK)
        ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
    LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU WITH(NOLOCK)
        ON REU.UsrIdUser = ACH.UserId
    LEFT JOIN DeliveryBackOffice.dbo.Cost cost WITH(NOLOCK)
        ON cost.ProductNumber = CONCAT(DOR.Guide_Serie, DOR.Guide_Number)
    LEFT JOIN DeliveryBackOffice.dbo.CostDetail costd WITH(NOLOCK)
        ON costd.IdCost = cost.IdCost
        AND costd.Amount > 0
        AND (DOPD.TypeofInOutMoneyId IN (6, 10) AND costd.Voucher != '')
    LEFT JOIN [DeliveryBackOffice].[dbo].AccountingClosuresHeaderVisitPoint ACHVP WITH(NOLOCK)
        ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId
    LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1 WITH(NOLOCK)
        ON REU1.UsrIdUser = ACHVP.UserId
    WHERE DOPD.DateCreated >= @StartDateClean AND DOPD.DateCreated < @EndDateClean
        AND DOPD.AccountId IN (SELECT AccountId FROM @tblIdAccount)
        AND (ACD.AccountingClosuresHeaderId IN (SELECT CierreId FROM @tblIdCierre) OR @IdCierre = '-1')
        AND COALESCE(DOPD.VisitPoint, ACH.VisitPoint) IN (SELECT CodeOfReference FROM @tblVisitPointId)
        AND DOPD.ShipmentCompleted = 1
        AND DOPD.AccountId > 0
    ORDER BY DOPD.DateCreated ASC
    OPTION (RECOMPILE);
END