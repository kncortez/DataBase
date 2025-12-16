-- =============================================
-- Author:		<Alejandro Rodríguez>
-- Create date: <2022-03-28>
-- Description:	<SP para obtener la lista de guías que se procesaron en un express center>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-07-04>
-- Description:	<Se agrega las cuentas y el simbolo de la moneda correspondiente>
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-11-06>
-- Description:	<Se agrega la opción a mostrar que el pago fue con Zigi>
-- =============================================
CREATE PROCEDURE [dbo].[GetDataForClosureVisitPoint]
@VisitPointId int = 4246,
@IdAccount int = 0
AS
BEGIN

	DECLARE @IdCountry NVARCHAR(2),
		    @Account NVARCHAR(30),
			@AccountCOD NVARCHAR(30),
	        @AccountZigi NVARCHAR(30);

	SELECT @IdCountry = CountryId 
	FROM VisitPointClient 
	WHERE CodeOfReference = @VisitPointId

	SELECT @Account = Name +' '+ '('+ AccountNumber +')' 
	FROM dbo.ClosureAccount 
	WHERE Description = 'Cuenta Express Center' AND IdCountry = @IdCountry
	
	SELECT @AccountCOD = Name +' '+ '('+ AccountNumber +')' 
	FROM dbo.ClosureAccount 
	WHERE Description = 'Cuenta Área COD' AND IdCountry = @IdCountry

	-- MODIFICACIÓN [17/10/2025] - Campos para Zigi
	SELECT @AccountZigi = Name +' '+ '('+ AccountNumber +')'
	FROM dbo.ClosureAccount
	WHERE Description = 'Cuenta Zigi' AND IdCountry = @IdCountry
	

	SELECT	UsrIdUser 'UserId', UsrNickName 'UserNickName', DateCreated, IdAccountingClosuresHeader 'IdCierre',
		ISNULL(SUM(S1.TotalAmountCash), 0) 'TotalAmountCash',
		ISNULL(SUM(S1.TotalAmountCashDeclared), 0) 'TotalAmountCashDeclared',
		ISNULL(SUM(S1.TotalAmountCredit), 0) 'TotalAmountCredit',
		ISNULL(SUM(S1.TotalAmountCreditDeclared), 0) 'TotalAmountCreditDeclared',
		ISNULL(SUM(S1.TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
		ISNULL(SUM(S1.TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
		ISNULL(SUM(S1.TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
		ISNULL(SUM(S1.TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
		ISNULL(SUM(S1.TotalAmountCODCash), 0) 'TotalAmountCODCash',
		ISNULL(SUM(S1.TotalAmountCODCashDeclared), 0) 'TotalAmountCODCashDeclared',
		-- MODIFICACIÓN [17/10/2025] - Campos para Zigi
		-- TotalAmountZigi debe ser la suma de Facturas + COD:
		ISNULL(SUM(S1.TotalAmountFacturaZigi + S1.TotalAmountCODZigi), 0) 'TotalAmountZigi',
		ISNULL(SUM(S1.TotalAmountFacturaZigiDeclared + S1.TotalAmountCODZigiDeclared), 0) 'TotalAmountZigiDeclared',
		ISNULL(SUM(S1.TotalAmountFacturaZigi), 0) 'TotalAmountFacturaZigi',
		ISNULL(SUM(S1.TotalAmountFacturaZigiDeclared), 0) 'TotalAmountFacturaZigiDeclared',
		ISNULL(SUM(S1.TotalAmountCODZigi), 0) 'TotalAmountCODZigi',
		ISNULL(SUM(S1.TotalAmountCODZigiDeclared), 0) 'TotalAmountCODZigiDeclared',
		-- FIN MODIFICACIÓN
		S1.CurrencySymbolDetail
	FROM 
	(
		SELECT	TotalAmountCash, TotalAmountCashDeclared, InvoiceAmountCash,
				TotalAmountCredit, TotalAmountCreditDeclared, InvoiceAmountCredit,
				TotalAmountFacturaCash, TotalAmountFacturaCashDeclared, InvoiceAmountFacturaCash,
				TotalAmountFacturaCard, TotalAmountFacturaCardDeclared, InvoiceAmountFacturaCard,
				-- COD Cash desde subconsulta agrupada:
				ISNULL(CODCashCalc.TotalCODCash, 0) AS TotalAmountCODCash,
				ACH.TotalAmountCODCashDeclared,
				ACH.InvoiceAmountCOD,
				-- MODIFICACIÓN [17/10/2025] - Campos para Zigi
				ACH.TotalAmountFacturaZigi,
				ACH.TotalAmountFacturaZigiDeclared,
				ACH.InvoiceAmountZigi,
				ACH.InvoiceAmountFacturaZigi,
				-- COD Zigi desde subconsulta agrupada:
				ISNULL(CODZigiCalc.TotalCODZigi, 0) AS TotalAmountCODZigi,
				ACH.TotalAmountCODZigiDeclared,
				-- FIN MODIFICACIÓN
				RU.UsrNickName, RU.UsrIdUser, ACH.DateCreated, ACH.IdAccountingClosuresHeader,
				ISNULL(CCC.Symbol,'') AS 'CurrencySymbolDetail'
		FROM AccountingClosuresHeader ACH
		INNER JOIN RegisterUser RU
			ON ACH.UserId = RU.UsrIdUser
		INNER JOIN VisitPointClient VP WITH (NOLOCK)
			ON ACH.VisitPoint = VP.CodeOfReference
		-- AQUÍ ESTÁN LAS SUBCONSULTAS
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
		-- AQUÍ TERMINAN LAS SUBCONSULTAS
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
			ON ISNULL(VP.CountryId,'GT') = DC.Currency_IdCountry
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
			ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
		WHERE CAST(ACH.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
			AND ACH.VisitPoint = @VisitPointId
			AND ACH.AccountingClosuresHeaderVisitPointId IS NULL
			AND DC.DefaultPerCountry = 1
	) S1
	GROUP BY UsrIdUser, UsrNickName, DateCreated, IdAccountingClosuresHeader, CurrencySymbolDetail


	SELECT @Account AS 'AccountExp',
		ISNULL(SUM(TotalAmountCash), 0) 'TotalAmountCash',
		ISNULL(SUM(TotalAmountCashDeclared), 0) 'TotalAmountCashDeclared',
		ISNULL(SUM(TotalAmountCredit), 0) 'TotalAmountCredit',
		ISNULL(SUM(TotalAmountCreditDeclared), 0) 'TotalAmountCreditDeclared',
		ISNULL(SUM(TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
		ISNULL(SUM(TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
		ISNULL(SUM(TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
		ISNULL(SUM(TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
		@AccountCOD AS 'AccountCOD',
		-- COD Cash desde transacciones agrupadas:
		ISNULL(SUM(CODCashCalc.TotalCODCash), 0) 'TotalAmountCODCash',
		ISNULL(SUM(TotalAmountCODCashDeclared), 0) 'TotalAmountCODCashDeclared',
		-- MODIFICACIÓN [17/10/2025] - Campos para Zigi
		@AccountZigi as 'AccountZigi',
		-- TotalAmountZigi: Solo facturas (del header):
		ISNULL(SUM(TotalAmountFacturaZigi), 0) 'TotalAmountZigi',
		ISNULL(SUM(TotalAmountFacturaZigiDeclared), 0) 'TotalAmountZigiDeclared',
		ISNULL(SUM(TotalAmountFacturaZigi), 0) 'TotalAmountFacturaZigi',
		ISNULL(SUM(TotalAmountFacturaZigiDeclared), 0) 'TotalAmountFacturaZigiDeclared',
		-- COD Zigi desde transacciones agrupadas:
		ISNULL(SUM(CODZigiCalc.TotalCODZigi), 0) 'TotalAmountCODZigi',
		ISNULL(SUM(TotalAmountCODZigiDeclared), 0) 'TotalAmountCODZigiDeclared',
		-- FIN MODIFICACIÓN
		ISNULL(SUM(InvoiceAmountCash), 0) 'InvoiceAmountCash',
		ISNULL(SUM(InvoiceAmountCredit), 0) 'InvoiceAmountCredit',
		ISNULL(SUM(InvoiceAmountFacturaCash), 0) 'InvoiceAmountFacturaCash',
		ISNULL(SUM(InvoiceAmountFacturaCard), 0) 'InvoiceAmountFacturaCard',
		ISNULL(SUM(InvoiceAmountCOD), 0) 'InvoiceAmountCOD',
		-- MODIFICACIÓN [17/10/2025] - Campos para Zigi
		ISNULL(SUM(InvoiceAmountZigi), 0) 'InvoiceAmountZigi',
		ISNULL(SUM(InvoiceAmountFacturaZigi), 0) 'InvoiceAmountFacturaZigi',
		-- FIN MODIFICACIÓN
		ISNULL(CCC.Symbol,'') AS 'CurrencySymbol'
	FROM AccountingClosuresHeader ACH
	INNER JOIN VisitPointClient VP WITH (NOLOCK)
		ON ACH.VisitPoint = VP.CodeofReference
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
			ON ISNULL(VP.CountryId,'GT') = DC.Currency_IdCountry
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
			ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
	WHERE CAST(ACH.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
		AND ACH.VisitPoint = @VisitPointId
		AND ACH.AccountingClosuresHeaderVisitPointId IS NULL
		AND DC.DefaultPerCountry = 1
	GROUP BY VP.CountryId, CCC.Symbol
END;