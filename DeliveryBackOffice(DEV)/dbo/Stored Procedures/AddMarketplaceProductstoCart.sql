

-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023->
-- Description:	<Description,Método para agregar productos marketplace al carrito>
-- =============================================
CREATE PROCEDURE [dbo].[AddMarketplaceProductstoCart]
    @IdAccount BIGINT,
	@Token NVARCHAR(50),
	@TblProductsList [TblSalePackageMarketPlace]  READONLY,
	@IdCountry NVARCHAR(3)='GT',
	@IsUserTeleMarketing BIT = 0
AS
	
	DECLARE @MarketplaceCartId INT;
    DECLARE @IdCart INT=0;
	

BEGIN TRANSACTION
BEGIN TRY



  IF(@IsUserTeleMarketing=0) 
  BEGIN

   SET  @IdCart  =(Select Top 1 ISNULL(a.IdMarketplaceCart,0) From [dbo].[MarketplaceCart] a  WHERE  ISNULL(a.AccountId,0) = @IdAccount 
                                                                          AND a.RowStatus=1 AND ISNULL(a.IdCountry,'GT') = @IdCountry  ORDER BY a.DateCreated DESC);
   END
	   ELSE
	    BEGIN

	        SET  @IdCart  =(Select Top 1 ISNULL(a.IdMarketplaceCart,0) From [dbo].[MarketplaceCart] a  WHERE  ISNULL(a.RegisterUserId,0) = @IdAccount 
																			  AND a.RowStatus=1 AND ISNULL(a.IdCountry,'GT') = @IdCountry  ORDER BY a.DateCreated DESC);
	 END


IF(ISNULL(@IdCart,0) = 0  )
	BEGIN
	
			INSERT INTO [dbo].[MarketplaceCart](
			AccountId,
			RowStatus,
			TokenCreated,
			DateCreated,
			IdCountry
			)VALUES(
			 @IdAccount,
			 1,
			 @Token,
			 GETDATE(),
			 @IdCountry
			)

			SET @MarketplaceCartId = SCOPE_IDENTITY();
	

			INSERT INTO [dbo].[MarketplaceCartDetail]
			(   
				MarketplaceCartId,
				CatProductId,
				RowStatus,
				TokenCreated,
				DateCreated,
				TypeProduct
			)
			SELECT
	
			 @MarketplaceCartId,
			 TPL.IdSalePackage,
			 1,
			 @Token,
			 GETDATE(),
			  CASE 
			  WHEN CS.SubscriptionName IS NULL  THEN CS2.MembershipName
			  WHEN CS2.MembershipName IS NULL THEN CS.SubscriptionName
			  ELSE
			     'N/D'
			  END
			 FROM @TblProductsList TPL
			 LEFT JOIN [CatSubscription] CS WITH (NOLOCK)
			 ON TPL.IdSalePackage = CS.IdCatSubscription 
			 AND TPL.TypeSalePackage = CS.SubscriptionDescription --COLLATE Latin1_General_CI_AI
			 LEFT JOIN [CatMembership] CS2 WITH (NOLOCK)
			 ON TPL.IdSalePackage = CS2.IdCatMembership
			 AND TPL.TypeSalePackage = 'MEMBERSHIP' --COLLATE Latin1_General_CI_AI

			
		
	
			
  END 
      ELSE
	  BEGIN
	
		 INSERT INTO [dbo].[MarketplaceCartDetail]
			(   
				MarketplaceCartId,
				CatProductId,
				RowStatus,
				TokenCreated,
				DateCreated,
				TypeProduct
			)
			SELECT
	
			 @IdCart ,
			 TPL.IdSalePackage,
			 1,
			 @Token,
			 GETDATE(),
			 CASE 
			  WHEN CS.SubscriptionName IS NULL  THEN CS2.MembershipName
			  WHEN CS2.MembershipName IS NULL THEN CS.SubscriptionName
			  ELSE
			     'N/D'
			  END
			 FROM @TblProductsList TPL
			 LEFT JOIN [CatSubscription] CS WITH (NOLOCK)
			 ON TPL.IdSalePackage = CS.IdCatSubscription 
			 AND TPL.TypeSalePackage = CS.SubscriptionDescription --COLLATE Latin1_General_CI_AI
			 LEFT JOIN [CatMembership] CS2 WITH (NOLOCK)
			 ON TPL.IdSalePackage = CS2.IdCatMembership
			 AND TPL.TypeSalePackage = 'MEMBERSHIP' --COLLATE Latin1_General_CI_AI

			
		 END
  

	COMMIT TRANSACTION

	 SELECT 200 [IdResult],
                   'Producto agregado exitosamente' [Message];
END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
		
     SELECT 209 [IdResult],
                  'error en proceso' [Message],
				  ERROR_MESSAGE() AS [ErrorMessage];

END CATCH 

