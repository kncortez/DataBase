USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GenerateClosureOperador]    Script Date: 28/03/2022 14:26:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Alejandro Rodríguez>
-- Create date: <2022-03-17>
-- Description:	<SP para generar el cierre de los express center>
-- Nota: Es una copia de GenerateClosure pero se agregaron validaciones
-- =============================================

CREATE PROCEDURE [dbo].[GenerateClosureOperador]
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
	@TotalCOD INT
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
    DECLARE @UserId2 INT;

    IF OBJECT_ID('tempdb.dbo.#TempClosureDetail', 'U') IS NOT NULL
        DROP TABLE #TempClosureDetail;

    SET @UserId2 =
    (
        SELECT TOP 1
               vp.RegisterUserID
        FROM [dbo].RegisterUser usr
            LEFT JOIN [dbo].[RolByUserByAccount] rua
                ON rua.RuaIdUser = usr.UsrIdUser
                   AND rua.RuaRowStatus = 1
            INNER JOIN [dbo].Account ac
                ON ac.AccIdAccount = rua.RuaIdAccount
                   AND ac.AccRowStatus = 1
            INNER JOIN VisitPointByUser vp
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
    FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPT
        LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND
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
            ON DOPD.guideserie = DOR.Guide_Serie
               AND DOPD.guidenumber = DOR.Guide_Number
               AND DOPD.ShipmentCompleted = 1
			   AND DOR.StatusOrderId != 7
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND DOPD.AccountId = @UserId
          AND NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
        WHERE ACD.GuideSerie = DOR.Guide_Serie
              AND ACD.GuideNumber = DOR.Guide_Number
              AND ACD.RowStatus = 1
    )
	UNION ALL
	SELECT DOPD.GuideSerie, DOPD.GuideNumber, DOPD.Fel
    FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD
         
        JOIN CatTypeServiceClosure CTS
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
		JOIN invoiceHeader INH  ON INH.inv_numberFEL = (SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
        
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND DOPD.AccountId = @UserId
          AND DOPD.GuideSerie is null
		  AND NOT EXISTS
		  (
			SELECT 1
			FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
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

	SET @Estandar = (SELECT IdTypeService FROM CatTypeServiceClosure 
					WHERE NameTypeService = 'Estándar');
	SET @Entrega = (SELECT IdTypeService FROM CatTypeServiceClosure 
					WHERE NameTypeService = 'Entrega');
	SET @Recepcion = (SELECT IdTypeService FROM CatTypeServiceClosure 
						WHERE NameTypeService = 'Recepción');
	SET @Devolucion = (SELECT IdTypeService FROM CatTypeServiceClosure 
						WHERE NameTypeService = 'Devolución')
	SET @Traslado = (SELECT IdTypeService FROM CatTypeServiceClosure 
					WHERE NameTypeService = 'Traslado')
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
                           SUM(   CASE
                                      WHEN DOR.IsCollect = 1 THEN
                                          DOR.PriceShippment
                                      ELSE
                                          DOPD.amount
                                  END
                              )
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
							AND DOPD.TypeServiceId IN (@Entrega,@Recepcion,@Traslado)  
						THEN
                           SUM(   CASE
                                      WHEN DOR.IsCollect = 1 THEN
                                          DOR.PriceShippment
                                      ELSE
                                          DOPD.amount
                                  END
                              )
                       ELSE
                           0
                   END 'TotalFacturaCard',
				   CASE
                       WHEN
                       (
                           (DOPD.TypeofInOutMoneyId = 6  OR DOPD.TypeofInOutMoneyId = 2)
                           AND DOPD.amount != 0
						   AND DOPD.TypeServiceId IN (@Entrega,@Recepcion,@Traslado) 
                       ) THEN
                           COUNT(DOPD.TypeofInOutMoneyId)
                       ELSE
                           0
                   END 'CountFacturaCard'
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
                ON DOPD.guideserie = DOR.Guide_Serie
                   AND DOPD.guidenumber = DOR.Guide_Number
                   AND DOPD.ShipmentCompleted = 1
				   AND DOR.StatusOrderId != 7
        WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
              AND DOPD.AccountId = @UserId
              AND NOT EXISTS
        (
            SELECT 1
            FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
            WHERE ACD.GuideSerie = DOR.Guide_Serie
                  AND ACD.GuideNumber = DOR.Guide_Number
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
			FROM  DeliveryBackOffice.dbo.DeliveryOrderPaymentTransaction DOPD
         
        JOIN CatTypeServiceClosure CTS
            ON CTS.IdTypeService = DOPD.TypeServiceId
        LEFT JOIN DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney ctgmon
            ON ctgmon.tio_pk_id = DOPD.TypeofInOutMoneyId
        
    WHERE CAST(DOPD.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
          AND DOPD.AccountId = @UserId
          AND DOPD.GuideSerie is null
		  AND NOT EXISTS
		  (
			SELECT 1
			FROM DeliveryBackOffice.dbo.AccountingClosuresDetail ACD
			WHERE ACD.Fel =(SELECT item FROM dbo.SplitUnlimited(DOPD.Fel, '-') WHERE id = 2)
				  AND ACD.RowStatus = 1
		  )
		  GROUP BY DOPD.TypeofInOutMoneyId, DOPD.TypeServiceId, DOPD.amount, AccountId
    ) S1;

    DECLARE @HeaderClosures INT = 0;

    BEGIN TRANSACTION;
    BEGIN TRY
        IF ((@TotalCash + @TotalCard) >= 0) --Si existen datos para cierre
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
				InvoiceAmountCOD
            )
            VALUES
            (@UserId2, @ClosurerPOS, @TotalCash, @TotalAmountCashDeclared, @TotalCard, @TotalAmountCreditDeclared,
             @CountCash, @Countcard, @VisitPointId, @Voucher1, @Bag1, @Voucher2, @Bag2, 1, @TokenCreated, GETDATE(),
             NULL, NULL, @TotalAmountCODCash, @TotalAmountCODCashDeclared, 
			 @TotalAmountFacturaCashDeclared, @TotalAmountFacturaCardDeclared,
			 @TotalFacturaCash, @CountFacturaCash, @TotalFacturaCard, @CountFacturaCard, @TotalCOD);
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
				   (SELECT item FROM dbo.SplitUnlimited(Fel, '-') WHERE id = 2)
            FROM #TempClosureDetail;

            SELECT 200 IdResult,
                   'Cierre generado exitosamente' Message,
                   Value 'URL',
                   @HeaderClosures 'IdCierre'
            FROM ConfigParams
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