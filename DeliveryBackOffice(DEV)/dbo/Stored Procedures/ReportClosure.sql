-- =============================================
-- Author:		<Freddy Monterroso>
-- Create date: <19/01/2022>
-- Description:	<SP para consulta de cierres en reporte de reporting services>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <09/07/2024>
-- Description:	<Se agrega el simbolo de la moneda y las cuentas correspondientes al pais>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <22/07/2024>
-- Description:	<Se optimiza la consulta en la segunda validacion, para la generacion de los cierres>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <10/10/2025>
-- Description:	<Se agregan envios internacionales.>
-- =============================================
CREATE PROCEDURE [dbo].[ReportClosure]
@StartDate datetime = null,
@EndDate datetime = null,
@VisitPointId INT = null,
@IdCierre INT = null,
@IdAccount INT = null
AS
BEGIN

DECLARE @TEMPLATEDETAIL TABLE
    (
        guideserie NVARCHAR(MAX),
        guidenumber BIGINT,
        header BIGINT
    );

    INSERT INTO @TEMPLATEDETAIL
    (
        guideserie,
        guidenumber,
        header
    )
    SELECT IND.dti_fk_orderSerie,
           IND.dti_fk_orderNumber,
           MAX(IND.dti_fk_header) 'dti_fk_header'
	FROM invoiceDetail IND WITH (NOLOCK)
	INNER JOIN DeliveryOrderPaymentTransaction DPT
		ON IND.dti_fk_orderSerie = DPT.GuideSerie
		   AND IND.dti_fk_orderNumber = DPT.GuideNumber
	WHERE CONVERT(DATE, DPT.DateCreated) >= CONVERT(DATE, @StartDate) AND CONVERT(DATE, DPT.DateCreated) <= CONVERT(DATE, @EndDate)
		GROUP BY IND.dti_fk_orderSerie,
			     IND.dti_fk_orderNumber



if(@VisitPointId > 0 and @IdCierre > 0)
begin
	SELECT DISTINCT ACD.AccountingClosuresHeaderId ClosuresHeaderId
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
		,DOR.Guide_Serie + CONVERT(VARCHAR,DOR.Guide_Number) 'Guide'
		,isnull(costd.Voucher,'') 'Voucher'
		,CASE WHEN ISNULL(DOR.SenderCountryId,'GT') = 'GT' THEN 'GTQ.' ELSE 'HNL.' END AS CurrencySymbol
		,isnull(DOPD.amount, 0)'PriceShippment'
		,isnull(DOPD.CODAmountProcess,0) 'COD'
		, case 
			when DOPD.TypeofInOutMoneyId  = 1 THEN UPPER(ctgmon.tio_pk_name)
			when DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
			when DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
			when DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
			when DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
			when DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
			when DOPD.TypeofInOutMoneyId = 8 THEN UPPER(ctgmon.tio_pk_name)
			 else '' end 'PaymentType'
		,CTS.NameTypeService as 'ServiceType'
	FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
		LEFT JOIN @TEMPLATEDETAIL IND
			ON IND.guideserie = DOR.Guide_Serie
			AND IND.guidenumber = DOR.Guide_Number
		LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
			ON INH.inv_pk_id = IND.header
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder STO 
			ON STO.StatusOrderId = DOR.StatusOrderId
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
			 ON DOPD.GuideSerie = DOR.Guide_Serie 
			 AND DOPD.GuideNumber = DOR.Guide_Number
			 AND dopd.ShipmentCompleted = 1
			 AND DOPD.AccountId > 0
			 AND DOR.StatusOrderId != 7
			 AND DOPD.[TypeofInOutMoneyId] != 8

		-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
			ON DOPD.VisitPoint = VPC.CodeOfReference
		-- FIN MODIFICACIÓN

		INNER JOIN CatTypeServiceClosure CTS 
			ON CTS.IdTypeService = DOPD.TypeServiceId
		INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
			on ACD.GuideSerie = DOR.Guide_Serie
			AND ACD.GuideNumber = DOR.Guide_Number

			-- MODIFICACIÓN 31/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			AND ACD.DopId = DOPD.DopId 
			-- FIN MODIFICACIÓN

			AND ACD.RowStatus = 1
		INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
			ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
		LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
			ON REU.UsrIdUser = ACH.UserId
		left join DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon 
			on ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
		left join DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK)
			on cost.GuideNumber = DOR.Guide_Number
            AND cost.GuideSerie = DOR.Guide_Serie
		left join DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK)
			on costd.IdCost = cost.IdCost 
			AND costd.Amount > 0 
			AND (DOPD.TypeofInOutMoneyId = 6 AND costd.Voucher != '')
	WHERE  CONVERT(DATE, DOPD.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) 
		AND CONVERT(DATE, @EndDate)
		AND (DOPD.AccountId = @IdAccount OR DOPD.VisitPoint = @VisitPointId)
		AND ACD.AccountingClosuresHeaderId = @IdCierre
	-- ORDER BY DOPD.DateCreated ASC
	UNION ALL
		SELECT ACD.AccountingClosuresHeaderId ClosuresHeaderId
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
			,Status='----'  
			,Guide='----'
			,Voucher=''
			,'' AS CurrencySymbol
			,isnull(DOPD.amount, 0)'PriceShippment'
			,isnull(DOPD.CODAmountProcess,0) 'COD'
			, case 
				when DOPD.TypeofInOutMoneyId  = 1 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
				when DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
				WHEN DOPD.TypeofInOutMoneyId = 8 THEN UPPER(ctgmon.tio_pk_name)
				 else '' end 'PaymentType'
			,CTS.NameTypeService as 'ServiceType'
		
    --,DOPD.*
    --SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
    FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)

		-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
        INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
			ON DOPD.VisitPoint = VPC.CodeOfReference
		-- FIN MODIFICACIÓN

        INNER JOIN CatTypeServiceClosure CTS
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
		INNER JOIN invoiceHeader INH WITH (NOLOCK)
			ON INH.inv_numberFEL = (SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
        INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
			ON INH.inv_numberFEL = ACD.Fel 
		INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
			ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
		LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
			ON REU.UsrIdUser = ACH.UserId
	WHERE  CONVERT(DATE, DOPD.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
		AND (VPC.CodeOfReference = @VisitPointId OR DOPD.AccountId = @IdAccount) and ACD.AccountingClosuresHeaderId = @IdCierre
		AND ACD.RowStatus = 1
        AND (CTS.IdTypeService <> 23)
			 AND DOPD.[TypeofInOutMoneyId] != 8
	ORDER BY DOPD.DateCreated ASC
end


if(@VisitPointId > 0 and (@IdCierre <= 0 or @IdCierre is null) )
begin
	SELECT DISTINCT ACD.AccountingClosuresHeaderId ClosuresHeaderId
			,VP.VisitPointId
			,VP.DescriptionOfClient VisitPointDescription
			,ACh.UserId
			,REU.UsrNickName
			,DTP.DateCreated 'DateCreated'
			,DOR.Sender_FirstName + ' ' + DOR.Sender_LastName 'Client' 
			--,vpc.DescriptionOfClient,DOR.Sender_ID,DOR.IsCollect,DOPD.PayTypeId
			,INH.inv_certificationFEL 'CertificationFEL'
			,INH.inv_serieFEL 'SerieFel'
			,INH.inv_numberFEL 'NumberFel'
			,INH.inv_SAPDocEntry 'DOCSAP'
			,STO.OrderDescription 'Status'
			,DOR.Guide_Serie + CONVERT(VARCHAR,DOR.Guide_Number) 'Guide'
			,isnull(CD.Voucher,'') 'Voucher'
			,CASE WHEN ISNULL(DOR.SenderCountryId, 'GT') = 'GT' THEN 'GTQ.' ELSE 'HNL.' END AS CurrencySymbol 
			,isnull(DTP.amount, 0)'PriceShippment'
			,isnull(DTP.CODAmountProcess,0) 'COD'
			, case 
				when DTP.TypeofInOutMoneyId  = 1 THEN UPPER(ctgmon.tio_pk_name)
				when DTP.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
				when DTP.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
				when DTP.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
				when DTP.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
				when DTP.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
				WHEN DTP.TypeofInOutMoneyId = 8 THEN UPPER(ctgmon.tio_pk_name)
				 else '' end 'PaymentType'
			,CTS.NameTypeService as 'ServiceType'
	FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
			INNER JOIN @TEMPLATEDETAIL IND 
				ON IND.guideserie = DOR.Guide_Serie
				AND IND.guidenumber = DOR.Guide_Number
			INNER JOIN DeliveryOrderPaymentTransaction DTP WITH (NOLOCK)
				ON DTP.GuideSerie = IND.guideserie
				AND DTP.GuideNumber = IND.guidenumber
			INNER JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
				ON INH.inv_pk_id = IND.header
			INNER JOIN StatusOrder STO WITH (NOLOCK)
				ON DOR.StatusOrderId = STO.StatusOrderId
			INNER JOIN VisitPointClient VP WITH (NOLOCK)
				ON DTP.VisitPoint = VP.CodeOfReference
			INNER JOIN CatTypeServiceClosure CTS WITH (NOLOCK)
				ON CTS.IdTypeService = DTP.TypeServiceId
			INNER JOIN AccountingClosuresDetail ACD WITH (NOLOCK)
				ON ACD.GuideSerie = DOR.Guide_Serie
				AND ACD.GuideNumber = DOR.Guide_Number
				AND ACD.DopId = DTP.DopId
			INNER JOIN AccountingClosuresHeader ACH WITH (NOLOCK)
				ON ACD.AccountingClosuresHeaderId = ACH.IdAccountingClosuresHeader
			INNER JOIN  RegisterUser REU WITH (NOLOCK)
				ON ACH.UserId = REU.UsrIdUser
			INNER JOIN ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
				ON ctgmon.tio_pk_id = DTP.TypeofInOutMoneyId
			INNER JOIN Cost CO WITH (NOLOCK)
				ON CO.GuideSerie = DOR.Guide_Serie
				AND CO.GuideNumber = dor.Guide_Number
			INNER JOIN CostDetail CD WITH (NOLOCK)
				ON CD.IdCost = CO.IdCost
	WHERE CONVERT(DATE, DTP.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
	AND (DTP.AccountId = @IdAccount OR DTP.VisitPoint = @VisitPointId) AND DTP.ShipmentCompleted = 1
	AND DTP.AccountId > 0 AND DOR.StatusOrderId != 7 AND DTP.TypeofInOutMoneyId != 8 AND ACD.RowStatus = 1
-- ORDER BY ACD.AccountingClosuresHeaderId, DOPD.DateCreated ASC

	UNION ALL
		SELECT DISTINCT ACD.AccountingClosuresHeaderId ClosuresHeaderId
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
			,Status='----'  
			,Guide='----'
			,Voucher=''
			,CurrencySymbol = ''
			,isnull(DOPD.amount, 0)'PriceShippment'
			,isnull(DOPD.CODAmountProcess,0) 'COD'
			, case 
				when DOPD.TypeofInOutMoneyId  = 1 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
				when DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
				WHEN DOPD.TypeofInOutMoneyId = 8 THEN UPPER(ctgmon.tio_pk_name)
				 else '' end 'PaymentType'
			,CTS.NameTypeService as 'ServiceType'
		
		--,DOPD.*
		--SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
		FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)

		-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
				ON DOPD.VisitPoint = VPC.CodeOfReference
			-- FIN MODIFICACIÓN

			INNER JOIN CatTypeServiceClosure CTS
				ON CTS.IdTypeService = DOPD.TypeServiceId
			LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
				ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
			INNER JOIN invoiceHeader INH WITH (NOLOCK)  
				ON INH.inv_numberFEL = (SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
			INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
				ON INH.inv_numberFEL = ACD.Fel
			INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
				ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
				ON REU.UsrIdUser = ACH.UserId
		WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
			AND (VPC.CodeOfReference = @VisitPointId OR DOPD.AccountId = @IdAccount)
			AND (CTS.IdTypeService <> 23)
			AND DOPD.[TypeofInOutMoneyId] != 8
            AND ACD.RowStatus = 1
	--	ORDER BY ACD.AccountingClosuresHeaderId, DOPD.DateCreated ASC

end


if(@VisitPointId = -1  and (@IdCierre <= 0 or @IdCierre is null))
begin
	SELECT DISTINCT ACD.AccountingClosuresHeaderId ClosuresHeaderId
		,VPC.VisitPointId
		,VPC.DescriptionOfClient VisitPointDescription
		,ACh.UserId
		,REU.UsrNickName
		,DOPD.DateCreated 'DateCreated'
		,DOR.Sender_FirstName + ' ' + DOR.Sender_LastName 'Client' 
		--,vpc.DescriptionOfClient,DOR.Sender_ID,DOR.IsCollect,DOPD.PayTypeId
		,INH.inv_certificationFEL 'CertificationFEL'
		,INH.inv_serieFEL 'SerieFel'
		,INH.inv_numberFEL 'NumberFel'
		,INH.inv_SAPDocEntry 'DOCSAP'
		,STO.OrderDescription 'Status'
		,DOR.Guide_Serie + CONVERT(VARCHAR,DOR.Guide_Number) 'Guide'
		,isnull(costd.Voucher,'') 'Voucher'
		,CASE WHEN ISNULL(DOR.SenderCountryId,'GT') = 'GT' THEN 'GTQ.' ELSE 'HNL.' END AS CurrencySymbol
		,isnull(DOPD.amount, 0)'PriceShippment'
		,isnull(DOPD.CODAmountProcess,0) 'COD'
		, case 
			when DOPD.TypeofInOutMoneyId  = 1 THEN UPPER(ctgmon.tio_pk_name)
			when DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
			when DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
			when DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
			when DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
			when DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
			WHEN DOPD.TypeofInOutMoneyId = 8 THEN UPPER(ctgmon.tio_pk_name)
			 else '' end 'PaymentType'
		,CTS.NameTypeService as 'ServiceType'
--,DOPD.*
--SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
	FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
		LEFT JOIN @TEMPLATEDETAIL IND
			ON IND.guideserie = DOR.Guide_Serie
			AND IND.guidenumber = DOR.Guide_Number
		LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
			ON INH.inv_pk_id = IND.header
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder STO 
			ON STO.StatusOrderId = DOR.StatusOrderId
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK) 
			ON DOPD.GuideSerie = DOR.Guide_Serie 
			AND DOPD.GuideNumber = DOR.Guide_Number
			AND dopd.ShipmentCompleted = 1
			AND DOPD.AccountId > 0
			AND DOR.StatusOrderId != 7
			 AND DOPD.[TypeofInOutMoneyId] != 8

		-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
			ON DOPD.VisitPoint = VPC.CodeOfReference
		-- FIN MODIFICACIÓN

		INNER JOIN CatTypeServiceClosure CTS 
			ON CTS.IdTypeService = DOPD.TypeServiceId
		INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
			on ACD.GuideSerie = DOR.Guide_Serie
			AND ACD.GuideNumber = DOR.Guide_Number

			-- MODIFICACIÓN 31/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			AND ACD.DopId = DOPD.DopId
			-- FIN MODIFICACIÓN

			AND ACD.RowStatus = 1
		INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
			ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
		LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
			ON REU.UsrIdUser = ACH.UserId
		left join DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon 
			on ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
		left join DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK) 
			on cost.GuideSerie = DOR.Guide_Serie
            AND cost.GuideNumber = DOR.Guide_Number
		left join DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK)  
			on costd.IdCost = cost.IdCost AND costd.Amount > 0 
			AND (DOPD.TypeofInOutMoneyId = 6 AND costd.Voucher != '')
	WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)

--ORDER BY ACD.AccountingClosuresHeaderId, DOPD.DateCreated ASC

	UNION ALL
		SELECT DISTINCT ACD.AccountingClosuresHeaderId ClosuresHeaderId
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
			,Status='----'  
			,Guide='----'
			,Voucher=''
			,CurrencySymbol = ''
			,isnull(DOPD.amount, 0)'PriceShippment'
			,isnull(DOPD.CODAmountProcess,0) 'COD'
			, case 
				when DOPD.TypeofInOutMoneyId  = 1 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
				when DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
				when DOPD.TypeofInOutMoneyId = 7 THEN UPPER(ctgmon.tio_pk_name)
				WHEN DOPD.TypeofInOutMoneyId = 8 THEN UPPER(ctgmon.tio_pk_name)
				 else '' end 'PaymentType'
			,CTS.NameTypeService as 'ServiceType'
		
    --,DOPD.*
    --SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
		FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
			INNER JOIN CatTypeServiceClosure CTS
				ON CTS.IdTypeService = DOPD.TypeServiceId
			LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
				ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
			INNER JOIN invoiceHeader INH WITH (NOLOCK)
				ON INH.inv_numberFEL = (SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
			INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
				ON INH.inv_numberFEL = ACD.Fel
			INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
				ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId

			-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
				ON DOPD.VisitPoint = VPC.CodeOfReference
			-- FIN MODIFICACIÓN

			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
				ON REU.UsrIdUser = ACH.UserId
		WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
			AND (CTS.IdTypeService <> 23)
			 AND DOPD.[TypeofInOutMoneyId] != 8
             AND ACD.RowStatus = 1
		ORDER BY ACD.AccountingClosuresHeaderId, DOPD.DateCreated ASC
end
END
