USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[ReportClosureTotal]    Script Date: 2/02/2022 16:15:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,Freddy Monterroso>
-- Create date: <Create Date,27-01-2022>
-- Description:	<Description, SP para mostrar totales en reporte>
-- =============================================
CREATE PROCEDURE  [dbo].[ReportClosureTotal] 
@StartDate datetime = null,
@EndDate datetime = null,
@VisitPointId INT = null,
@IdCierre INT = null
AS
BEGIN

if(@VisitPointId > 0 and @IdCierre > 0)
begin
SELECT isnull(sum(ACH.TotalAmountCash),0) 'TotalCash',
 isnull(sum(ACH.TotalAmountCredit),0) 'TotalCredit',
 isnull(sum(ACH.TotalAmountCashDeclared),0) 'TotalCashDeclared',
 isnull(sum(ACH.TotalAmountCreditDeclared),0) 'TotalCreditDeclared',
 isnull(sum(ACH.TotalAmountCODCash),0) 'TotalCODCash',
 isnull(sum(ACH.TotalAmountCODCredit),0) 'TotalCODCredit',
 isnull(sum(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountCODCredit), 0) 'TotalGeneral'
 FROM dbo.AccountingClosuresHeader ACH
 JOIN dbo.VisitPointClient VPC ON VPC.CodeOfReference = ACH.VisitPoint AND VPC.CodeOfReference = @VisitPointId
 WHERE  CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
 AND ACH.IdAccountingClosuresHeader = @IdCierre 
end

if(@VisitPointId > 0 and (@IdCierre <= 0 or @IdCierre is null) )
begin
SELECT isnull(sum(ACH.TotalAmountCash),0) 'TotalCash',
 isnull(sum(ACH.TotalAmountCredit),0) 'TotalCredit',
 isnull(sum(ACH.TotalAmountCashDeclared),0) 'TotalCashDeclared',
 isnull(sum(ACH.TotalAmountCreditDeclared),0) 'TotalCreditDeclared',
 isnull(sum(ACH.TotalAmountCODCash),0) 'TotalCODCash',
 isnull(sum(ACH.TotalAmountCODCredit),0) 'TotalCODCredit',
 isnull(sum(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountCODCredit), 0) 'TotalGeneral'
 FROM dbo.AccountingClosuresHeader ACH
 JOIN dbo.VisitPointClient VPC ON VPC.CodeOfReference = ACH.VisitPoint AND VPC.CodeOfReference = @VisitPointId
 WHERE  CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
GROUP BY VisitPoint
end

if(@VisitPointId = -1  and (@IdCierre <= 0 or @IdCierre is null))
begin
SELECT isnull(sum(ACH.TotalAmountCash),0) 'TotalCash',
 isnull(sum(ACH.TotalAmountCredit),0) 'TotalCredit',
 isnull(sum(ACH.TotalAmountCashDeclared),0) 'TotalCashDeclared',
 isnull(sum(ACH.TotalAmountCreditDeclared),0) 'TotalCreditDeclared',
 isnull(sum(ACH.TotalAmountCODCash),0) 'TotalCODCash',
 isnull(sum(ACH.TotalAmountCODCredit),0) 'TotalCODCredit',
 isnull(sum(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountCODCredit), 0) 'TotalGeneral'
 FROM dbo.AccountingClosuresHeader ACH
 JOIN dbo.VisitPointClient VPC ON VPC.CodeOfReference = ACH.VisitPoint AND VPC.CodeOfReference = @VisitPointId
 WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
end
 
END
