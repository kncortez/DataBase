-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2022-07-11>
-- Description:	<Cambia la tarjeta de crédito/débito por defecto asociada a un cliente>
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePaymentMethod] 
	-- Add the parameters for the stored procedure here
	@CustomerId INT,
	@UpdateId INT,
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    BEGIN TRY
		BEGIN TRANSACTION
		
		IF EXISTS (SELECT
				1
			FROM CustomerPaymentValue
			WHERE IdCustomerPaymentValue = @UpdateId
			AND CustomerId = @CustomerId
			AND RowStatus = 1)
		BEGIN
			UPDATE CustomerPaymentValue
			SET IsDefault = 0
			   ,TokenUpdated = @Token
			   ,DateUpdated = GETDATE()
			WHERE CustomerId = @CustomerId
			AND RowStatus = 1

			UPDATE CustomerPaymentValue
			SET IsDefault = 1
			   ,TokenUpdated = @Token
			   ,DateUpdated = GETDATE()
			WHERE IdCustomerPaymentValue = @UpdateId

			COMMIT TRANSACTION;

			SELECT
				1 [blnResult]
			   ,'Registro modificado correctamente.' [Description]
			   ,@UpdateId [NumTransferID]
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION;

			SELECT
				-1 [blnResult]
			   ,'No existe registro o no pertenece al cliente.' [Description]
			   ,0 [NumTransferID]
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SELECT
			0 [blnResult]
			,ERROR_MESSAGE() [Description]
			,0 [NumTransferID]
			,ERROR_NUMBER() [ErrorNumber]
			,ERROR_SEVERITY() [ErrorSeverity]
			,ERROR_STATE() [ErrorState]
			,ERROR_PROCEDURE() [ErrorProcedure]
			,ERROR_LINE() [ErrorLine]
			,ERROR_MESSAGE() [ErrorMessage];
	END CATCH
END