USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[ReportClosureDesktop]    Script Date: 9/03/2022 11:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-03-04>
-- Description:	<Sp para el detalle del reporte de cierres en desktop>
-- =============================================
CREATE PROCEDURE [dbo].[ReportClosureDesktop]
@StartDate datetime = null,
@EndDate datetime = null,
@VisitPointId NVARCHAR(MAX) = null,
@IdCierre NVARCHAR(MAX) = null,
@IdAccount NVARCHAR(MAX) = null
AS
BEGIN

	DECLARE @TEMPLATEDETAIL TABLE
		(
			guideserie NVARCHAR(MAX),
			guidenumber BIGINT,
			header BIGINT
		);

	INSERT INTO @TEMPLATEDETAIL (guideserie,
	guidenumber,
	header)
		SELECT
			IND.dti_fk_orderSerie
		   ,IND.dti_fk_orderNumber
		   ,MAX(IND.dti_fk_header) 'dti_fk_header'
		FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPT
		LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND
			ON IND.dti_fk_orderSerie = DOPT.GuideSerie
				AND IND.dti_fk_orderNumber = DOPT.GuideNumber
		WHERE CAST(DOPT.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
		GROUP BY IND.dti_fk_orderSerie
				,IND.dti_fk_orderNumber;

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
	
	SELECT DISTINCT
		ACD.AccountingClosuresHeaderId ClosuresHeaderId
	   ,VPC.VisitPointId
	   ,VPC.DescriptionOfClient VisitPointDescription
	   ,ACh.UserId
	   ,REU.UsrNickName
	   ,DOPD.DateCreated 'DateCreated'
	   ,DOR.Sender_FirstName + ' ' + DOR.Sender_LastName 'Client'
	   ,INH.inv_certificationFEL 'CertificationFEL'
	   ,INH.inv_serieFEL 'SerieFel'
	   ,INH.inv_numberFEL 'NumberFel'
	   ,INH.inv_SAPDocEntry 'DOCSAP'
	   ,STO.OrderDescription 'Status'
	   ,DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number) 'Guide'
	   ,ISNULL(costd.Voucher, '') 'Voucher'
	   ,ISNULL(DOPD.amount, 0) 'PriceShippment'
	   ,ISNULL(DOPD.CODAmountProcess, 0) 'COD'
	   ,CASE
			WHEN DOPD.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
			WHEN DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
			WHEN DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
			WHEN DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
			WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
			WHEN DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
			ELSE ''
		END 'PaymentType'
	   ,CTS.NameTypeService AS 'ServiceType'
	FROM dbo.DeliveryOrder DOR
	JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
		ON DOR.Sender_ID = VPC.CodeOfReference
	LEFT JOIN @TEMPLATEDETAIL IND
		ON IND.guideserie = DOR.Guide_Serie
			AND IND.guidenumber = DOR.Guide_Number
	LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH
		ON INH.inv_pk_id = IND.header
	JOIN DeliveryBackOffice.dbo.StatusOrder STO
		ON STO.StatusOrderId = DOR.StatusOrderId
	LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD
		ON DOPD.GuideSerie = DOR.Guide_Serie
			AND DOPD.GuideNumber = DOR.Guide_Number
			AND dopd.ShipmentCompleted = 1
			AND DOPD.AccountId > 0
			AND DOR.StatusOrderId != 7
	JOIN CatTypeServiceClosure CTS
		ON CTS.IdTypeService = DOPD.TypeServiceId
	JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
		ON ACD.GuideSerie = DOR.Guide_Serie
			AND ACD.GuideNumber = DOR.Guide_Number
			AND ACD.RowStatus = 1
	JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
		ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU
		ON REU.UsrIdUser = ACH.UserId
	LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
		ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
	LEFT JOIN DeliveryBackOffice.dbo.Cost cost
		ON cost.ProductNumber = CONCAT(DOR.Guide_Serie, DOR.Guide_Number)
	LEFT JOIN DeliveryBackOffice.dbo.CostDetail costd
		ON costd.IdCost = cost.IdCost
			AND costd.Amount > 0
			AND (DOPD.TypeofInOutMoneyId = 6
				AND costd.Voucher != '')
	WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	AND ((DOR.Sender_ID IN (SELECT CodeOfReference FROM @tblVisitPointId) OR @VisitPointId = '-1')
	OR (DOPD.AccountId IN (SELECT AccountId FROM @tblIdAccount) OR @IdAccount = '-1')
	OR DOPD.VisitPoint IN (SELECT CodeOfReference FROM @tblVisitPointId))
	AND (ACD.AccountingClosuresHeaderId IN (SELECT CierreId FROM @tblIdCierre) OR @IdCierre = '-1')
	-- ORDER BY DOPD.DateCreated ASC
	UNION ALL
	SELECT DISTINCT
		ACD.AccountingClosuresHeaderId ClosuresHeaderId
	   ,VPC.VisitPointId
	   ,VPC.DescriptionOfClient VisitPointDescription
	   ,ACh.UserId
	   ,REU.UsrNickName
	   ,DOPD.DateCreated 'DateCreated'
	   ,INH.inv_UserName 'Client'
	   ,INH.inv_certificationFEL 'CertificationFEL'
	   ,INH.inv_serieFEL 'SerieFel'
	   ,INH.inv_numberFEL 'NumberFel'
	   ,INH.inv_SAPDocEntry 'DOCSAP'
	   ,Status = '----'
	   ,Guide = '----'
	   ,Voucher = ''
	   ,ISNULL(DOPD.amount, 0) 'PriceShippment'
	   ,ISNULL(DOPD.CODAmountProcess, 0) 'COD'
	   ,CASE
			WHEN DOPD.TypeofInOutMoneyId = 1 THEN UPPER(ctgmon.tio_pk_name)
			WHEN DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
			WHEN DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
			WHEN DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
			WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
			WHEN DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
			ELSE ''
		END 'PaymentType'
	   ,CTS.NameTypeService AS 'ServiceType'

	--,DOPD.*
	--SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
	FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD

	JOIN CatTypeServiceClosure CTS
		ON CTS.IdTypeService = DOPD.TypeServiceId
	LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
		ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
	JOIN invoiceHeader INH
		ON INH.inv_numberFEL = (SELECT
					item
				FROM dbo.SplitUnlimited(DOPD.Fel, '-')
				WHERE id = 2)
	JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
		ON INH.inv_numberFEL = ACD.Fel
			AND ACD.RowStatus = 1
	JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
		ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
	JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
		ON VPC.CodeOfReference IN (SELECT CodeOfReference FROM @tblVisitPointId)
		OR (@VisitPointId = '-1' AND VPC.CodeOfReference = ACH.VisitPoint)
	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU
		ON REU.UsrIdUser = ACH.UserId
	WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	AND ((VPC.CodeOfReference IN (SELECT CodeOfReference FROM @tblVisitPointId) OR @VisitPointId = '-1')
	OR (DOPD.AccountId IN (SELECT AccountId FROM @tblIdAccount) OR @IdAccount = '-1'))
	AND (ACD.AccountingClosuresHeaderId IN (SELECT CierreId FROM @tblIdCierre) OR @IdCierre = '-1')
	AND (CTS.IdTypeService NOT IN (5, 23))
	ORDER BY DOPD.DateCreated ASC
END