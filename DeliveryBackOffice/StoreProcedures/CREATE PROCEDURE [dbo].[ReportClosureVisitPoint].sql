USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[ReportClosureVisitPoint]    Script Date: 6/04/2022 14:56:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alejandro Rodríguez>
-- Create date: <30/03/2022>
-- Description:	<SP para consulta de cierres generales en reporte de reporting services>
-- Nota: Es una copia de ReportClosure
-- =============================================
CREATE PROCEDURE [dbo].[ReportClosureVisitPoint]
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
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPT WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH (NOLOCK)
            ON IND.dti_fk_orderSerie = DOPT.GuideSerie
               AND IND.dti_fk_orderNumber = DOPT.GuideNumber
    WHERE CAST(DOPT.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
    GROUP BY IND.dti_fk_orderSerie,
             IND.dti_fk_orderNumber;


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
		
		-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
		,ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral'
		,REU1.UsrNickName 'Encargado'
		-- FIN MODIFICACIÓN

	FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
		LEFT JOIN @TEMPLATEDETAIL IND
			ON IND.guideserie = DOR.Guide_Serie
			AND IND.guidenumber = DOR.Guide_Number
		LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
			ON INH.inv_pk_id = IND.header
		JOIN DeliveryBackOffice.dbo.StatusOrder STO 
			ON STO.StatusOrderId = DOR.StatusOrderId
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
			 ON DOPD.GuideSerie = DOR.Guide_Serie 
			 AND DOPD.GuideNumber = DOR.Guide_Number
			 AND dopd.ShipmentCompleted = 1
			 AND DOPD.AccountId > 0
			 AND DOR.StatusOrderId != 7
		JOIN CatTypeServiceClosure CTS 
			ON CTS.IdTypeService = DOPD.TypeServiceId
		JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
			on ACD.GuideSerie = DOR.Guide_Serie
			AND ACD.GuideNumber = DOR.Guide_Number

			-- MODIFICACIÓN 01/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			AND ACD.DopId = DOPD.DopId
			-- FIN MODIFICACIÓN

			AND ACD.RowStatus = 1
		JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
			ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
		LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
			ON REU.UsrIdUser = ACH.UserId
		left join DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon 
			on ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
		left join DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK)
			on cost.ProductNumber = CONCAT(DOR.Guide_Serie,DOR.Guide_Number)
		left join DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK)
			on costd.IdCost = cost.IdCost 
			AND costd.Amount > 0 
			AND (DOPD.TypeofInOutMoneyId = 6 AND costd.Voucher != '')
		LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
			ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint

		-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
			ON DOPD.VisitPoint = VPC.CodeOfReference
		LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
			ON REU1.UsrIdUser = ACHVP.UserId
		-- FIN MODIFICACIÓN

	WHERE  CONVERT(DATE, DOPD.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) 
		AND CONVERT(DATE, @EndDate)
		AND (DOR.Sender_ID = @VisitPointId 
			--OR DOPD.AccountId = @IdAccount 
			OR DOPD.VisitPoint = @VisitPointId)
		AND ACHVP.IdAccountingClosuresHeaderVisitPoint = @IdCierre 
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
		
			-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
			,ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral'
			,REU1.UsrNickName 'Encargado'
			-- FIN MODIFICACIÓN

		--,DOPD.*
		--SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
		FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
			JOIN CatTypeServiceClosure CTS
				ON CTS.IdTypeService = DOPD.TypeServiceId
			LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
				ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
			JOIN invoiceHeader INH WITH (NOLOCK)
				ON INH.inv_numberFEL = (SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
			JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
				ON INH.inv_numberFEL = ACD.Fel AND ACD.RowStatus = 1
			JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
				ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
				ON REU.UsrIdUser = ACH.UserId
			LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
				ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint

			-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
				ON DOPD.VisitPoint = VPC.CodeOfReference
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
				ON REU1.UsrIdUser = ACHVP.UserId
			-- FIN MODIFICACIÓN

			WHERE CONVERT(DATE, DOPD.DateCreated) 
				BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
				AND (VPC.CodeOfReference = @VisitPointId 
					--OR DOPD.AccountId = @IdAccount
					) 
				and ACHVP.IdAccountingClosuresHeaderVisitPoint = @IdCierre
				AND (CTS.IdTypeService NOT IN (5,23))
			ORDER BY DOPD.DateCreated ASC
end


if(@VisitPointId > 0 and (@IdCierre <= 0 or @IdCierre is null) )
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

		-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
		,ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral'
		,REU1.UsrNickName 'Encargado'
		-- FIN MODIFICACIÓN

	FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
		LEFT JOIN @TEMPLATEDETAIL IND
			ON IND.guideserie = DOR.Guide_Serie
			AND IND.guidenumber = DOR.Guide_Number
		LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
			ON INH.inv_pk_id = IND.header
		JOIN DeliveryBackOffice.dbo.StatusOrder STO 
			ON STO.StatusOrderId = DOR.StatusOrderId
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
			ON DOPD.GuideSerie = DOR.Guide_Serie 
			AND DOPD.GuideNumber = DOR.Guide_Number
			AND dopd.ShipmentCompleted = 1
			AND DOPD.AccountId > 0
			AND DOR.StatusOrderId != 7
		JOIN CatTypeServiceClosure CTS 
			ON CTS.IdTypeService = DOPD.TypeServiceId
		JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
			on ACD.GuideSerie = DOR.Guide_Serie
			AND ACD.GuideNumber = DOR.Guide_Number

			-- MODIFICACIÓN 01/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			AND ACD.DopId = DOPD.DopId
			-- FIN MODIFICACIÓN

			AND ACD.RowStatus = 1
		JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
			ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
		LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
			ON REU.UsrIdUser = ACH.UserId
		left join DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon 
			on ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
		left join DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK)
			on cost.ProductNumber = CONCAT(DOR.Guide_Serie,DOR.Guide_Number)
		left join DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK)
			on costd.IdCost = cost.IdCost AND costd.Amount > 0 
			AND (DOPD.TypeofInOutMoneyId = 6 AND costd.Voucher != '')
		LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
			ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint

		-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
			ON DOPD.VisitPoint = VPC.CodeOfReference
		LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
			ON REU1.UsrIdUser = ACHVP.UserId
		-- FIN MODIFICACIÓN

	WHERE CONVERT(DATE, DOPD.DateCreated) 
		BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
		AND (DOR.Sender_ID = @VisitPointId 
			--OR DOPD.AccountId = @IdAccount 
			OR DOPD.VisitPoint = @VisitPointId)
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

			-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
			,ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral'
			,REU1.UsrNickName 'Encargado'
			-- FIN MODIFICACIÓN
		
		--,DOPD.*
		--SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
		FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
			JOIN CatTypeServiceClosure CTS
				ON CTS.IdTypeService = DOPD.TypeServiceId
			LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
				ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
			JOIN invoiceHeader INH WITH (NOLOCK)
				ON INH.inv_numberFEL = (SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
			JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
				ON INH.inv_numberFEL = ACD.Fel AND ACD.RowStatus = 1
			JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
				ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
				ON REU.UsrIdUser = ACH.UserId
			LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
				ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint

			-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
				ON DOPD.VisitPoint = VPC.CodeOfReference
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
				ON REU1.UsrIdUser = ACHVP.UserId
			-- FIN MODIFICACIÓN

		WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
			AND (VPC.CodeOfReference = @VisitPointId 
				--OR DOPD.AccountId = @IdAccount
				)
			AND (CTS.IdTypeService NOT IN (5,23))
		ORDER BY ACD.AccountingClosuresHeaderId, DOPD.DateCreated ASC

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

		-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
		,ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral'
		,REU1.UsrNickName 'Encargado'
		-- FIN MODIFICACIÓN

--,DOPD.*
--SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
	FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
		LEFT JOIN @TEMPLATEDETAIL IND
			ON IND.guideserie = DOR.Guide_Serie
			AND IND.guidenumber = DOR.Guide_Number
		LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
			ON INH.inv_pk_id = IND.header
		JOIN DeliveryBackOffice.dbo.StatusOrder STO 
			ON STO.StatusOrderId = DOR.StatusOrderId
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
			ON DOPD.GuideSerie = DOR.Guide_Serie 
			AND DOPD.GuideNumber = DOR.Guide_Number
			AND dopd.ShipmentCompleted = 1
			AND DOPD.AccountId > 0
			AND DOR.StatusOrderId != 7
		JOIN CatTypeServiceClosure CTS 
			ON CTS.IdTypeService = DOPD.TypeServiceId
		JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
			on ACD.GuideSerie = DOR.Guide_Serie
			AND ACD.GuideNumber = DOR.Guide_Number

			-- MODIFICACIÓN 01/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			AND ACD.DopId = DOPD.DopId
			-- FIN MODIFICACIÓN

			AND ACD.RowStatus = 1
		JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
			ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
		LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
			ON REU.UsrIdUser = ACH.UserId
		left join DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon 
			on ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
		left join DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK)
			on cost.ProductNumber = CONCAT(DOR.Guide_Serie,DOR.Guide_Number)
		left join DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK) 
			on costd.IdCost = cost.IdCost AND costd.Amount > 0 
			AND (DOPD.TypeofInOutMoneyId = 6 AND costd.Voucher != '')
		LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
			ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint

		-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
			ON DOPD.VisitPoint = VPC.CodeOfReference
		LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
			ON REU1.UsrIdUser = ACHVP.UserId
		-- FIN MODIFICACIÓN

	WHERE CONVERT(DATE, DOPD.DateCreated) 
		BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)

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
		
			-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
			,ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral'
			,REU1.UsrNickName 'Encargado'
			-- FIN MODIFICACIÓN

    --,DOPD.*
    --SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
		FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
			JOIN CatTypeServiceClosure CTS
				ON CTS.IdTypeService = DOPD.TypeServiceId
			LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
				ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
			JOIN invoiceHeader INH WITH (NOLOCK)  
				ON INH.inv_numberFEL = (SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
			JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
				ON INH.inv_numberFEL = ACD.Fel AND ACD.RowStatus = 1
			JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
				ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU 
				ON REU.UsrIdUser = ACH.UserId
			LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
				ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.IdAccountingClosuresHeaderVisitPoint

			-- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
				ON DOPD.VisitPoint = VPC.CodeOfReference
			LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
				ON REU1.UsrIdUser = ACHVP.UserId
			-- FIN MODIFICACIÓN
		WHERE CONVERT(DATE, DOPD.DateCreated) 
			BETWEEN  CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
			AND (CTS.IdTypeService NOT IN (5,23))
		ORDER BY ACD.AccountingClosuresHeaderId, DOPD.DateCreated ASC
end
END
