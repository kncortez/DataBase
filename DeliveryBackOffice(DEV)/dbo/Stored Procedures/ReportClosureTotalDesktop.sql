/* =========================================
   SP:         [dbo].[ReportClosureTotalDesktop]
   Propósito:  Totales del reporte de cierres en desktop.
   Autor:      Oscar Morales
   Historia:
   Fecha:      2022-03-04
========================================= */

/* === CHANGELOG ============================
2026-05-28 | Historia/épica: FDAPI-6052 | Autor: Keneth Hoffens   |
-----
2026-03-03 | Historia/épica:            | Autor: Bilkar Morataya  |
-----
2025-11-04 | Historia/épica:            | Autor: Bilkar Morataya  |
-----
2024-07-08 | Historia/épica:            | Autor: Cristian Suazo   |
-----
2022-03-04 | Historia/épica:            | Autor: Oscar Morales    |
-----
========================================= */
CREATE PROCEDURE  [dbo].[ReportClosureTotalDesktop]
    @StartDate datetime = NULL,
    @EndDate datetime = NULL,
    @VisitPointId NVARCHAR(50) = NULL,
    @IdCierre NVARCHAR(50) = NULL,
    @IdAccount NVARCHAR(50) = NULL,
    @IdCountry NVARCHAR(2) = NULL
AS
BEGIN
    DECLARE @AccountExp NVARCHAR(30),
            @AccountCOD NVARCHAR(30),
            @AccountZigi NVARCHAR(30);

    DECLARE @StartDateClean DATE = CONVERT(DATE, @StartDate);
    DECLARE @EndDateClean   DATE = CONVERT(DATE, @EndDate);

    SELECT @AccountExp = Name +' '+ '(' +AccountNumber +')'
    FROM DeliveryBackOffice.dbo.ClosureAccount WITH (NOLOCK)
    WHERE Name = 'Cuenta Express Center' AND IdCountry = @IdCountry

    SELECT @AccountCOD = Name +' '+ '(' +AccountNumber +')' 
    FROM DeliveryBackOffice.dbo.ClosureAccount WITH (NOLOCK)
    WHERE Name = 'Cuenta Área COD' AND IdCountry = @IdCountry

    SELECT @AccountZigi = Name +' '+ '(' +AccountNumber +')' 
    FROM DeliveryBackOffice.dbo.ClosureAccount WITH (NOLOCK)
    WHERE Name = 'Cuenta Zigi' AND IdCountry = @IdCountry

    DECLARE @tblVisitPointId TABLE(
        CodeOfReference int
    )

    INSERT INTO @tblVisitPointId
    SELECT
        SUBSTRING(Item, 1, LEN(Item)) ItemNumber
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@VisitPointId, ',')

    DECLARE @tblIdCierre TABLE(
        CierreId int
    )

    INSERT INTO @tblIdCierre
    SELECT
        SUBSTRING(Item, 1, LEN(Item)) ItemNumber
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@IdCierre, ',')

    DECLARE @tblIdAccount TABLE(
        AccountId int
    )

    INSERT INTO @tblIdAccount
    SELECT
        SUBSTRING(Item, 1, LEN(Item)) ItemNumber
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@IdAccount, ',')


    SELECT
        @AccountExp AS AccountExp
        ,ISNULL(SUM(TotalCash), 0) TotalCash
        ,ISNULL(SUM(TotalCredit), 0) TotalCredit
        ,ISNULL(SUM(TotalZigi), 0) TotalZigi
        ,ISNULL(SUM(TotalCashDeclared), 0) TotalCashDeclared
        ,ISNULL(SUM(TotalCreditDeclared), 0) TotalCreditDeclared
        ,ISNULL(SUM(TotalZigiDeclared), 0) TotalZigiDeclared
        ,@AccountCOD AS AccountCOD
        ,ISNULL(SUM(TotalCODCash), 0) TotalCODCash
        ,ISNULL(SUM(TotalAmountCODZigi), 0) TotalAmountCODZigi
        -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
        ,ISNULL(SUM(TotalAmountCODCashDeclared), 0) TotalAmountCODCashDeclared
        ,ISNULL(SUM(TotalAmountCODZigiDeclared), 0) TotalAmountCODZigiDeclared
        ,ISNULL(SUM(TotalAmountFacturaCash), 0) TotalAmountFacturaCash
        ,ISNULL(SUM(TotalAmountFacturaCard), 0) TotalAmountFacturaCard
        ,@AccountZigi AS AccountZigi
        ,ISNULL(SUM(TotalAmountFacturaZigi), 0) TotalAmountFacturaZigi
        ,ISNULL(SUM(TotalAmountFacturaCashDeclared), 0) TotalAmountFacturaCashDeclared
        ,ISNULL(SUM(TotalAmountFacturaCardDeclared), 0) TotalAmountFacturaCardDeclared
        ,ISNULL(SUM(TotalAmountFacturaZigiDeclared), 0) TotalAmountFacturaZigiDeclared
        -- FIN MODIFICACIÓN
        ,ISNULL(SUM(TotalGeneral), 0 ) TotalGeneral
        ,CurrencySymbol
    FROM (SELECT
            ISNULL(MAX(ACH.TotalAmountCash), 0) TotalCash
           ,ISNULL(MAX(ACH.TotalAmountCredit), 0) TotalCredit
           ,ISNULL(MAX(ACH.TotalAmountFacturaZigi), 0) + ISNULL(MAX(CODZigiCalc.TotalCODZigi), 0) TotalZigi
           ,ISNULL(MAX(ACH.TotalAmountCashDeclared), 0) TotalCashDeclared
           ,ISNULL(MAX(ACH.TotalAmountCreditDeclared), 0) TotalCreditDeclared
           ,ISNULL(MAX(ACH.TotalAmountFacturaZigiDeclared), 0) + ISNULL(MAX(ACH.TotalAmountCODZigiDeclared), 0) TotalZigiDeclared
           ,ISNULL(MAX(CODCashCalc.TotalCODCash), 0) TotalCODCash
           ,ISNULL(MAX(CODZigiCalc.TotalCODZigi), 0) TotalAmountCODZigi
           -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
           ,ISNULL(MAX(ACH.TotalAmountCODCashDeclared), 0) TotalAmountCODCashDeclared
           ,ISNULL(MAX(ACH.TotalAmountCODZigiDeclared), 0) TotalAmountCODZigiDeclared
           ,ISNULL(MAX(ACH.TotalAmountFacturaCash), 0) TotalAmountFacturaCash
           ,ISNULL(MAX(ACH.TotalAmountFacturaCard), 0) TotalAmountFacturaCard
           ,ISNULL(MAX(ACH.TotalAmountFacturaZigi), 0) TotalAmountFacturaZigi
           ,ISNULL(MAX(ACH.TotalAmountFacturaCashDeclared), 0) TotalAmountFacturaCashDeclared
           ,ISNULL(MAX(ACH.TotalAmountFacturaCardDeclared), 0) TotalAmountFacturaCardDeclared
           ,ISNULL(MAX(ACH.TotalAmountFacturaZigiDeclared), 0) TotalAmountFacturaZigiDeclared
           ,ISNULL(
				MAX(ACH.TotalAmountCash + ACH.TotalAmountCredit +
                            ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard + 
                            ISNULL(CODCashCalc.TotalCODCash, 0) +
                            ACH.TotalAmountFacturaZigi + ISNULL(CODZigiCalc.TotalCODZigi, 0)), 0) TotalGeneral
           -- FIN MODIFICACIÓN
           ,CCC.CodeISO AS CurrencySymbol
        FROM DeliveryBackOffice.dbo.AccountingClosuresHeader ACH WITH(NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
            ON VPC.CodeOfReference = ACH.VisitPoint
        -- Subconsulta para COD Cash (evitar duplicados):
        LEFT JOIN (
            SELECT ACD.AccountingClosuresHeaderId,
                   SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 1 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODCash
            FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                ON DOPT.GuideSerie = ACD.GuideSerie
                AND DOPT.GuideNumber = ACD.GuideNumber
                AND DOPT.DopId = ACD.DopId
            GROUP BY ACD.AccountingClosuresHeaderId
        ) CODCashCalc ON CODCashCalc.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
        -- Subconsulta para COD Zigi (evitar duplicados):
        LEFT JOIN (
            SELECT ACD.AccountingClosuresHeaderId,
                   SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 10 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODZigi
            FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                ON DOPT.GuideSerie = ACD.GuideSerie
                AND DOPT.GuideNumber = ACD.GuideNumber
                AND DOPT.DopId = ACD.DopId
            GROUP BY ACD.AccountingClosuresHeaderId
        ) CODZigiCalc ON CODZigiCalc.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
            ON VPC.CountryId = DC.Currency_IdCountry
            AND DC.DefaultPerCountry = 1
        LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
            ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
        LEFT JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
            ON ACD.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)
            ON DOPD.GuideSerie = ACD.GuideSerie
            AND DOPD.GuideNumber = ACD.GuideNumber
        WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN @StartDateClean AND @EndDateClean
            AND (@VisitPointId IS NULL OR @VisitPointId = '-1' OR ACH.VisitPoint IN (SELECT CodeOfReference FROM @tblVisitPointId))
            AND (@IdCierre IS NULL OR @IdCierre = '-1' OR ACH.IdAccountingClosuresHeader IN (SELECT CierreId FROM @tblIdCierre))
            AND (@IdAccount IS NULL OR @IdAccount = '-1' OR DOPD.AccountId IN (SELECT AccountId FROM @tblIdAccount))
            AND VPC.CountryId = @IdCountry
        GROUP BY ACH.IdAccountingClosuresHeader, VPC.CountryId, CCC.CodeISO) X
    GROUP BY CurrencySymbol
END