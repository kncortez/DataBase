-- =============================================
-- Author:		<Alejandro Rodríguez>
-- Create date: <28-03-2022>
-- Description:	<SP para mostrar totales en reporte de VisitPoint>
-- Nota: Es una copia de ReportClosureTotal
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <10-07-2024>
-- Description:	<Se agrega la moneda y las cuentas para mostrar en el reporte>
-- =============================================
CREATE PROCEDURE  [dbo].[ReportClosureTotalVisitPoint] 
@StartDate datetime = null,
@EndDate datetime = null,
@VisitPointId INT = null,
@IdCierre INT = null
AS
BEGIN

    DECLARE @IdCountry NVARCHAR(2),
            @Account NVARCHAR(30),
            @AccountCOD NVARCHAR(30);

    SELECT @IdCountry = CountryId
    FROM VisitPointClient
    WHERE CodeOfReference = @VisitPointId

    SELECT @Account = Name + ' ' + '(' + AccountNumber + ')'
    FROM dbo.ClosureAccount
    WHERE Description = 'Cuenta Express Center'
          AND ISNULL(IdCountry, 'GT') = @IdCountry

    SELECT @AccountCOD = Name + ' ' + '(' + AccountNumber + ')'
    FROM dbo.ClosureAccount
    WHERE Description = 'Cuenta Área COD'
          AND ISNULL(IdCountry, 'GT') = @IdCountry

    if (@VisitPointId > 0 and @IdCierre > 0)
    begin
        SELECT @Account AS AccountExp,
			   isnull(sum(ACH.TotalAmountCash), 0) 'TotalCash',
               isnull(sum(ACH.TotalAmountCredit), 0) 'TotalCredit',
               isnull(sum(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               isnull(sum(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
			   @AccountCOD AS AccountCOD,
               isnull(sum(ACH.TotalAmountCODCash), 0) 'TotalCODCash',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               isnull(sum(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               isnull(sum(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               isnull(sum(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               isnull(sum(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               isnull(sum(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               isnull(sum(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard),0) 'TotalGeneral',
               -- FIN MODIFICACIÓN
               CCC.CodeISO AS CurrencySymbol
        FROM dbo.AccountingClosuresHeaderVisitPoint ACH
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
				ON VPC.CountryId = DC.Currency_IdCountry
                AND DC.DefaultPerCountry = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
				ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
        WHERE CONVERT(DATE, ACH.DateCreated)
              BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
          AND ACH.IdAccountingClosuresHeaderVisitPoint = @IdCierre
          AND VPC.CodeOfReference = @VisitPointId
        GROUP BY VPC.CountryId, CCC.CodeISO
    end

    if (@VisitPointId > 0 and (@IdCierre <= 0 or @IdCierre is null))
    begin
        SELECT @Account AS AccountExp,
			   isnull(sum(ACH.TotalAmountCash), 0) 'TotalCash',
               isnull(sum(ACH.TotalAmountCredit), 0) 'TotalCredit',
               isnull(sum(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               isnull(sum(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
			   @AccountCOD AS AccountCOD,
               isnull(sum(ACH.TotalAmountCODCash), 0) 'TotalCODCash',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               isnull(sum(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               isnull(sum(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               isnull(sum(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               isnull(sum(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               isnull(sum(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               isnull(sum(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard),0) 'TotalGeneral',
               -- FIN MODIFICACIÓN
               CCC.CodeISO AS CurrencySymbol
        FROM dbo.AccountingClosuresHeaderVisitPoint ACH
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
				ON VPC.CountryId = DC.Currency_IdCountry
                AND DC.DefaultPerCountry = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
				ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
        WHERE CONVERT(DATE, ACH.DateCreated)
        BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
          AND VPC.CodeOfReference = @VisitPointId
        GROUP BY VisitPoint, VPC.CountryId, CCC.CodeISO
    end

    if (@VisitPointId = -1 and (@IdCierre <= 0 or @IdCierre is null))
    begin
        SELECT @Account AS AccountExp,
			   isnull(sum(ACH.TotalAmountCash), 0) 'TotalCash',
               isnull(sum(ACH.TotalAmountCredit), 0) 'TotalCredit',
               isnull(sum(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               isnull(sum(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
			   @AccountCOD AS AccountCOD,
               isnull(sum(ACH.TotalAmountCODCash), 0) 'TotalCODCash',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               isnull(sum(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               isnull(sum(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               isnull(sum(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               isnull(sum(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               isnull(sum(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               isnull(sum(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard),0) 'TotalGeneral',
               -- FIN MODIFICACIÓN
               CCC.CodeISO AS CurrencySymbol
        FROM dbo.AccountingClosuresHeaderVisitPoint ACH
            INNER JOIN VisitPointClient VPC WITH (NOLOCK)
                ON ACH.VisitPoint = VPC.IdVisitPointClient
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
				ON VPC.CountryId = DC.Currency_IdCountry
                AND DC.DefaultPerCountry = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
				ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
        WHERE CONVERT(DATE, ACH.DateCreated)
        BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
        GROUP BY VPC.CountryId, CCC.CodeISO
    end

END
