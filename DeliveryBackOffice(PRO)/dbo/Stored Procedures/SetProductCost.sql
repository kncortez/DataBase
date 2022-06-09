
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

    -- ================================================================
    -- verificar si ya existe un registro del producto
    -- si existe el registro, verficar si ya tiene un pago asociado
    -- si ya tiene un pago asociado insertar otro registro,
    -- si no tiene ningun pago asociado, actualizar registro
    -- si no existe , insertar registro
    -- =================================================================

    -- verificar si el registro existe o esta pagado

    IF OBJECT_ID('tempdb.dbo.#TblExist', 'U') IS NOT NULL
        DROP TABLE #TblExist;

    DECLARE @jsonResult NVARCHAR(MAX);
    SELECT TOP 1
           cst.IdCost,
           cst.TotalAmountPaid
    INTO #TblExist
    FROM dbo.Cost cst WITH (NOLOCK)
    WHERE cst.IdProduct = @IdProduct
          AND cst.ProductNumber = @ProductNumber;
    --	and cst.TotalAmountPaid is not null or cst.TotalAmountPaid =0

    DECLARE @Exist INT =
            (
                SELECT COUNT(*)FROM #TblExist
            );

    DECLARE @IsPaid DECIMAL(12, 2) =
            (
                SELECT ISNULL(xd.TotalAmountPaid, 0)FROM #TblExist xd
            );

    DECLARE @IdCost INT = 0;

    DECLARE @CostCount INT;

    --- Variables para manejo de guardado de pagos si fue efectuado de inmediato
    DECLARE @TimeOfPayment INT = 0;
    SET @TimeOfPayment
        = ISNULL(
          (
              SELECT DOPD.TimePlaId
              FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
              WHERE DOPD.GuideSerie = SUBSTRING(LTRIM(@ProductNumber), 0, 3)
                    AND DOPD.GuideNumber = CAST(SUBSTRING(LTRIM(@ProductNumber), 3, LEN(@ProductNumber)) AS INT)
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
            IF (@Exist > 0 AND @IsPaid = 0) -- si el registro existe y esta pendiente de pago	
            BEGIN
                -- actualizar registro

                UPDATE dbo.Cost
                SET TotalAmount = @Amount,
                    TotalAmountPaid = @AmountPaid,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE(),
                    ReturnAmount = @ReturnAmount
                WHERE IdProduct = @IdProduct
                      AND ProductNumber = @ProductNumber
                      AND TotalAmountPaid IS NULL
                      OR TotalAmountPaid = 0;

                SET @IdCost =
                (
                    SELECT tb.IdCost FROM #TblExist tb
                );

                IF (@Voucher != '' OR @Voucher IS NOT NULL)
                BEGIN
                    SELECT @CostCount = COUNT(1)
                    FROM CostDetail cd WITH(NOLOCK)
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
                    [DateCreated]
                )
                SELECT @IdCost,
                       det.Description,
                       det.Amount,
                       det.ModIdModule,
                       1, -- crear registro activo por default
                       det.TokenCreated,
                       GETDATE()
                FROM @TblDetail det
                    LEFT JOIN dbo.BreakdownOfPayment bk WITH(NOLOCK)
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
                    LEFT JOIN dbo.BreakdownOfPayment bk WITH(NOLOCK)
                        ON bk.Description = det.Description
                           AND bk.IdCost = @IdCost
                WHERE bk.IdBreakdownOfPayment IS NOT NULL;

                -- Actualizar price shipping con total de cargos 

                SET @Amount =
                (
                    SELECT SUM(ISNULL(bk.Amount, 0))
                    FROM dbo.BreakdownOfPayment bk WITH(NOLOCK)
                    WHERE bk.IdCost = @IdCost
                          AND bk.RowStatus = 1
                );

                UPDATE dbo.Cost
                SET TotalAmount = @Amount,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE(),
                    ReturnAmount = @ReturnAmount
                WHERE IdProduct = @IdProduct
                      AND ProductNumber = @ProductNumber;

            END;
            ELSE IF (@Exist IS NULL OR @Exist = 0) -- si el registro no existe crear uno nuevo o registro ya esta pagado
            BEGIN
				
				IF( 
					NOT EXISTS
					(
						SELECT
							TOP 1
								1
						FROM
							[DeliveryBackOffice].[dbo].[Cost] C WITH(NOLOCK)
						WHERE
							C.IdProduct = @IdProduct
							AND
							C.IdTypeCharge = @IdTypeCharge
							AND
							C.ProductNumber = @ProductNumber
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
						RowStatus,
						TokenCreated,
						DateCreated,
						TokenUpdated,
						DateUpdated,
						ReturnAmount
					)
					VALUES
					(   @IdProduct, @ProductNumber, @IdTypeCharge, @Amount, @PaymentDate, @IdModule,
						1, -- guardar los registros como activos 
						@Token, GETDATE(), NULL, NULL, @ReturnAmount);

					SET @IdCost = SCOPE_IDENTITY();

					IF (@Voucher != '' OR @Voucher IS NOT NULL)
					BEGIN
						SELECT @CostCount = COUNT(1)
						FROM CostDetail cd WITH(NOLOCK)
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
						[DateCreated]
					)
					SELECT @IdCost,
						   det.Description,
						   det.Amount,
						   det.ModIdModule,
						   1, -- crear registro activo por default
						   det.TokenCreated,
						   GETDATE()
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

			SELECT
				@Exist = 1
				,@IsPaid = ISNULL(C.TotalAmountPaid,0)
			FROM
				[DeliveryBackOffice].[dbo].[Cost] C
			WHERE
				C.IdProduct = @IdProduct
				AND
				C.IdTypeCharge = @IdTypeCharge
				AND
				C.ProductNumber = @ProductNumber

            IF (@Exist > 0 AND @IsPaid = 0 AND @PaymentType = 6 AND @TimeOfPayment = 1)
            BEGIN
                --- REGISTRO DE PAGO DE LAS GUÍAS
                UPDATE C
                SET C.TotalAmountPaid = C.TotalAmount,
                    C.TokenUpdated = @Token,
                    C.DateUpdated = GETDATE()
                OUTPUT inserted.IdCost,
                       SUBSTRING(LTRIM(@ProductNumber), 0, 3),
                       CAST(SUBSTRING(LTRIM(@ProductNumber), 3, LEN(@ProductNumber)) AS INT)
                INTO @PaymentUpdated
                (
                    CostId,
                    GuideSerie,
                    GuideNumber
                )
                FROM [DeliveryBackOffice].[dbo].[Cost] C WITH(NOLOCK)
                WHERE C.ProductNumber = @ProductNumber
					  AND C.IdProduct = @IdProduct
					  AND C.IdTypeCharge = @IdTypeCharge
                      AND (C.TotalAmountPaid IS NULL
                      OR C.TotalAmountPaid = 0);

                SET @CostDetailExists = ISNULL(
                                        (
                                            SELECT TOP 1
                                                   CD.IdCostDetail
                                            FROM [DeliveryBackOffice].[dbo].[Cost] C WITH(NOLOCK)
                                                JOIN @PaymentUpdated PU 
                                                    ON C.IdCost = PU.CostId
                                                LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH(NOLOCK)
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
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH(NOLOCK)
                        JOIN @PaymentUpdated PU
                            ON C.IdCost = PU.CostId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH(NOLOCK)
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
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH(NOLOCK)
                        JOIN @PaymentUpdated PU
                            ON C.IdCost = PU.CostId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH(NOLOCK)
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
            -- select * from #TblExist
            IF (@Exist > 0 AND @IsPaid = 0) -- si el registro existe y esta pendiente de pago	
            BEGIN
                -- actualizar registro

                UPDATE dbo.Cost
                SET TotalAmount = @Amount,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE(),
                    ReturnAmount = @ReturnAmount
                WHERE IdProduct = @IdProduct
                      AND ProductNumber = @ProductNumber;

                SET @IdCost =
                (
                    SELECT tb.IdCost FROM #TblExist tb
                );

                -- insertar costos que no existen
                INSERT INTO [dbo].[BreakdownOfPayment]
                (
                    [IdCost],
                    [Description],
                    [Amount],
                    [ModIdModule],
                    [RowStatus],
                    [TokenCreated],
                    [DateCreated]
                )
                SELECT @IdCost,
                       det.Description,
                       det.Amount,
                       det.ModIdModule,
                       1, -- crear registro activo por default
                       det.TokenCreated,
                       GETDATE()
                FROM @TblDetail det
                    LEFT JOIN dbo.BreakdownOfPayment bk WITH(NOLOCK)
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
                    LEFT JOIN dbo.BreakdownOfPayment bk WITH(NOLOCK)
                        ON bk.Description = det.Description
                           AND bk.IdCost = @IdCost
                WHERE bk.IdBreakdownOfPayment IS NOT NULL;

                -- Actualizar price shipping con total de cargos 

                SET @Amount =
                (
                    SELECT SUM(ISNULL(bk.Amount, 0))
                    FROM dbo.BreakdownOfPayment bk WITH(NOLOCK)
                    WHERE bk.IdCost = @IdCost
                          AND bk.RowStatus = 1
                );
                UPDATE dbo.Cost
                SET TotalAmount = @Amount,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE(),
                    ReturnAmount = @ReturnAmount
                WHERE IdProduct = @IdProduct
                      AND ProductNumber = @ProductNumber;
            END;
            ELSE IF (@Exist IS NULL OR @Exist = 0) -- si el registro no existe crear uno nuevo o registro ya esta pagado
            BEGIN

				IF( 
					NOT EXISTS
					(
						SELECT
							TOP 1
								1
						FROM
							[DeliveryBackOffice].[dbo].[Cost] C WITH(NOLOCK)
						WHERE
							C.IdProduct = @IdProduct
							AND
							C.IdTypeCharge = @IdTypeCharge
							AND
							C.ProductNumber = @ProductNumber
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
						RowStatus,
						TokenCreated,
						DateCreated,
						TokenUpdated,
						DateUpdated
					)
					VALUES
					(   @IdProduct, @ProductNumber, @IdTypeCharge, @Amount, @PaymentDate, @IdModule,
						1, -- guardar los registros como activos 
						@Token, GETDATE(), NULL, NULL);

					SET @IdCost = SCOPE_IDENTITY();

					INSERT INTO [dbo].[BreakdownOfPayment]
					(
						[IdCost],
						[Description],
						[Amount],
						[ModIdModule],
						[RowStatus],
						[TokenCreated],
						[DateCreated]
					)
					SELECT @IdCost,
						   det.Description,
						   det.Amount,
						   det.ModIdModule,
						   1, -- crear registro activo por default
						   det.TokenCreated,
						   GETDATE()
					FROM @TblDetail det;

				END
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

			SELECT
				@Exist = 1
				,@IsPaid = ISNULL(C.TotalAmountPaid,0)
			FROM
				[DeliveryBackOffice].[dbo].[Cost] C
			WHERE
				C.IdProduct = @IdProduct
				AND
				C.IdTypeCharge = @IdTypeCharge
				AND
				C.ProductNumber = @ProductNumber

            IF (@Exist > 0 AND @IsPaid = 0 AND @PaymentType = 1 AND @TimeOfPayment = 1)
            BEGIN
                --- REGISTRO DE PAGO DE LAS GUÍAS
                UPDATE C
                SET C.TotalAmountPaid = C.TotalAmount,
                    C.TokenUpdated = @Token,
                    C.DateUpdated = GETDATE()
                OUTPUT inserted.IdCost,
                       SUBSTRING(LTRIM(@ProductNumber), 0, 3),
                       CAST(SUBSTRING(LTRIM(@ProductNumber), 3, LEN(@ProductNumber)) AS INT)
                INTO @PaymentUpdated
                (
                    CostId,
                    GuideSerie,
                    GuideNumber
                )
                FROM [DeliveryBackOffice].[dbo].[Cost] C WITH(NOLOCK)
                WHERE C.ProductNumber = @ProductNumber
					  AND C.IdProduct = @IdProduct
					  AND C.IdTypeCharge = @IdTypeCharge
                      AND (C.TotalAmountPaid IS NULL
                      OR C.TotalAmountPaid = 0);

                SET @CostDetailExists = ISNULL(
                                        (
                                            SELECT TOP 1
                                                   CD.IdCostDetail
                                            FROM [DeliveryBackOffice].[dbo].[Cost] C WITH(NOLOCK)
                                                JOIN @PaymentUpdated PU
                                                    ON C.IdCost = PU.CostId
                                                LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH(NOLOCK)
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
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH(NOLOCK)
                        JOIN @PaymentUpdated PU
                            ON C.IdCost = PU.CostId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH(NOLOCK)
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
                    FROM [DeliveryBackOffice].[dbo].[Cost] C WITH(NOLOCK)
                        JOIN @PaymentUpdated PU
                            ON C.IdCost = PU.CostId
                        LEFT JOIN [DeliveryBackOffice].[dbo].[CostDetail] CD WITH(NOLOCK)
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



