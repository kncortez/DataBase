-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-17>
-- Description:	<Finaliza un carrito de compra>
-- =============================================
CREATE PROCEDURE [dbo].[FinishServiceCartbyAccount]
	-- Add the parameters for the stored procedure here
	@IdAccount BIGINT,
	@Token NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION

	BEGIN TRY

		UPDATE AccountServiceCart
		SET IsPending = 0
		WHERE AccountId = @IdAccount
		AND IsPending = 1
		AND RowStatus = 1

		IF (@@ROWCOUNT > 0)
		BEGIN
			SELECT
				1 'StatusCode'
				,'Service Cart finished successfully' 'Description'
		END
		ELSE
			SELECT
			2 'StatusCode'
		   ,'Service Cart not found' 'Description'
			
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