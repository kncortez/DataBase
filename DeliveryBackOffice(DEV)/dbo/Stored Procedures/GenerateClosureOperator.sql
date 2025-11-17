-- =============================================
-- Author:		<Alejandro Rodríguez>
-- Create date: <2022-03-17>
-- Description:	<SP para generar el cierre de los express center>
-- Nota: Es una copia de GenerateClosure pero se agregaron validaciones
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2022-11-06>
-- Description:	<Se agrega control de método de pago Zigi>
-- =============================================
CREATE PROCEDURE [dbo].[GenerateClosureOperator]
    @VisitPointId INT = 4246,
    @UserId INT,
    @TokenCreated NVARCHAR(50),
    @ClosurerPOS NVARCHAR(50) = NULL,
    @Voucher1 NVARCHAR(50) = NULL,
    @Bag1 NVARCHAR(50) = NULL,
    @Voucher2 NVARCHAR(50) = NULL,
    @Bag2 NVARCHAR(50) = NULL,
    @TotalAmountCODCash DECIMAL(18, 5),
    @TotalAmountCashDeclared DECIMAL(18, 5),
    @TotalAmountCreditDeclared DECIMAL(18, 5),
	@TotalAmountCODCashDeclared DECIMAL(18, 5),
	@TotalAmountFacturaCashDeclared DECIMAL(18,5),
	@TotalAmountFacturaCardDeclared DECIMAL(18,5),
	@TotalCOD INT,
	-- MODIFICACIÓN [2025-10-17] - Parámetros declarados para Zigi
	@TotalAmountZigiDeclared DECIMAL(18, 5) = 0,
	@TotalAmountCODZigiDeclared DECIMAL(18, 5) = 0,
	@TotalAmountFacturaZigiDeclared DECIMAL(18, 5) = 0
	-- FIN MODIFICACIÓN
AS
BEGIN

    DECLARE @TotalCash DECIMAL(18, 5);
    DECLARE @TotalCard DECIMAL(18, 5);
    DECLARE @CountCash INT;
    DECLARE @Countcard INT;
	-- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	DECLARE @TotalFacturaCash DECIMAL(18, 5);
    DECLARE @TotalFacturaCard DECIMAL(18, 5);
    DECLARE @CountFacturaCash INT;
    DECLARE @CountFacturaCard INT;
	-- FIN MODIFICACIÓN
	-- MODIFICACIÓN [2025-10-17] - Soporte para Zigi
	DECLARE @TotalZigi DECIMAL(18, 5);
	DECLARE @TotalCODZigi DECIMAL(18, 5);
	DECLARE @CountZigi INT;
	DECLARE @TotalFacturaZigi DECIMAL(18, 5);
	DECLARE @CountFacturaZigi INT;
	-- FIN MODIFICACIÓN
    DECLARE @UserId2 INT;

    IF OBJECT_ID('tempdb.dbo.#TempClosureDetail', 'U') IS NOT NULL
        DROP TABLE #TempClosureDetail;

    SET @UserId2 =
    (
        SELECT TOP 1
               vp.RegisterUserID
        FROM [dbo].RegisterUser usr WITH (NOLOCK)
            LEFT JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK)
                ON rua.RuaIdUser = usr.UsrIdUser
                   AND rua.RuaRowStatus = 1
            INNER JOIN [dbo].Account ac WITH (NOLOCK)
                ON ac.AccIdAccount = rua.RuaIdAccount
                   AND ac.AccRowStatus = 1
            INNER JOIN VisitPointByUser vp WITH (NOLOCK)
                ON vp.RegisterUserID = usr.UsrIdUser
        WHERE ac.AccIdAccount = @UserId
    );


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


    --Consultar data
    SELECT DOR.Guide_Serie,
           DOR.Guide_Number,
		   DOPD.Fel

		   -- MODIFICACIÓN 31/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		   ,DOPD.DopId
		   -- FIN MODIFICACIÓN

    INTO #TempClosureDetail
    FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
            ON DOR.Sender_ID = VPC.CodeOfReference
        LEFT JOIN @TEMPLATEDETAIL IND
            ON IND.guideserie = DOR.Guide_Serie
               AND IND.guidenumber = DOR.Guide_Number
        LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
            ON INH.inv_pk_id = IND.header
        JOIN DeliveryBackOffice.dbo.StatusOrder STO WITH (NOLOCK)
            ON STO.StatusOrderId = DOR.StatusOrderId
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
            ON DOPD.guideserie = DOR.Guide_Serie
               AND DOPD.guidenumber = DOR.Guide_Number
               AND DOPD.ShipmentCompleted = 1
			   AND DOR.StatusOrderId != 7
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND DOPD.AccountId = @UserId
		  AND (ISNULL(DOPD.amount,0) > 0 OR ISNULL(DOPD.CODAmountProcess,0) > 0)
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
	UNION ALL
	SELECT DOPD.GuideSerie, DOPD.GuideNumber, DOPD.Fel

			-- MODIFICACIÓN 31/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		   ,DOPD.DopId
			-- FIN MODIFICACIÓN

    FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
         
        INNER JOIN CatTypeServiceClosure CTS WITH (NOLOCK)
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
		JOIN invoiceHeader INH WITH (NOLOCK)
			ON INH.inv_numberFEL = (SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
        
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND DOPD.AccountId = @UserId
          AND DOPD.GuideSerie is null
		  AND NOT EXISTS
		  (
			SELECT 1
			FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
			WHERE ACD.Fel =(SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
				  AND ACD.RowStatus = 1
		  )

	-- MODIFICACIÓN 22/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	-- Variables para los diferentes servicios a tomar en cuenta en los cierres
	DECLARE @Estandar INT;
	DECLARE @Entrega INT;
	DECLARE @Recepcion INT;
	DECLARE @Devolucion INT;
	DECLARE @Traslado INT;

	SET @Estandar = (SELECT IdTypeService FROM CatTypeServiceClosure WITH (NOLOCK)
					WHERE NameTypeService = 'Estándar');
	SET @Entrega = (SELECT IdTypeService FROM CatTypeServiceClosure WITH (NOLOCK)
					WHERE NameTypeService = 'Entrega');
	SET @Recepcion = (SELECT IdTypeService FROM CatTypeServiceClosure WITH (NOLOCK)
						WHERE NameTypeService = 'Recepción');
	SET @Devolucion = (SELECT IdTypeService FROM CatTypeServiceClosure WITH (NOLOCK)
						WHERE NameTypeService = 'Devolución')
	SET @Traslado = (SELECT IdTypeService FROM CatTypeServiceClosure WITH (NOLOCK)
					WHERE NameTypeService = 'Traslado')
	-- FIN MODIFICACIÓN

	-- MODIFICACIÓN 06/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
	-- Estos campos se reciben en la llamada al SP, pero ha causado problemas 
	-- y se optó por asignarlos aquí al igual que en el SP GetDataForClosure
    SELECT @TotalAmountCODCash = ISNULL(SUM(dpd.CODAmountProcess), 0),
           @TotalCOD = COUNT(dpd.CODAmountProcess)
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction dpd WITH (NOLOCK)
        JOIN DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
            ON DOR.Guide_Number = dpd.GuideNumber
               AND DOR.Guide_Serie = dpd.GuideSerie
               AND dpd.CODAmountProcess > 0
               AND DOR.StatusOrderId != 7
    WHERE CAST(dpd.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND AccountId = @UserId
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
	-- FIN MODIFICACIÓN

    SELECT @TotalCash = ISNULL(SUM(S1.TotalCash), 0),
           @CountCash = ISNULL(SUM(S1.CountCash), 0),
           @TotalCard = ISNULL(SUM(S1.TotalCard), 0),
           @Countcard = ISNULL(SUM(S1.CountCard), 0),
		   -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		   @TotalFacturaCash = ISNULL(SUM(S1.TotalFacturaCash),0),
		   @CountFacturaCash = ISNULL(SUM(S1.CountFacturaCash), 0),
		   @TotalFacturaCard = ISNULL(SUM(S1.TotalFacturaCard),0),
		   @CountFacturaCard = ISNULL(SUM(S1.CountFacturaCard), 0)
		   -- FIN MODIFICACIÓN
    FROM
    (
        SELECT CASE
                   WHEN DOPD.TypeofInOutMoneyId = 1 
						AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) 
					THEN
                       SUM(DOPD.amount)
                   ELSE
                       0
               END 'TotalCash',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 1 
						AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) 
					THEN
                       COUNT(DOPD.TypeofInOutMoneyId)
                   ELSE
                       0
               END 'CountCash',
               CASE
                   WHEN (DOPD.TypeofInOutMoneyId = 6 OR DOPD.TypeofInOutMoneyId = 2) 
				   AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) THEN
                       SUM(DOPD.amount)
                   ELSE
                       0
               END 'TotalCard',
               CASE
                   WHEN (DOPD.TypeofInOutMoneyId = 6 OR DOPD.TypeofInOutMoneyId = 2) 
						AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) 
					THEN
                       COUNT(DOPD.TypeofInOutMoneyId)
                   ELSE
                       0
               END 'CountCard',
			   CASE
                       WHEN DOPD.TypeofInOutMoneyId = 1
							AND DOPD.TypeServiceId IN (@Entrega,@Recepcion,@Traslado) 
						THEN
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
						   AND DOPD.TypeServiceId IN (@Entrega,@Recepcion,@Traslado) 
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountFacturaCash',
				   CASE
                       WHEN (DOPD.TypeofInOutMoneyId = 6 OR DOPD.TypeofInOutMoneyId = 2)  
							AND DOPD.TypeServiceId IN (@Entrega,@Recepcion)  
						THEN
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
                           (DOPD.TypeofInOutMoneyId = 6  OR DOPD.TypeofInOutMoneyId = 2)
                           AND DOPD.amount != 0
						   AND DOPD.TypeServiceId IN (@Entrega,@Recepcion) 
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountFacturaCard'
        FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
                ON DOR.Sender_ID = VPC.CodeOfReference
            LEFT JOIN @TEMPLATEDETAIL IND
                ON IND.guideserie = DOR.Guide_Serie
                   AND IND.guidenumber = DOR.Guide_Number
            LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
                ON INH.inv_pk_id = IND.header
            INNER JOIN DeliveryBackOffice.dbo.StatusOrder STO WITH (NOLOCK)
                ON STO.StatusOrderId = DOR.StatusOrderId
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
                ON DOPD.guideserie = DOR.Guide_Serie
                   AND DOPD.guidenumber = DOR.Guide_Number
                   AND DOPD.ShipmentCompleted = 1
				   AND DOR.StatusOrderId != 7
        WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
              AND DOPD.AccountId = @UserId
			  AND (ISNULL(DOPD.amount,0) > 0 OR ISNULL(DOPD.CODAmountProcess,0) > 0)
              AND NOT EXISTS
        (
            SELECT 1
            FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
            WHERE ACD.GuideSerie = DOR.Guide_Serie
                  AND ACD.GuideNumber = DOR.Guide_Number

				  -- MODIFICACIÓN 09/05/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
				  AND ACD.DopId = DOPD.DopId
				  -- FIN MODIFICACIÓN

                  AND ACD.RowStatus = 1
        )
        GROUP BY DOPD.TypeofInOutMoneyId,
				DOPD.TypeServiceId,
				DOPD.amount

		UNION ALL

			SELECT CASE
                   WHEN DOPD.TypeofInOutMoneyId = 1 
						AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) 
					THEN
                       SUM(DOPD.amount)
                   ELSE
                       0
               END 'TotalCash',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 1 
						AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) 
					THEN
                       COUNT(DOPD.TypeofInOutMoneyId)
                   ELSE
                       0
               END 'CountCash',
               CASE
                   WHEN (DOPD.TypeofInOutMoneyId = 6 OR DOPD.TypeofInOutMoneyId = 2)
				   AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) THEN
                       SUM(DOPD.amount)
                   ELSE
                       0
               END 'TotalCard',
               CASE
                   WHEN (DOPD.TypeofInOutMoneyId = 6 OR DOPD.TypeofInOutMoneyId = 2)
				   AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) 
				THEN
                       COUNT(DOPD.TypeofInOutMoneyId)
                   ELSE
                       0
               END 'CountCard',
			   0 'TotalFacturaCash',
			   0 'CountFacturaCash',
			   0 'TotalFacturaCard',
			   0 'CountFacturaCard'
			FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
         
        INNER JOIN CatTypeServiceClosure CTS WITH (NOLOCK)
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
        
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND DOPD.AccountId = @UserId
          AND DOPD.GuideSerie is null
		  AND NOT EXISTS
		  (
			SELECT 1
			FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
			WHERE ACD.Fel =(SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
				  AND ACD.RowStatus = 1
		  )
		  GROUP BY DOPD.TypeofInOutMoneyId, DOPD.TypeServiceId, DOPD.amount, AccountId
    ) S1;

	-- FIN MODIFICACIÓN

	-- MODIFICACIÓN [2025-10-17] - Cálculo de totales para Zigi (TypeofInOutMoneyId = 10)
	SELECT @TotalZigi = ISNULL(SUM(S1.TotalZigi), 0),
		   @CountZigi = ISNULL(SUM(S1.CountZigi), 0),
		   @TotalCODZigi = ISNULL(SUM(S1.TotalCODZigi), 0),
		   @TotalFacturaZigi = ISNULL(SUM(S1.TotalFacturaZigi), 0),
		   @CountFacturaZigi = ISNULL(SUM(S1.CountFacturaZigi), 0)
	FROM
	(
		SELECT CASE
				   WHEN DOPD.TypeofInOutMoneyId = 10 
						AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) 
					THEN SUM(DOPD.amount)
				   ELSE 0
			   END 'TotalZigi',
			   CASE
				   WHEN DOPD.TypeofInOutMoneyId = 10 
						AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) 
					THEN COUNT(DOPD.TypeofInOutMoneyId)
				   ELSE 0
			   END 'CountZigi',
			   CASE
				   WHEN DOPD.TypeofInOutMoneyId = 10 
						AND DOPD.CODAmountProcess > 0
					THEN SUM(DOPD.CODAmountProcess)
				   ELSE 0
			   END 'TotalCODZigi',
			   CASE
				   WHEN DOPD.TypeofInOutMoneyId = 10
						AND DOPD.TypeServiceId IN (@Entrega,@Recepcion,@Traslado) 
					THEN SUM(DOPD.amount)
				   ELSE 0
			   END 'TotalFacturaZigi',
			   CASE
				   WHEN DOPD.TypeofInOutMoneyId = 10
						AND DOPD.amount != 0
						AND DOPD.TypeServiceId IN (@Entrega,@Recepcion,@Traslado) 
					THEN COUNT(DOPD.TypeofInOutMoneyId)
				   ELSE 0
			   END 'CountFacturaZigi'
		FROM dbo.DeliveryOrder DOR WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
				ON DOR.Sender_ID = VPC.CodeOfReference
			LEFT JOIN @TEMPLATEDETAIL IND
				ON IND.guideserie = DOR.Guide_Serie
				   AND IND.guidenumber = DOR.Guide_Number
			LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH (NOLOCK)
				ON INH.inv_pk_id = IND.header
			JOIN DeliveryBackOffice.dbo.StatusOrder STO WITH (NOLOCK)
				ON STO.StatusOrderId = DOR.StatusOrderId
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
				ON DOPD.guideserie = DOR.Guide_Serie
				   AND DOPD.guidenumber = DOR.Guide_Number
				   AND DOPD.ShipmentCompleted = 1
				   AND DOR.StatusOrderId != 7
		WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
			  AND DOPD.AccountId = @UserId
			  AND (ISNULL(DOPD.amount,0) > 0 OR ISNULL(DOPD.CODAmountProcess,0) > 0)
			  AND NOT EXISTS
		(
			SELECT 1
			FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
			WHERE ACD.GuideSerie = DOR.Guide_Serie
				  AND ACD.GuideNumber = DOR.Guide_Number
				  AND ACD.DopId = DOPD.DopId
				  AND ACD.RowStatus = 1
		)
		GROUP BY DOPD.TypeofInOutMoneyId,
				DOPD.TypeServiceId,
				DOPD.amount,
				DOPD.CODAmountProcess

		UNION ALL

		SELECT CASE
				   WHEN DOPD.TypeofInOutMoneyId = 10 
						AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) 
					THEN SUM(DOPD.amount)
				   ELSE 0
			   END 'TotalZigi',
			   CASE
				   WHEN DOPD.TypeofInOutMoneyId = 10 
						AND DOPD.TypeServiceId IN (@Estandar,@Devolucion) 
					THEN COUNT(DOPD.TypeofInOutMoneyId)
				   ELSE 0
			   END 'CountZigi',
			   CASE
				   WHEN DOPD.TypeofInOutMoneyId = 10 
						AND DOPD.CODAmountProcess > 0
					THEN SUM(DOPD.CODAmountProcess)
				   ELSE 0
			   END 'TotalCODZigi',
			   0 'TotalFacturaZigi',
			   0 'CountFacturaZigi'
		FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH (NOLOCK)
		INNER JOIN CatTypeServiceClosure CTS WITH (NOLOCK)
			ON CTS.IdTypeService = DOPD.TypeServiceId
		LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH (NOLOCK)
			ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
		WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
			  AND DOPD.AccountId = @UserId
			  AND DOPD.GuideSerie is null
			  AND NOT EXISTS
			  (
				SELECT 1
				FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH (NOLOCK)
				WHERE ACD.Fel =(SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
					  AND ACD.RowStatus = 1
			  )
		GROUP BY DOPD.TypeofInOutMoneyId, DOPD.TypeServiceId, DOPD.amount, DOPD.CODAmountProcess, AccountId
	) S1;
	
	-- Sumar TotalZigi como la suma de TotalCODZigi + TotalFacturaZigi si TotalZigi es 0
	IF @TotalZigi = 0
	BEGIN
		SET @TotalZigi = @TotalCODZigi + @TotalFacturaZigi;
	END
	ELSE
	BEGIN
		SET @TotalZigi = @TotalZigi + @TotalCODZigi + @TotalFacturaZigi;
	END
	-- FIN MODIFICACIÓN

    DECLARE @HeaderClosures INT = 0;

    BEGIN TRANSACTION;
    BEGIN TRY
        IF ((@TotalCash + @TotalCard + @TotalFacturaCash + @TotalFacturaCard + @TotalAmountCODCash + @TotalZigi + @TotalCODZigi + @TotalFacturaZigi) >= 0) --Si existen datos para cierre
        BEGIN
		PRINT 'INSERTA HEADER';
            --Insertar encabezado
            INSERT INTO DeliveryBackOffice.dbo.AccountingClosuresHeader
            (
                UserId,
                ClosurerPOS,
                TotalAmountCash,
                TotalAmountCashDeclared,
                TotalAmountCredit,
                TotalAmountCreditDeclared,
                InvoiceAmountCash,
                InvoiceAmountCredit,
                VisitPoint,
                Voucher1,
                Bag1,
                Voucher2,
                Bag2,
                RowStatus,
                TokenCreated,
                DateCreated,
                TokenUpdated,
                DateUpdated,
                TotalAmountCODCash,
				TotalAmountCODCashDeclared,
				TotalAmountFacturaCashDeclared,
				TotalAmountFacturaCardDeclared,
				TotalAmountFacturaCash,
				InvoiceAmountFacturaCash,
				TotalAmountFacturaCard,
				InvoiceAmountFacturaCard,
				InvoiceAmountCOD,
				-- MODIFICACIÓN [2025-10-17] - Campos para Zigi
				TotalAmountZigi,
				TotalAmountZigiDeclared,
				InvoiceAmountZigi,
				TotalAmountCODZigi,
				TotalAmountCODZigiDeclared,
				TotalAmountFacturaZigi,
				TotalAmountFacturaZigiDeclared,
				InvoiceAmountFacturaZigi
            )
            VALUES
            (@UserId2, @ClosurerPOS, @TotalCash, @TotalAmountCashDeclared, @TotalCard, @TotalAmountCreditDeclared,
             @CountCash, @Countcard, @VisitPointId, @Voucher1, @Bag1, @Voucher2, @Bag2, 1, @TokenCreated, GETDATE(),
             NULL, NULL, @TotalAmountCODCash, @TotalAmountCODCashDeclared, 
			 @TotalAmountFacturaCashDeclared, @TotalAmountFacturaCardDeclared,
			 @TotalFacturaCash, @CountFacturaCash, @TotalFacturaCard, @CountFacturaCard, @TotalCOD,
			 @TotalZigi, @TotalAmountZigiDeclared, @CountZigi, @TotalCODZigi, @TotalAmountCODZigiDeclared, @TotalFacturaZigi, @TotalAmountFacturaZigiDeclared, @CountFacturaZigi
			 -- FIN MODIFICACIÓN
			 );
            PRINT 'INSERTA ENCABEZADO';
            SET @HeaderClosures = SCOPE_IDENTITY();
            PRINT @HeaderClosures;
            --Insertar detalle
            INSERT INTO DeliveryBackOffice.dbo.AccountingClosuresDetail
            (
                AccountingClosuresHeaderId,
                GuideSerie,
                GuideNumber,
                RowStatus,
                TokenCreated,
                DateCreated,
                TokenUpdated,
                DateUpdated,
				Fel

				-- MODIFICACIÓN 31/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
				,DopId
				-- FIN MODIFICACIÓN

            )
            SELECT @HeaderClosures,
                   Guide_Serie,
                   Guide_Number,
                   1,
                   @TokenCreated,
                   GETDATE(),
                   NULL,
                   NULL,
				   (SELECT item FROM dbo.SplitUnlimited(Fel, '-') WHERE id = 2)

				   -- MODIFICACIÓN 31/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
				   ,DopId
				   -- FIN MODIFICACIÓN

            FROM #TempClosureDetail;

            SELECT 200 IdResult,
                   'Cierre generado exitosamente' Message,
                   Value 'URL',
                   @HeaderClosures 'IdCierre'
            FROM ConfigParams WITH (NOLOCK)
            WHERE Name = 'ClosureExpressCenter';

			select * from #TempClosureDetail;
        END;
        ELSE
        BEGIN
            SELECT 500 IdResult,
                   'No existen datos para generar cierre' Message;
        END;

    END TRY
    BEGIN CATCH
	    PRINT 'ROLLBACK SE HIZO';
        ROLLBACK TRANSACTION;

    END CATCH;
    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;
    END;


END;