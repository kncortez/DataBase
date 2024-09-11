
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

CREATE PROCEDURE [dbo].[GetDataForClosureVisitPoint]
@VisitPointId int = 4246,
@IdAccount int = 0
AS
BEGIN

	DECLARE @IdCountry NVARCHAR(2),
		    @Account NVARCHAR(30),
			@AccountCOD NVARCHAR(30);

	SELECT @IdCountry = CountryId 
	FROM VisitPointClient 
	WHERE CodeOfReference = @VisitPointId

	SELECT @Account = Name +' '+ '('+ AccountNumber +')' 
	FROM dbo.ClosureAccount 
	WHERE Description = 'Cuenta Express Center' AND ISNULL(IdCountry,'GT') = @IdCountry
	
	SELECT @AccountCOD = Name +' '+ '('+ AccountNumber +')' 
	FROM dbo.ClosureAccount 
	WHERE Description = 'Cuenta Área COD' AND ISNULL(IdCountry,'GT') = @IdCountry

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
		S1.CurrencySymbolDetail
	FROM 
	(
		SELECT	TotalAmountCash, TotalAmountCashDeclared, InvoiceAmountCash,
				TotalAmountCredit, TotalAmountCreditDeclared, InvoiceAmountCredit,
				TotalAmountFacturaCash, TotalAmountFacturaCashDeclared, InvoiceAmountFacturaCash,
				TotalAmountFacturaCard, TotalAmountFacturaCardDeclared, InvoiceAmountFacturaCard,
				TotalAmountCODCash, TotalAmountCODCashDeclared, InvoiceAmountCOD,
				RU.UsrNickName, RU.UsrIdUser, ACH.DateCreated, ACH.IdAccountingClosuresHeader,
				CASE WHEN VP.CountryId = 'GT' THEN 'Q.' ELSE 'L.' END AS 'CurrencySymbolDetail'
		FROM AccountingClosuresHeader ACH
		INNER JOIN RegisterUser RU
			ON ACH.UserId = RU.UsrIdUser
		INNER JOIN VisitPointClient VP WITH (NOLOCK)
			ON ACH.VisitPoint = VP.CodeOfReference
		WHERE CAST(ACH.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
			AND ACH.VisitPoint = @VisitPointId
			AND ACH.AccountingClosuresHeaderVisitPointId IS NULL
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
		ISNULL(SUM(TotalAmountCODCash), 0) 'TotalAmountCODCash',
		ISNULL(SUM(TotalAmountCODCashDeclared), 0) 'TotalAmountCODCashDeclared',
		ISNULL(SUM(InvoiceAmountCash), 0) 'InvoiceAmountCash',
		ISNULL(SUM(InvoiceAmountCredit), 0) 'InvoiceAmountCredit',
		ISNULL(SUM(InvoiceAmountFacturaCash), 0) 'InvoiceAmountFacturaCash',
		ISNULL(SUM(InvoiceAmountFacturaCard), 0) 'InvoiceAmountFacturaCard',
		ISNULL(SUM(InvoiceAmountCOD), 0) 'InvoiceAmountCOD',
		CASE WHEN VP.CountryId = 'GT' THEN 'Q.' ELSE 'L.' END AS 'CurrencySymbol'
	FROM AccountingClosuresHeader ACH
	INNER JOIN VisitPointClient VP WITH (NOLOCK)
		ON ACH.VisitPoint = VP.CodeofReference
	WHERE CAST(ACH.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
		AND ACH.VisitPoint = @VisitPointId
		AND ACH.AccountingClosuresHeaderVisitPointId IS NULL
	GROUP BY VP.CountryId
END;