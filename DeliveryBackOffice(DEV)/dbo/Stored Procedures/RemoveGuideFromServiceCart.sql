-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-19>
-- Description:	<Elimina y anula una guía del carrito de compra>
-- =============================================
CREATE PROCEDURE [dbo].[RemoveGuideFromServiceCart]
	-- Add the parameters for the stored procedure here
	@IdAccount BIGINT,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Token NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION

	BEGIN TRY

		DECLARE @AccountServiceCartId INT

		SELECT TOP 1
			@AccountServiceCartId = IdAccountServiceCart
		FROM AccountServiceCart
		WHERE AccountId = @IdAccount
		AND IsPending = 1
		AND RowStatus = 1
		ORDER BY DateCreated DESC

		IF @AccountServiceCartId IS NOT NULL
		BEGIN
			
			--Desactivar otros carritos
			UPDATE AccountServiceCart
			SET IsPending = 0
			   ,RowStatus = 0
			WHERE IsPending = 1
			AND RowStatus = 1
			AND IdAccountServiceCart <> @AccountServiceCartId


			DECLARE @AccountServicecartDetailId INT

			SELECT 
				@AccountServicecartDetailId = IdAccountServiceCartDetail
			FROM AccountServiceCartDetail 
			WHERE AccountServiceCartId = @AccountServiceCartId
				AND GuideSerie = @GuideSerie
				AND GuideNumber = @GuideNumber
				AND RowStatus = 1

			IF @AccountServicecartDetailId IS NOT NULL
			BEGIN
	
				IF NOT EXISTS (SELECT
						1
					FROM Cost WITH (NOLOCK)
					WHERE ProductNumber = CONCAT(@GuideSerie, @GuideNumber)
					AND TotalAmountPaid IS NOT NULL
					AND TotalAmountPaid > 0
					AND RowStatus = 1)
				BEGIN
					
					UPDATE DeliveryOrder
					SET StatusOrderId = (SELECT
								StatusOrderId
							FROM StatusOrder
							WHERE OrderDescription = 'Anulado')
					   ,TokenUpdated = TokenUpdated
					   ,DateUpdated = GETDATE()
					WHERE Guide_Serie = @GuideSerie
					AND Guide_Number = @GuideNumber

					INSERT INTO DeliveryOrderDetail (Guide_Serie,
					Guide_Number,
					StatusOrderId,
					UserCreated,
					DateCreated,
					DateCreatedInSystem,
					RowStatus)
						VALUES (@GuideSerie, @GuideNumber, (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Anulado'), @Token, GETDATE(), GETDATE(), 1)

					UPDATE AccountServiceCartDetail
					SET RowStatus = 0
					   ,TokenUpdated = @Token
					   ,DateUpdated = GETDATE()
					WHERE IdAccountServiceCartDetail = @AccountServicecartDetailId

					IF NOT EXISTS (SELECT TOP 1
							1
						FROM AccountServiceCartDetail
						WHERE AccountServiceCartId = @AccountServiceCartId
						AND RowStatus = 1)
					BEGIN
						--Deshabilitar carrito sin servicios
						UPDATE AccountServiceCart
						SET IsPending = 0
						   ,RowStatus = 0
						   ,TokenUpdated = @Token
						   ,DateUpdated = GETDATE()
						WHERE IdAccountServiceCart = @AccountServiceCartId
					END
					
					SELECT
						1 'StatusCode'
					   ,'Guide remove successfully' 'Description'
				END
				ELSE
				BEGIN
					SELECT
						4 'StatusCode'
					   ,'Guide is already paid' 'Description'
				END
			END
			ELSE
			BEGIN
				SELECT
					3 'StatusCode'
				   ,'Guide not found in Service Cart' 'Description'
			END
		END
		ELSE
		BEGIN
			SELECT
				2 'StatusCode'
			   ,'Service Cart not found' 'Description'
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