

-- =============================================
-- Author:		<Edelman>
-- Create date: <2023-08-31>
-- Description:	<Obtiene información del carrito de compras MarketPlace>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-08-05>
-- Description:	<Se agrega la moneda por pais en la consulta>
-- =============================================
CREATE PROCEDURE [dbo].[GetServiceCartbyAccountMarketPlace]
	@IdAccount BIGINT,
	@Token NVARCHAR(50),
	@IdCountry NVARCHAR(3)
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;

	BEGIN TRANSACTION

	BEGIN TRY

		DECLARE @AccountServiceCartId INT

		SELECT TOP 1
			@AccountServiceCartId = [IdMarketplaceCart]
		FROM [dbo].[MarketplaceCart]
		WHERE AccountId = @IdAccount
		AND RowStatus = 1
		AND ISNULL(IdCountry,'GT')=@IdCountry 
		ORDER BY DateCreated DESC

		IF @AccountServiceCartId IS NOT NULL
		BEGIN
			
		

	
				
			IF EXISTS (SELECT TOP 1
					1
				FROM MarketplaceCartDetail
				WHERE MarketplaceCartId = @AccountServiceCartId
				AND RowStatus = 1)
			BEGIN
				
				SELECT
					1 'StatusCode'
				   ,'Records found' 'Description'
				
				SELECT
				       mpcm.CatProductId,
					   cp.SubscriptionName [CatProductName],
					   cp.SubscriptionDescription  [CatProductDescription],
					   cp.SubscriptionCost [CatProductCost],
					   CASE WHEN ISNULL(cp.IdCountry,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END AS CurrencySymbol,
					   mpcm.IdMarketplaceCartDetail,
					   cp.SubscriptionFixedValue   [CatProductDiscountValue],
					   IIF(cp.SubscriptionValidity = 1, CONVERT(Varchar,cp.SubscriptionValidity)+' mes', CONVERT(Varchar,cp.SubscriptionValidity)+' meses') [ExpirationProduct]
				FROM [dbo].[MarketplaceCartDetail] mpcm
				INNER JOIN [dbo].[MarketplaceCart] mpc
				ON mpcm.MarketplaceCartId = mpc.IdMarketplaceCart
				AND mpcm.TypeProduct <> 'Club Forza'
				INNER JOIN dbo.CatSubscription cp with (nolock)
				on mpcm.CatProductId = cp.IdCatSubscription
				WHERE  mpc.AccountId = @IdAccount
				AND mpc.RowStatus = 1
				AND mpcm.RowStatus=1
				AND ISNULL(mpc.IdCountry,'GT')=@IdCountry 
				UNION ALL
				SELECT
				       mpcm.CatProductId,
					   cp.MembershipName [CatProductName],
					   cp.MembershipDescription  [CatProductDescription],
					   cp.MembershipCost [CatProductCost],
					   CASE WHEN ISNULL(cp.IdCountry,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END AS CurrencySymbol,
					   mpcm.IdMarketplaceCartDetail,
					   cp.MembershipFixedValue   [CatProductDiscountValue],
					   IIF(cp.MembershipValidity = 1, CONVERT(Varchar,cp.MembershipValidity)+' mes', CONVERT(Varchar,cp.MembershipValidity)+' meses') [ExpirationProduct]
				FROM [dbo].[MarketplaceCartDetail] mpcm
				INNER JOIN [dbo].[MarketplaceCart] mpc
				ON mpcm.MarketplaceCartId = mpc.IdMarketplaceCart
				INNER JOIN dbo.CatMembership cp with (nolock)
				on mpcm.CatProductId = cp.IdCatMembership
				 AND mpcm.TypeProduct = cp.MembershipName
				WHERE  mpc.AccountId = @IdAccount
				AND mpc.RowStatus = 1
				AND mpcm.RowStatus=1
				AND ISNULL(mpc.IdCountry,'GT')=@IdCountry 
				
			
				
				
			END
			
		END
		ELSE
		BEGIN
			SELECT
			2 [StatusCode]
		   ,'Service Cart not found' [Description]
		END
	
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
		
		SELECT
			0 [StatusCode]
		   ,ERROR_MESSAGE() [Description]
		   ,ERROR_NUMBER() [ErrorNumber]
		   ,ERROR_SEVERITY() [ErrorSeverity]
		   ,ERROR_STATE() [ErrorState]
		   ,ERROR_PROCEDURE() [ErrorProcedure]
		   ,ERROR_LINE() [ErrorLine];
				
		ROLLBACK TRANSACTION;
	END CATCH
END
