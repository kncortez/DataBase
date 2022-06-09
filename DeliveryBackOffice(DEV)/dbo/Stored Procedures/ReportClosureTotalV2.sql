-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-04>
-- Description:	<Copia con mejoras del sp ReportClosureTotal PARA PRUEBAS>
-- =============================================
CREATE PROCEDURE  [dbo].[ReportClosureTotalV2] 
@StartDate datetime = null,
@EndDate datetime = null,
@VisitPointId INT = null,
@IdCierre INT = null
AS
BEGIN

	SELECT
		ISNULL(SUM(ACH.TotalAmountCash), 0) 'TotalCash'
	   ,ISNULL(SUM(ACH.TotalAmountCredit), 0) 'TotalCredit'
	   ,ISNULL(SUM(ACH.TotalAmountCashDeclared), 0) 'TotalCashDeclared'
	   ,ISNULL(SUM(ACH.TotalAmountCreditDeclared), 0) 'TotalCreditDeclared'
	   ,ISNULL(SUM(ACH.TotalAmountCODCash), 0) 'TotalCODCash'
	   ,ISNULL(SUM(ACH.TotalAmountCODCredit), 0) 'TotalCODCredit'
	   ,ISNULL(SUM(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountCODCredit), 0) 'TotalGeneral'
	FROM dbo.AccountingClosuresHeader ACH
	JOIN dbo.VisitPointClient VPC
		ON VPC.CodeOfReference = ACH.VisitPoint
	WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	AND (VPC.CodeOfReference = @VisitPointId OR @VisitPointId < 0)
	AND (ACH.IdAccountingClosuresHeader = @IdCierre OR @IdCierre < 0)

END