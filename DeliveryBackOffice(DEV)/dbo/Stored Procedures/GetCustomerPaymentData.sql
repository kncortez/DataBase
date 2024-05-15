-- =============================================
-- Author:		<Andrés,Ruiz>
-- Create date: <2022-07-21>
-- Description:	<Obtener datos de pago de cliente>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerPaymentData]
	-- Add the parameters for the stored procedure here
	@PaymentId INT,
	@AccountId INT
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @CustomerId INT = 0;
	DECLARE @Phone AS VARCHAR(10);
	DECLARE @Email AS NVARCHAR(50);

	SELECT TOP 1 @Email =  usr.UsrEmail, @Phone= usr.Phone    
			FROM dbo.RegisterUser usr WITH (NOLOCK)
                INNER JOIN dbo.Person per WITH (NOLOCK)
                    ON per.PerIdPerson = usr.UsrIdPerson
				INNER JOIN dbo.RolByUserByAccount RUB WITH (NOLOCK)
				    ON  usr.UsrIdUser  = RUB.RuaIdUser
            WHERE 
			RUB.RuaIdAccount= @AccountId

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
		,@Phone Phone
		,@Email Email
	FROM
		[DeliveryBackOffice].[dbo].[CustomerPaymentValue] CPV WITH(NOLOCK)
	WHERE
		CPV.IdCustomerPaymentValue = @PaymentId
		AND
		(CPV.AccountId IS NULL OR CPV.AccountId = @AccountId)
		AND
		CPV.CustomerId = @CustomerId
		AND
		CPV.RowStatus = 1

END