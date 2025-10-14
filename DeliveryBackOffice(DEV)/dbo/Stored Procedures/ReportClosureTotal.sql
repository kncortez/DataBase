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
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash
                             + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard
                            ),
                         0
                     ) 'TotalGeneral',
               ISNULL(CCC.CodeISO,'') CurrencySymbol
        -- FIN MODIFICACIÓN
        FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
				ON ISNULL(VPC.CountryId,'GT') = DC.Currency_IdCountry
			LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
				ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
        WHERE CONVERT(DATE, ACH.DateCreated)
              BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
              AND ACH.IdAccountingClosuresHeader = @IdCierre
              AND VPC.CodeOfReference = @VisitPointId
              AND DC.DefaultPerCountry = 1
		GROUP BY VPC.CountryId, CCC.CodeISO;
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
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash
                             + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard
                            ),
                         0
                     ) 'TotalGeneral',
			  ISNULL(CCC.CodeISO,'') CurrencySymbol
        -- FIN MODIFICACIÓN
        FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
				ON ISNULL(VPC.CountryId,'GT') = DC.Currency_IdCountry
			LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
				ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
        WHERE CONVERT(DATE, ACH.DateCreated)
        BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
        AND VPC.CodeOfReference = @VisitPointId
        AND DC.DefaultPerCountry = 1
        GROUP BY VisitPoint, VPC.CountryId, CCC.CodeISO;
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
               ISNULL(
                         SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash
                             + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard
                            ),
                         0
                     ) 'TotalGeneral',
			  ISNULL(CCC.CodeISO,'') CurrencySymbol
        -- FIN MODIFICACIÓN
        FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
		INNER JOIN VisitPointClient VPC WITH (NOLOCK)
			ON ACH.VisitPoint = VPC.IdVisitPointClient
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
				ON ISNULL(VPC.CountryId,'GT') = DC.Currency_IdCountry
			LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
				ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
        WHERE CONVERT(DATE, ACH.DateCreated)
        BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
        AND DC.DefaultPerCountry = 1
		GROUP BY VPC.CountryId, CCC.CodeISO;
    END;

END;
