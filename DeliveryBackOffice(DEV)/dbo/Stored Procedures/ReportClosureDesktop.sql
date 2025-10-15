-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-03-04>
-- Description:	<Sp para el detalle del reporte de cierres en desktop>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-07-08>
-- Description:	<Se agrega el simbolo de la moneda, segun pais de origen, para el detalle del reporte>
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <10/10/2025>
-- Description:	<Se agregan envios internacionales.>
-- =============================================
CREATE PROCEDURE [dbo].[ReportClosureDesktop]
@StartDate datetime = null,
@EndDate datetime = null,
@VisitPointId NVARCHAR(3000) = null,
@IdCierre NVARCHAR(3000) = null,
@IdAccount NVARCHAR(3000) = null
AS
BEGIN

	DECLARE @TEMPLATEDETAIL TABLE
		(
			guideserie NVARCHAR(3000),
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
		FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPT WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH(NOLOCK)
			ON IND.dti_fk_orderSerie = DOPT.GuideSerie
				AND IND.dti_fk_orderNumber = DOPT.GuideNumber

		-- MODIFICACIÓN 23/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		WHERE CONVERT(DATE, DOPT.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
		-- FIN MODIFICACIÓN

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
	
	SELECT DISTINCT DOPD.AccountId,
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
	   ,CASE WHEN ISNULL(DOR.SenderCountryId,'GT') = 'GT' THEN 'GTQ' ELSE 'HNL' END AS CurrencySymbol
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

		-- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
		,ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral'
		,REU1.UsrNickName 'Encargado'
		,ISNULL(ACHVP.Voucher1, '') 'VoucherGeneral'
		,ISNULL(ACHVP.Bag1, '') 'Bolsa'
		,ISNULL(ACHVP.ClosurerPOS,'') 'CierrePOS'
		-- FIN MODIFICACIÓN

	FROM dbo.DeliveryOrder DOR WITH(NOLOCK)
	LEFT JOIN @TEMPLATEDETAIL IND
		ON IND.guideserie = DOR.Guide_Serie
			AND IND.guidenumber = DOR.Guide_Number
	LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH(NOLOCK)
		ON INH.inv_pk_id = IND.header
	INNER JOIN DeliveryBackOffice.dbo.StatusOrder STO WITH(NOLOCK)
		ON STO.StatusOrderId = DOR.StatusOrderId
	LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)
		ON DOPD.GuideSerie = DOR.Guide_Serie
			AND DOPD.GuideNumber = DOR.Guide_Number
			AND dopd.ShipmentCompleted = 1
			AND DOPD.AccountId > 0
			AND DOR.StatusOrderId != 7

	-- MODIFICACIÓN 27/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
		ON DOPD.VisitPoint = VPC.CodeOfReference
	-- FIN MODIFICACIÓN

	INNER JOIN CatTypeServiceClosure CTS WITH(NOLOCK)
		ON CTS.IdTypeService = DOPD.TypeServiceId
	INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
		ON ACD.GuideSerie = DOR.Guide_Serie
			AND ACD.GuideNumber = DOR.Guide_Number
			AND ACD.DopId = DOPD.DopId
	INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH WITH(NOLOCK)
		ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU WITH(NOLOCK)
		ON REU.UsrIdUser = ACH.UserId
	LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH(NOLOCK)
		ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
	LEFT JOIN DeliveryBackOffice.dbo.Cost cost WITH(NOLOCK)
		ON cost.ProductNumber = CONCAT(DOR.Guide_Serie, DOR.Guide_Number)
	LEFT JOIN DeliveryBackOffice.dbo.CostDetail costd WITH(NOLOCK)
		ON costd.IdCost = cost.IdCost
			AND costd.Amount > 0
			AND (DOPD.TypeofInOutMoneyId = 6
				AND costd.Voucher != '')

	-- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP WITH(NOLOCK)
			ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId
	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1 WITH(NOLOCK)
			ON REU1.UsrIdUser = ACHVP.UserId
	-- FIN MODIFICACIÓN

	WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	AND (DOPD.AccountId IN (SELECT AccountId FROM @tblIdAccount) OR @IdAccount = '-1')
    AND ACD.RowStatus = 1
	-- MODIFICACIÓN 23/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	AND (DOPD.VisitPoint IN (SELECT CodeOfReference FROM @tblVisitPointId) OR @VisitPointId = '-1' OR DOPD.VisitPoint IS NULL)
	-- FIN MODIFICACIÓN

	AND (ACD.AccountingClosuresHeaderId IN (SELECT CierreId FROM @tblIdCierre) OR @IdCierre = '-1')
	-- ORDER BY DOPD.DateCreated ASC
	UNION ALL
	SELECT DISTINCT DOPD.AccountId,
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
	   ,'  ' AS CurrencySymbol
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

	   -- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
		,ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral'
		,REU1.UsrNickName 'Encargado'
		,ISNULL(ACHVP.Voucher1, '') 'VoucherGeneral'
		,ISNULL(ACHVP.Bag1, '') 'Bolsa'
		,ISNULL(ACHVP.ClosurerPOS,'') 'CierrePOS'
		-- FIN MODIFICACIÓN

	--,DOPD.*
	--SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
	FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)

	INNER JOIN CatTypeServiceClosure CTS WITH(NOLOCK)
		ON CTS.IdTypeService = DOPD.TypeServiceId
	LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH(NOLOCK)
		ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
	INNER JOIN invoiceHeader INH WITH(NOLOCK)
		ON INH.inv_numberFEL = (SELECT
					item
				FROM dbo.SplitUnlimited(DOPD.Fel, '-')
				WHERE id = 2)
	LEFT JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
		ON INH.inv_numberFEL = ACD.Fel AND ACD.RowStatus = 1
	LEFT JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH WITH(NOLOCK)
		ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId

	-- MODIFICACIÓN 27/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
		--ON VPC.CodeOfReference IN (SELECT CodeOfReference FROM @tblVisitPointId)
		ON DOPD.VisitPoint = VPC.CodeOfReference
	-- FIN MODIFICACIÓN

	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU WITH(NOLOCK)
		ON REU.UsrIdUser = ACH.UserId

	-- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP WITH(NOLOCK)
			ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId
	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1 WITH(NOLOCK)
			ON REU1.UsrIdUser = ACHVP.UserId
	-- FIN MODIFICACIÓN

	WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)

	-- MODIFICACIÓN 23/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	AND (VPC.CodeOfReference IN (SELECT CodeOfReference FROM @tblVisitPointId) OR @VisitPointId = '-1' OR VPC.CodeOfReference IS NULL)
	-- FIN MODIFICACIÓN
	AND (DOPD.AccountId IN (SELECT AccountId FROM @tblIdAccount) OR @IdAccount = '-1')
	AND (ACD.AccountingClosuresHeaderId IN (SELECT CierreId FROM @tblIdCierre) OR @IdCierre = '-1')
	AND (CTS.IdTypeService <> 23)
	AND @VisitPointId <> '-1'
	UNION ALL
	SELECT DISTINCT DOPD.AccountId,
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
	   ,'  ' AS CurrencySymbol
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

	   -- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
		,ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral'
		,REU1.UsrNickName 'Encargado'
		,ISNULL(ACHVP.Voucher1, '') 'VoucherGeneral'
		,ISNULL(ACHVP.Bag1, '') 'Bolsa'
		,ISNULL(ACHVP.ClosurerPOS,'') 'CierrePOS'
		-- FIN MODIFICACIÓN

	--,DOPD.*
	--SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
	FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)

	INNER JOIN CatTypeServiceClosure CTS WITH(NOLOCK)
		ON CTS.IdTypeService = DOPD.TypeServiceId
	LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH(NOLOCK)
		ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
	INNER JOIN invoiceHeader INH WITH(NOLOCK)
		ON INH.inv_numberFEL = (SELECT
					item
				FROM dbo.SplitUnlimited(DOPD.Fel, '-')
				WHERE id = 2)
	LEFT JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
		ON INH.inv_numberFEL = ACD.Fel AND ACD.RowStatus = 1
	LEFT JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH WITH(NOLOCK)
		ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId

	-- MODIFICACIÓN 27/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
		--ON VPC.CodeOfReference IN (SELECT CodeOfReference FROM @tblVisitPointId)
		ON VPC.CodeOfReference = ACH.VisitPoint
	-- FIN MODIFICACIÓN

	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU WITH(NOLOCK)
		ON REU.UsrIdUser = ACH.UserId

	-- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP WITH(NOLOCK)
			ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId
	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1 WITH(NOLOCK)
			ON REU1.UsrIdUser = ACHVP.UserId
	-- FIN MODIFICACIÓN

	WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)

	-- MODIFICACIÓN 23/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	AND (VPC.CodeOfReference IN (SELECT CodeOfReference FROM @tblVisitPointId) OR @VisitPointId = '-1' OR VPC.CodeOfReference IS NULL)
	-- FIN MODIFICACIÓN
	AND (DOPD.AccountId IN (SELECT AccountId FROM @tblIdAccount) OR @IdAccount = '-1')
	AND (ACD.AccountingClosuresHeaderId IN (SELECT CierreId FROM @tblIdCierre) OR @IdCierre = '-1')
	AND (CTS.IdTypeService <> 23)
	AND @VisitPointId = '-1'
	ORDER BY DOPD.DateCreated ASC
	option (optimize for unknown)
END