USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[ReportClosureTotal]    Script Date: 28/03/2022 12:41:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alejandro Rodríguez>
-- Create date: <28-03-2022>
-- Description:	<SP para mostrar totales en reporte de VisitPoint>
-- Nota: Es una copia de ReportClosureTotal
-- =============================================
CREATE PROCEDURE  [dbo].[ReportClosureTotalVisitPoint] 
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
 -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
 isnull(sum(ACH.TotalAmountCODCashDeclared),0) 'TotalCODCashDeclared',
 isnull(sum(ACH.TotalAmountFacturaCash),0) 'TotalAmountFacturaCash',
 isnull(sum(ACH.TotalAmountFacturaCard),0) 'TotalAmountFacturaCard',
 isnull(sum(ACH.TotalAmountFacturaCashDeclared),0) 'TotalAmountFacturaCashDeclared',
 isnull(sum(ACH.TotalAmountFacturaCardDeclared),0) 'TotalAmountFacturaCardDeclared',
 isnull(sum(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard), 0) 'TotalGeneral'
 -- FIN MODIFICACIÓN
 FROM dbo.AccountingClosuresHeaderVisitPoint ACH
 JOIN dbo.VisitPointClient VPC ON VPC.CodeOfReference = ACH.VisitPoint AND VPC.CodeOfReference = @VisitPointId
 WHERE  CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
 AND ACH.IdAccountingClosuresHeaderVisitPoint = @IdCierre 
end

if(@VisitPointId > 0 and (@IdCierre <= 0 or @IdCierre is null) )
begin
SELECT isnull(sum(ACH.TotalAmountCash),0) 'TotalCash',
 isnull(sum(ACH.TotalAmountCredit),0) 'TotalCredit',
 isnull(sum(ACH.TotalAmountCashDeclared),0) 'TotalCashDeclared',
 isnull(sum(ACH.TotalAmountCreditDeclared),0) 'TotalCreditDeclared',
 isnull(sum(ACH.TotalAmountCODCash),0) 'TotalCODCash',
 -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
 isnull(sum(ACH.TotalAmountCODCashDeclared),0) 'TotalCODCashDeclared',
 isnull(sum(ACH.TotalAmountFacturaCash),0) 'TotalAmountFacturaCash',
 isnull(sum(ACH.TotalAmountFacturaCard),0) 'TotalAmountFacturaCard',
 isnull(sum(ACH.TotalAmountFacturaCashDeclared),0) 'TotalAmountFacturaCashDeclared',
 isnull(sum(ACH.TotalAmountFacturaCardDeclared),0) 'TotalAmountFacturaCardDeclared',
 isnull(sum(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard), 0) 'TotalGeneral'
 -- FIN MODIFICACIÓN
 FROM dbo.AccountingClosuresHeaderVisitPoint ACH
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
 -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
 isnull(sum(ACH.TotalAmountCODCashDeclared),0) 'TotalCODCashDeclared',
 isnull(sum(ACH.TotalAmountFacturaCash),0) 'TotalAmountFacturaCash',
 isnull(sum(ACH.TotalAmountFacturaCard),0) 'TotalAmountFacturaCard',
 isnull(sum(ACH.TotalAmountFacturaCashDeclared),0) 'TotalAmountFacturaCashDeclared',
 isnull(sum(ACH.TotalAmountFacturaCardDeclared),0) 'TotalAmountFacturaCardDeclared',
 isnull(sum(ACH.TotalAmountCash + ACH.TotalAmountCredit + ACH.TotalAmountCODCash + ACH.TotalAmountFacturaCash + ACH.TotalAmountFacturaCard), 0) 'TotalGeneral'
 -- FIN MODIFICACIÓN
 FROM dbo.AccountingClosuresHeaderVisitPoint ACH
 WHERE CONVERT(DATE, ACH.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
end
 
END
