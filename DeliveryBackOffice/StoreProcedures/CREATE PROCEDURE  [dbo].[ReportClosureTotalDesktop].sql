USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[ReportClosureTotalDesktop]    Script Date: 9/03/2022 11:48:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
		,ISNULL(SUM(TotalCODCredit), 0) TotalCODCredit
		,ISNULL(SUM(TotalGeneral), 0 ) TotalGeneral
	FROM (SELECT
			ISNULL(MAX(ACH.TotalAmountCash), 0) TotalCash
		   ,ISNULL(MAX(ACH.TotalAmountCredit), 0) TotalCredit
		   ,ISNULL(MAX(ACH.TotalAmountCashDeclared), 0) TotalCashDeclared
		   ,ISNULL(MAX(ACH.TotalAmountCreditDeclared), 0) TotalCreditDeclared
		   ,ISNULL(MAX(ACH.TotalAmountCODCash), 0) TotalCODCash
		   ,ISNULL(MAX(ACH.TotalAmountCODCredit), 0) TotalCODCredit
		   ,ISNULL(MAX(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountCODCredit), 0) TotalGeneral
		FROM dbo.AccountingClosuresHeader ACH
		LEFT JOIN dbo.VisitPointClient VPC
			ON VPC.CodeOfReference = ACH.VisitPoint
		LEFT JOIN AccountingClosuresDetail ACD
			ON ACD.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
		LEFT JOIN DeliveryOrderPaymentTransaction DOPD
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