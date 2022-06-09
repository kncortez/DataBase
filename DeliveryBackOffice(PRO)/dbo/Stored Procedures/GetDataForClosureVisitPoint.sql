
-- =============================================
-- Author:		<Alejandro Rodríguez>
-- Create date: <2022-03-28>
-- Description:	<SP para obtener la lista de guías que se procesaron en un express center>
-- =============================================

CREATE PROCEDURE [dbo].[GetDataForClosureVisitPoint]
@VisitPointId int = 4246,
@IdAccount int = 0
AS
BEGIN

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
		ISNULL(SUM(S1.TotalAmountCODCashDeclared), 0) 'TotalAmountCODCashDeclared'
	FROM 
	(
		SELECT	TotalAmountCash, TotalAmountCashDeclared, InvoiceAmountCash,
				TotalAmountCredit, TotalAmountCreditDeclared, InvoiceAmountCredit,
				TotalAmountFacturaCash, TotalAmountFacturaCashDeclared, InvoiceAmountFacturaCash,
				TotalAmountFacturaCard, TotalAmountFacturaCardDeclared, InvoiceAmountFacturaCard,
				TotalAmountCODCash, TotalAmountCODCashDeclared, InvoiceAmountCOD,
				RU.UsrNickName, RU.UsrIdUser, ACH.DateCreated, ACH.IdAccountingClosuresHeader
		FROM AccountingClosuresHeader ACH
		JOIN RegisterUser RU
			ON ACH.UserId = RU.UsrIdUser
		WHERE CAST(ACH.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
			AND ACH.VisitPoint = @VisitPointId
			AND ACH.AccountingClosuresHeaderVisitPointId IS NULL
	) S1
	GROUP BY UsrIdUser, UsrNickName, DateCreated, IdAccountingClosuresHeader


	SELECT	ISNULL(SUM(TotalAmountCash), 0) 'TotalAmountCash',
		ISNULL(SUM(TotalAmountCashDeclared), 0) 'TotalAmountCashDeclared',
		ISNULL(SUM(TotalAmountCredit), 0) 'TotalAmountCredit',
		ISNULL(SUM(TotalAmountCreditDeclared), 0) 'TotalAmountCreditDeclared',
		ISNULL(SUM(TotalAmountFacturaCash), 0) 'TotalAmountFacturaCash',
		ISNULL(SUM(TotalAmountFacturaCashDeclared), 0) 'TotalAmountFacturaCashDeclared',
		ISNULL(SUM(TotalAmountFacturaCard), 0) 'TotalAmountFacturaCard',
		ISNULL(SUM(TotalAmountFacturaCardDeclared), 0) 'TotalAmountFacturaCardDeclared',
		ISNULL(SUM(TotalAmountCODCash), 0) 'TotalAmountCODCash',
		ISNULL(SUM(TotalAmountCODCashDeclared), 0) 'TotalAmountCODCashDeclared',
		ISNULL(SUM(InvoiceAmountCash), 0) 'InvoiceAmountCash',
		ISNULL(SUM(InvoiceAmountCredit), 0) 'InvoiceAmountCredit',
		ISNULL(SUM(InvoiceAmountFacturaCash), 0) 'InvoiceAmountFacturaCash',
		ISNULL(SUM(InvoiceAmountFacturaCard), 0) 'InvoiceAmountFacturaCard',
		ISNULL(SUM(InvoiceAmountCOD), 0) 'InvoiceAmountCOD'
	FROM AccountingClosuresHeader ACH
	WHERE CAST(ACH.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
		AND ACH.VisitPoint = @VisitPointId
		AND ACH.AccountingClosuresHeaderVisitPointId IS NULL
END;