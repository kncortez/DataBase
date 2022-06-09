/*
EXEC GetClosureList
@VisitPointId = -1
,@StartDate = '20210627'
,@EndDate = '20210627'
*/
CREATE PROCEDURE [dbo].[GetClosureList]
@VisitPointId INT
,@StartDate datetime
,@EndDate datetime
AS
BEGIN

SELECT ACH.IdAccountingClosuresHeader 'ClosureId',
ACH.VisitPoint 'VisitPointId',vpc.DescriptionOfClient 'VisitPoinDescription'
,ACH.UserId,REU.UsrNickName 'UserDescription'
,ACH.DateCreated 'DateCreated'
,ACH.Voucher1,ACH.Bag1
,ACH.Voucher2,ACH.Bag2
,ACH.TotalAmountCash
,ACH.TotalAmountCashDeclared
,ACH.TotalAmountCredit
,ACH.TotalAmountCreditDeclared
,ACH.TotalAmountCODCash
-- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
,ACH.TotalAmountCODCashDeclared
,ACH.TotalAmountFacturaCash
,ACH.TotalAmountFacturaCashDeclared
,ACH.TotalAmountFacturaCard
,ACH.TotalAmountFacturaCardDeclared
-- FIN MODIFICACIÓN
FROM DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
 ON ACH.VisitPoint = VPC.CodeOfReference
JOIN DeliveryBackOffice.dbo.RegisterUser REU ON REU.UsrIdUser = ACH.UserId
WHERE CAST(ACH.DateCreated AS DATE) BETWEEN CAST(@StartDate AS DATE) 
AND CAST(@EndDate AS DATE)
AND (@VisitPointId = ACH.VisitPoint OR @VisitPointId = -1)

select Value 'URL' from ConfigParams
where Name = 'ClosureExpressCenter'

END
