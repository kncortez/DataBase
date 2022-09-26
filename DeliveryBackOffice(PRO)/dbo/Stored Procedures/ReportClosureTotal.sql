-- =============================================
-- Author:		<Author,Freddy Monterroso>
-- Create date: <Create Date,27-01-2022>
-- Description:	<Description, SP para mostrar totales en reporte>
-- =============================================
CREATE PROCEDURE [dbo].[ReportClosureTotal]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @VisitPointId INT = NULL,
    @IdCierre INT = NULL
AS
BEGIN

    IF (@VisitPointId > 0 AND @IdCierre > 0)
    BEGIN
        SELECT ISNULL(SUM(ACH.TotalAmountCash), 0) 'TotalCash',
               ISNULL(SUM(ACH.TotalAmountCredit), 0) 'TotalCredit',
               ISNULL(SUM(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               ISNULL(SUM(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
               ISNULL(SUM(ACH.TotalAmountCODCash), 0) 'TotalCODCash',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               ISNULL(SUM(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               ISNULL(SUM(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               ISNULL(SUM(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash
                             + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard
                            ),
                         0
                     ) 'TotalGeneral'
        -- FIN MODIFICACIÓN
        FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
                   AND VPC.CodeOfReference = @VisitPointId
        WHERE CONVERT(DATE, ACH.DateCreated)
              BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
              AND ACH.IdAccountingClosuresHeader = @IdCierre;
    END;

    IF (@VisitPointId > 0 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
    BEGIN
        SELECT ISNULL(SUM(ACH.TotalAmountCash), 0) 'TotalCash',
               ISNULL(SUM(ACH.TotalAmountCredit), 0) 'TotalCredit',
               ISNULL(SUM(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               ISNULL(SUM(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
               ISNULL(SUM(ACH.TotalAmountCODCash), 0) 'TotalCODCash',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               ISNULL(SUM(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               ISNULL(SUM(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               ISNULL(SUM(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash
                             + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard
                            ),
                         0
                     ) 'TotalGeneral'
        -- FIN MODIFICACIÓN
        FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
                   AND VPC.CodeOfReference = @VisitPointId
        WHERE CONVERT(DATE, ACH.DateCreated)
        BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
        GROUP BY VisitPoint;
    END;

    IF (@VisitPointId = -1 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
    BEGIN
        SELECT ISNULL(SUM(ACH.TotalAmountCash), 0) 'TotalCash',
               ISNULL(SUM(ACH.TotalAmountCredit), 0) 'TotalCredit',
               ISNULL(SUM(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               ISNULL(SUM(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
               ISNULL(SUM(ACH.TotalAmountCODCash), 0) 'TotalCODCash',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               ISNULL(SUM(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               ISNULL(SUM(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               ISNULL(SUM(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash
                             + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard
                            ),
                         0
                     ) 'TotalGeneral'
        -- FIN MODIFICACIÓN
        FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
        WHERE CONVERT(DATE, ACH.DateCreated)
        BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate);
    END;

END;
