
-- =============================================
-- Author:		<Aquino,César>
-- Create date: <2021-02-26>
-- Description:	<Registrar cuentas por cobrar>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-01-27>
-- Description:	<Registrar cuentas por cobrar>
-- =============================================

CREATE PROCEDURE [dbo].[SetProductCost]
    -- Add the parameters for the stored procedure here
    @IdProduct INT,
    @IdTypeCharge INT,
    @ProductNumber NVARCHAR(100),
    @Amount DECIMAL(18, 2) = 15.00,
    @AmountPaid DECIMAL(18, 2),
    @IdModule INT = 1,
    @PaymentType INT = 2,
    @Voucher VARCHAR(200) = 'FSLDKFJ123KJLK31',
    @Token VARCHAR(200) = '12324system',
    @PaymentDate DATE,
    @TblDetail AS TblChangeList READONLY,
    @ReturnAmount DECIMAL(12, 2) = 0,
    @Format VARCHAR(50) = 'DataTable'

--,@TblDetail as TblChangeList  READONLY
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	DECLARE @GuideSerie NVARCHAR(2)
	DECLARE @GuideNumber INT
    -- ================================================================
    -- verificar si ya existe un registro del producto
    -- si existe el registro, verficar si ya tiene un pago asociado
    -- si ya tiene un pago asociado insertar otro registro,
    -- si no tiene ningun pago asociado, actualizar registro
    -- si no existe , insertar registro
    -- =================================================================

    -- verificar si el registro existe o esta pagado

	DECLARE @TblExists TABLE (
        IdCost INT,
        TotalAmountPaid DECIMAL(12, 2)
	)
	DECLARE @ListGuides TABLE (
		ItemSerie NVARCHAR(2),
		ItemNumber INT
	)

	INSERT INTO
		@ListGuides
		(
			ItemSerie
			,ItemNumber
		)
	SELECT 
		CONVERT(NVARCHAR(2), LTRIM(RTRIM(SUBSTRING(Item, 1,2)))) ItemSerie
		,CAST(LTRIM(RTRIM(SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))))) AS INT) ItemNumber 
	FROM 
		DeliveryBackOffice.dbo.SplitUnlimited(RTRIM(LTRIM(@ProductNumber)),',')

	SELECT
		TOP 1
			@GuideSerie = LG.ItemSerie
			,@GuideNumber = LG.ItemNumber
	FROM
		@ListGuides LG

    SELECT TOP 1 
        @CurrencySender = C.IdCatCurrencyCOD
        ,@SenderCountryId = od.SenderCountryId
    FROM DeliveryOrder od WITH(NOLOCK)
    INNER JOIN DeliveryCurrency DC WITH(NOLOCK)
     ON dc.Currency_IdCountry = od.SenderCountryId
    INNER JOIN CatCurrencyCOD C WITH(NOLOCK)
    ON C.IdCatCurrencyCOD = DC.IdCurrencyCOD
    WHERE od.Guide_Serie  = @GuideSerie
     AND od.Guide_Number = @GuideNumber
     AND DC.Currency_Status = 1 
     AND DC.DefaultPerCountry = 1
    
    SELECT TOP 1 
        @ExchangeSender = CER.ExchangeRate
    FROM DeliveryBackOffice.dbo.CurrencyExchangeRates CER WITH(NOLOCK)
    WHERE CER.IdCountry = @SenderCountryId
      AND cer.SourceCurrency = @CurrencySender
    ORDER BY cer.ExchangeDate DESC
		
    DECLARE @jsonResult NVARCHAR(MAX);
    INSERT INTO @TblExists
    (
        IdCost,
        TotalAmountPaid
    )
    SELECT TOP 1
           cst.IdCost,
           cst.TotalAmountPaid

    FROM dbo.Cost cst WITH (NOLOCK)
    WHERE 
		(
			(
				cst.GuideSerie = @GuideSerie
				AND
				cst.GuideNumber = @GuideNumber
			)
			OR
			(
				cst.ProductNumber = @ProductNumber
				AND
				cst.GuideSerie IS NULL
				AND
				cst.GuideNumber IS NULL
			)
		)
		AND
		cst.RowStatus = 1
	ORDER BY
		cst.DateCreated DESC;
    --	and cst.TotalAmountPaid is not null or cst.TotalAmountPaid =0

    DECLARE @IdCost INT =
            (
                SELECT ISNULL(xd.IdCost, 0)FROM @TblExists xd
            );

    DECLARE @IsPaid DECIMAL(12, 2) =
            (
                SELECT ISNULL(xd.TotalAmountPaid, 0)FROM @TblExists xd
            );

    DECLARE @CostCount INT;

    --- Variables para manejo de guardado de pagos si fue efectuado de inmediato
    DECLARE @TimeOfPayment INT = 0;
    SET @TimeOfPayment
        = ISNULL(
          (
              SELECT DOPD.TimePlaId
              FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
              WHERE DOPD.GuideSerie = @GuideSerie
                    AND DOPD.GuideNumber = @GuideNumber
          ),
          0
                );

    DECLARE @PaymentUpdated AS TABLE
    (
        CostId INT,
        GuideSerie NVARCHAR(2),
        GuideNumber INT
    );

    DECLARE @CostDetailExists INT = 0;

    IF @PaymentType = 6 -- Datafono / Pago con tarjeta
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            IF (@IdCost > 0 AND @IsPaid = 0) -- si el registro existe y esta pendiente de pago	
            BEGIN

                -- actualizar registro
                IF (@Voucher != '' OR @Voucher IS NOT NULL)
                BEGIN
                    SELECT @CostCount = COUNT(1)
                    FROM CostDetail cd WITH (NOLOCK)
                    WHERE cd.IdCost = @IdCost;

                    IF (@CostCount > 0)
                    BEGIN
                        UPDATE CostDetail
                        SET Amount = @Amount,
                            Voucher = @Voucher,
                            TokenUpdated = @Token,
                            DateUpdated = GETDATE()
                        WHERE IdCost = @IdCost;
                    END;
                    ELSE IF (@CostCount = 0)
                    BEGIN
                        INSERT INTO CostDetail
                        (
                            IdCost,
                            IdTypeOfMoney,
                            Amount,
                            Voucher,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            TokenUpdated,
                            DateUpdated
                        )
                        VALUES
                        (@IdCost, 6, @Amount, @Voucher, 1, @Token, GETDATE(), NULL, NULL);
                    END;
                END;

                -- insertar costos que no existen
                INSERT INTO [dbo].[BreakdownOfPayment]
                (
                    [IdCost],
                    [Description],
                    [Amount],
                    [ModIdModule],
                    [RowStatus],
                    [TokenCreated],
                    [DateCreated],
					[BreakdownOfPaymentTypeId]
                )
                SELECT @IdCost,
                       det.Description,
                       det.Amount,
                       det.ModIdModule,
                       1, -- crear registro activo por default
                       det.TokenCreated,
                       GETDATE(),
					   (SELECT TOP 1 CBOPT.IdCatBreakdownOfPaymentType FROM [DeliveryBackOffice].[dbo].[CatBreakdownOfPaymentType] CBOPT WITH(NOLOCK) WHERE CBOPT.BreakdownOfPaymentTypeName = det.Description COLLATE Latin1_General_CI_AI)
                FROM @TblDetail det
                    LEFT JOIN dbo.BreakdownOfPayment bk WITH (NOLOCK)
                        ON bk.Description = det.Description
                           AND bk.IdCost = @IdCost
                WHERE bk.IdBreakdownOfPayment IS NULL;

                -- actualizar los registros que si existen 
                UPDATE dbo.BreakdownOfPayment
                SET Amount = det.Amount,
                    RowStatus = det.RowStatus,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                FROM @TblDetail det
                    LEFT JOIN dbo.BreakdownOfPayment bk WITH (NOLOCK)
                        ON bk.Description = det.Description
                           AND bk.IdCost = @IdCost
                WHERE bk.IdBreakdownOfPayment IS NOT NULL;

                -- Actualizar price shipping con total de cargos 

                SET @Amount =
                (
                    SELECT SUM(ISNULL(bk.Amount, 0))
                    FROM dbo.BreakdownOfPayment bk WITH (NOLOCK)
                    WHERE bk.IdCost = @IdCost
                          AND bk.RowStatus = 1
                );

                UPDATE dbo.Cost
                SET TotalAmount = @Amount,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE(),
                    ReturnAmount = @ReturnAmount,
					GuideSerie = @GuideSerie,
					GuideNumber = @GuideNumber
                WHERE IdCost = @IdCost;

            END;
            ELSE IF (@IdCost IS NULL OR @IdCost = 0) -- si el registro no existe crear uno nuevo o registro ya esta pagado
            BEGIN

                IF (NOT EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM [DeliveryBackOffice].[dbo].[Cost] cst WITH (NOLOCK)
                    WHERE 
					(
						(
							cst.GuideSerie = @GuideSerie
							AND
							cst.GuideNumber = @GuideNumber
						)
						OR
						(
							cst.ProductNumber = @ProductNumber
							AND
							cst.GuideSerie IS NULL
							AND
							cst.GuideNumber IS NULL
						)
					)
					AND
					cst.RowStatus = 1
                )
                   )
                BEGIN

                    INSERT INTO dbo.Cost
                    (
                        IdProduct,
                        ProductNumber,
                        IdTypeCharge,
                        TotalAmount,
                        PaymentDate,
                        IdModule,
                        ShippingCurrency,
                        ShippingExchangeRate,
                        RowStatus,
                        TokenCreated,
                        DateCreated,
                        TokenUpdated,
                        DateUpdated,
                        ReturnAmount,
						GuideSerie,
						GuideNumber
                    )
                    VALUES
                    (   @IdProduct, @ProductNumber, @IdTypeCharge, @Amount, @PaymentDate, @IdModule,
                        @CurrencySender, @ExchangeSender,
                        1, -- guardar los registros como activos 
                        @Token, GETDATE(), NULL, NULL, @ReturnAmount, @GuideSerie, @GuideNumber);

                    SET @IdCost = SCOPE_IDENTITY();

                    IF (@Voucher != '' OR @Voucher IS NOT NULL)
                    BEGIN
                        SELECT @CostCount = COUNT(1)
                        FROM CostDetail cd WITH (NOLOCK)
                        WHERE cd.IdCost = @IdCost;

                        IF (@CostCount > 0)
                        BEGIN

                            UPDATE CostDetail
                            SET Amount = @Amount,
                                Voucher = @Voucher,
                                TokenUpdated = @Token,
                                DateUpdated = GETDATE()
                            WHERE IdCost = @IdCost;

                        END;
                        ELSE IF (@CostCount = 0)
                        BEGIN

                            INSERT INTO CostDetail
                            (
                                IdCost,
                                IdTypeOfMoney,
                                Amount,
                                Voucher,
                                RowStatus,
                                TokenCreated,
                                DateCreated,
                                TokenUpdated,
                                DateUpdated
                            )
                            VALUES
                            (@IdCost, 6, @Amount, @Voucher, 1, @Token, GETDATE(), NULL, NULL);

                        END;
                    END;

                    INSERT INTO [dbo].[BreakdownOfPayment]
                    (
                        [IdCost],
                        [Description],
                        [Amount],
                        [ModIdModule],
                        [RowStatus],
                        [TokenCreated],
                        [DateCreated],
						[BreakdownOfPaymentTypeId]
                    )
                    SELECT @IdCost,
                           det.Description,
                           det.Amount,
                           det.ModIdModule,
                           1, -- crear registro activo por default
                           det.TokenCreated,
                           GETDATE(),
						(SELECT TOP 1 CBOPT.IdCatBreakdownOfPaymentType FROM [DeliveryBackOffice].[dbo].[CatBreakdownOfPaymentType] CBOPT WITH(NOLOCK) WHERE CBOPT.BreakdownOfPaymentTypeName = det.Description COLLATE Latin1_General_CI_AI)
                    FROM @TblDetail det;

                END;

            END;

            --- Registrar un pago, SI Y SOLO SI:
            /*
					Existe su registro en Cost
					No ha sido registrado un pago
					El pago es con  datafono (Tarjeta de credito)
					Y que el pago sea inmediato (Pago en portal)
				*/

            SELECT @IdCost = cst.IdCost,
                   @IsPaid = ISNULL(cst.TotalAmountPaid, 0)
            FROM [DeliveryBackOffice].[dbo].[Cost] cst WITH(NOLOCK)
            WHERE 
				(
					(
						cst.GuideSerie = @GuideSerie
						AND
						cst.GuideNumber = @GuideNumber
					)
					OR
					(
						cst.ProductNumber = @ProductNumber
						AND
						cst.GuideSerie IS NULL
						AND
						cst.GuideNumber IS NULL
					)
				)
				AND
				cst.RowStatus = 1
			ORDER BY
				cst.DateCreated DESC;

            IF (@IdCost > 0 AND @IsPaid = 0 AND @PaymentType = 6 AND @TimeOfPayment = 1)
            BEGIN
                --- REGISTRO DE PAGO DE LAS GUÍAS
                UPDATE C
                SET C.TotalAmountPaid = C.TotalAmount,
                    C.TokenUpdated = @Token,
                    C.DateUpdated = GETDATE(),
					C.GuideSerie = @GuideSerie,
					C.GuideNumber = @GuideNumber
                OUTPUT inserted.IdCost,
                       SUBSTRING(LTRIM(@ProductNumber), 0, 3),
                       CAST(SUBSTRING(LTRIM(@ProductNumber), 3, LEN(@ProductNumber)) AS INT)
                INTO @PaymentUpdated
                (
                    CostId,
                    GuideSerie,
                    GuideNumber
                )
                FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                WHERE C.IdCost = @IdCost
                      AND
                      (
                          C.TotalAmountPaid IS NULL
                          OR C.TotalAmountPaid = 0
                      );

                SET @CostDetailExists = ISNULL(
                                        (
                                            SELECT TOP 1
                                                   CD.IdCostDetail
                                            FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                                                INNER JOIN @PaymentUpdated PU
                                                    ON C.IdCost = PU.CostId
                                                LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
                                                    ON C.IdCost = CD.IdCost
                                        ),
                                        0
                                              );

                IF (@CostDetailExists > 0)
                BEGIN
                    --- ACTUALIZACIÓN DEL DETALLE DEL PAGO DE LA GUÍA 
                    UPDATE CD
                    SET CD.IdTypeOfMoney = @PaymentType,
                        CD.Amount = C.TotalAmountPaid,
                        CD.Voucher = @Voucher,
                        CD.TokenUpdated = @Token,
                        CD.DateUpdated = GETDATE()
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                        INNER JOIN @PaymentUpdated PU
                            ON C.IdCost = PU.CostId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
                            ON C.IdCost = CD.IdCost
                    WHERE CD.IdCostDetail = @CostDetailExists;
                END;
                ELSE
                BEGIN
                    --- REGISTRO DEL DETALLE DEL PAGO DE LA GUÍA 
                    INSERT INTO dbo.CostDetail
                    (
                        IdCost,
                        IdTypeOfMoney,
                        Amount,
                        Voucher,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    SELECT C.IdCost,
                           @PaymentType,
                           C.TotalAmountPaid,
                           @Voucher,
                           1,
                           @Token,
                           GETDATE()
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                        INNER JOIN @PaymentUpdated PU
                            ON C.IdCost = PU.CostId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
                            ON C.IdCost = CD.IdCost
                    WHERE CD.IdCostDetail IS NULL;
                END;
            END;
        END TRY
        BEGIN CATCH

            ROLLBACK TRANSACTION;

            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":500,' + '"Message":" Error de transacción"}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END CATCH;
    --END TRANSACTION
    END;
    --- Cualquier otro tipo de pago ---
    ELSE
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY

            IF (@IdCost > 0 AND @IsPaid = 0) -- si el registro existe y esta pendiente de pago	
            BEGIN

                -- insertar costos que no existen
                INSERT INTO [dbo].[BreakdownOfPayment]
                (
                    [IdCost],
                    [Description],
                    [Amount],
                    [ModIdModule],
                    [RowStatus],
                    [TokenCreated],
                    [DateCreated],
					[BreakdownOfPaymentTypeId]
                )
                SELECT @IdCost,
                       det.Description,
                       det.Amount,
                       det.ModIdModule,
                       1, -- crear registro activo por default
                       det.TokenCreated,
                       GETDATE(),
					   (SELECT TOP 1 CBOPT.IdCatBreakdownOfPaymentType FROM [DeliveryBackOffice].[dbo].[CatBreakdownOfPaymentType] CBOPT WITH(NOLOCK) WHERE CBOPT.BreakdownOfPaymentTypeName = det.Description COLLATE Latin1_General_CI_AI)
                FROM @TblDetail det
                    LEFT JOIN dbo.BreakdownOfPayment bk WITH (NOLOCK)
                        ON bk.Description = det.Description
                           AND bk.IdCost = @IdCost
                WHERE bk.IdBreakdownOfPayment IS NULL;

                -- actualizar los registros que si existen 
                UPDATE dbo.BreakdownOfPayment
                SET Amount = det.Amount,
                    RowStatus = det.RowStatus,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                FROM @TblDetail det
                    LEFT JOIN dbo.BreakdownOfPayment bk WITH (NOLOCK)
                        ON bk.Description = det.Description
                           AND bk.IdCost = @IdCost
                WHERE bk.IdBreakdownOfPayment IS NOT NULL;

                -- Actualizar price shipping con total de cargos 

                SET @Amount =
                (
                    SELECT SUM(ISNULL(bk.Amount, 0))
                    FROM dbo.BreakdownOfPayment bk WITH (NOLOCK)
                    WHERE bk.IdCost = @IdCost
                          AND bk.RowStatus = 1
                );

                UPDATE dbo.Cost
                SET TotalAmount = @Amount,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE(),
                    ReturnAmount = @ReturnAmount,
					GuideSerie = @GuideSerie,
					GuideNumber = @GuideNumber
                WHERE IdCost = @IdCost;

            END;
            ELSE IF (@IdCost IS NULL OR @IdCost = 0) -- si el registro no existe crear uno nuevo o registro ya esta pagado
            BEGIN

                IF (NOT EXISTS
                (
                    SELECT TOP 1
                           1
                    FROM [DeliveryBackOffice].[dbo].[Cost] cst WITH (NOLOCK)
                    WHERE 
						(
							(
								cst.GuideSerie = @GuideSerie
								AND
								cst.GuideNumber = @GuideNumber
							)
							OR
							(
								cst.ProductNumber = @ProductNumber
								AND
								cst.GuideSerie IS NULL
								AND
								cst.GuideNumber IS NULL
							)
						)
						AND
						cst.RowStatus = 1
                )
                   )
                BEGIN

                    INSERT INTO dbo.Cost
                    (
                        IdProduct,
                        ProductNumber,
                        IdTypeCharge,
                        TotalAmount,
                        PaymentDate,
                        IdModule,
                        ShippingCurrency,
                        ShippingExchangeRate,                       
                        RowStatus,
                        TokenCreated,
                        DateCreated,
                        TokenUpdated,
                        DateUpdated,
						GuideSerie,
						GuideNumber
                    )
                    VALUES
                    (   @IdProduct, @ProductNumber, @IdTypeCharge, @Amount, @PaymentDate, @IdModule,
                        @CurrencySender, @ExchangeSender,
                        1, -- guardar los registros como activos 
                        @Token, GETDATE(), NULL, NULL, @GuideSerie, @GuideNumber);

                    SET @IdCost = SCOPE_IDENTITY();

                    INSERT INTO [dbo].[BreakdownOfPayment]
                    (
                        [IdCost],
                        [Description],
                        [Amount],
                        [ModIdModule],
                        [RowStatus],
                        [TokenCreated],
                        [DateCreated],
						[BreakdownOfPaymentTypeId]
                    )
                    SELECT @IdCost,
                           det.Description,
                           det.Amount,
                           det.ModIdModule,
                           1, -- crear registro activo por default
                           det.TokenCreated,
                           GETDATE(),
						   (SELECT TOP 1 CBOPT.IdCatBreakdownOfPaymentType FROM [DeliveryBackOffice].[dbo].[CatBreakdownOfPaymentType] CBOPT WITH(NOLOCK) WHERE CBOPT.BreakdownOfPaymentTypeName = det.Description COLLATE Latin1_General_CI_AI)
                    FROM @TblDetail det;

                END;
            END;

            -- actualizar precios de producto
            IF (@IdTypeCharge = 1) -- consto de envio (flete)
            BEGIN

                UPDATE dbo.DeliveryOrder
                SET PriceShippment = @Amount
                WHERE Guide_Serie = SUBSTRING(LTRIM(@ProductNumber), 0, 3)
                      AND Guide_Number = SUBSTRING(LTRIM(@ProductNumber), 3, LEN(@ProductNumber));

            END;
            ELSE -- pickup
            BEGIN

                UPDATE dbo.SchedulePickup
                SET AmountPickup = @Amount
                WHERE SchedulePickupId = CONVERT(INT, @ProductNumber);

            END;

            --- Registrar un pago, SI Y SOLO SI:
            /*
					Existe su registro en Cost
					No ha sido registrado un pago
					El pago es con efectivo
					Y que el pago sea inmediato (Pago en portal)
				*/

            SELECT @IdCost = cst.IdCost,
                   @IsPaid = ISNULL(cst.TotalAmountPaid, 0)
            FROM [DeliveryBackOffice].[dbo].[Cost] cst WITH(NOLOCK)
            WHERE 
				(
					(
						cst.GuideSerie = @GuideSerie
						AND
						cst.GuideNumber = @GuideNumber
					)
					OR
					(
						cst.ProductNumber = @ProductNumber
						AND
						cst.GuideSerie IS NULL
						AND
						cst.GuideNumber IS NULL
					)
				)
				AND
				cst.RowStatus = 1
			ORDER BY
				cst.DateCreated DESC;

            IF (@IdCost > 0 AND @IsPaid = 0 AND @PaymentType = 1 AND @TimeOfPayment = 1)
            BEGIN
                --- REGISTRO DE PAGO DE LAS GUÍAS
                UPDATE C
                SET C.TotalAmountPaid = C.TotalAmount,
                    C.TokenUpdated = @Token,
                    C.DateUpdated = GETDATE(),
					C.GuideSerie = @GuideSerie,
					C.GuideNumber = @GuideNumber
                OUTPUT inserted.IdCost,
                       SUBSTRING(LTRIM(@ProductNumber), 0, 3),
                       CAST(SUBSTRING(LTRIM(@ProductNumber), 3, LEN(@ProductNumber)) AS INT)
                INTO @PaymentUpdated
                (
                    CostId,
                    GuideSerie,
                    GuideNumber
                )
                FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                WHERE C.IdCost = @IdCost
                      AND
                      (
                          C.TotalAmountPaid IS NULL
                          OR C.TotalAmountPaid = 0
                      );

                SET @CostDetailExists = ISNULL(
                                        (
                                            SELECT TOP 1
                                                   CD.IdCostDetail
                                            FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                                                INNER JOIN @PaymentUpdated PU
                                                    ON C.IdCost = PU.CostId
                                                LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
                                                    ON C.IdCost = CD.IdCost
                                        ),
                                        0
                                              );

                IF (@CostDetailExists > 0)
                BEGIN
                    --- ACTUALIZACIÓN DEL DETALLE DEL PAGO DE LA GUÍA 
                    UPDATE CD
                    SET CD.IdTypeOfMoney = @PaymentType,
                        CD.Amount = C.TotalAmountPaid,
                        CD.Voucher = '',
                        CD.TokenUpdated = @Token,
                        CD.DateUpdated = GETDATE()
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                        INNER JOIN @PaymentUpdated PU
                            ON C.IdCost = PU.CostId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
                            ON C.IdCost = CD.IdCost
                    WHERE CD.IdCostDetail = @CostDetailExists;
                END;
                ELSE
                BEGIN
                    --- REGISTRO DEL DETALLE DEL PAGO DE LA GUÍA 
                    INSERT INTO dbo.CostDetail
                    (
                        IdCost,
                        IdTypeOfMoney,
                        Amount,
                        Voucher,
                        RowStatus,
                        TokenCreated,
                        DateCreated
                    )
                    SELECT C.IdCost,
                           @PaymentType,
                           C.TotalAmountPaid,
                           '',
                           1,
                           @Token,
                           GETDATE()
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH (NOLOCK)
                        INNER JOIN @PaymentUpdated PU
                            ON C.IdCost = PU.CostId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH (NOLOCK)
                            ON C.IdCost = CD.IdCost
                    WHERE CD.IdCostDetail IS NULL;
                END;
            END;

        END TRY
        BEGIN CATCH

            ROLLBACK TRANSACTION;

            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":500,' + '"Message":" Error de transacción"}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END CATCH;
    -- END TRANSACTION
    END;

    --- Envio de respuesta ---
    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT '{{"IdResult":200,' + '"Message":" Registro actualizado correctamente "}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;

    IF @Format != 'Non'
        SELECT ('[' + @jsonResult + ']') jsonResult;

END;



