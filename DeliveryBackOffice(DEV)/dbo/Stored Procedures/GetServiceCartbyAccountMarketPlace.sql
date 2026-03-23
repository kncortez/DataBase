

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
-- =============================================
-- Author:		<Edelman>
-- Create date: <2024-08-07>
-- Description:	<Agregar país para obtener carrito de compra>
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2026-03-02>
-- Description:	<Se agregan campos IdCatTypeSubscription, CatTypeSubscriptionName y CatProductUsualPrice>
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2026-03-03>
-- Description:	<Se agregan campos StartDate y EndDate, y RTRIM a CatTypeSubscriptionName>
-- =============================================
CREATE PROCEDURE [dbo].[GetServiceCartbyAccountMarketPlace]
	@IdAccount BIGINT,
	@Token NVARCHAR(50),
	@IdCountry NVARCHAR(3),
	@IsUserTeleMarketing BIT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;

	BEGIN TRANSACTION

	BEGIN TRY

		DECLARE @AccountServiceCartId INT = NULL;

		IF(@IsUserTeleMarketing=0)
		BEGIN
				SELECT TOP 1
					@AccountServiceCartId = [IdMarketplaceCart]
				FROM [dbo].[MarketplaceCart]
				WHERE ISNULL(AccountId,0) = @IdAccount
				AND RowStatus = 1
				AND IdCountry = @IdCountry 
				ORDER BY DateCreated DESC
		END
		  ELSE
		      BEGIN

			  SELECT TOP 1
					@AccountServiceCartId = [IdMarketplaceCart]
				FROM [dbo].[MarketplaceCart]
				WHERE ISNULL(RegisterUserId,0) = @IdAccount
				AND RowStatus = 1
				AND IdCountry = @IdCountry 
				ORDER BY DateCreated DESC

			  END

		IF (@AccountServiceCartId IS NOT NULL OR @AccountServiceCartId != '')
		BEGIN
			
		
            IF(@IsUserTeleMarketing=0)
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
					   IIF(cp.SubscriptionValidity = 1, CONVERT(Varchar,cp.SubscriptionValidity)+' mes', CONVERT(Varchar,cp.SubscriptionValidity)+' meses') [ExpirationProduct],
					   ISNULL(cts.IdCatTypeSubscription, 1) [IdCatTypeSubscription],
					   ISNULL(RTRIM(cts.CatTypeSubscriptionName), N'Membresía') [CatTypeSubscriptionName],
					   cp.SubscriptionUsualPrice [CatProductUsualPrice],
					   cp.StartDate,
					   cp.EndDate
				FROM [dbo].[MarketplaceCartDetail] mpcm WITH (NOLOCK)
				INNER JOIN [dbo].[MarketplaceCart] mpc WITH (NOLOCK)
				ON mpcm.MarketplaceCartId = mpc.IdMarketplaceCart
				AND mpcm.TypeProduct <> 'Club Forza'
				INNER JOIN dbo.CatSubscription cp WITH (NOLOCK)
				ON mpcm.CatProductId = cp.IdCatSubscription
				LEFT JOIN dbo.CatTypeSubscription cts WITH (NOLOCK)
				ON cp.CatTypeSubscriptionId = cts.IdCatTypeSubscription
				WHERE ISNULL(mpc.AccountId,0) = @IdAccount
				AND mpc.RowStatus = 1
				AND mpcm.RowStatus=1
				AND mpc.IdCountry = @IdCountry 
				
				UNION ALL
				SELECT
				       mpcm.CatProductId,
					   cp.MembershipName [CatProductName],
					   cp.MembershipDescription  [CatProductDescription],
					   cp.MembershipCost [CatProductCost],
					   CASE WHEN ISNULL(cp.IdCountry,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END AS CurrencySymbol,
					   mpcm.IdMarketplaceCartDetail,
					   cp.MembershipFixedValue   [CatProductDiscountValue],
					   IIF(cp.MembershipValidity = 1, CONVERT(Varchar,cp.MembershipValidity)+' mes', CONVERT(Varchar,cp.MembershipValidity)+' meses') [ExpirationProduct],
					   1 [IdCatTypeSubscription],
					   N'Membresía' [CatTypeSubscriptionName],
					   cp.MembershipUsualPrice [CatProductUsualPrice],
					   cp.StartDate,
					   cp.EndDate
				FROM [dbo].[MarketplaceCartDetail] mpcm WITH (NOLOCK)
				INNER JOIN [dbo].[MarketplaceCart] mpc WITH (NOLOCK)
				ON mpcm.MarketplaceCartId = mpc.IdMarketplaceCart
				INNER JOIN dbo.CatMembership cp WITH (NOLOCK)
				ON mpcm.CatProductId = cp.IdCatMembership
				AND mpcm.TypeProduct = cp.MembershipName
				WHERE ISNULL(mpc.AccountId,0) = @IdAccount
				AND mpc.RowStatus = 1
				AND mpcm.RowStatus=1
				AND mpc.IdCountry = @IdCountry 
			
			
			
				
				
			END
			ELSE
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
					   IIF(cp.SubscriptionValidity = 1, CONVERT(Varchar,cp.SubscriptionValidity)+' mes', CONVERT(Varchar,cp.SubscriptionValidity)+' meses') [ExpirationProduct],
					   ISNULL(cts.IdCatTypeSubscription, 1) [IdCatTypeSubscription],
					   ISNULL(RTRIM(cts.CatTypeSubscriptionName), N'Membresía') [CatTypeSubscriptionName],
					   cp.SubscriptionUsualPrice [CatProductUsualPrice],
					   cp.StartDate,
					   cp.EndDate
				FROM [dbo].[MarketplaceCartDetail] mpcm with (nolock)
				INNER JOIN [dbo].[MarketplaceCart] mpc with (nolock)
				ON mpcm.MarketplaceCartId = mpc.IdMarketplaceCart
				AND mpcm.TypeProduct <> 'Club Forza'
				INNER JOIN dbo.CatSubscription cp with (nolock)
				on mpcm.CatProductId = cp.IdCatSubscription
				LEFT JOIN dbo.CatTypeSubscription cts with (nolock)
				on cp.CatTypeSubscriptionId = cts.IdCatTypeSubscription
				WHERE  ISNULL(mpc.RegisterUserId,0) = @IdAccount
				AND mpc.RowStatus = 1
				AND mpcm.RowStatus=1
				AND mpc.IdCountry = @IdCountry 
				
				UNION ALL
				SELECT
				       mpcm.CatProductId,
					   cp.MembershipName [CatProductName],
					   cp.MembershipDescription  [CatProductDescription],
					   cp.MembershipCost [CatProductCost],
					   CASE WHEN ISNULL(cp.IdCountry,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END AS CurrencySymbol,
					   mpcm.IdMarketplaceCartDetail,
					   cp.MembershipFixedValue   [CatProductDiscountValue],
					   IIF(cp.MembershipValidity = 1, CONVERT(Varchar,cp.MembershipValidity)+' mes', CONVERT(Varchar,cp.MembershipValidity)+' meses') [ExpirationProduct],
					   1 [IdCatTypeSubscription],
					   N'Membresía' [CatTypeSubscriptionName],
					   cp.MembershipUsualPrice [CatProductUsualPrice],
					   cp.StartDate,
					   cp.EndDate
				FROM [dbo].[MarketplaceCartDetail] mpcm with (nolock)
				INNER JOIN [dbo].[MarketplaceCart] mpc with (nolock)
				ON mpcm.MarketplaceCartId = mpc.IdMarketplaceCart
				INNER JOIN dbo.CatMembership cp with (nolock)
				on mpcm.CatProductId = cp.IdCatMembership
				 AND mpcm.TypeProduct = cp.MembershipName
				WHERE  ISNULL(mpc.RegisterUserId,0) = @IdAccount
				AND mpc.RowStatus = 1
				AND mpcm.RowStatus=1
				AND mpc.IdCountry = @IdCountry 

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
