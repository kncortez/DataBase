-- =============================================
-- Author:		<Edelman>
-- Create date: <2023-12-6>
-- Description:	<Obtener datos de pago de cliente logueado>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerPaymentDataMarketPlace]
	-- Add the parameters for the stored procedure here
	@PaymentId INT,
	@AccountId INT
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @CustomerId INT = 0;

	SELECT
		TOP 1 
		   @CustomerId = Cu.IdCustomer
	FROM 
		[DeliveryBackOffice].[dbo].[Account] AC WITH (NOLOCK) 
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Customer] Cu WITH (NOLOCK) 
			ON 
				AC.IdCustomer = Cu.IdCustomer 
				AND 
				ISNULL(Cu.RowSatus,1) = 1
	WHERE 
		AC.AccIdAccount = @AccountId
		AND 
		AC.AccRowStatus = 1;

	SELECT
		CPV.TokenizedToken
		,CPV.TokenizedExpirationDate
		,CPV.TokenizedCVV
		,CPV.[Type]
	FROM
		[DeliveryBackOffice].[dbo].[CustomerPaymentValue] CPV WITH(NOLOCK)
	WHERE
		CPV.IdCustomerPaymentValue = @PaymentId
		AND
		 ISNULL(CPV.AccountId,0) = @AccountId
		AND
		CPV.CustomerId = @CustomerId
		AND
		CPV.RowStatus = 1

END