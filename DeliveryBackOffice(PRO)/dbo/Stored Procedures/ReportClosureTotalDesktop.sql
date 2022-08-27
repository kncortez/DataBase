-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-04>
-- Description:	<SP para mostrar totales en reporte de cierres en desktop>
-- =============================================
CREATE PROCEDURE  [dbo].[ReportClosureTotalDesktop] 
	@StartDate datetime = NULL,
	@EndDate datetime = NULL,
	@VisitPointId NVARCHAR(MAX) = NULL,
	@IdCierre NVARCHAR(MAX) = NULL,
	@IdAccount NVARCHAR(MAX) = NULL
AS
BEGIN

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
		ISNULL(SUM(TotalCash), 0) TotalCash
		,ISNULL(SUM(TotalCredit), 0) TotalCredit
		,ISNULL(SUM(TotalCashDeclared), 0) TotalCashDeclared
		,ISNULL(SUM(TotalCreditDeclared), 0) TotalCreditDeclared
		,ISNULL(SUM(TotalCODCash), 0) TotalCODCash
		-- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		,ISNULL(SUM(TotalAmountCODCashDeclared), 0) TotalAmountCODCashDeclared
		,ISNULL(SUM(TotalAmountFacturaCash), 0) TotalAmountFacturaCash
		,ISNULL(SUM(TotalAmountFacturaCard), 0) TotalAmountFacturaCard
		,ISNULL(SUM(TotalAmountFacturaCashDeclared), 0) TotalAmountFacturaCashDeclared
		,ISNULL(SUM(TotalAmountFacturaCardDeclared), 0) TotalAmountFacturaCardDeclared
		-- FIN MODIFICACIÓN
		,ISNULL(SUM(TotalGeneral), 0 ) TotalGeneral
	FROM (SELECT
			ISNULL(MAX(ACH.TotalAmountCash), 0) TotalCash
		   ,ISNULL(MAX(ACH.TotalAmountCredit), 0) TotalCredit
		   ,ISNULL(MAX(ACH.TotalAmountCashDeclared), 0) TotalCashDeclared
		   ,ISNULL(MAX(ACH.TotalAmountCreditDeclared), 0) TotalCreditDeclared
		   ,ISNULL(MAX(ACH.TotalAmountCODCash), 0) TotalCODCash
		   -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		   ,ISNULL(MAX(ACH.TotalAmountCODCashDeclared), 0) TotalAmountCODCashDeclared
		   ,ISNULL(MAX(ACH.TotalAmountFacturaCash), 0) TotalAmountFacturaCash
		   ,ISNULL(MAX(ACH.TotalAmountFacturaCard), 0) TotalAmountFacturaCard
		   ,ISNULL(MAX(ACH.TotalAmountFacturaCashDeclared), 0) TotalAmountFacturaCashDeclared
		   ,ISNULL(MAX(ACH.TotalAmountFacturaCardDeclared), 0) TotalAmountFacturaCardDeclared
		   ,ISNULL(MAX(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard), 0) TotalGeneral
		   -- FIN MODIFICACIÓN
		FROM dbo.AccountingClosuresHeader ACH WITH(NOLOCK)
		LEFT JOIN dbo.VisitPointClient VPC WITH(NOLOCK)
			ON VPC.CodeOfReference = ACH.VisitPoint
		LEFT JOIN AccountingClosuresDetail ACD WITH(NOLOCK)
			ON ACD.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
		LEFT JOIN DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)
			ON DOPD.GuideSerie = ACD.GuideSerie
			AND DOPD.GuideNumber = ACD.GuideNumber
		WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
		AND (VPC.CodeOfReference IN (SELECT
				CodeOfReference
			FROM @tblVisitPointId)
		OR @VisitPointId = '-1')
		AND (ACH.IdAccountingClosuresHeader IN (SELECT
				CierreId
			FROM @tblIdCierre)
		OR @IdCierre = '-1')
		AND (DOPD.AccountId IN (SELECT
				AccountId
			FROM @tblIdAccount)
		OR @IdAccount = '-1')
		GROUP BY ACH.IdAccountingClosuresHeader) X
END