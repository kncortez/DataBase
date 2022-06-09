



-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Recotizacion>
-- =============================================


CREATE PROCEDURE [dbo].[SetPaymentTransaction]
	-- Add the parameters for the stored procedure here
	@ProductNumber  nvarchar(100),
	@Amount DECIMAL (18,2) = 15.00,
	@IdModule int = 1,
	@PaymentType INT = 2,
	@Voucher VARCHAR (200) = 'FSLDKFJ123KJLK31',
	@Token varchar (200) = '12324system'
	,@PaymentDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


		insert into dbo.Cost (IdProduct, ProductNumber, IdTypeCharge, TotalAmount, PaymentDate, IdModule, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
		values (2, @ProductNumber, 2, @Amount, @PaymentDate, @IdModule, 1, @Token,GETDATE(), null, null ) 

		declare @IdCost int = SCOPE_IDENTITY()  

		insert into dbo.CostDetail (IdCost, IdTypeOfMoney,Amount, Voucher, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
		values (@IdCost, @PaymentType, @Amount, @Voucher, 1, @Token, GETDATE(), null, null)
END



