/* =================================================
   SP:        [dbo].[GetDataForClosure]
   Propósito: Se agrega el filtro por pais y el nombre de las cuentas asignadas por pais
   Autor:     Cristian Suazo
   Historia:
   Fecha:     2024-02-07
============================================
=== CHANGELOG ================================
2026-04-20 | Historia/épica: <FDAPI-5784> | Autor: Keila Cortéz |
-----
2025-11-03 | Description: <Se agregan elementos para el método de pago de Zigi> | Autor: Bilkar Morataya |
-----
2025-04-07 | Description: <Mejoras de multipaís en moneda para SV.> | Autor: Walter Orozco |
-----
2024-07-02 | Description: <Se agrega el filtro por pais y el nombre de las cuentas asignadas por pais> | Autor: Cristian Suazo |
============================================ */
CREATE PROCEDURE [dbo].[GetDataForClosure]
    @VisitPointId INT = 4246,
    @IdAccount INT = 0,
	@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN

    DECLARE @Estandar INT;
    DECLARE @Entrega INT;
    DECLARE @Recepcion INT;
    DECLARE @Devolucion INT;
    DECLARE @Traslado INT;
    DECLARE @Internacional INT;
    DECLARE @Articulo INT;
	DECLARE @AccountCOD NVARCHAR(30);
	DECLARE @Account NVARCHAR(30);
    DECLARE @AccountZigi NVARCHAR(30);
	DECLARE @CountryId NVARCHAR(2)
    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);

	SELECT @CountryId = CountryId
	FROM DeliveryBackOffice.dbo.VisitPointClient WITH (NOLOCK)
	WHERE CodeOfReference = @VisitPointId

		DECLARE @LastWorkingDate DATE;
		DECLARE @IsCNC BIT = 0;

		SELECT @IsCNC = 1
		FROM DeliveryBackOffice.dbo.VisitPointClient WITH(NOLOCK)
		WHERE CodeOfReference = @VisitPointId
		  AND IdKindOfVPClient IN (3,14,25);

		IF (@IsCNC = 1)
		BEGIN
			SELECT @LastWorkingDate = MIN(CAST(DOPT.DateCreated AS DATE))
			FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPT WITH(NOLOCK)
			WHERE DOPT.AccountId = @IdAccount
			  AND DOPT.ShipmentCompleted = 1
			  AND NOT EXISTS ( 
				  SELECT 1
				  FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
				  WHERE ACD.DopId = DOPT.DopId
					AND ACD.RowStatus = 1
      );
		END
		ELSE
		BEGIN
			SET @LastWorkingDate = CAST(GETDATE() AS DATE);
		END

	SELECT @Account = Name +' '+ '('+ AccountNumber +')' FROM DeliveryBackOffice.dbo.ClosureAccount WITH (NOLOCK) WHERE Description = 'Cuenta Express Center' AND IdCountry = @CountryId
	SELECT @AccountCOD = Name +' '+ '('+ AccountNumber +')' FROM DeliveryBackOffice.dbo.ClosureAccount WITH (NOLOCK) WHERE Description = 'Cuenta Área COD' AND IdCountry = @CountryId
    SELECT @AccountZigi = Name +' '+ '('+ AccountNumber +')' FROM DeliveryBackOffice.dbo.ClosureAccount WITH (NOLOCK) WHERE Description = 'Cuenta Zigi' AND IdCountry = @CountryId
    SET @Estandar =
    (
        SELECT IdTypeService
        FROM DeliveryBackOffice.dbo.CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Estándar'
    );
    SET @Entrega =
    (
        SELECT IdTypeService
        FROM DeliveryBackOffice.dbo.CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Entrega'
    );
    SET @Recepcion =
    (
        SELECT IdTypeService
        FROM DeliveryBackOffice.dbo.CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Recepción'
    );
    SET @Devolucion =
    (
        SELECT IdTypeService
        FROM DeliveryBackOffice.dbo.CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Devolución'
    );
    SET @Traslado =
    (
        SELECT IdTypeService
        FROM DeliveryBackOffice.dbo.CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Traslado'
    );
    SET @Internacional =
    (
        SELECT IdTypeService
        FROM [DeliveryBackOffice].[dbo].CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Internacional'
    );
    SET @Articulo = 
    (
        SELECT IdTypeService
        FROM [DeliveryBackOffice].[dbo].CatTypeServiceClosure WITH (NOLOCK)
        WHERE NameTypeService = 'Artículos'
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
    WHERE CAST(DOPT.DateCreated AS DATE) = @LastWorkingDate
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
           CTS.NameTypeService AS 'ServiceType'
    FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
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

        INNER JOIN DeliveryBackOffice.dbo.CatTypeServiceClosure CTS WITH (NOLOCK)
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
        LEFT JOIN DeliveryBackOffice.dbo.Cost cost WITH (NOLOCK)
		   ON COST.GuideSerie = DOR.Guide_Serie AND COST.GuideNumber = DOR.Guide_Number
        OUTER APPLY (
		  SELECT TOP 1 costd.IdCost,Voucher  FROM DeliveryBackOffice.dbo.CostDetail costd WITH (NOLOCK)
            WHERE costd.IdCost = cost.IdCost
			 AND costd.Amount > 0
			 ORDER BY costd.IdCostDetail desc
		)costd
        LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH (NOLOCK)
			ON cost.ShippingCurrency = CCC.IdCatCurrencyCOD
	    WHERE CAST(DOPD.DateCreated AS DATE) = @LastWorkingDate

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
              AND ACD.DopId = DOPD.DopId
              AND ACD.RowStatus = 1
    )

        AND DOPD.ShipmentCompleted = 1
        AND DOPD.AccountId = @IdAccount
        AND DOPD.AccountId > 0
		AND DOPD.[TypeofInOutMoneyId] != 8

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
           CTS.NameTypeService AS 'ServiceType'
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.CatTypeServiceClosure CTS WITH (NOLOCK)
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
        INNER JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
            ON INH.inv_numberFEL =
            (
                SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2
            )
    WHERE CAST(DOPD.DateCreated AS DATE) = @LastWorkingDate
          AND DOPD.AccountId = @IdAccount
			 AND DOPD.[TypeofInOutMoneyId] != 8
          AND DOPD.GuideSerie IS NULL
          AND NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
        WHERE ACD.Fel =
        (
            SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2
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
            ON DOR.Guide_Serie = dpd.GuideSerie
               AND DOR.Guide_Number = dpd.GuideNumber
    WHERE CAST(dpd.DateCreated AS DATE) = @LastWorkingDate
          AND AccountId = @IdAccount
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

    SELECT @TOTALAMOUNTCODCASH = ISNULL(SUM(dpd.CODAmountProcess), 0),
           @TOTALCODCASH = COUNT(dpd.CODAmountProcess)
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction dpd WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
            ON DOR.Guide_Serie = dpd.GuideSerie
                AND DOR.Guide_Number = dpd.GuideNumber
    WHERE CAST(dpd.DateCreated AS DATE) = @LastWorkingDate
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
    WHERE CAST(dpd.DateCreated AS DATE) = @LastWorkingDate
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
			   MAX(S1.CurrencySymbolExp) AS CurrencySymbolExp,
               ISNULL(SUM(S1.TotalCredit), 0) 'TotalCredit',
               ISNULL(SUM(S1.CountCredit), 0) 'CountCredit',
			   @AccountCOD AS 'AccountCOD',
               ISNULL(SUM(S1.TotalFacturaCash), 0) 'TotalFacturaCash',
               ISNULL(SUM(S1.CountFacturaCash), 0) 'CountFacturaCash',
               ISNULL(SUM(S1.TotalFacturaCard), 0) 'TotalFacturaCard',
               ISNULL(SUM(S1.CountFacturaCard), 0) 'CountFacturaCard',
               ISNULL(SUM(S1.TotalFacturaZigi), 0) 'TotalFacturaZigi',
               ISNULL(SUM(S1.CountFacturaZigi), 0) 'CountFacturaZigi',
			   MAX(S1.CurrencySymbolCOD) AS CurrencySymbolCOD,
               -- FIN MODIFICACIÓN
               IdAccount
        FROM
        (
            SELECT CASE

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
				   ISNULL(CCC.Symbol, '') 'CurrencySymbolCOD',

                   DOPD.AccountId IdAccount
            FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
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
            WHERE CAST(DOPD.DateCreated AS DATE) = @LastWorkingDate
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
                      AND ACD.DopId = DOPD.DopId
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
                            AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional, @Articulo ) THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalCash',
                   CASE
                       WHEN
                       (
                           DOPD.TypeofInOutMoneyId = 1
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional, @Articulo )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountCash',
                   CASE
                       WHEN DOPD.TypeofInOutMoneyId = 6
                            OR DOPD.TypeofInOutMoneyId = 2
                               AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional, @Articulo ) THEN
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
                           AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional, @Articulo )
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountCard',
                CASE
                       WHEN DOPD.TypeofInOutMoneyId = 10
                            AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion, @Internacional, @Articulo ) THEN
                           SUM(DOPD.amount)
                       ELSE
                           0
                   END 'TotalZigi',
                   CASE
                       WHEN
                       (
                           DOPD.TypeofInOutMoneyId = 10
                           AND DOPD.amount != 0
                           AND DOPD.TypeServiceId IN ( @Estandar, @Devolucion)
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountZigi',
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
				   ISNULL(CCC.Symbol, '') 'CurrencySymbolCOD',

                   DOPD.AccountId IdAccount
            FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
                INNER JOIN CatTypeServiceClosure CTS WITH (NOLOCK)
                    ON CTS.IdTypeService = DOPD.TypeServiceId
                LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
                    ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
					ON DOR.Guide_Serie = DOPD.GuideSerie AND DOR.Guide_Number = DOPD.GuideNumber
				LEFT JOIN DeliveryBackOffice.dbo.Cost C WITH(NOLOCK)
					ON C.GuideSerie = DOR.Guide_Serie AND C.GuideNumber = DOR.Guide_Number
				LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
					ON ISNULL(C.CodCurrency,C.ShippingCurrency) = CCC.IdCatCurrencyCOD
            WHERE CAST(DOPD.DateCreated AS DATE) = @LastWorkingDate
                  AND DOPD.AccountId = @IdAccount
			 AND DOPD.[TypeofInOutMoneyId] != 8
                  AND DOPD.GuideSerie IS NULL
                  AND NOT EXISTS
            (
                SELECT 1
                FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
                WHERE ACD.Fel =
                (
                    SELECT Item FROM DeliveryBackOffice.dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2
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
        GROUP BY IdAccount)
    SELECT *,
           @TOTALAMOUNTCOD 'TotalAmountCOD',
           @TOTALCOD 'TotalCOD',
           @TOTALAMOUNTCODCASH 'TotalAmountCODCash',
           @TOTALCODCASH 'TotalCODCash',
           @TOTALAMOUNTCODZIGI 'TotalAmountCODZigi',
           @TOTALCODZIGI 'TotalCODZigi'
    FROM ROWCTE

END;