-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2022-07-08>
-- Description:	<Almacena una tarjeta de crédito/débito asociada a un cliente>
-- =============================================
CREATE PROCEDURE [dbo].[SetPaymentMethod] 
	-- Add the parameters for the stored procedure here
	@AccountId BIGINT,
	@CustomerId INT,
	@VisitPointId INT,
	@TokenizedToken NVARCHAR(100),
	@TokenizedExpirationDate NVARCHAR(50),
	@TokenizedCVV NVARCHAR(50),
	@DisplayText NVARCHAR(25),
	@Type NVARCHAR(2),
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION

		IF NOT EXISTS (SELECT 1 FROM CustomerPaymentValue WHERE CustomerId = @CustomerId AND TokenizedToken = @TokenizedToken AND RowStatus = 1)
		BEGIN
			DECLARE @IsDefault BIT = ISNULL((SELECT TOP 1 0 FROM CustomerPaymentValue WHERE CustomerId = @CustomerId AND RowStatus = 1), 1)
		

			INSERT INTO [dbo].[CustomerPaymentValue] ([AccountId]
			, [CustomerId]
			, [VisitPointId]
			, [TokenizedToken]
			, [TokenizedExpirationDate]
			, [TokenizedCVV]
			, [DisplayText]
			, [IsDefault]
			, [Type]
			, [RowStatus]
			, [TokenCreated]
			, [DateCreated]
			, [TokenUpdated]
			, [DateUpdated])
				VALUES (@AccountId, @CustomerId, @VisitPointId, @TokenizedToken, @TokenizedExpirationDate, @TokenizedCVV, @DisplayText, @IsDefault, @Type, 1, @Token, GETDATE(), NULL, NULL)
			
			COMMIT TRANSACTION

			SELECT
				1 [blnResult]
				,'Registro guardado correctamente.' [Description]
				,SCOPE_IDENTITY() [NumTransferID]
			
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION;
			SELECT
				-1 [blnResult]
				,'Ya existe registro.' [Description]
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