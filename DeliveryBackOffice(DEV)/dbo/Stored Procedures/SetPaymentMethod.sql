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
	@Token NVARCHAR(50),
	@Holder NVARCHAR(50),
	@FirstName NVARCHAR(50)= NULL,
	@LastName NVARCHAR(50)= NULL,
	@Nirphone NVARCHAR(5)= NULL,
	@Address NVARCHAR(150)= NULL,
	@Phone NVARCHAR(15)= NULL,
	@IsoCode NVARCHAR(3)= NULL,
	@PaymentGateway NVARCHAR(25)= NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION

		IF NOT EXISTS (SELECT 1 FROM CustomerPaymentValue WITH(NOLOCK) WHERE CustomerId = @CustomerId AND TokenizedToken = @TokenizedToken AND RowStatus = 1)
		BEGIN
			DECLARE @IsDefault BIT = ISNULL((SELECT TOP 1 0 FROM CustomerPaymentValue WITH(NOLOCK) WHERE CustomerId = @CustomerId AND RowStatus = 1), 1)
		

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
			, [DateUpdated]
			, [Holder]
			, [FirstName]
			, [LastName]
			, [Nirphone]
			, [Address]
			, [Phone]
			, [IsoCode]
			, [PaymentGateway]
			)
				VALUES (@AccountId, @CustomerId, @VisitPointId, @TokenizedToken, @TokenizedExpirationDate, @TokenizedCVV, @DisplayText, @IsDefault, @Type, 1, @Token, GETDATE(), NULL, NULL,@Holder, @FirstName,	@LastName,	@Nirphone,	@Address,	@Phone,	@IsoCode,	@PaymentGateway)
			
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