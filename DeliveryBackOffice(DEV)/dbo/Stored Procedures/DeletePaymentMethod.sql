-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2022-07-11>
-- Description:	<Da de baja a una tarjeta de crédito/débito asociada a un cliente>
-- =============================================
CREATE PROCEDURE [dbo].[DeletePaymentMethod] 
	-- Add the parameters for the stored procedure here
	@AccountId INT,
	@DeleteId INT,
	@DefaultId INT,
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
			WHERE IdCustomerPaymentValue = @DeleteId
			AND (AccountId = @AccountId
			OR CustomerId = (SELECT
					IdCustomer
				FROM Account
				WHERE AccIdAccount = @AccountId)
			)
			AND RowStatus = 1)
		AND (@DefaultId IS NULL OR EXISTS (SELECT
				1
			FROM CustomerPaymentValue
			WHERE IdCustomerPaymentValue = @DefaultId
			AND (AccountId = @AccountId
			OR CustomerId = (SELECT
					IdCustomer
				FROM Account
				WHERE AccIdAccount = @AccountId)
			)
			AND RowStatus = 1)
		)
		BEGIN
			IF (@DefaultId IS NOT NULL OR EXISTS (SELECT
					1
				FROM CustomerPaymentValue
				WHERE IdCustomerPaymentValue = @DeleteId
				AND IsDefault = 0)
			OR NOT EXISTS (SELECT TOP 1
					1
				FROM CustomerPaymentValue
				WHERE (AccountId = @AccountId
				OR CustomerId = (SELECT
						IdCustomer
					FROM Account
					WHERE AccIdAccount = @AccountId)
				)
				AND IdCustomerPaymentValue <> @DeleteId
				AND RowStatus = 1)
			)
			BEGIN
				
				IF (@DefaultId IS NOT NULL)
				BEGIN
					UPDATE CustomerPaymentValue
					SET IsDefault = 1
					   ,TokenUpdated = @Token
					   ,DateUpdated = GETDATE()
					WHERE IdCustomerPaymentValue = @DefaultId
				END

				UPDATE CustomerPaymentValue
				SET RowStatus = 0
				   ,TokenizedToken = 'DATA DELETED'
				   ,TokenizedExpirationDate = 'DATA DELETED'
				   ,IsDefault = 0
				   ,TokenUpdated = @Token
				   ,DateUpdated = GETDATE()
				WHERE IdCustomerPaymentValue = @DeleteId

				COMMIT TRANSACTION;

				SELECT
					1 [blnResult]
				   ,'Registro eliminado correctamente.' [Description]
				   ,@DeleteId [NumTransferID]

			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION;

				SELECT
					-2 [blnResult]
				   ,'No se puede eliminar registro por defecto.' [Description]
				   ,0 [NumTransferID]
				END
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