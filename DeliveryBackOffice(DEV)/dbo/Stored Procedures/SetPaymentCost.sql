
-- =============================================
-- Author:		<Aquino,César>
-- Create date: <2021-03-23>
-- Description:	<Registrar pagos >
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-10>
-- Description:	< Corrección de manejo de voucher >
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <2026-01-14>
-- Description:	<Guardar Voucher y Path de la imagen del voucher>
-- =============================================
CREATE PROCEDURE [dbo].[SetPaymentCost]
    @TypeProduct INT,            -- = 1
    @ProductNumber VARCHAR(20),  -- = 'FD1990760'
    @TblDetail AS TblPaymentList READONLY,
    @FullPayment DECIMAL(12, 2), -- =100
    @TypeCharge INT,             -- = 1
    @Token VARCHAR(50),          -- = 'SYS-CAQUINO'
    @CODPayment DECIMAL(12, 2) = 0,
    @Responsible VARCHAR(100) = '',
    @TransferImagePath  NVARCHAR(300) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @IdCost INT = 0;
    DECLARE @TotalAmountPaid DECIMAL(12, 2) = 0;

    DECLARE @Voucher NVARCHAR(300);
	DECLARE @IdTypeOfMoney INT;
	DECLARE @Amount DECIMAL(18,2);

	 SELECT  @Voucher = det.Voucher,
			 @IdTypeOfMoney = det.IdTypeOfMoney,
			 @Amount  = det.Amount
	 FROM @TblDetail det;

    IF OBJECT_ID('tempdb.dbo.#TempCost', 'U') IS NOT NULL
        DROP TABLE #TempCost;

    IF NOT EXISTS
    (
        SELECT Top 1 1
        FROM dbo.Cost WITH (NOLOCK)
        WHERE IdProduct = @TypeProduct
              AND ProductNumber = @ProductNumber
    )
    BEGIN

        -- si no existe insertar registro en tabla cost

        INSERT INTO [dbo].[Cost]
        (
            [IdProduct],
            [ProductNumber],
            [IdTypeCharge],
            [TotalAmount],
            [PaymentDate],
            [IdModule],
            [RowStatus],
            [TokenCreated],
            [DateCreated],
            [TotalAmountPaid],
            [CODAmount]
        )
        VALUES
        (@TypeProduct, @ProductNumber, @TypeCharge, @FullPayment, GETDATE(), NULL, 1, @Token, GETDATE(), @FullPayment,
         @CODPayment);

        SET @IdCost = SCOPE_IDENTITY();

    END;
    ELSE
    BEGIN

        SELECT c.IdCost,
               ISNULL(c.TotalAmountPaid, 0) TotalAmountPaid,
               ISNULL(CODAmount, 0) CODAmount
        INTO #TempCost
        FROM dbo.Cost c WITH (NOLOCK)
        WHERE c.IdProduct = @TypeProduct
              AND c.ProductNumber = @ProductNumber;

        SET @IdCost =
        (
            SELECT TOP 1 IdCost FROM #TempCost
        );
        SET @TotalAmountPaid =
        (
            SELECT TOP 1 TotalAmountPaid FROM #TempCost
        );
    -- set @CODPayment = (Select top 1 CODAmount from #TempCost)
    END;
    IF (@TotalAmountPaid >= 0) -- El producto no esta pagado
    BEGIN

        UPDATE [DeliveryBackOffice].[dbo].[Cost]
        SET [PaymentDate] = GETDATE(),
            [TokenUpdated] = @Token,
            [DateUpdated] = GETDATE(),
            [TotalAmountPaid] = IIF([TotalAmountPaid] IS NULL,@FullPayment,(ISNULL(@Amount,0) + ISNULL(@CODPayment,0))),
            [CODAmount] = IIF([CODAmount] > 0,[CODAmount],@CODPayment)
        WHERE IdCost = @IdCost;

         IF(NOT EXISTS(Select TOP 1  1 From [DeliveryBackOffice].[dbo].[CostDetail] WITH(NOLOCK)
             WHERE [IdCost] = @IdCost
			)
         )
		 BEGIN
			INSERT INTO [DeliveryBackOffice].[dbo].[CostDetail]
			(
				[IdCost],
				[IdTypeOfMoney],
				[Amount],
				[Voucher],
				[RowStatus],
				[TokenCreated],
				[DateCreated],
				[Responsible],
				[VoucherPath],
				[IdTypeOfMoneyCOD],
				[IdTypeOfMoneyCollect]
			)
			SELECT @IdCost,
				   det.IdTypeOfMoney,
				   det.Amount,
				   IIF(det.IdTypeOfMoney in (6,11), det.Voucher, ''),
				   1, -- crear registro activo por default
				   @Token,
				   GETDATE(),
				   det.Responsible,
				   IIF(det.IdTypeOfMoney in (11),@TransferImagePath,''),
				   IIF(@CODPayment > 0,det.IdTypeOfMoney,NULL),
				   IIF(det.Amount  > 0,det.IdTypeOfMoney,NULL)
			FROM @TblDetail det;
		END
		   ELSE
				   UPDATE [DeliveryBackOffice].[dbo].[CostDetail] 
				        SET [Voucher] = IIF(@IdTypeOfMoney in (11), @Voucher, ''),
						    [IdTypeOfMoney] = @IdTypeOfMoney,
                            [IdTypeOfMoneyCOD] = IIF(@CODPayment > 0 AND IdTypeOfMoneyCOD IS NULL,@IdTypeOfMoney,IdTypeOfMoneyCOD),
							[IdTypeOfMoneyCollect] = IIF(@Amount > 0 AND IdTypeOfMoneyCollect IS NULL,@IdTypeOfMoney,IdTypeOfMoneyCollect),
							[Amount] = IIF([Amount] > 0,[Amount],@Amount)
					WHERE [IdCost] = @IdCost;
		END;
END;


