-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-16>
-- Description:	<Obtiene información del carrito de compras>
-- =============================================
CREATE PROCEDURE [dbo].[GetServiceCartbyAccount]
	-- Add the parameters for the stored procedure here
	@IdAccount BIGINT,
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


			--Eliminar guías anuladas
			UPDATE ascd
			SET ascd.RowStatus = 0
			   ,ascd.TokenUpdated = @Token
			   ,ascd.DateUpdated = GETDATE()
			FROM AccountServiceCartDetail ascd
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON do.Guide_Serie = ascd.GuideSerie
				AND do.Guide_Number = ascd.GuideNumber
			INNER JOIN StatusOrder so
				ON so.StatusOrderId = do.StatusOrderId
			WHERE ascd.AccountServiceCartId = @AccountServiceCartId
			AND so.OrderDescription = 'Anulado'
			
			IF EXISTS (SELECT TOP 1
					1
				FROM AccountServiceCartDetail
				WHERE AccountServiceCartId = @AccountServiceCartId
				AND RowStatus = 1)
			BEGIN
				
				SELECT
					1 'StatusCode'
				   ,'Records found' 'Description'
				
				SELECT
					ascd.IdAccountServiceCartDetail
					,ascd.GuideSerie
					,ascd.GuideNumber
					,do.Pieces_Dry
					,do.Pieces_Cold
					,do.PriceShippment
					,do.Sender_ID
					,CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) ReceiverName
					,do.Receiver_Address
					,do.IsCollect
					,do.Collect_OnDelivery
				FROM AccountServiceCartDetail ascd
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON do.Guide_Serie = ascd.GuideSerie
					AND do.Guide_Number = ascd.GuideNumber
				WHERE ascd.AccountServiceCartId = @AccountServiceCartId
				AND ascd.RowStatus = 1
			END
			ELSE
			BEGIN 
				
				--Deshabilitar carrito sin servicios
				UPDATE AccountServiceCart
				SET IsPending = 0
				   ,RowStatus = 0
				   ,TokenUpdated = @Token
				   ,DateUpdated = GETDATE()
				WHERE IdAccountServiceCart = @AccountServiceCartId

				SELECT
					2 'StatusCode'
				   ,'Service Cart not found' 'Description'
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