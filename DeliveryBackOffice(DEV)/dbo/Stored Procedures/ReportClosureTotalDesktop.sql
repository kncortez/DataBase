-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-04>
-- Description:	<SP para mostrar totales en reporte de cierres en desktop>
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-07-08>
-- Description:	<Se agrega el simbolo de la moneda, segun pais de origen, para encabezado del reporte>
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-11-04>
-- Description:	<Se agrega el método de pago Zigi en los totales del reporte de cierres en desktop>
-- =============================================
CREATE PROCEDURE  [dbo].[ReportClosureTotalDesktop] 
    @StartDate datetime = NULL,
    @EndDate datetime = NULL,
    @VisitPointId NVARCHAR(MAX) = NULL,
    @IdCierre NVARCHAR(MAX) = NULL,
    @IdAccount NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @AccountExp NVARCHAR(30),
            @AccountCOD NVARCHAR(30),
            @AccountZigi NVARCHAR(30);
    DECLARE @IdCountry NVARCHAR(2) = (SELECT CountryId FROM VisitPointClient WITH (NOLOCK) WHERE CodeOfReference = @VisitPointId)

    SELECT @AccountExp = Name +' '+ '(' +AccountNumber +')' 
    FROM ClosureAccount WITH (NOLOCK)
    WHERE Name = 'Cuenta Express Center' AND IdCountry = @IdCountry

    SELECT @AccountCOD = Name +' '+ '(' +AccountNumber +')' 
    FROM ClosureAccount WITH (NOLOCK)
    WHERE Name = 'Cuenta Área COD' AND IdCountry = @IdCountry

    SELECT @AccountZigi = Name +' '+ '(' +AccountNumber +')' 
    FROM ClosureAccount WITH (NOLOCK)
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
           ,ISNULL(MAX(ACH.TotalAmountZigi), 0) TotalZigi
           ,ISNULL(MAX(ACH.TotalAmountCashDeclared), 0) TotalCashDeclared
           ,ISNULL(MAX(ACH.TotalAmountCreditDeclared), 0) TotalCreditDeclared
           ,ISNULL(MAX(ACH.TotalAmountZigiDeclared), 0) TotalZigiDeclared
           ,ISNULL(MAX(ACH.TotalAmountCODCash), 0) TotalCODCash
           ,ISNULL(MAX(ACH.TotalAmountCODZigi), 0) TotalAmountCODZigi
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
                            ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard + ACH.TotalAmountCODCash +
                            ACH.TotalAmountFacturaZigi + ACH.TotalAmountCODZigi), 0) 'TotalGeneral'
           -- FIN MODIFICACIÓN
           ,CCC.CodeISO AS CurrencySymbol
        FROM dbo.AccountingClosuresHeader ACH WITH(NOLOCK)
        LEFT JOIN dbo.VisitPointClient VPC WITH(NOLOCK)
            ON VPC.CodeOfReference = ACH.VisitPoint
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
            ON VPC.CountryId = DC.Currency_IdCountry
            AND DC.DefaultPerCountry = 1
        LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
            ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
        LEFT JOIN AccountingClosuresDetail ACD WITH(NOLOCK)
            ON ACD.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
        LEFT JOIN DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)
            ON DOPD.GuideSerie = ACD.GuideSerie
            AND DOPD.GuideNumber = ACD.GuideNumber
        WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
            AND (@VisitPointId IS NULL OR ACH.VisitPoint IN (SELECT CodeOfReference FROM @tblVisitPointId))
            AND (@IdCierre IS NULL OR ACH.IdAccountingClosuresHeader IN (SELECT CierreId FROM @tblIdCierre))
            AND (@IdAccount IS NULL OR DOPD.AccountId IN (SELECT AccountId FROM @tblIdAccount))
        GROUP BY ACH.IdAccountingClosuresHeader, VPC.CountryId, CCC.CodeISO) X
    GROUP BY CurrencySymbol
END