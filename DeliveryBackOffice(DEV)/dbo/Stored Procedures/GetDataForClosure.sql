-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-07-02>
-- Description:	<Se agrega el filtro por pais y el nombre de las cuentas asignadas por pais>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-04-07>
-- Description:	<Mejoras de multipaís en moneda para SV.>
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-11-03>
-- Description:	<Se agregan elementos para el método de pago de Zigi>
-- =============================================
CREATE PROCEDURE [dbo].[GetDataForClosure]
    @VisitPointId INT = 4246,
    @IdAccount INT = 0,
	@IdCountry NVARCHAR(2) = 'GT'
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
	DECLARE @AccountCOD NVARCHAR(30);
	DECLARE @Account NVARCHAR(30);
    DECLARE @AccountZigi NVARCHAR(30);
	DECLARE @CountryId NVARCHAR(2)

	SELECT @CountryId = CountryId
	FROM VisitPointClient WITH (NOLOCK)
	WHERE CodeOfReference = @VisitPointId

	SELECT @Account = Name +' '+ '('+ AccountNumber +')' FROM dbo.ClosureAccount WITH (NOLOCK) WHERE Description = 'Cuenta Express Center' AND IdCountry = @CountryId
	SELECT @AccountCOD = Name +' '+ '('+ AccountNumber +')' FROM dbo.ClosureAccount WITH (NOLOCK) WHERE Description = 'Cuenta Área COD' AND IdCountry = @CountryId
     -- MODIFICACIÓN 2025-11-03 Bilkar Morataya - Zigi
    SELECT @AccountZigi = Name +' '+ '('+ AccountNumber +')' FROM dbo.ClosureAccount WITH (NOLOCK) WHERE Description = 'Cuenta Zigi' AND IdCountry = @CountryId
    -- Fin Modificación
    SET @Estandar =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Estándar'
    );
    SET @Entrega =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Entrega'
    );
    SET @Recepcion =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Recepción'
    );
    SET @Devolucion =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Devolución'
    );
    SET @Traslado =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Traslado'
    );
    SET @Internacional =
    (
        SELECT IdTypeService
        FROM CatTypeServiceClosure WITH (NOLOCK)
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
		   ISNULL(CCC.Symbol, '') 'CurrencySymbol',
           ISNULL(DOPD.CODAmountProcess, 0) 'ProcessedCOD',
           -- MODIFICACIÓN 2025-11-03 Bilkar Morataya - Zigi
           CASE
                WHEN DOPD.TypeofInOutMoneyId = 6 THEN
                    'pago con tarjeta'
                WHEN DOPD.TypeofInOutMoneyId = 8 THEN
                    'credito'
                WHEN DOPD.TypeofInOutMoneyId IN (1, 2, 3, 4, 7, 10) THEN
                    ctgmon.tio_pk_name
                ELSE
                    ''
            END 'PaymentType',
            --- FIN MODIFICACION
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

        INNER JOIN CatTypeServiceClosure CTS WITH (NOLOCK)
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
        LEFT JOIN DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK)
           -- ON cost.ProductNumber = CONCAT(DOR.Guide_Serie, DOR.Guide_Number)
		   ON COST.GuideSerie = DOR.Guide_Serie AND COST.GuideNumber = DOR.Guide_Number
        OUTER APPLY (
		  SELECT TOP 1 costd.IdCost,Voucher  FROM DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK)
            WHERE costd.IdCost = cost.IdCost
			 AND costd.Amount > 0
			 ORDER BY costd.IdCostDetail desc
		)costd
        LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH (NOLOCK)
			ON cost.ShippingCurrency = CCC.IdCatCurrencyCOD
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

        AND DOPD.ShipmentCompleted = 1
        AND DOPD.AccountId = @IdAccount
        AND DOPD.AccountId > 0
		AND DOPD.[TypeofInOutMoneyId] != 8
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
		   '' AS 'CurrencySymbol',
           ISNULL(DOPD.CODAmountProcess, 0) 'ProcessedCOD',
           -- MODIFICACIÓN 2025-11-03 Bilkar Morataya - Zigi
           CASE
               WHEN DOPD.TypeofInOutMoneyId = 6 THEN
                   'pago con tarjeta'
               WHEN DOPD.TypeofInOutMoneyId = 8 THEN
                   'credito'
               WHEN DOPD.TypeofInOutMoneyId IN (1, 2, 3, 4, 7, 10) THEN
                   ctgmon.tio_pk_name
               ELSE
                   ''
           END 'PaymentType',
            -- FIN MODIFICACION
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
        FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
        WHERE ACD.Fel =
        (
            SELECT Item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2
        )
              AND ACD.RowStatus = 1
    )
    ORDER BY DOPD.DateCreated DESC;
    DECLARE @TOTALAMOUNTCOD DECIMAL(18, 2);
    DECLARE @TOTALCOD INT;
    DECLARE @TOTALAMOUNTCODCASH DECIMAL(18, 2);
    DECLARE @TOTALCODCASH INT;
    DECLARE @TOTALAMOUNTCODZIGI DECIMAL(18, 2);
    DECLARE @TOTALCODZIGI INT;

    SELECT @TOTALAMOUNTCOD = ISNULL(SUM(dpd.CODAmountProcess), 0),
           @TOTALCOD = COUNT(dpd.CODAmountProcess)
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction dpd WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
            ON DOR.Guide_Number = dpd.GuideNumber
               AND DOR.Guide_Serie = dpd.GuideSerie
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
    )
        AND dpd.CODAmountProcess > 0
        AND DOR.StatusOrderId != 7;

    SELECT @TOTALAMOUNTCODCASH = ISNULL(SUM(dpd.CODAmountProcess), 0),
           @TOTALCODCASH = COUNT(dpd.CODAmountProcess)
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction dpd WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
            ON DOR.Guide_Serie = dpd.GuideSerie
                AND DOR.Guide_Number = dpd.GuideNumber
    WHERE CAST(dpd.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND AccountId = @IdAccount
          AND dpd.TypeofInOutMoneyId = 1
          AND NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
        WHERE ACD.GuideSerie = DOR.Guide_Serie
              AND ACD.GuideNumber = DOR.Guide_Number
              AND ACD.DopId = dpd.DopId
              AND ACD.RowStatus = 1
    )
        AND dpd.CODAmountProcess > 0
        AND DOR.StatusOrderId != 7;

    SELECT @TOTALAMOUNTCODZIGI = ISNULL(SUM(dpd.CODAmountProcess), 0),
           @TOTALCODZIGI = COUNT(dpd.CODAmountProcess)
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction dpd WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
            ON DOR.Guide_Serie = dpd.GuideSerie
                AND DOR.Guide_Number = dpd.GuideNumber
    WHERE CAST(dpd.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND AccountId = @IdAccount
          AND dpd.TypeofInOutMoneyId = 10
          AND NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
        WHERE ACD.GuideSerie = DOR.Guide_Serie
              AND ACD.GuideNumber = DOR.Guide_Number
              AND ACD.DopId = dpd.DopId
              AND ACD.RowStatus = 1
    )
        AND dpd.CODAmountProcess > 0
        AND DOR.StatusOrderId != 7;

    -- MODIFICACIÓN 2025-11-03 Bilkar Morataya - Zigi
    WITH ROWCTE (TotalCash, AccountExp, CountCash, TotalCard, CountCard, AccountZigi, TotalZigi, CountZigi, CurrencySymbolExp, TotalCredit,  CountCredit, AccountCOD, TotalFacturaCash,
                 CountFacturaCash, TotalFacturaCard, CountFacturaCard, TotalFacturaZigi, CountFacturaZigi, CurrencySymbolCOD, IdAccount
                )
    AS (SELECT ISNULL(SUM(S1.TotalCash), 0) 'TotalCash',
				@Account AS 'AccountExp',
               ISNULL(SUM(S1.CountCash), 0) 'CountCash',
               ISNULL(SUM(S1.TotalCard), 0) 'TotalCard',
               ISNULL(SUM(S1.CountCard), 0) 'CountCard',
               @AccountZigi AS 'AccountZigi',
               ISNULL(SUM(S1.TotalZigi), 0) 'TotalZigi',
               ISNULL(SUM(S1.CountZigi), 0) 'CountZigi',
			   S1.CurrencySymbolExp,
               ISNULL(SUM(S1.TotalCredit), 0) 'TotalCredit',
               ISNULL(SUM(S1.CountCredit), 0) 'CountCredit',
               -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
			   @AccountCOD AS 'AccountCOD',
               ISNULL(SUM(S1.TotalFacturaCash), 0) 'TotalFacturaCash',
               ISNULL(SUM(S1.CountFacturaCash), 0) 'CountFacturaCash',
               ISNULL(SUM(S1.TotalFacturaCard), 0) 'TotalFacturaCard',
               ISNULL(SUM(S1.CountFacturaCard), 0) 'CountFacturaCard',
               ISNULL(SUM(S1.TotalFacturaZigi), 0) 'TotalFacturaZigi',
               ISNULL(SUM(S1.CountFacturaZigi), 0) 'CountFacturaZigi',
			   S1.CurrencySymbolCOD,
               -- FIN MODIFICACIÓN
               IdAccount
        FROM
        -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
        (
            SELECT CASE

                       -- CUENTA DE EXPRESS CENTER
                       WHEN DOPD.TypeofInOutMoneyId = 1
                            AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion ) THEN
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
                 -- MODIFICACIÓN 2025-11-03 Bilkar Morataya - Zigi
                    CASE
                       -- CUENTA DE EXPRESS CENTER
                       WHEN DOPD.TypeofInOutMoneyId = 10
                            AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion ) THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalZigi',
                   CASE
                       WHEN
                       (
                           DOPD.TypeofInOutMoneyId = 10
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountZigi',
                -- Fin modificación
				   ISNULL(CCC.Symbol, '') 'CurrencySymbolExp',
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
            -- MODIFICACIÓN 2025-11-03 Bilkar Morataya - Zigi
                CASE
                       WHEN DOPD.TypeofInOutMoneyId = 10
                            AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion, @Traslado ) THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalFacturaZigi',
                   CASE
                       WHEN
                       (
                           DOPD.TypeofInOutMoneyId = 10
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion, @Traslado )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountFacturaZigi',
            -- Fin modificación
				   ISNULL(CCC.Symbol, '') 'CurrencySymbolCOD',
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
				LEFT JOIN DeliveryBackOffice.dbo.Cost C WITH(NOLOCK)
					ON C.GuideSerie = DOR.Guide_Serie AND C.GuideNumber = DOR.Guide_Number
				LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
					ON ISNULL(C.CodCurrency,C.ShippingCurrency) = CCC.IdCatCurrencyCOD
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
                FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
                WHERE ACD.GuideSerie = DOR.Guide_Serie
                      AND ACD.GuideNumber = DOR.Guide_Number

                      -- MODIFICACIÓN 31/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
                      AND ACD.DopId = DOPD.DopId
                      -- FIN MODIFICACIÓN

                      AND ACD.RowStatus = 1
            )
                AND DOPD.ShipmentCompleted = 1
                AND DOR.StatusOrderId != 7
                AND DOPD.[TypeofInOutMoneyId] != 8
            GROUP BY DOPD.TypeofInOutMoneyId,
                     DOPD.TypeServiceId,
                     DOPD.amount,
                     AccountId,
					 DOR.SenderCountryId,
					 CCC.Symbol
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
             -- MODIFICACIÓN 2025-11-03 Bilkar Morataya - Zigi
                CASE
                       WHEN DOPD.TypeofInOutMoneyId = 10
                            AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional ) THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalZigi',
                   CASE
                       WHEN
                       (
                           DOPD.TypeofInOutMoneyId = 10
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountZigi',
            -- Fin modificación
				   ISNULL(CCC.Symbol, '') 'CurrencySymbolExp',
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
                -- MODIFICACIÓN 2025-11-03 Bilkar Morataya - Zigi
                    CASE
                       WHEN DOPD.TypeofInOutMoneyId = 10
                            AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion, @Traslado ) THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalFacturaZigi',
                   CASE
                       WHEN
                       (
                           DOPD.TypeofInOutMoneyId = 10
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Entrega, @Recepcion, @Traslado )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountFacturaZigi',
                -- Fin modificación
				   ISNULL(CCC.Symbol, '') 'CurrencySymbolCOD',
                   -- FIN MODIFICACIÓN

                   DOPD.AccountId IdAccount
            FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
                -- FIN MODIFICACIÓN
                INNER JOIN CatTypeServiceClosure CTS WITH (NOLOCK)
                    ON CTS.IdTypeService = DOPD.TypeServiceId
                LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
                    ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
				INNER JOIN DeliveryOrder DOR WITH (NOLOCK)
					ON DOR.Guide_Serie = DOPD.GuideSerie AND DOR.Guide_Number = DOPD.GuideNumber
				LEFT JOIN DeliveryBackOffice.dbo.Cost C WITH(NOLOCK)
					ON C.GuideSerie = DOR.Guide_Serie AND C.GuideNumber = DOR.Guide_Number
				LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
					ON ISNULL(C.CodCurrency,C.ShippingCurrency) = CCC.IdCatCurrencyCOD
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
                     AccountId,
					 DOR.SenderCountryId,
					 CCC.Symbol

        ) S1
        GROUP BY IdAccount, CurrencySymbolExp, CurrencySymbolCOD)
    SELECT *,
           @TOTALAMOUNTCOD 'TotalAmountCOD',
           @TOTALCOD 'TotalCOD',
           -- MODIFICACIÓN 2025-11-05 - Campos adicionales de COD por método de pago
           @TOTALAMOUNTCODCASH 'TotalAmountCODCash',
           @TOTALCODCASH 'TotalCODCash',
           @TOTALAMOUNTCODZIGI 'TotalAmountCODZigi',
           @TOTALCODZIGI 'TotalCODZigi'
           -- Fin modificación
    FROM ROWCTE
	--option (optimize for UNKNOWN)

END;