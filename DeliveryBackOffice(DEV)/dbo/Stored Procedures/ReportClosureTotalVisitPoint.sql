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
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <08-04-2025>
-- Description:	<Mejoras de multipaís para moneda en SV.>
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-11-07>
-- Description:	<Se agrega campos de nuevo método de Zigi>
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
            @AccountCOD NVARCHAR(30),
            @AccountZigi NVARCHAR(30);

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

    SELECT @AccountZigi = Name + ' ' + '(' + AccountNumber + ')'
    FROM dbo.ClosureAccount
    WHERE Description = 'Cuenta Zigi'
          AND ISNULL(IdCountry, 'GT') = @IdCountry

    if (@VisitPointId > 0 and @IdCierre > 0)
    begin
        SELECT @Account AS AccountExp,
			   isnull(sum(ACH.TotalAmountCash), 0) 'TotalCash',
               isnull(sum(ACH.TotalAmountCredit), 0) 'TotalCredit',
               isnull(sum(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               isnull(sum(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
			   @AccountCOD AS AccountCOD,
               -- MODIFICACIÓN 07/11/2025: Calcular COD Cash desde transacciones
               isnull(sum(CODCashCalc.TotalCODCash), 0) 'TotalCODCash',
               isnull(sum(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               -- FIN MODIFICACIÓN
               isnull(sum(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               isnull(sum(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               isnull(sum(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               isnull(sum(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               -- MODIFICACIÓN 07/11/2025: Separar correctamente Zigi
               @AccountZigi AS AccountZigi,
               -- TotalAmountZigi debe ser la suma de Facturas + COD Zigi:
               ISNULL(SUM(ACH.TotalAmountFacturaZigi), 0) + ISNULL(SUM(CODZigiCalc.TotalCODZigi), 0) 'TotalAmountZigi',
               ISNULL(SUM(ACH.TotalAmountFacturaZigiDeclared), 0) + ISNULL(SUM(ACH.TotalAmountCODZigiDeclared), 0) 'TotalAmountZigiDeclared',
               -- COD Zigi calculado desde transacciones:
               ISNULL(SUM(CODZigiCalc.TotalCODZigi), 0) 'TotalAmountCODZigi',
               ISNULL(SUM(ACH.TotalAmountCODZigiDeclared), 0) 'TotalAmountCODZigiDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaZigi), 0) 'TotalAmountFacturaZigi',
               ISNULL(SUM(ACH.TotalAmountFacturaZigiDeclared), 0) 'TotalAmountFacturaZigiDeclared',
               -- Total General corregido:
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + 
                             ISNULL(CODCashCalc.TotalCODCash, 0) +
                             ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard +
                             ISNULL(CODZigiCalc.TotalCODZigi, 0) + ACH.TotalAmountFacturaZigi
                            ),
                         0
                     ) 'TotalGeneral',
               -- FIN MODIFICACIÓN
               CCC.CodeISO AS CurrencySymbol
        FROM dbo.AccountingClosuresHeaderVisitPoint ACH
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
            -- Subconsulta para COD Cash (evitar duplicados):
            LEFT JOIN (
                SELECT ACHVP.IdAccountingClosuresHeaderVisitPoint,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 1 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODCash
                FROM AccountingClosuresHeader ACHeader WITH (NOLOCK)
                LEFT JOIN AccountingClosuresDetail ACD WITH (NOLOCK)
                    ON ACD.AccountingClosuresHeaderId = ACHeader.IdAccountingClosuresHeader
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                INNER JOIN AccountingClosuresHeaderVisitPoint ACHVP WITH (NOLOCK)
                    ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACHeader.AccountingClosuresHeaderVisitPointId
                GROUP BY ACHVP.IdAccountingClosuresHeaderVisitPoint
            ) CODCashCalc ON CODCashCalc.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint
            -- Subconsulta para COD Zigi (evitar duplicados):
            LEFT JOIN (
                SELECT ACHVP.IdAccountingClosuresHeaderVisitPoint,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 10 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODZigi
                FROM AccountingClosuresHeader ACHeader WITH (NOLOCK)
                LEFT JOIN AccountingClosuresDetail ACD WITH (NOLOCK)
                    ON ACD.AccountingClosuresHeaderId = ACHeader.IdAccountingClosuresHeader
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                INNER JOIN AccountingClosuresHeaderVisitPoint ACHVP WITH (NOLOCK)
                    ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACHeader.AccountingClosuresHeaderVisitPointId
                GROUP BY ACHVP.IdAccountingClosuresHeaderVisitPoint
            ) CODZigiCalc ON CODZigiCalc.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint
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
               -- MODIFICACIÓN 07/11/2025: Calcular COD Cash desde transacciones
               isnull(sum(CODCashCalc.TotalCODCash), 0) 'TotalCODCash',
               isnull(sum(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               -- FIN MODIFICACIÓN
               isnull(sum(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               isnull(sum(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               isnull(sum(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               isnull(sum(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               -- MODIFICACIÓN 07/11/2025: Separar correctamente Zigi
               @AccountZigi AS AccountZigi,
               -- TotalAmountZigi debe ser la suma de Facturas + COD Zigi:
               ISNULL(SUM(ACH.TotalAmountFacturaZigi), 0) + ISNULL(SUM(CODZigiCalc.TotalCODZigi), 0) 'TotalAmountZigi',
               ISNULL(SUM(ACH.TotalAmountFacturaZigiDeclared), 0) + ISNULL(SUM(ACH.TotalAmountCODZigiDeclared), 0) 'TotalAmountZigiDeclared',
               -- COD Zigi calculado desde transacciones:
               ISNULL(SUM(CODZigiCalc.TotalCODZigi), 0) 'TotalAmountCODZigi',
               ISNULL(SUM(ACH.TotalAmountCODZigiDeclared), 0) 'TotalAmountCODZigiDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaZigi), 0) 'TotalAmountFacturaZigi',
               ISNULL(SUM(ACH.TotalAmountFacturaZigiDeclared), 0) 'TotalAmountFacturaZigiDeclared',
               -- Total General corregido:
               ISNULL(
                        SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + 
                            ISNULL(CODCashCalc.TotalCODCash, 0) +
                            ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard +
                            ISNULL(CODZigiCalc.TotalCODZigi, 0) + ACH.TotalAmountFacturaZigi
                            ),
                         0
                     ) 'TotalGeneral',
               CCC.CodeISO AS CurrencySymbol
        FROM dbo.AccountingClosuresHeaderVisitPoint ACH
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
            -- Subconsulta para COD Cash (evitar duplicados):
            LEFT JOIN (
                SELECT ACHVP.IdAccountingClosuresHeaderVisitPoint,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 1 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODCash
                FROM AccountingClosuresHeader ACHeader WITH (NOLOCK)
                LEFT JOIN AccountingClosuresDetail ACD WITH (NOLOCK)
                    ON ACD.AccountingClosuresHeaderId = ACHeader.IdAccountingClosuresHeader
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                INNER JOIN AccountingClosuresHeaderVisitPoint ACHVP WITH (NOLOCK)
                    ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACHeader.AccountingClosuresHeaderVisitPointId
                GROUP BY ACHVP.IdAccountingClosuresHeaderVisitPoint
            ) CODCashCalc ON CODCashCalc.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint
            -- Subconsulta para COD Zigi (evitar duplicados):
            LEFT JOIN (
                SELECT ACHVP.IdAccountingClosuresHeaderVisitPoint,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 10 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODZigi
                FROM AccountingClosuresHeader ACHeader WITH (NOLOCK)
                LEFT JOIN AccountingClosuresDetail ACD WITH (NOLOCK)
                    ON ACD.AccountingClosuresHeaderId = ACHeader.IdAccountingClosuresHeader
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                INNER JOIN AccountingClosuresHeaderVisitPoint ACHVP WITH (NOLOCK)
                    ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACHeader.AccountingClosuresHeaderVisitPointId
                GROUP BY ACHVP.IdAccountingClosuresHeaderVisitPoint
            ) CODZigiCalc ON CODZigiCalc.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint
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
               -- MODIFICACIÓN 07/11/2025: Calcular COD Cash desde transacciones
               isnull(sum(CODCashCalc.TotalCODCash), 0) 'TotalCODCash',
               isnull(sum(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               -- FIN MODIFICACIÓN
               isnull(sum(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               isnull(sum(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               isnull(sum(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               isnull(sum(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               -- MODIFICACIÓN 07/11/2025: Separar correctamente Zigi
               @AccountZigi AS AccountZigi,
               -- TotalAmountZigi debe ser la suma de Facturas + COD Zigi:
               ISNULL(SUM(ACH.TotalAmountFacturaZigi), 0) + ISNULL(SUM(CODZigiCalc.TotalCODZigi), 0) 'TotalAmountZigi',
               ISNULL(SUM(ACH.TotalAmountFacturaZigiDeclared), 0) + ISNULL(SUM(ACH.TotalAmountCODZigiDeclared), 0) 'TotalAmountZigiDeclared',
               -- COD Zigi calculado desde transacciones:
               ISNULL(SUM(CODZigiCalc.TotalCODZigi), 0) 'TotalAmountCODZigi',
               ISNULL(SUM(ACH.TotalAmountCODZigiDeclared), 0) 'TotalAmountCODZigiDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaZigi), 0) 'TotalAmountFacturaZigi',
               ISNULL(SUM(ACH.TotalAmountFacturaZigiDeclared), 0) 'TotalAmountFacturaZigiDeclared',
               -- Total General corregido:
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + 
                             ISNULL(CODCashCalc.TotalCODCash, 0) +
                             ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard +
                             ISNULL(CODZigiCalc.TotalCODZigi, 0) + ACH.TotalAmountFacturaZigi
                            ),
                         0
                     ) 'TotalGeneral',
               CCC.CodeISO AS CurrencySymbol
        FROM dbo.AccountingClosuresHeaderVisitPoint ACH
            INNER JOIN VisitPointClient VPC WITH (NOLOCK)
                ON ACH.VisitPoint = VPC.IdVisitPointClient
            -- Subconsulta para COD Cash (evitar duplicados):
            LEFT JOIN (
                SELECT ACHVP.IdAccountingClosuresHeaderVisitPoint,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 1 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODCash
                FROM AccountingClosuresHeader ACHeader WITH (NOLOCK)
                LEFT JOIN AccountingClosuresDetail ACD WITH (NOLOCK)
                    ON ACD.AccountingClosuresHeaderId = ACHeader.IdAccountingClosuresHeader
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                INNER JOIN AccountingClosuresHeaderVisitPoint ACHVP WITH (NOLOCK)
                    ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACHeader.AccountingClosuresHeaderVisitPointId
                GROUP BY ACHVP.IdAccountingClosuresHeaderVisitPoint
            ) CODCashCalc ON CODCashCalc.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint
            -- Subconsulta para COD Zigi (evitar duplicados):
            LEFT JOIN (
                SELECT ACHVP.IdAccountingClosuresHeaderVisitPoint,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 10 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODZigi
                FROM AccountingClosuresHeader ACHeader WITH (NOLOCK)
                LEFT JOIN AccountingClosuresDetail ACD WITH (NOLOCK)
                    ON ACD.AccountingClosuresHeaderId = ACHeader.IdAccountingClosuresHeader
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                INNER JOIN AccountingClosuresHeaderVisitPoint ACHVP WITH (NOLOCK)
                    ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACHeader.AccountingClosuresHeaderVisitPointId
                GROUP BY ACHVP.IdAccountingClosuresHeaderVisitPoint
            ) CODZigiCalc ON CODZigiCalc.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint
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