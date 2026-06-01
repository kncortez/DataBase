CREATE PROCEDURE [dbo].[GenerateClosure]
    @VisitPointId INT = 4246,
    @UserId INT,
    @TokenCreated NVARCHAR(50),
    @ClosurerPOS NVARCHAR(50),
    @Voucher1 NVARCHAR(50),
    @Bag1 NVARCHAR(50),
    @Voucher2 NVARCHAR(50) = NULL,
    @Bag2 NVARCHAR(50) = NULL,
    @TotalAmountCODCash DECIMAL(18, 5),
    @TotalAmountCODCredit DECIMAL(18, 5),
    @TotalAmountCashDeclared DECIMAL(18, 5),
    @TotalAmountCreditDeclared DECIMAL(18, 5),
    -- Nuevos parámetros para Zigi
    @TotalAmountZigiDeclared DECIMAL(18, 5) = 0,
    @TotalAmountCODZigiDeclared DECIMAL(18, 5) = 0,
    @TotalAmountFacturaZigiDeclared DECIMAL(18, 5) = 0
AS
BEGIN

    DECLARE @TotalCash DECIMAL(18, 5);
    DECLARE @TotalCard DECIMAL(18, 5);
    DECLARE @CountCash INT;
    DECLARE @Countcard INT;
    DECLARE @UserId2 INT;
    -- Nuevas variables para Zigi
    DECLARE @TotalZigi DECIMAL(18, 5);
    DECLARE @CountZigi INT;

    IF OBJECT_ID('tempdb.dbo.#TempClosureDetail', 'U') IS NOT NULL
        DROP TABLE #TempClosureDetail;

    SET @UserId2 =
    (
        SELECT TOP 1
               vp.RegisterUserID
        FROM [dbo].RegisterUser usr WITH(NOLOCK)
            LEFT JOIN [dbo].[RolByUserByAccount] rua WITH(NOLOCK)
                ON rua.RuaIdUser = usr.UsrIdUser
              AND rua.RuaRowStatus = 1
            INNER JOIN [dbo].Account ac WITH(NOLOCK)
                ON ac.AccIdAccount = rua.RuaIdAccount
            INNER JOIN VisitPointByUser vp WITH(NOLOCK)
                ON vp.RegisterUserID = usr.UsrIdUser
        WHERE ac.AccIdAccount = @UserId  AND ac.AccRowStatus = 1
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
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPT WITH(NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH(NOLOCK)
            ON IND.dti_fk_orderSerie = DOPT.GuideSerie
               AND IND.dti_fk_orderNumber = DOPT.GuideNumber
    WHERE CAST(DOPT.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
    GROUP BY IND.dti_fk_orderSerie,
             IND.dti_fk_orderNumber;


    --Consultar data
    SELECT DOR.Guide_Serie,
           DOR.Guide_Number,
		   DOPD.Fel
    INTO #TempClosureDetail
    FROM dbo.DeliveryOrder DOR WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
            ON DOR.Sender_ID = VPC.CodeOfReference
        LEFT JOIN @TEMPLATEDETAIL IND
            ON IND.guideserie = DOR.Guide_Serie
               AND IND.guidenumber = DOR.Guide_Number
        LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH(NOLOCK)
            ON INH.inv_pk_id = IND.header
        INNER JOIN DeliveryBackOffice.dbo.StatusOrder STO WITH(NOLOCK)
            ON STO.StatusOrderId = DOR.StatusOrderId
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)
            ON DOPD.guideserie = DOR.Guide_Serie
               AND DOPD.guidenumber = DOR.Guide_Number
               AND DOPD.ShipmentCompleted = 1
			   AND DOR.StatusOrderId != 7
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND DOPD.AccountId = @UserId
          AND NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
        WHERE ACD.GuideSerie = DOR.Guide_Serie
              AND ACD.GuideNumber = DOR.Guide_Number
              AND ACD.RowStatus = 1
    )
	UNION ALL
	SELECT DOPD.GuideSerie, 
           DOPD.GuideNumber, 
           (SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2) AS Fel
    FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)
         
        INNER JOIN CatTypeServiceClosure CTS WITH(NOLOCK)
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH(NOLOCK)
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
		INNER JOIN invoiceHeader INH WITH(NOLOCK) ON INH.inv_numberFEL = (SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
        
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND DOPD.AccountId = @UserId
          AND DOPD.GuideSerie is null
		  AND NOT EXISTS
		  (
			SELECT 1
			FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
			WHERE ACD.Fel =(SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
				  AND ACD.RowStatus = 1
		  )

    SELECT @TotalCash = ISNULL(SUM(S1.TotalCash), 0),
           @CountCash = ISNULL(SUM(S1.CountCash), 0),
           @TotalCard = ISNULL(SUM(S1.TotalCard), 0),
           @Countcard = ISNULL(SUM(S1.CountCard), 0),
           @TotalZigi = ISNULL(SUM(S1.TotalZigi), 0),
           @CountZigi = ISNULL(SUM(S1.CountZigi), 0)
    FROM
    (
        SELECT CASE
                   WHEN DOPD.TypeofInOutMoneyId = 1 THEN
                       SUM(DOPD.amount)
                   ELSE
                       0
               END 'TotalCash',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 1 THEN
                       COUNT(DOPD.TypeofInOutMoneyId)
                   ELSE
                       0
               END 'CountCash',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 6 OR DOPD.TypeofInOutMoneyId = 2 THEN
                       SUM(DOPD.amount)
                   ELSE
                       0
               END 'TotalCard',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 6 OR DOPD.TypeofInOutMoneyId = 2 THEN
                       COUNT(DOPD.TypeofInOutMoneyId)
                   ELSE
                       0
               END 'CountCard',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 10 THEN
                       SUM(DOPD.amount)
                   ELSE
                       0
               END 'TotalZigi',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 10 THEN
                       COUNT(DOPD.TypeofInOutMoneyId)
                   ELSE
                       0
               END 'CountZigi'
        FROM dbo.DeliveryOrder DOR WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
                ON DOR.Sender_ID = VPC.CodeOfReference
            LEFT JOIN @TEMPLATEDETAIL IND
                ON IND.guideserie = DOR.Guide_Serie
                   AND IND.guidenumber = DOR.Guide_Number
            LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader INH WITH(NOLOCK)
                ON INH.inv_pk_id = IND.header
            INNER JOIN DeliveryBackOffice.dbo.StatusOrder STO WITH(NOLOCK)
                ON STO.StatusOrderId = DOR.StatusOrderId
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)
                ON DOPD.guideserie = DOR.Guide_Serie
                   AND DOPD.guidenumber = DOR.Guide_Number
                   AND DOPD.ShipmentCompleted = 1
				   AND DOR.StatusOrderId != 7
        WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
              AND DOPD.AccountId = @UserId
              AND NOT EXISTS
        (
            SELECT 1
            FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
            WHERE ACD.GuideSerie = DOR.Guide_Serie
                  AND ACD.GuideNumber = DOR.Guide_Number
                  AND ACD.RowStatus = 1
        )
        GROUP BY DOPD.TypeofInOutMoneyId

		UNION ALL

			SELECT CASE
                   WHEN DOPD.TypeofInOutMoneyId = 1 THEN
                       SUM(DOPD.amount)
                   ELSE
                       0
               END 'TotalCash',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 1 THEN
                       COUNT(DOPD.TypeofInOutMoneyId)
                   ELSE
                       0
               END 'CountCash',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 6 OR DOPD.TypeofInOutMoneyId = 2 THEN
                       SUM(DOPD.amount)
                   ELSE
                       0
               END 'TotalCard',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 6 OR DOPD.TypeofInOutMoneyId = 2 THEN
                       COUNT(DOPD.TypeofInOutMoneyId)
                   ELSE
                       0
               END 'CountCard',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 10 THEN
                       SUM(DOPD.amount)
                   ELSE
                       0
               END 'TotalZigi',
               CASE
                   WHEN DOPD.TypeofInOutMoneyId = 10 THEN
                       COUNT(DOPD.TypeofInOutMoneyId)
                   ELSE
                       0
               END 'CountZigi'
			FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD WITH(NOLOCK)
         
        INNER JOIN CatTypeServiceClosure CTS WITH(NOLOCK)
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon WITH(NOLOCK)
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
        
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND DOPD.AccountId = @UserId
          AND DOPD.GuideSerie is null
		  AND NOT EXISTS
		  (
			SELECT 1
			FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD WITH(NOLOCK)
			WHERE ACD.Fel =(SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
				  AND ACD.RowStatus = 1
		  )
		  GROUP BY DOPD.TypeofInOutMoneyId, DOPD.amount, AccountId
    ) S1;

    DECLARE @HeaderClosures INT = 0;

    BEGIN TRANSACTION;
    BEGIN TRY
        IF ((@TotalCash + @TotalCard + @TotalZigi) >= 0) --Si existen datos para cierre
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
                TotalAmountCODCredit,
                TotalAmountZigi,
                TotalAmountZigiDeclared,
                TotalAmountCODZigi,
                TotalAmountCODZigiDeclared,
                TotalAmountFacturaZigi,
                InvoiceAmountZigi,
                TotalAmountFacturaZigiDeclared,
                InvoiceAmountFacturaZigi
            )
            VALUES
            (@UserId2, @ClosurerPOS, @TotalCash, @TotalAmountCashDeclared, @TotalCard, @TotalAmountCreditDeclared,
             @CountCash, @Countcard, @VisitPointId, @Voucher1, @Bag1, @Voucher2, @Bag2, 1, @TokenCreated, GETDATE(),
             NULL, NULL, @TotalAmountCODCash, @TotalAmountCODCredit,
             @TotalZigi, @TotalAmountZigiDeclared, 0, @TotalAmountCODZigiDeclared,
             0, @CountZigi, @TotalAmountFacturaZigiDeclared, 0);
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
            )
            SELECT @HeaderClosures,
                   Guide_Serie,
                   Guide_Number,
                   1,
                   @TokenCreated,
                   GETDATE(),
                   NULL,
                   NULL,
				   Fel
            FROM #TempClosureDetail;

            SELECT 200 IdResult,
                   'Cierre generado exitosamente' Message,
                   Value 'URL',
                   @HeaderClosures 'IdCierre'
            FROM ConfigParams WITH(NOLOCK)
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