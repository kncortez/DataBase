
-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-08-19>
-- Description:	<Elimina y anula un producto del carrito de compra>
-- =============================================
CREATE PROCEDURE [dbo].[RemoveProductFromServiceCartMarketPlace]
	-- Add the parameters for the stored procedure here
	@IdAccount BIGINT,
	@IdPrtoduct INT,
	@Token NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION

	BEGIN TRY

		DECLARE @AccountServiceCartId AS INT;			-- AccountServiceCart
		DECLARE @AccountServicecartDetailId AS INT		-- AccountServiceCartDetail
	
		DECLARE @TR_ID AS INT;							-- MembershipSubscriptionLog
		


		SELECT TOP 1 @AccountServiceCartId = IdAccountServiceCart
		FROM		[dbo].[AccountServiceCart] ACSC
		WHERE		[ACSC].[AccountId] = @IdAccount
			AND		[ACSC].[IsPending] = 1
			AND		[ACSC].[RowStatus] = 1
		ORDER BY	[ACSC].[DateCreated] DESC;

		IF @AccountServiceCartId IS NOT NULL
			BEGIN
				--Desactivar otros carritos
				UPDATE	[dbo].[AccountServiceCart]
				SET		[IsPending] = 0,
						[RowStatus] = 0
				WHERE	[IsPending] = 1
					AND [RowStatus] = 1
					AND [IdAccountServiceCart] <> @AccountServiceCartId
					AND [AccountId] = @IdAccount;

				SELECT	@AccountServicecartDetailId = IdMarketplaceCartDetail
				FROM	[dbo].[MarketplaceCartDetail] ASCD
				WHERE	[ASCD].[MarketplaceCartId] = @AccountServiceCartId
					AND [ASCD].[RowStatus] = 1;

			
			END
		ELSE
			BEGIN
				SELECT 2 'StatusCode' ,'Service Cart not found' 'Description';
			END
	
		IF (@@TRANCOUNT > 0)
			COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
		
		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,ERROR_NUMBER() 'ErrorNumber'
		   ,ERROR_SEVERITY() 'ErrorSeverity'
		   ,ERROR_STATE() 'ErrorState'
		   ,ERROR_PROCEDURE() 'ErrorProcedure'
		   ,ERROR_LINE() 'ErrorLine';
				
		ROLLBACK TRANSACTION;
	END CATCH
END