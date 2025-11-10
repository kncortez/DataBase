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
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @VisitPointId INT = NULL,
    @IdCierre INT = NULL
AS
BEGIN
	DECLARE @AccountExp NVARCHAR(30),
			@AccountCOD NVARCHAR(30),
			@AccountZigi NVARCHAR(30);
	DECLARE @IdCountry NVARCHAR(2) = (SELECT CountryId FROM VisitPointClient WHERE CodeOfReference = @VisitPointId)

	SELECT @AccountExp = Name +' '+ '(' +AccountNumber +')' 
	FROM ClosureAccount 
	WHERE Name = 'Cuenta Express Center' AND ISNULL(IdCountry,'GT') = @IdCountry

	SELECT @AccountCOD = Name +' '+ '(' +AccountNumber +')' 
	FROM ClosureAccount 
	WHERE Name = 'Cuenta Área COD' AND ISNULL(IdCountry,'GT') = @IdCountry

	SELECT @AccountZigi = Name +' '+ '(' +AccountNumber +')' 
	FROM ClosureAccount 
	WHERE Name = 'Cuenta Zigi' AND ISNULL(IdCountry,'GT') = @IdCountry

    IF (@VisitPointId > 0 AND @IdCierre > 0)
    BEGIN
        SELECT @AccountExp AS AccountExp,
			   ISNULL(SUM(ACH.TotalAmountCash), 0) 'TotalCash',
               ISNULL(SUM(ACH.TotalAmountCredit), 0) 'TotalCredit',
               ISNULL(SUM(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               ISNULL(SUM(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
			   @AccountCOD AS AccountCOD,
               -- MODIFICACIÓN 07/11/2025: Calcular COD Cash desde transacciones
               ISNULL(SUM(CODCashCalc.TotalCODCash), 0) 'TotalCODCash',
               ISNULL(SUM(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               -- FIN MODIFICACIÓN
               ISNULL(SUM(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               ISNULL(SUM(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               ISNULL(SUM(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
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
                            ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard + 
                            ISNULL(CODCashCalc.TotalCODCash, 0) +
                            ACH.TotalAmountFacturaZigi + ISNULL(CODZigiCalc.TotalCODZigi, 0)
                            ),
                         0
                     ) 'TotalGeneral',
                -- FIN DE MODIFICACIÓN
<<<<<<< HEAD
               CCC.CodeISO CurrencySymbol
        -- FIN MODIFICACIÓN
=======
			   CCC.CodeISO CurrencySymbol
>>>>>>> de3ff128 (FDAPI-4438: Cambios finales en SPs para eliminar duplicidades y que sea comportamiento de COD separados (efectivo y Zigi))
        FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
            -- Subconsulta para COD Cash (evitar duplicados):
            LEFT JOIN (
                SELECT ACD.AccountingClosuresHeaderId,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 1 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODCash
                FROM AccountingClosuresDetail ACD WITH (NOLOCK)
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                GROUP BY ACD.AccountingClosuresHeaderId
            ) CODCashCalc ON CODCashCalc.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
            -- Subconsulta para COD Zigi (evitar duplicados):
            LEFT JOIN (
                SELECT ACD.AccountingClosuresHeaderId,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 10 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODZigi
                FROM AccountingClosuresDetail ACD WITH (NOLOCK)
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                GROUP BY ACD.AccountingClosuresHeaderId
            ) CODZigiCalc ON CODZigiCalc.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
				ON ISNULL(VPC.CountryId,'GT') = DC.Currency_IdCountry
                AND DC.DefaultPerCountry = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
				ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
        WHERE CONVERT(DATE, ACH.DateCreated)
              BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
              AND ACH.IdAccountingClosuresHeader = @IdCierre
              AND VPC.CodeOfReference = @VisitPointId
		GROUP BY VisitPoint, VPC.CountryId, CCC.CodeISO;
    END;

    IF (@VisitPointId > 0 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
    BEGIN
        SELECT @AccountExp AS AccountExp,
		       ISNULL(SUM(ACH.TotalAmountCash), 0) 'TotalCash',
               ISNULL(SUM(ACH.TotalAmountCredit), 0) 'TotalCredit',
               ISNULL(SUM(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared',
               ISNULL(SUM(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared',
			    @AccountCOD AS AccountCOD,
               -- MODIFICACIÓN 07/11/2025: Calcular COD Cash desde transacciones
               ISNULL(SUM(CODCashCalc.TotalCODCash), 0) 'TotalCODCash',
               ISNULL(SUM(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               -- FIN MODIFICACIÓN
               ISNULL(SUM(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               ISNULL(SUM(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               ISNULL(SUM(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
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
                            ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard + 
                            ISNULL(CODCashCalc.TotalCODCash, 0) +
                            ACH.TotalAmountFacturaZigi + ISNULL(CODZigiCalc.TotalCODZigi, 0)
                            ),
                         0
                     ) 'TotalGeneral',
                -- FIN DE MODIFICACIÓN
<<<<<<< HEAD
               CCC.CodeISO CurrencySymbol
        -- FIN MODIFICACIÓN
=======
			  CCC.CodeISO CurrencySymbol
>>>>>>> de3ff128 (FDAPI-4438: Cambios finales en SPs para eliminar duplicidades y que sea comportamiento de COD separados (efectivo y Zigi))
          FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
            INNER JOIN dbo.VisitPointClient VPC WITH (NOLOCK)
                ON VPC.CodeOfReference = ACH.VisitPoint
            -- Subconsulta para COD Cash (evitar duplicados):
            LEFT JOIN (
                SELECT ACD.AccountingClosuresHeaderId,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 1 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODCash
                FROM AccountingClosuresDetail ACD WITH (NOLOCK)
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                GROUP BY ACD.AccountingClosuresHeaderId
            ) CODCashCalc ON CODCashCalc.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
            -- Subconsulta para COD Zigi (evitar duplicados):
            LEFT JOIN (
                SELECT ACD.AccountingClosuresHeaderId,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 10 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODZigi
                FROM AccountingClosuresDetail ACD WITH (NOLOCK)
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                GROUP BY ACD.AccountingClosuresHeaderId
            ) CODZigiCalc ON CODZigiCalc.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
				ON ISNULL(VPC.CountryId,'GT') = DC.Currency_IdCountry
                AND DC.DefaultPerCountry = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
				ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
        WHERE CONVERT(DATE, ACH.DateCreated)
        BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
        AND VPC.CodeOfReference = @VisitPointId
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
               -- MODIFICACIÓN 07/11/2025: Calcular COD Cash desde transacciones
               ISNULL(SUM(CODCashCalc.TotalCODCash), 0) 'TotalCODCash',
               ISNULL(SUM(ACH.TotalAmountCODCashDeclared), 0) 'TotalCODCashDeclared',
               -- FIN MODIFICACIÓN
               ISNULL(SUM(ACH.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
               ISNULL(SUM(ACH.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
               ISNULL(SUM(ACH.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
               ISNULL(SUM(ACH.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
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
                            ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard + 
                            ISNULL(CODCashCalc.TotalCODCash, 0) +
                            ACH.TotalAmountFacturaZigi + ISNULL(CODZigiCalc.TotalCODZigi, 0)
                            ),
                         0
                     ) 'TotalGeneral',
                -- FIN DE MODIFICACIÓN
<<<<<<< HEAD
               CCC.CodeISO CurrencySymbol
        -- FIN MODIFICACIÓN
=======
			  CCC.CodeISO CurrencySymbol
>>>>>>> de3ff128 (FDAPI-4438: Cambios finales en SPs para eliminar duplicidades y que sea comportamiento de COD separados (efectivo y Zigi))
         FROM dbo.AccountingClosuresHeader ACH WITH (NOLOCK)
		INNER JOIN VisitPointClient VPC WITH (NOLOCK)
			ON ACH.VisitPoint = VPC.IdVisitPointClient
            -- Subconsulta para COD Cash (evitar duplicados):
            LEFT JOIN (
                SELECT ACD.AccountingClosuresHeaderId,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 1 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODCash
                FROM AccountingClosuresDetail ACD WITH (NOLOCK)
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
                    ON DOPT.GuideSerie = ACD.GuideSerie
                    AND DOPT.GuideNumber = ACD.GuideNumber
                    AND DOPT.DopId = ACD.DopId
                GROUP BY ACD.AccountingClosuresHeaderId
            ) CODCashCalc ON CODCashCalc.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
            -- Subconsulta para COD Zigi (evitar duplicados):
            LEFT JOIN (
                SELECT ACD.AccountingClosuresHeaderId,
                       SUM(CASE WHEN DOPT.TypeofInOutMoneyId = 10 THEN DOPT.CODAmountProcess ELSE 0 END) AS TotalCODZigi
                FROM AccountingClosuresDetail ACD WITH (NOLOCK)
                LEFT JOIN DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
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
        WHERE CONVERT(DATE, ACH.DateCreated)
        BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
		GROUP BY VPC.CountryId, CCC.CodeISO;
    END;

END;