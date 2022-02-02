USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[ReportClosure]    Script Date: 2/02/2022 16:13:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Freddy Monterroso>
-- Create date: <19/01/2022>
-- Description:	<SP para consulta de cierres en reporte de reporting services>
-- =============================================
ALTER PROCEDURE [dbo].[ReportClosure]
@StartDate datetime = null,
@EndDate datetime = null,
@VisitPointId INT = null,
@IdCierre INT = null,
@IdAccount INT = null
AS
BEGIN
if(@VisitPointId > 0 and @IdCierre > 0)
begin
	SELECT DISTINCT ACD.AccountingClosuresHeaderId ClosuresHeaderId
	,VPC.VisitPointId
	,VPC.DescriptionOfClient VisitPointDescription
	,ACh.UserId
	,REU.UsrNickName
	,ACH.DateCreated 'DateCreated'
	,DOR.Sender_FirstName + ' ' + DOR.Sender_LastName 'Client' 
	,INH.inv_certificationFEL 'CertificationFEL'
	,INH.inv_serieFEL 'SerieFel'
	,INH.inv_numberFEL 'NumberFel'
	,INH.inv_SAPDocEntry 'DOCSAP'
	,STO.OrderDescription 'Status'
	,DOR.Guide_Serie + CONVERT(VARCHAR,DOR.Guide_Number) 'Guide'
	,isnull(costd.Voucher,'') 'Voucher'
	,isnull(DOPD.amount, 0)'PriceShippment'
	,isnull(DOPD.CODAmountProcess,0) 'COD'
	, case 
		when DOPD.TypeofInOutMoneyId  = 1 THEN UPPER(ctgmon.tio_pk_name)
		when DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
		when DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
		when DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
		when DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
		when DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
		 else '' end 'PaymentType'
	,CTS.NameTypeService as 'ServiceType'
	FROM dbo.DeliveryOrder DOR
	JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
	 ON DOR.Sender_ID = VPC.CodeOfReference
	LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND
	 ON IND.dti_fk_orderSerie = DOR.Guide_Serie
	   AND IND.dti_fk_orderNumber = DOR.Guide_Number
	LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH
	 ON INH.inv_pk_id = IND.dti_fk_header
	JOIN DeliveryBackOffice.dbo.StatusOrder STO 
	ON STO.StatusOrderId = DOR.StatusOrderId
	LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD 
	 ON DOPD.GuideSerie = DOR.Guide_Serie 
	 AND DOPD.GuideNumber = DOR.Guide_Number
	 AND dopd.ShipmentCompleted = 1
	 AND DOPD.AccountId > 0
	 JOIN CatTypeServiceClosure CTS 
	ON CTS.IdTypeService = DOPD.TypeServiceId
	 JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
	on ACD.GuideSerie = DOR.Guide_Serie
	AND ACD.GuideNumber = DOR.Guide_Number
	AND ACD.RowStatus = 1
	 JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
	ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU ON REU.UsrIdUser = ACH.UserId
	 left join DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon on ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
	 left join DeliveryBackOffice.dbo.Cost cost on cost.ProductNumber = CONCAT(DOR.Guide_Serie,DOR.Guide_Number)
	 left join DeliveryBackOffice.dbo.CostDetail costd  on costd.IdCost = cost.IdCost AND costd.Amount > 0 
	 AND (DOPD.TypeofInOutMoneyId = 6 AND costd.Voucher != '')
	WHERE  CONVERT(DATE, DOR.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	AND (DOR.Sender_ID = @VisitPointId OR DOPD.AccountId = @IdAccount) and ACD.AccountingClosuresHeaderId = @IdCierre 
end


if(@VisitPointId > 0 and (@IdCierre <= 0 or @IdCierre is null) )
begin
SELECT DISTINCT ACD.AccountingClosuresHeaderId ClosuresHeaderId
,VPC.VisitPointId
,VPC.DescriptionOfClient VisitPointDescription
,ACh.UserId
,REU.UsrNickName
,ACH.DateCreated 'DateCreated'
,DOR.Sender_FirstName + ' ' + DOR.Sender_LastName 'Client' 
--,vpc.DescriptionOfClient,DOR.Sender_ID,DOR.IsCollect,DOPD.PayTypeId
,INH.inv_certificationFEL 'CertificationFEL'
,INH.inv_serieFEL 'SerieFel'
,INH.inv_numberFEL 'NumberFel'
,INH.inv_SAPDocEntry 'DOCSAP'
,STO.OrderDescription 'Status'
,DOR.Guide_Serie + CONVERT(VARCHAR,DOR.Guide_Number) 'Guide'
,isnull(costd.Voucher,'') 'Voucher'
,isnull(DOPD.amount, 0)'PriceShippment'
,isnull(DOPD.CODAmountProcess,0) 'COD'
, case 
	when DOPD.TypeofInOutMoneyId  = 1 THEN UPPER(ctgmon.tio_pk_name)
	when DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
	when DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
	when DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
	when DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
	when DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
	 else '' end 'PaymentType'
,CTS.NameTypeService as 'ServiceType'
FROM dbo.DeliveryOrder DOR
JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
 ON DOR.Sender_ID = VPC.CodeOfReference
LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND
 ON IND.dti_fk_orderSerie = DOR.Guide_Serie
   AND IND.dti_fk_orderNumber = DOR.Guide_Number
LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH
 ON INH.inv_pk_id = IND.dti_fk_header
JOIN DeliveryBackOffice.dbo.StatusOrder STO 
ON STO.StatusOrderId = DOR.StatusOrderId
LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD 
 ON DOPD.GuideSerie = DOR.Guide_Serie 
 AND DOPD.GuideNumber = DOR.Guide_Number
 AND dopd.ShipmentCompleted = 1
 JOIN CatTypeServiceClosure CTS 
 ON CTS.IdTypeService = DOPD.TypeServiceId
 JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
on ACD.GuideSerie = DOR.Guide_Serie
AND ACD.GuideNumber = DOR.Guide_Number
AND ACD.RowStatus = 1
 JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU ON REU.UsrIdUser = ACH.UserId
 left join DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon on ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
 left join DeliveryBackOffice.dbo.Cost cost on cost.ProductNumber = CONCAT(DOR.Guide_Serie,DOR.Guide_Number)
 left join DeliveryBackOffice.dbo.CostDetail costd  on costd.IdCost = cost.IdCost AND costd.Amount > 0 
 AND (DOPD.TypeofInOutMoneyId = 6 AND costd.Voucher != '')
WHERE CONVERT(DATE, DOR.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
AND (DOR.Sender_ID = @VisitPointId OR DOPD.AccountId = @IdAccount)
ORDER BY ACD.AccountingClosuresHeaderId
end


if(@VisitPointId = -1  and (@IdCierre <= 0 or @IdCierre is null))
begin
SELECT DISTINCT ACD.AccountingClosuresHeaderId ClosuresHeaderId
,VPC.VisitPointId
,VPC.DescriptionOfClient VisitPointDescription
,ACh.UserId
,REU.UsrNickName
,ACH.DateCreated 'DateCreated'
,DOR.Sender_FirstName + ' ' + DOR.Sender_LastName 'Client' 
--,vpc.DescriptionOfClient,DOR.Sender_ID,DOR.IsCollect,DOPD.PayTypeId
,INH.inv_certificationFEL 'CertificationFEL'
,INH.inv_serieFEL 'SerieFel'
,INH.inv_numberFEL 'NumberFel'
,INH.inv_SAPDocEntry 'DOCSAP'
,STO.OrderDescription 'Status'
,DOR.Guide_Serie + CONVERT(VARCHAR,DOR.Guide_Number) 'Guide'
,isnull(costd.Voucher,'') 'Voucher'
,isnull(DOPD.amount, 0)'PriceShippment'
,isnull(DOPD.CODAmountProcess,0) 'COD'
, case 
	when DOPD.TypeofInOutMoneyId  = 1 THEN UPPER(ctgmon.tio_pk_name)
	when DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
	when DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
	when DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
	when DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
	when DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
	 else '' end 'PaymentType'
,CTS.NameTypeService as 'ServiceType'
--,DOPD.*
--SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
FROM dbo.DeliveryOrder DOR
JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
 ON DOR.Sender_ID = VPC.CodeOfReference
LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND
 ON IND.dti_fk_orderSerie = DOR.Guide_Serie
   AND IND.dti_fk_orderNumber = DOR.Guide_Number
LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH
 ON INH.inv_pk_id = IND.dti_fk_header
JOIN DeliveryBackOffice.dbo.StatusOrder STO 
ON STO.StatusOrderId = DOR.StatusOrderId
LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD 
 ON DOPD.GuideSerie = DOR.Guide_Serie 
 AND DOPD.GuideNumber = DOR.Guide_Number
 AND dopd.ShipmentCompleted = 1
 JOIN CatTypeServiceClosure CTS 
 ON CTS.IdTypeService = DOPD.TypeServiceId
 JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
on ACD.GuideSerie = DOR.Guide_Serie
AND ACD.GuideNumber = DOR.Guide_Number
AND ACD.RowStatus = 1
 JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU ON REU.UsrIdUser = ACH.UserId
 left join DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon on ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
 left join DeliveryBackOffice.dbo.Cost cost on cost.ProductNumber = CONCAT(DOR.Guide_Serie,DOR.Guide_Number)
 left join DeliveryBackOffice.dbo.CostDetail costd  on costd.IdCost = cost.IdCost AND costd.Amount > 0 
 AND (DOPD.TypeofInOutMoneyId = 6 AND costd.Voucher != '')
WHERE CONVERT(DATE, DOR.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
ORDER BY ACD.AccountingClosuresHeaderId
end
END
