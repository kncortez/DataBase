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
	SET ARITHABORT ON;

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
			   ,TokenUpdated = @Token
			   ,DateUpdated = GETDATE()
			WHERE IsPending = 1
			AND RowStatus = 1
			AND IdAccountServiceCart <> @AccountServiceCartId
			AND AccountId = @IdAccount

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

			--Eliminar guías pagadas
			DECLARE @PaidCartGuides AS TABLE(
				GuideSerie NVARCHAR(2),
				GuideNumber INT,
				TotalAmountPaid DECIMAL(18,2)
			);
			DECLARE @PaidGuides AS TABLE(
				GuideSerie NVARCHAR(2),
				GuideNumber INT
			);

			INSERT INTO @PaidCartGuides
				(GuideSerie, GuideNumber, TotalAmountPaid)
			SELECT
				ascd.GuideSerie, ascd.GuideNumber, co.TotalAmountPaid
			FROM DeliveryBackOffice.dbo.AccountServiceCartDetail ascd with (nolock)
			LEFT JOIN DeliveryBackOffice.dbo.Cost Co with (nolock)
				ON 
					(
						(
							Co.GuideSerie = ascd.GuideSerie
							AND
							Co.GuideNumber = ascd.GuideNumber
						)
					)
			WHERE ascd.AccountServiceCartId = @AccountServiceCartId
			AND ISNULL(co.TotalAmountPaid,0) > 0
			AND ascd.RowStatus = 1;
			
			UPDATE ascd
			SET ascd.RowStatus = 0
			   ,ascd.TokenUpdated = @Token
			   ,ascd.DateUpdated = GETDATE()
			OUTPUT inserted.GuideSerie, inserted.GuideNumber INTO @PaidGuides(GuideSerie, GuideNumber)
			FROM DeliveryBackOffice.dbo.AccountServiceCartDetail ascd with (nolock)
			INNER JOIN @PaidCartGuides PCG
				ON 
					ascd.GuideSerie = PCG.GuideSerie
					AND
					ascd.GuideNumber = PCG.GuideNumber
			
			-- Actualizar guías validas que fueron procesadas
			UPDATE DOPD
			SET ShipmentCompleted = 1
			FROM 
			DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD WITH(NOLOCK)
			INNER JOIN @PaidGuides PG
				ON PG.GuideSerie = DOPD.GuideSerie
				AND PG.GuideNumber = DOPD.GuideNumber
				
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
					,ISNULL(CAST(do.DCBA_ID AS NVARCHAR), '') 'DCBA_ID'
					,ISNULL(CAST(do.InsuranceAmount AS NVARCHAR),'') InsuranceAmount
					,(CASE WHEN ISNULL(MSL.IdMembershipSubscriptionLog, 0) > 0 THEN 'true' ELSE 'false' END) UsedMembership
				FROM AccountServiceCartDetail ascd
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON do.Guide_Serie = ascd.GuideSerie
					AND do.Guide_Number = ascd.GuideNumber
				LEFT JOIN DeliveryBackOffice.dbo.MembershipSubscriptionLog MSL WITH(NOLOCK)
					ON ascd.GuideSerie = MSL.LogGuideSerie
					AND ascd.GuideNumber = MSL.LogGuideNumber
					AND MSL.RowStatus = 1
				WHERE ascd.AccountServiceCartId = @AccountServiceCartId
				AND ascd.RowStatus = 1
				
				SELECT
					ascd.GuideSerie GuideSerie
				   ,ascd.GuideNumber GuideNumber
				   ,bop.[Description] [Description]
				   ,bop.Amount Amount
				FROM AccountServiceCartDetail ascd
				INNER JOIN Cost c WITH (NOLOCK)
					ON CONCAT(ascd.GuideSerie, ascd.GuideNumber) = c.ProductNumber
						AND c.RowStatus = 1
				INNER JOIN BreakdownOfPayment bop WITH (NOLOCK)
					ON c.IdCost = bop.IdCost
						AND bop.RowStatus = 1
						AND bop.Amount <> 0
				WHERE ascd.AccountServiceCartId = @AccountServiceCartId
				AND ascd.RowStatus = 1
				ORDER BY bop.IdBreakdownOfPayment
				
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