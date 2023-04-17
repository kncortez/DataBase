--EXEC GetDataForClosure

CREATE PROCEDURE [dbo].[GetDataForClosure]
    @VisitPointId INT = 4246,
    @IdAccount INT = 0
AS
BEGIN

    -- MODIFICACIÓN 22/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
    -- Variables para los diferentes servicios a tomar en cuenta en los cierres
    DECLARE @Estandar INT;
    DECLARE @Entrega INT;
    DECLARE @Recepcion INT;
    DECLARE @Devolucion INT;
    DECLARE @Traslado INT;
    DECLARE @Internacional INT;

    SET @Estandar =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure
        WHERE NameTypeService = 'Estándar'
    );
    SET @Entrega =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure
        WHERE NameTypeService = 'Entrega'
    );
    SET @Recepcion =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure
        WHERE NameTypeService = 'Recepción'
    );
    SET @Devolucion =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure
        WHERE NameTypeService = 'Devolución'
    );
    SET @Traslado =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure
        WHERE NameTypeService = 'Traslado'
    );
    SET @Internacional =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure
        WHERE NameTypeService = 'Internacional'
    );
    -- FIN MODIFICACIÓN

	CREATE TABLE  #TEMPLATEDETAIL (
        guideserie NVARCHAR(2),
        guidenumber BIGINT,
        header BIGINT
    );

	 CREATE NONCLUSTERED INDEX IX_SettlementList_#TEMPLATEDETAIL
            ON #TEMPLATEDETAIL (guideserie,guidenumber);

    INSERT INTO #TEMPLATEDETAIL
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
	 AND DOPT.ShipmentCompleted = 1
               AND DOPT.AccountId = @IdAccount
               AND DOPT.AccountId > 0
    GROUP BY IND.dti_fk_orderSerie,
             IND.dti_fk_orderNumber;

    SELECT DOPD.DateCreated 'DateCreatedTransaction',
           DOR.DateCreated 'DateCreated',
           DOR.Sender_FirstName + ' ' + DOR.Sender_LastName 'Client',
           INH.inv_certificationFEL 'CertificationFEL',
           INH.inv_serieFEL 'SerieFel',
           INH.inv_numberFEL 'NumberFel',
           INH.inv_SAPDocEntry 'DOCSAP',
           STO.OrderDescription 'Status',
           DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number) 'Guide',
           ISNULL(costd.Voucher, '') 'Voucher',
           ISNULL(DOPD.amount, 0) 'PriceShippment',
           ISNULL(DOR.Collect_OnDelivery, 0) 'COD',
           ISNULL(DOPD.CODAmountProcess, 0) 'ProcessedCOD',
           CASE
               WHEN DOPD.TypeofInOutMoneyId = 1 THEN
                   ctgmon.tio_pk_name
               WHEN DOPD.TypeofInOutMoneyId = 2 THEN
                   ctgmon.tio_pk_name
               WHEN DOPD.TypeofInOutMoneyId = 3 THEN
                   ctgmon.tio_pk_name
               WHEN DOPD.TypeofInOutMoneyId = 4 THEN
                   ctgmon.tio_pk_name
               WHEN DOPD.TypeofInOutMoneyId = 6 THEN
                   'pago con tarjeta'
               WHEN DOPD.TypeofInOutMoneyId = 7 THEN
                   ctgmon.tio_pk_name
               WHEN DOPD.TypeofInOutMoneyId = 8 THEN
                   'credito'
               ELSE
                   ''
           END 'PaymentType',
           CTS.NameTypeService AS 'ServiceType'
    FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
            ON DOR.Sender_ID = VPC.CodeOfReference
        LEFT JOIN #TEMPLATEDETAIL IND
            ON IND.guideserie = DOR.Guide_Serie
               AND IND.guidenumber = DOR.Guide_Number
        LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
            ON INH.inv_pk_id = IND.header
        INNER JOIN DeliveryBackOffice.dbo.StatusOrder STO WITH (NOLOCK)
            ON STO.StatusOrderId = DOR.StatusOrderId
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
            ON DOPD.GuideSerie = DOR.Guide_Serie
               AND DOPD.GuideNumber = DOR.Guide_Number
               AND DOPD.ShipmentCompleted = 1
               AND DOPD.AccountId = @IdAccount
               AND DOPD.AccountId > 0
			 AND DOPD.[TypeofInOutMoneyId] != 8
               
        INNER JOIN CatTypeServiceClosure CTS WITH (NOLOCK)
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
        LEFT JOIN DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK)
           -- ON cost.ProductNumber = CONCAT(DOR.Guide_Serie, DOR.Guide_Number)
		   ON COST.GuideSerie = DOR.Guide_Serie AND COST.GuideNumber = DOR.Guide_Number 
        LEFT JOIN DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK)
            ON costd.IdCost = cost.IdCost
			 AND costd.Amount > 0
             --  AND
             --  (
                  -- DOPD.TypeofInOutMoneyId = 6
                  -- AND 
				   --costd.Voucher != ''
            --  )
              
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
	
	AND DOR.StatusOrderId != 7
          AND DOPD.AccountId = @IdAccount
          AND
          (
              ISNULL(DOPD.amount, 0) > 0
              OR ISNULL(DOPD.CODAmountProcess, 0) > 0
          )
          AND NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
        WHERE ACD.GuideSerie = DOR.Guide_Serie
              AND ACD.GuideNumber = DOR.Guide_Number

              -- MODIFICACIÓN 31/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
              AND ACD.DopId = DOPD.DopId
              -- FIN MODIFICACIÓN

              AND ACD.RowStatus = 1
    )
    -- ORDER BY DOPD.DateCreated DESC;
    ---------------------------------------------------------------------------------------------
    UNION ALL
    SELECT DOPD.DateCreated 'DateCreatedTransaction',
           DOPD.DateCreated 'DateCreated',
           INH.inv_UserName 'Client',
           INH.inv_certificationFEL 'CertificationFEL',
           INH.inv_serieFEL 'SerieFel',
           INH.inv_numberFEL 'NumberFel',
           INH.inv_SAPDocEntry 'DOCSAP',
           Status = '--',
           Guide = '--',
           Voucher = '',
           ISNULL(DOPD.amount, 0) 'PriceShippment',
           COD = 0,
           ISNULL(DOPD.CODAmountProcess, 0) 'ProcessedCOD',
           CASE
               WHEN DOPD.TypeofInOutMoneyId = 1 THEN
                   ctgmon.tio_pk_name
               WHEN DOPD.TypeofInOutMoneyId = 2 THEN
                   ctgmon.tio_pk_name
               WHEN DOPD.TypeofInOutMoneyId = 3 THEN
                   ctgmon.tio_pk_name
               WHEN DOPD.TypeofInOutMoneyId = 4 THEN
                   ctgmon.tio_pk_name
               WHEN DOPD.TypeofInOutMoneyId = 6 THEN
                   'pago con tarjeta'
               WHEN DOPD.TypeofInOutMoneyId = 7 THEN
                   ctgmon.tio_pk_name
               WHEN DOPD.TypeofInOutMoneyId = 8 THEN
                   'credito'
               ELSE
                   ''
           END 'PaymentType',
           CTS.NameTypeService AS 'ServiceType'
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
        INNER JOIN CatTypeServiceClosure CTS WITH (NOLOCK)
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
        INNER JOIN invoiceHeader INH WITH (NOLOCK)
            ON INH.inv_numberFEL =
            (
                SELECT Item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2
            )
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND DOPD.AccountId = @IdAccount
			 AND DOPD.[TypeofInOutMoneyId] != 8
          AND DOPD.GuideSerie IS NULL
          AND NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
        WHERE ACD.Fel =
        (
            SELECT Item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2
        )
              AND ACD.RowStatus = 1
    )
    ORDER BY DOPD.DateCreated DESC;
    DECLARE @TOTALAMOUNTCOD DECIMAL(18, 2);
    DECLARE @TOTALCOD INT;

    SELECT @TOTALAMOUNTCOD = ISNULL(SUM(dpd.CODAmountProcess), 0),
           @TOTALCOD = COUNT(dpd.CODAmountProcess)
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction dpd WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
            ON DOR.Guide_Number = dpd.GuideNumber
               AND DOR.Guide_Serie = dpd.GuideSerie
               AND dpd.CODAmountProcess > 0
               AND DOR.StatusOrderId != 7
    WHERE CAST(dpd.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND AccountId = @IdAccount
          AND NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
        WHERE ACD.GuideSerie = DOR.Guide_Serie
              AND ACD.GuideNumber = DOR.Guide_Number

              -- MODIFICACIÓN 31/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
              AND ACD.DopId = dpd.DopId
              -- FIN MODIFICACIÓN

              AND ACD.RowStatus = 1
    );
    WITH ROWCTE (TotalCash, CountCash, TotalCard, CountCard, TotalCredit, CountCredit, TotalFacturaCash,
                 CountFacturaCash, TotalFacturaCard, CountFacturaCard, IdAccount
                )
    AS (SELECT ISNULL(SUM(S1.TotalCash), 0) 'TotalCash',
               ISNULL(SUM(S1.CountCash), 0) 'CountCash',
               ISNULL(SUM(S1.TotalCard), 0) 'TotalCard',
               ISNULL(SUM(S1.CountCard), 0) 'CountCard',
               ISNULL(SUM(S1.TotalCredit), 0) 'TotalCredit',
               ISNULL(SUM(S1.CountCredit), 0) 'CountCredit',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
               ISNULL(SUM(S1.TotalFacturaCash), 0) 'TotalFacturaCash',
               ISNULL(SUM(S1.CountFacturaCash), 0) 'CountFacturaCash',
               ISNULL(SUM(S1.TotalFacturaCard), 0) 'TotalFacturaCard',
               ISNULL(SUM(S1.CountFacturaCard), 0) 'CountFacturaCard',
               -- FIN MODIFICACIÓN
               IdAccount
        FROM
        -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
        (
            SELECT CASE

                       -- CUENTA DE EXPRESS CENTER
                       WHEN DOPD.TypeofInOutMoneyId = 1
                            AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion ) THEN
                           /*SUM(   CASE
                                      WHEN DOR.IsCollect = 1 THEN
                                          DOR.PriceShippment
                                      ELSE
                                          DOPD.amount
                                  END
                              )*/
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalCash',
                   CASE
                       WHEN
                       (
                           DOPD.TypeofInOutMoneyId = 1
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountCash',
                   CASE
                       WHEN (
                                DOPD.TypeofInOutMoneyId = 6
                                OR DOPD.TypeofInOutMoneyId = 2
                            )
                            AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion ) THEN
                           /*SUM(   CASE
                                      WHEN DOR.IsCollect = 1 THEN
                                          DOR.PriceShippment
                                      ELSE
                                          DOPD.amount
                                  END
                              )*/
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalCard',
                   CASE
                       WHEN
                       (
                           (
                               DOPD.TypeofInOutMoneyId = 6
                               OR DOPD.TypeofInOutMoneyId = 2
                           )
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountCard',
                   CASE
                       WHEN DOPD.TypeofInOutMoneyId = 8 THEN
                           /*SUM(   CASE
                                      WHEN DOR.IsCollect = 1 THEN
                                          DOR.PriceShippment
                                      ELSE
                                          DOPD.amount
                                  END
                              )*/
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalCredit',
                   CASE
                       WHEN DOPD.TypeofInOutMoneyId = 8 THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountCredit',

                   -- MODIFICACIÓN 22/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                   -- CUENTA COD
                   CASE
                       WHEN DOPD.TypeofInOutMoneyId = 1
                            AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion, @Traslado ) THEN
                           /*SUM(   CASE
                                      WHEN DOR.IsCollect = 1 THEN
                                          DOR.PriceShippment
                                      ELSE
                                          DOPD.amount
                                  END
                              )*/
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalFacturaCash',
                   CASE
                       WHEN
                       (
                           DOPD.TypeofInOutMoneyId = 1
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion, @Traslado )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountFacturaCash',
                   CASE
                       WHEN (
                                DOPD.TypeofInOutMoneyId = 6
                                OR DOPD.TypeofInOutMoneyId = 2
                            )
                            AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion ) THEN
                           /*SUM(   CASE
                                      WHEN DOR.IsCollect = 1 THEN
                                          DOR.PriceShippment
                                      ELSE
                                          DOPD.amount
                                  END
                              )*/
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalFacturaCard',
                   CASE
                       WHEN
                       (
                           (
                               DOPD.TypeofInOutMoneyId = 6
                               OR DOPD.TypeofInOutMoneyId = 2
                           )
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountFacturaCard',
                   --FIN MODIFICACIÓN 

                   DOPD.AccountId IdAccount
            FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
                    ON DOR.Sender_ID = VPC.CodeOfReference
                LEFT JOIN #TEMPLATEDETAIL IND
                    ON IND.guideserie = DOR.Guide_Serie
                       AND IND.guidenumber = DOR.Guide_Number
                LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
                    ON INH.inv_pk_id = IND.header
                INNER JOIN DeliveryBackOffice.dbo.StatusOrder STO WITH (NOLOCK)
                    ON STO.StatusOrderId = DOR.StatusOrderId
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
                    ON DOPD.GuideSerie = DOR.Guide_Serie
                       AND DOPD.GuideNumber = DOR.Guide_Number
                       AND DOPD.ShipmentCompleted = 1
                       AND DOR.StatusOrderId != 7
			 AND DOPD.[TypeofInOutMoneyId] != 8
            WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
                  AND DOPD.AccountId = @IdAccount
                  AND
                  (
                      ISNULL(DOPD.amount, 0) > 0
                      OR ISNULL(DOPD.CODAmountProcess, 0) > 0
                  )
                  AND NOT EXISTS
            (
                SELECT 1
                FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
                WHERE ACD.GuideSerie = DOR.Guide_Serie
                      AND ACD.GuideNumber = DOR.Guide_Number

                      -- MODIFICACIÓN 31/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                      AND ACD.DopId = DOPD.DopId
                      -- FIN MODIFICACIÓN

                      AND ACD.RowStatus = 1
            )
            GROUP BY DOPD.TypeofInOutMoneyId,
                     DOPD.TypeServiceId,
                     DOPD.amount,
                     AccountId
            UNION ALL
            SELECT CASE
                       WHEN DOPD.TypeofInOutMoneyId = 1
                            AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional ) THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalCash',
                   CASE
                       WHEN
                       (
                           DOPD.TypeofInOutMoneyId = 1
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountCash',
                   CASE
                       WHEN DOPD.TypeofInOutMoneyId = 6
                            OR DOPD.TypeofInOutMoneyId = 2
                               AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional ) THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalCard',
                   CASE
                       WHEN
                       (
                           (
                               DOPD.TypeofInOutMoneyId = 6
                               OR DOPD.TypeofInOutMoneyId = 2
                           )
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountCard',
                   CASE
                       WHEN DOPD.TypeofInOutMoneyId = 8 THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalCredit',
                   CASE
                       WHEN DOPD.TypeofInOutMoneyId = 8 THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountCredit',

                   -- MODIFICACIÓN 22/04/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                   CASE
                       WHEN DOPD.TypeofInOutMoneyId = 1
                            AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion, @Traslado ) THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalFacturaCash',
                   CASE
                       WHEN
                       (
                           DOPD.TypeofInOutMoneyId = 1
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion, @Traslado )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountFacturaCash',
                   CASE
                       WHEN DOPD.TypeofInOutMoneyId = 6
                            OR DOPD.TypeofInOutMoneyId = 2
                               AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion ) THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalFacturaCard',
                   CASE
                       WHEN
                       (
                           (
                               DOPD.TypeofInOutMoneyId = 6
                               OR DOPD.TypeofInOutMoneyId = 2
                           )
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountFacturaCard',
                   -- FIN MODIFICACIÓN

                   DOPD.AccountId IdAccount
            FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
                -- FIN MODIFICACIÓN
                INNER JOIN CatTypeServiceClosure CTS WITH (NOLOCK)
                    ON CTS.IdTypeService = DOPD.TypeServiceId
                LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
                    ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
            WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
                  AND DOPD.AccountId = @IdAccount
			 AND DOPD.[TypeofInOutMoneyId] != 8
                  AND DOPD.GuideSerie IS NULL
                  AND NOT EXISTS
            (
                SELECT 1
                FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
                WHERE ACD.Fel =
                (
                    SELECT Item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2
                )
                      AND ACD.RowStatus = 1
            )
            GROUP BY DOPD.TypeofInOutMoneyId,
                     DOPD.TypeServiceId,
                     DOPD.amount,
                     AccountId
        ) S1
        GROUP BY IdAccount)
    SELECT *,
           @TOTALAMOUNTCOD 'TotalAmountCOD',
           @TOTALCOD 'TotalCOD'
    FROM ROWCTE
	--option (optimize for UNKNOWN)

END;