-- =============================================
-- Author:		<Alejandro Rodríguez>
-- Create date: <30/03/2022>
-- Description:	<SP para consulta de cierres generales en reporte de reporting services>
-- Nota: Es una copia de ReportClosure
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <10-07-2024>
-- Description:	<Se agrega la moneda y las cuentas para mostrar en el detalle del reporte>
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <26-07-2024>
-- Description:	<Se optimiza la consulta ya que se tardaba 1:30seg>
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <26-07-2024>
-- Description:	<Aceptación de Voucher en pagos con Zigi>
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <10/10/2025>
-- Description:	<Se agregan envios internacionales.>
-- =============================================
CREATE PROCEDURE [dbo].[ReportClosureVisitPoint]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @VisitPointId INT = NULL,
    @IdCierre INT = NULL,
    @IdAccount INT = NULL
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

    -- MODIFICACIÓN 23/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
    WHERE CONVERT(DATE, DOPT.DateCreated)
    BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
    -- FIN MODIFICACIÓN

    GROUP BY IND.dti_fk_orderSerie,
             IND.dti_fk_orderNumber;

    IF (@VisitPointId > 0 AND @IdCierre > 0)
    BEGIN
        SELECT DISTINCT
               ACD.AccountingClosuresHeaderId ClosuresHeaderId,
               VPC.VisitPointId,
               VPC.DescriptionOfClient VisitPointDescription,
               ACH.UserId,
               REU.UsrNickName,
               DOPD.DateCreated 'DateCreated',
               DOR.Sender_FirstName + ' ' + DOR.Sender_LastName 'Client',
               INH.inv_certificationFEL 'CertificationFEL',
               INH.inv_serieFEL 'SerieFel',
               INH.inv_numberFEL 'NumberFel',
               INH.inv_SAPDocEntry 'DOCSAP',
               STO.OrderDescription 'Status',
               DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number) 'Guide',
               ISNULL(costd.Voucher, '') 'Voucher',
               ISNULL(DOPD.amount, 0) 'PriceShippment',
               ISNULL(DOPD.CODAmountProcess, 0) 'COD',
               CASE
                    -- Modificación 21/10/2025
                    WHEN DOPD.TypeofInOutMoneyId IN (1, 2, 3, 4, 7, 8, 10) THEN UPPER(ctgmon.tio_pk_name)
                    WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
                    -- Fin de modificación
                ELSE
                       ''
               END 'PaymentType',
               CTS.NameTypeService AS 'ServiceType',
               -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral',
               REU1.UsrNickName 'Encargado',
               -- FIN MODIFICACIÓN

               -- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ISNULL(ACHVP.Voucher1, '') 'VoucherGeneral',
               ISNULL(ACHVP.Bag1, '') 'Bolsa',
               ISNULL(ACHVP.ClosurerPOS, '') 'CierrePOS',
        -- FIN MODIFICACIÓN
            ISNULL(CCC.CodeISO,'') AS CurrencySymbol
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
                   AND DOPD.ShipmentCompleted = 1
                   AND DOPD.AccountId > 0
                   AND DOR.StatusOrderId != 7
                   AND DOPD.[TypeofInOutMoneyId] != 8
            INNER JOIN CatTypeServiceClosure CTS
                ON CTS.IdTypeService = DOPD.TypeServiceId
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
                ON ACD.GuideSerie = DOR.Guide_Serie
                   AND ACD.GuideNumber = DOR.Guide_Number

                   -- MODIFICACIÓN 01/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                   AND ACD.DopId = DOPD.DopId
                   -- FIN MODIFICACIÓN
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
                ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU
                ON REU.UsrIdUser = ACH.UserId
            LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
                ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
            LEFT JOIN DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK)
                ON cost.GuideSerie = DOR.Guide_Serie 
                AND DOR.Guide_Number = cost.GuideNumber  
            LEFT JOIN DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK)
                ON costd.IdCost = cost.IdCost
                   AND costd.Amount > 0
                   AND
                   (
                       DOPD.TypeofInOutMoneyId IN (6, 10)
                       AND costd.Voucher != ''
                   )
            LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
                ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId

            -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
            INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
                ON DOPD.VisitPoint = VPC.CodeOfReference
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
                ON REU1.UsrIdUser = ACHVP.UserId
            LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
                ON cost.ShippingCurrency = CCC.IdCatCurrencyCOD
        -- FIN MODIFICACIÓN

            WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
              AND ACD.RowStatus = 1
              -- MODIFICACIÓN 25/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
              AND
              (
                  DOPD.AccountId = @IdAccount
                  OR DOPD.VisitPoint = @VisitPointId
              )
              -- FIN MODIFICACIÓN

              AND ACHVP.IdAccountingClosuresHeaderVisitPoint = @IdCierre
              AND ACH.AccountingClosuresHeaderVisitPointId IS NOT NULL
              AND ACD.RowStatus = 1
        -- ORDER BY DOPD.DateCreated ASC
        UNION ALL
        SELECT ACD.AccountingClosuresHeaderId ClosuresHeaderId,
               VPC.VisitPointId,
               VPC.DescriptionOfClient VisitPointDescription,
               ACH.UserId,
               REU.UsrNickName,
               DOPD.DateCreated 'DateCreated',
               INH.inv_UserName 'Client',
               INH.inv_certificationFEL 'CertificationFEL',
               INH.inv_serieFEL 'SerieFel',
               INH.inv_numberFEL 'NumberFel',
               INH.inv_SAPDocEntry 'DOCSAP',
               Status = '----',
               Guide = '----',
               Voucher = '',
               ISNULL(DOPD.amount, 0) 'PriceShippment',
               ISNULL(DOPD.CODAmountProcess, 0) 'COD',
               CASE
                    -- Modificación 21/10/2025
                    WHEN DOPD.TypeofInOutMoneyId IN (1, 2, 3, 4, 7, 8, 10) THEN UPPER(ctgmon.tio_pk_name)
                    WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
                    -- Fin de modificación
                ELSE
                       ''
               END 'PaymentType',
               CTS.NameTypeService AS 'ServiceType',
               -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral',
               REU1.UsrNickName 'Encargado',
               -- FIN MODIFICACIÓN

               -- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ISNULL(ACHVP.Voucher1, '') 'VoucherGeneral',
               ISNULL(ACHVP.Bag1, '') 'Bolsa',
               ISNULL(ACHVP.ClosurerPOS, '') 'CierrePOS',
        -- FIN MODIFICACIÓN
			   CurrencySymbol = ''

        --,DOPD.*
        --SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
        FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
            INNER JOIN CatTypeServiceClosure CTS
                ON CTS.IdTypeService = DOPD.TypeServiceId
            LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
                ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
            INNER JOIN invoiceHeader INH WITH (NOLOCK)
                ON INH.inv_numberFEL =
                (
                    SELECT Item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2
                )
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
                ON INH.inv_numberFEL = ACD.Fel
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
                ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU
                ON REU.UsrIdUser = ACH.UserId
            LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
                ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId

            -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
            INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
                ON DOPD.VisitPoint = VPC.CodeOfReference
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
                ON REU1.UsrIdUser = ACHVP.UserId
        -- FIN MODIFICACIÓN

        WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
              AND ACD.RowStatus = 1
              AND (VPC.CodeOfReference = @VisitPointId
                  --OR DOPD.AccountId = @IdAccount
                  )
              AND ACHVP.IdAccountingClosuresHeaderVisitPoint = @IdCierre
              AND (CTS.IdTypeService NOT IN ( 5, 23 ))
              AND ACH.AccountingClosuresHeaderVisitPointId IS NOT NULL
              AND DOPD.[TypeofInOutMoneyId] != 8
              AND ACD.RowStatus = 1
        ORDER BY DOPD.DateCreated ASC;
    END;


    IF (@VisitPointId > 0 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
    BEGIN
        SELECT DISTINCT
               ACD.AccountingClosuresHeaderId ClosuresHeaderId,
               VPC.VisitPointId,
               VPC.DescriptionOfClient VisitPointDescription,
               ACH.UserId,
               REU.UsrNickName,
               DOPD.DateCreated 'DateCreated',
               DOR.Sender_FirstName + ' ' + DOR.Sender_LastName 'Client',
               --,vpc.DescriptionOfClient,DOR.Sender_ID,DOR.IsCollect,DOPD.PayTypeId
               INH.inv_certificationFEL 'CertificationFEL',
               INH.inv_serieFEL 'SerieFel',
               INH.inv_numberFEL 'NumberFel',
               INH.inv_SAPDocEntry 'DOCSAP',
               STO.OrderDescription 'Status',
               DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number) 'Guide',
               ISNULL(costd.Voucher, '') 'Voucher',
               ISNULL(DOPD.amount, 0) 'PriceShippment',
               ISNULL(DOPD.CODAmountProcess, 0) 'COD',
               CASE
                   -- Modificación 21/10/2025
                    WHEN DOPD.TypeofInOutMoneyId IN (1, 2, 3, 4, 7, 8, 10) THEN UPPER(ctgmon.tio_pk_name)
                    WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
                    -- Fin de modificación
                   ELSE
                       ''
               END 'PaymentType',
               CTS.NameTypeService AS 'ServiceType',
               -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral',
               REU1.UsrNickName 'Encargado',
               -- FIN MODIFICACIÓN

               -- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ISNULL(ACHVP.Voucher1, '') 'VoucherGeneral',
               ISNULL(ACHVP.Bag1, '') 'Bolsa',
               ISNULL(ACHVP.ClosurerPOS, '') 'CierrePOS',
        -- FIN MODIFICACIÓN
			   ISNULL(CCC.CodeISO,'') AS CurrencySymbol
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
            INNER JOIN CatTypeServiceClosure CTS
                ON CTS.IdTypeService = DOPD.TypeServiceId
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
                ON ACD.GuideSerie = DOR.Guide_Serie
                   AND ACD.GuideNumber = DOR.Guide_Number

                   -- MODIFICACIÓN 01/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                   AND ACD.DopId = DOPD.DopId
                   -- FIN MODIFICACIÓN
                   AND ACD.RowStatus = 1
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
                ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU
                ON REU.UsrIdUser = ACH.UserId
            LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
                ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
            LEFT JOIN DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK)
                ON cost.GuideSerie = DOR.Guide_Serie 
                AND DOR.Guide_Number = cost.GuideNumber 
            LEFT JOIN DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK)
                ON costd.IdCost = cost.IdCost
                   AND costd.Amount > 0
                   AND
                   (
                       DOPD.TypeofInOutMoneyId IN (6, 10)
                       AND costd.Voucher != ''
                   )
            LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
                ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId

            -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
            INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
                ON DOPD.VisitPoint = VPC.CodeOfReference
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
                ON REU1.UsrIdUser = ACHVP.UserId
        -- FIN MODIFICACIÓN
            LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
                ON cost.ShippingCurrency = CCC.IdCatCurrencyCOD
        WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
              AND ACD.RowStatus = 1
              -- MODIFICACIÓN 25/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
              AND
              (
                  DOPD.AccountId = @IdAccount
                  OR DOPD.VisitPoint = @VisitPointId
              )
              -- FIN MODIFICACIÓN
              AND ACH.AccountingClosuresHeaderVisitPointId IS NOT NULL 
              AND DOPD.ShipmentCompleted = 1
              AND DOPD.AccountId > 0
			  AND DOPD.[TypeofInOutMoneyId] != 8
              AND ACD.RowStatus = 1
        -- ORDER BY ACD.AccountingClosuresHeaderId, DOPD.DateCreated ASC

        UNION ALL
        SELECT DISTINCT
               ACD.AccountingClosuresHeaderId ClosuresHeaderId,
               VPC.VisitPointId,
               VPC.DescriptionOfClient VisitPointDescription,
               ACH.UserId,
               REU.UsrNickName,
               DOPD.DateCreated 'DateCreated',
               INH.inv_UserName 'Client',
               INH.inv_certificationFEL 'CertificationFEL',
               INH.inv_serieFEL 'SerieFel',
               INH.inv_numberFEL 'NumberFel',
               INH.inv_SAPDocEntry 'DOCSAP',
               Status = '----',
               Guide = '----',
               Voucher = '',
               ISNULL(DOPD.amount, 0) 'PriceShippment',
               ISNULL(DOPD.CODAmountProcess, 0) 'COD',
               CASE
                   -- Modificación 21/10/2025
                    WHEN DOPD.TypeofInOutMoneyId IN (1, 2, 3, 4, 7, 8, 10) THEN UPPER(ctgmon.tio_pk_name)
                    WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
                    -- Fin de modificación
                   ELSE
                       ''
               END 'PaymentType',
               CTS.NameTypeService AS 'ServiceType',
               -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral',
               REU1.UsrNickName 'Encargado',
               -- FIN MODIFICACIÓN

               -- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ISNULL(ACHVP.Voucher1, '') 'VoucherGeneral',
               ISNULL(ACHVP.Bag1, '') 'Bolsa',
               ISNULL(ACHVP.ClosurerPOS, '') 'CierrePOS',
        -- FIN MODIFICACIÓN
			   CurrencySymbol = ''
        --,DOPD.*
        --SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
        FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
            INNER JOIN CatTypeServiceClosure CTS
                ON CTS.IdTypeService = DOPD.TypeServiceId
            LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
                ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
            INNER JOIN invoiceHeader INH WITH (NOLOCK)
                ON INH.inv_numberFEL =
                (
                    SELECT Item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2
                )
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
			ON INH.inv_numberFEL = ACD.Fel
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
                ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU
                ON REU.UsrIdUser = ACH.UserId
            LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
                ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId

            -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
            INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
                ON DOPD.VisitPoint = VPC.CodeOfReference
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
                ON REU1.UsrIdUser = ACHVP.UserId
        -- FIN MODIFICACIÓN
        WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
              AND ACD.RowStatus = 1
              AND (VPC.CodeOfReference = @VisitPointId
                  --OR DOPD.AccountId = @IdAccount
                  )
              AND (CTS.IdTypeService NOT IN ( 5, 23 ))
              AND ACH.AccountingClosuresHeaderVisitPointId IS NOT NULL
              AND DOPD.[TypeofInOutMoneyId] != 8
			  AND ACD.RowStatus = 1
        ORDER BY ACD.AccountingClosuresHeaderId,
                 DOPD.DateCreated ASC;

    END;

    IF (@VisitPointId = -1 AND (@IdCierre <= 0 OR @IdCierre IS NULL))
    BEGIN
        SELECT DISTINCT
               ACD.AccountingClosuresHeaderId ClosuresHeaderId,
               VPC.VisitPointId,
               VPC.DescriptionOfClient VisitPointDescription,
               ACH.UserId,
               REU.UsrNickName,
               DOPD.DateCreated 'DateCreated',
               DOR.Sender_FirstName + ' ' + DOR.Sender_LastName 'Client',
               --,vpc.DescriptionOfClient,DOR.Sender_ID,DOR.IsCollect,DOPD.PayTypeId
               INH.inv_certificationFEL 'CertificationFEL',
               INH.inv_serieFEL 'SerieFel',
               INH.inv_numberFEL 'NumberFel',
               INH.inv_SAPDocEntry 'DOCSAP',
               STO.OrderDescription 'Status',
               DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number) 'Guide',
               ISNULL(costd.Voucher, '') 'Voucher',
               ISNULL(DOPD.amount, 0) 'PriceShippment',
               ISNULL(DOPD.CODAmountProcess, 0) 'COD',
               CASE
                   -- Modificación 21/10/2025
                    WHEN DOPD.TypeofInOutMoneyId IN (1, 2, 3, 4, 7, 8, 10) THEN UPPER(ctgmon.tio_pk_name)
                    WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
                    -- Fin de modificación
                   ELSE
                       ''
               END 'PaymentType',
               CTS.NameTypeService AS 'ServiceType',
               -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral',
               REU1.UsrNickName 'Encargado',
               -- FIN MODIFICACIÓN

               -- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ISNULL(ACHVP.Voucher1, '') 'VoucherGeneral',
               ISNULL(ACHVP.Bag1, '') 'Bolsa',
               ISNULL(ACHVP.ClosurerPOS, '') 'CierrePOS',
        -- FIN MODIFICACIÓN
			   ISNULL(CCC.CodeISO,'') AS CurrencySymbol
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
                   AND DOPD.ShipmentCompleted = 1
                   AND DOPD.AccountId > 0
                   AND DOR.StatusOrderId != 7
                   AND DOPD.[TypeofInOutMoneyId] != 8
            INNER JOIN CatTypeServiceClosure CTS
                ON CTS.IdTypeService = DOPD.TypeServiceId
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
                ON ACD.GuideSerie = DOR.Guide_Serie
                   AND ACD.GuideNumber = DOR.Guide_Number
                   -- MODIFICACIÓN 01/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                   AND ACD.DopId = DOPD.DopId
                   -- FIN MODIFICACIÓN
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
                ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU
                ON REU.UsrIdUser = ACH.UserId
            LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
                ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
            LEFT JOIN DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK)
                ON cost.GuideSerie = DOR.Guide_Serie 
                AND DOR.Guide_Number = cost.GuideNumber  
            LEFT JOIN DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK)
                ON costd.IdCost = cost.IdCost
                   AND costd.Amount > 0
                   AND
                   (
                       DOPD.TypeofInOutMoneyId IN (6, 10)
                       AND costd.Voucher != ''
                   )
            LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
                ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId
            -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
            INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
                ON DOPD.VisitPoint = VPC.CodeOfReference
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
                ON REU1.UsrIdUser = ACHVP.UserId
        -- FIN MODIFICACIÓN
            LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
             ON cost.ShippingCurrency = CCC.IdCatCurrencyCOD
        WHERE CONVERT(DATE, DOPD.DateCreated) BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
              AND ACD.RowStatus = 1
              AND ACH.AccountingClosuresHeaderVisitPointId IS NOT NULL
              AND ACD.RowStatus = 1
        --ORDER BY ACD.AccountingClosuresHeaderId, DOPD.DateCreated ASC

        UNION ALL
        SELECT DISTINCT
               ACD.AccountingClosuresHeaderId ClosuresHeaderId,
               VPC.VisitPointId,
               VPC.DescriptionOfClient VisitPointDescription,
               ACH.UserId,
               REU.UsrNickName,
               DOPD.DateCreated 'DateCreated',
               INH.inv_UserName 'Client',
               INH.inv_certificationFEL 'CertificationFEL',
               INH.inv_serieFEL 'SerieFel',
               INH.inv_numberFEL 'NumberFel',
               INH.inv_SAPDocEntry 'DOCSAP',
               Status = '----',
               Guide = '----',
               Voucher = '',
               ISNULL(DOPD.amount, 0) 'PriceShippment',
               ISNULL(DOPD.CODAmountProcess, 0) 'COD',
              CASE
                   -- Modificación 21/10/2025
                    WHEN DOPD.TypeofInOutMoneyId IN (1, 2, 3, 4, 7, 8, 10) THEN UPPER(ctgmon.tio_pk_name)
                    WHEN DOPD.TypeofInOutMoneyId = 6 THEN UPPER('pago con tarjeta')
                    -- Fin de modificación
                   ELSE
                       ''
               END 'PaymentType',
               CTS.NameTypeService AS 'ServiceType',
               -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ACHVP.IdAccountingClosuresHeaderVisitPoint 'CierreGeneral',
               REU1.UsrNickName 'Encargado',
               -- FIN MODIFICACIÓN

               -- MODIFICACIÓN 12/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN 
               ISNULL(ACHVP.Voucher1, '') 'VoucherGeneral',
               ISNULL(ACHVP.Bag1, '') 'Bolsa',
               ISNULL(ACHVP.ClosurerPOS, '') 'CierrePOS',
        -- FIN MODIFICACIÓN
			   CurrencySymbol = ''
        --,DOPD.*
        --SELECT * FROM DeliveryBackOffice.dbo.CatPaymentType
        FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
            INNER JOIN CatTypeServiceClosure CTS
                ON CTS.IdTypeService = DOPD.TypeServiceId
            LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
                ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
            INNER JOIN invoiceHeader INH WITH (NOLOCK)
                ON INH.inv_numberFEL =
                (
                    SELECT Item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2
                )
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
			ON INH.inv_numberFEL = ACD.Fel
            INNER JOIN DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
                ON ACH.IdAccountingClosuresHeader = ACD.AccountingClosuresHeaderId
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU
                ON REU.UsrIdUser = ACH.UserId
            LEFT JOIN AccountingClosuresHeaderVisitPoint ACHVP
                ON ACHVP.IdAccountingClosuresHeaderVisitPoint = ACH.AccountingClosuresHeaderVisitPointId

            -- MODIFICACIÓN 06/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
            INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
                ON DOPD.VisitPoint = VPC.CodeOfReference
            LEFT JOIN DeliveryBackOffice.dbo.RegisterUser REU1
                ON REU1.UsrIdUser = ACHVP.UserId
        WHERE CONVERT(DATE, DOPD.DateCreated)
              BETWEEN CONVERT(DATE, @StartDate) AND CONVERT(DATE, @EndDate)
              AND (CTS.IdTypeService NOT IN ( 5, 23 ))
              AND ACH.AccountingClosuresHeaderVisitPointId IS NOT NULL
              AND DOPD.[TypeofInOutMoneyId] != 8
              AND ACD.RowStatus = 1
        ORDER BY ACD.AccountingClosuresHeaderId,
                 DOPD.DateCreated ASC;
    END;
END;