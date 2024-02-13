
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-12-01>
-- Description:	<Description,remove products from the marketplace cart>
-- =============================================
CREATE PROCEDURE [dbo].[RemoveProductsfromtheMarketplaceCart] 
	@IdAccount BIGINT,
	@IdMarketplaceCart INT,
	@Token NVARCHAR(50)
AS
BEGIN

  DECLARE @IdCart INT =(Select Top 1 MarketplaceCartId From [dbo].[MarketplaceCartDetail] a  WHERE  a.IdMarketplaceCartDetail = @IdMarketplaceCart)
	
	BEGIN TRAN
	BEGIN TRY

	

	  UPDATE  [dbo].[MarketplaceCartDetail]
	  SET RowStatus = 0,
	      TokenUpdated = @Token,
	      DateUpdated  = GETDATE()
	  WHERE  IdMarketplaceCartDetail = @IdMarketplaceCart

	  --  UPDATE  [dbo].[MarketplaceCart]
	  --SET RowStatus = 0,
	  --    TokenUpdated = @Token,
	  --    DateUpdated  = GETDATE()
	  --WHERE  AccountId = @IdAccount AND IdMarketplaceCart = @IdCart

	

	COMMIT TRAN

	 SELECT 200 [IdResult],
                   'Producto removido exitosamente' [Message];


	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		 SELECT 500 [IdResult],
                  ERROR_MESSAGE() +' ' +'error en proceso' [Message];
	END CATCH
END