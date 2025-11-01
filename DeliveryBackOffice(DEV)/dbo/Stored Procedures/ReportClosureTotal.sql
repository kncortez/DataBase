-- =============================================
-- Author:		<Author,Freddy Monterroso>
-- Create date: <Create Date,27-01-2022>
-- Description:	<Description, SP para mostrar totales en reporte>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <09/07/2024>
-- Description:	<Se agrega el simbolo de la moneda y las cuentas correspondientes al pais para el encabezado del reporte>
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-10-28>
-- Description:	<Se agrega campos de nuevo método de Zigi>
-- =============================================
CREATE PROCEDURE [dbo].[ReportClosureTotal]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @VisitPointId INT = NULL,
    @IdCierre INT = NULL
AS
BEGIN
	DECLARE @AccountExp NVARCHAR(30),
			@AccountCOD NVARCHAR(30);
	DECLARE @IdCountry NVARCHAR(2) = (SELECT CountryId FROM VisitPointClient WHERE CodeOfReference = @VisitPointId)

	SELECT @AccountExp = Name +' '+ '(' +AccountNumber +')' 
	FROM ClosureAccount 
	WHERE Name = 'Cuenta Express Center' AND ISNULL(IdCountry,'GT') = @IdCountry

	SELECT @AccountCOD = Name +' '+ '(' +AccountNumber +')' 
	FROM ClosureAccount 
	WHERE Name = 'Cuenta Área COD' AND ISNULL(IdCountry,'GT') = @IdCountry

    IF (@VisitPointId > 0 AND @IdCierre > 0)
    BEGIN
        SELECT @AccountExp AS AccountExp,
			   ISNULL(SUM(ACH.TotalAmountCash), 0) 'TotalCash',
               ISNULL(SUM(ACH.TotalAmountCredit), 0) 'TotalCredit',
               ISNULL(SUM(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               ISNULL(SUM(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
			   @AccountCOD AS AccountCOD,
               ISNULL(SUM(ACH.TotalAmountCODCash), 0) 'TotalCODCash',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               ISNULL(SUM(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               ISNULL(SUM(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               ISNULL(SUM(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               -- MODIFICACIÓN 28/10/2025 BILKAR MORATAYA
               @AccountZigi AS AccountZigi,
               ISNULL(SUM(ACH.TotalAmountZigi), 0) 'TotalAmountZigi',
               ISNULL(SUM(ACH.TotalAmountZigiDeclared), 0) 'TotalAmountZigiDeclared',
               ISNULL(SUM(ACH.TotalAmountCODZigi), 0) 'TotalAmountCODZigi',
               ISNULL(SUM(ACH.TotalAmountCODZigiDeclared), 0) 'TotalAmountCODZigiDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaZigi), 0) 'TotalAmountFacturaZigi',
               ISNULL(SUM(ACH.TotalAmountFacturaZigiDeclared), 0) 'TotalAmountFacturaZigiDeclared',
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash
                             + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard
                          + ACH.TotalAmountZigi + ACH.TotalAmountCODZigi + ACH.TotalAmountFacturaZigi
                            ),
                         0
                     ) 'TotalGeneral',
                -- FIN DE MODIFICACIÓN
			   CASE WHEN ISNULL(VPC.CountryId,'GT') = 'GT' THEN 'GTQ' ELSE 'HNL' END AS CurrencySymbol 
        -- FIN MODIFICACIÓN
        FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
        WHERE CONVERT(DATE, ACH.DateCreated)
              BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
              AND ACH.IdAccountingClosuresHeader = @IdCierre
              AND VPC.CodeOfReference = @VisitPointId
		GROUP BY VPC.CountryId;
    END;

    IF (@VisitPointId > 0 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
    BEGIN
        SELECT @AccountExp AS AccountExp,
		       ISNULL(SUM(ACH.TotalAmountCash), 0) 'TotalCash',
               ISNULL(SUM(ACH.TotalAmountCredit), 0) 'TotalCredit',
               ISNULL(SUM(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               ISNULL(SUM(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
			    @AccountCOD AS AccountCOD,
               ISNULL(SUM(ACH.TotalAmountCODCash), 0) 'TotalCODCash',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               ISNULL(SUM(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               ISNULL(SUM(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               ISNULL(SUM(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               -- MODIFICACIÓN 28/10/2025 BILKAR MORATAYA
               @AccountZigi AS AccountZigi,
               ISNULL(SUM(ACH.TotalAmountZigi), 0) 'TotalAmountZigi',
               ISNULL(SUM(ACH.TotalAmountZigiDeclared), 0) 'TotalAmountZigiDeclared',
               ISNULL(SUM(ACH.TotalAmountCODZigi), 0) 'TotalAmountCODZigi',
               ISNULL(SUM(ACH.TotalAmountCODZigiDeclared), 0) 'TotalAmountCODZigiDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaZigi), 0) 'TotalAmountFacturaZigi',
               ISNULL(SUM(ACH.TotalAmountFacturaZigiDeclared), 0) 'TotalAmountFacturaZigiDeclared',
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash
                             + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard
                          + ACH.TotalAmountZigi + ACH.TotalAmountCODZigi + ACH.TotalAmountFacturaZigi
                            ),
                         0
                     ) 'TotalGeneral',
                -- FIN DE MODIFICACIÓN
			  CASE WHEN ISNULL(VPC.CountryId,'GT') = 'GT' THEN 'GTQ' ELSE 'HNL' END AS CurrencySymbol
        -- FIN MODIFICACIÓN
        FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
        WHERE CONVERT(DATE, ACH.DateCreated)
        BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
        AND VPC.CodeOfReference = @VisitPointId
        GROUP BY VisitPoint, VPC.CountryId;
    END;

    IF (@VisitPointId = -1 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
    BEGIN
        SELECT @AccountExp AS AccountExp,
		       ISNULL(SUM(ACH.TotalAmountCash), 0) 'TotalCash',
               ISNULL(SUM(ACH.TotalAmountCredit), 0) 'TotalCredit',
               ISNULL(SUM(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               ISNULL(SUM(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
			    @AccountCOD AS AccountCOD,
               ISNULL(SUM(ACH.TotalAmountCODCash), 0) 'TotalCODCash',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               ISNULL(SUM(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               ISNULL(SUM(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               ISNULL(SUM(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
               -- MODIFICACIÓN 28/10/2025 BILKAR MORATAYA
               @AccountZigi AS AccountZigi,
               ISNULL(SUM(ACH.TotalAmountZigi), 0) 'TotalAmountZigi',
               ISNULL(SUM(ACH.TotalAmountZigiDeclared), 0) 'TotalAmountZigiDeclared',
               ISNULL(SUM(ACH.TotalAmountCODZigi), 0) 'TotalAmountCODZigi',
               ISNULL(SUM(ACH.TotalAmountCODZigiDeclared), 0) 'TotalAmountCODZigiDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaZigi), 0) 'TotalAmountFacturaZigi',
               ISNULL(SUM(ACH.TotalAmountFacturaZigiDeclared), 0) 'TotalAmountFacturaZigiDeclared',
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash
                             + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard
                          + ACH.TotalAmountZigi + ACH.TotalAmountCODZigi + ACH.TotalAmountFacturaZigi
                            ),
                         0
                     ) 'TotalGeneral',
                -- FIN DE MODIFICACIÓN
			  CASE WHEN ISNULL(VPC.CountryId, 'GT') = 'GT' THEN 'GTQ' ELSE 'HNL' END AS CurrencySymbol
        -- FIN MODIFICACIÓN
        FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
		INNER JOIN VisitPointClient VPC WITH (NOLOCK)
			ON ACH.VisitPoint = VPC.IdVisitPointClient
        WHERE CONVERT(DATE, ACH.DateCreated)
        BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
		GROUP BY VPC.CountryId;
    END;

END;
