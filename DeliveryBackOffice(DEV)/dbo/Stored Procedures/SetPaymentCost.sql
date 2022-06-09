
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


CREATE PROCEDURE [dbo].[SetPaymentCost]

 @TypeProduct int -- = 1
 ,@ProductNumber varchar(20) -- = 'FD1990760'
 ,@TblDetail AS TblPaymentList 	readonly
 ,@FullPayment decimal(12,2)-- =100
 ,@TypeCharge int -- = 1
 ,@Token varchar(50) -- = 'SYS-CAQUINO'
 ,@CODPayment  decimal(12,2) =0
 ,@Responsible varchar(100)  = ''

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @IdCost int =0
declare @TotalAmountPaid decimal(12,2) =0
	
IF OBJECT_ID('tempdb.dbo.#TempCost', 'U') IS NOT NULL DROP TABLE #TempCost;

IF not EXISTS (SELECT * FROM dbo.Cost WHERE IdProduct =@TypeProduct and ProductNumber =@ProductNumber) 
BEGIN

 -- si no existe insertar registro en tabla cost

	INSERT INTO [dbo].[Cost]
			   ([IdProduct]
			   ,[ProductNumber]
			   ,[IdTypeCharge]
			   ,[TotalAmount]
			   ,[PaymentDate]
			   ,[IdModule]
			   ,[RowStatus]
			   ,[TokenCreated]
			   ,[DateCreated]
			   ,[TotalAmountPaid]
			   ,[CODAmount])
		 VALUES
			   (@TypeProduct
			   ,@ProductNumber
			   ,@TypeCharge
			   ,@FullPayment
			   ,GETDATE()
			   ,NULL
			   ,1
			   ,@Token
			   ,GETDATE()
			   ,@FullPayment
			   ,@CODPayment)

	set @IdCost   = SCOPE_IDENTITY()  
   
END
ELSE
BEGIN

   SELECT c.IdCost, isnull(c.TotalAmountPaid,0) TotalAmountPaid, isnull(CODAmount ,0) CODAmount
   into #TempCost
   FROM dbo.Cost c
   WHERE c.IdProduct =@TypeProduct and c.ProductNumber =@ProductNumber

   set @IdCost = (Select top 1 IdCost from #TempCost)
   set @TotalAmountPaid = (Select top 1 TotalAmountPaid from #TempCost)
  -- set @CODPayment = (Select top 1 CODAmount from #TempCost)
END

If (@TotalAmountPaid =0) -- El producto no esta pagado
	begin

		UPDATE [dbo].[Cost]
		   SET 
			  [PaymentDate] = GETDATE()
			  ,[TokenUpdated] = @Token
			  ,[DateUpdated] = GETDATE()
			  ,[TotalAmountPaid] = @FullPayment
			  ,[CODAmount] = @CODPayment
		 WHERE IdCost = @IdCost

		 INSERT INTO [dbo].[CostDetail]
           ([IdCost]
           ,[IdTypeOfMoney]
           ,[Amount]
           ,[Voucher]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
		   ,[Responsible])
		select 
			@IdCost
			,det.IdTypeOfMoney
			,det.Amount
			,IIF(det.IdTypeOfMoney = 6, det.Voucher,'')
			,1 -- crear registro activo por default
			,@Token
			,getdate()
			,det.Responsible
		from @TblDetail det

	end
END



