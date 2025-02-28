-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-27-01>
-- Description:	<Método obtener el AccountId del pago de un beneficio>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_GetAccountTransaction]
@OrderNumber NVARCHAR(50)
AS
BEGIN
  	IF OBJECT_ID('tempdb.dbo.#Products', 'U') IS NOT NULL
        DROP TABLE #Products;

	SELECT  ISNULL(rtps.AccountId,0) AS [IdAccount],
			rtps.ProductGiftShippingEmail AS [EmailGift],
			IIF(rtps.TypeSalePackage LIKE '%MEMBERSHIP%','la Membresía Club Forza', 'el '+ rtps.TypeSalePackage) AS [ProductName]
    INTO #Products
    FROM dbo.CreditCardTransactionByCustomer cctc
	INNER JOIN dbo.RegistrationofTransactionProcessStates rtps ON rtps.OrderNumber = cctc.OrderNumber
	WHERE cctc.OrderNumber = @OrderNumber AND IdSalePackage != 0 AND cctc.ReasonCode = '00'

	UPDATE #Products
	SET 
		IdAccount = ISNULL(rua.RuaIdAccount,0)
	FROM #Products p
		INNER JOIN [dbo].[RegisterUser] us WITH (NOLOCK) ON us.UsrEmail = p.EmailGift
		INNER JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK) ON rua.RuaIdUser = us.UsrIdUser
	WHERE P.EmailGift IS NOT NULL;

	SELECT IdAccount, ProductName FROM #Products
END