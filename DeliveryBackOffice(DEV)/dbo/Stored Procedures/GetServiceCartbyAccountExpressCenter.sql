-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-05-25>
-- Description:	<Obtiene información del carrito de compras express center>
-- =============================================
CREATE PROCEDURE [dbo].[GetServiceCartbyAccountExpressCenter]
	-- Add the parameters for the stored procedure here
	@IdAccount BIGINT,
	@Token NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;

	DECLARE @IndividualCustomerType INT = 
	(
		SELECT 
			TOP (1)
				[CT].[IdCustomerType]
		FROM
			[DeliveryBackOffice].[dbo].[CustomerType] CT  WITH(NOLOCK) 
		WHERE
			[CT].[Description] = 'INDIVIDUAL'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @CorporateCustomerType INT = 
	(
		SELECT 
			TOP (1)
				[CT].[IdCustomerType]
		FROM
			[DeliveryBackOffice].[dbo].[CustomerType] CT  WITH(NOLOCK) 
		WHERE
			[CT].[Description] = 'CORPORATIVO'  COLLATE Latin1_General_CI_AI 
	)

	DECLARE @IndividualAccountType INT =
	(
		SELECT 
			TOP (1)
				CTA.[TacIdTypeAccount]
		FROM
			[DeliveryBackOffice].[dbo].[CatTypeAccount] CTA  WITH(NOLOCK) 
		WHERE
			[CTA].[TacShortName] = 'IND'  COLLATE Latin1_General_CI_AI 
	)

	BEGIN TRANSACTION

	BEGIN TRY

		DECLARE @ExpressAccountServiceCartId INT

		SELECT TOP 1
			@ExpressAccountServiceCartId = IdExpressAccountServiceCart
		FROM ExpressAccountServiceCart
		WHERE AccountId = @IdAccount
		AND IsPending = 1
		AND RowStatus = 1
		ORDER BY DateCreated DESC

		IF @ExpressAccountServiceCartId IS NOT NULL
		BEGIN
			
			--Desactivar otros carritos
			UPDATE ExpressAccountServiceCart
			SET IsPending = 0
			   ,RowStatus = 0
			   ,TokenUpdated = @Token
			   ,DateUpdated = GETDATE()
			WHERE IsPending = 1
			AND RowStatus = 1
			AND IdExpressAccountServiceCart <> @ExpressAccountServiceCartId
			AND AccountId = @IdAccount

			--Eliminar guías anuladas
			UPDATE eascd
			SET eascd.RowStatus = 0
			   ,eascd.TokenUpdated = @Token
			   ,eascd.DateUpdated = GETDATE()
			FROM ExpressAccountServiceCartDetail eascd
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON do.Guide_Serie = eascd.GuideSerie
				AND do.Guide_Number = eascd.GuideNumber
			INNER JOIN StatusOrder so
				ON so.StatusOrderId = do.StatusOrderId
			WHERE eascd.ExpressAccountServiceCartId = @ExpressAccountServiceCartId
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
				eascd.GuideSerie, eascd.GuideNumber, co.TotalAmountPaid
			FROM DeliveryBackOffice.dbo.ExpressAccountServiceCartDetail eascd with (nolock)
			LEFT JOIN DeliveryBackOffice.dbo.Cost Co with (nolock)
				ON 
					(
						(
							Co.GuideSerie = eascd.GuideSerie
							AND
							Co.GuideNumber = eascd.GuideNumber
						)
					)
			WHERE eascd.ExpressAccountServiceCartId = @ExpressAccountServiceCartId
			AND ISNULL(co.TotalAmountPaid,0) > 0
			AND eascd.RowStatus = 1;
			
			UPDATE eascd
			SET eascd.RowStatus = 0
			   ,eascd.TokenUpdated = @Token
			   ,eascd.DateUpdated = GETDATE()
			OUTPUT inserted.GuideSerie, inserted.GuideNumber INTO @PaidGuides(GuideSerie, GuideNumber)
			FROM DeliveryBackOffice.dbo.ExpressAccountServiceCartDetail eascd with (nolock)
			INNER JOIN @PaidCartGuides PCG
				ON 
					eascd.GuideSerie = PCG.GuideSerie
					AND
					eascd.GuideNumber = PCG.GuideNumber
			
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
				FROM ExpressAccountServiceCartDetail
				WHERE ExpressAccountServiceCartId = @ExpressAccountServiceCartId
				AND RowStatus = 1)
			BEGIN
				
				SELECT
					1 'StatusCode'
				   ,'Records found' 'Description'
				
				SELECT
					eascd.IdExpressAccountServiceCartDetail
					,eascd.GuideSerie
					,eascd.GuideNumber
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
				FROM ExpressAccountServiceCartDetail eascd
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON do.Guide_Serie = eascd.GuideSerie
					AND do.Guide_Number = eascd.GuideNumber
				LEFT JOIN DeliveryBackOffice.dbo.MembershipSubscriptionLog MSL WITH(NOLOCK)
					ON eascd.GuideSerie = MSL.LogGuideSerie
					AND eascd.GuideNumber = MSL.LogGuideNumber
					AND MSL.RowStatus = 1
				WHERE eascd.ExpressAccountServiceCartId = @ExpressAccountServiceCartId
				AND eascd.RowStatus = 1
				
				SELECT
					eascd.GuideSerie GuideSerie
				   ,eascd.GuideNumber GuideNumber
				   ,bop.[Description] [Description]
				   ,bop.Amount Amount
				FROM ExpressAccountServiceCartDetail eascd
				INNER JOIN Cost c WITH (NOLOCK)
					ON CONCAT(eascd.GuideSerie, eascd.GuideNumber) = c.ProductNumber
						AND c.RowStatus = 1
				INNER JOIN BreakdownOfPayment bop WITH (NOLOCK)
					ON c.IdCost = bop.IdCost
						AND bop.RowStatus = 1
						AND bop.Amount <> 0
				WHERE eascd.ExpressAccountServiceCartId = @ExpressAccountServiceCartId
				AND eascd.RowStatus = 1
				ORDER BY bop.IdBreakdownOfPayment

				SELECT 
					CAST((CASE WHEN [EASC].[CustomerId] IS NOT NULL THEN 1 ELSE 0 END) AS BIT) [IsImpersonated],
					[EASC].[CustomerId],
					[EASC].[CustomerPortfolioId],
					(
						CASE
							WHEN [Cu].[IdCustomerType] = @IndividualCustomerType THEN 'IND'
							WHEN [Cu].[IdCustomerType] = @CorporateCustomerType THEN 'COR'
							ELSE 'EXC'
						END
					) [ClientType],
					[Acc].[AccIdAccount] [AccountId]
				FROM
					[DeliveryBackOffice].[dbo].[ExpressAccountServiceCart] EASC  WITH(NOLOCK) 
					LEFT JOIN
						[DeliveryBackOffice].[dbo].[Customer] Cu  WITH(NOLOCK) 
						ON
							[EASC].[CustomerId] = [Cu].[IdCustomer]
					OUTER APPLY
					(
						SELECT 
							TOP (1) 
								[Acc].[AccIdAccount] 
						FROM 
							[DeliveryBackOffice].[dbo].[Account] Acc  WITH(NOLOCK) 
						WHERE
							[Acc].[IdCustomer] = [Cu].[IdCustomer]
							AND
							[Acc].[AccIdTypeAccount] = @IndividualAccountType
					) [Acc]
				WHERE
					[EASC].[IdExpressAccountServiceCart] = @ExpressAccountServiceCartId
					AND
					[EASC].[RowStatus] = 1;

			END
			ELSE
			BEGIN 
				
				--Deshabilitar carrito sin servicios
				UPDATE ExpressAccountServiceCart
				SET IsPending = 0
				   ,RowStatus = 0
				   ,TokenUpdated = @Token
				   ,DateUpdated = GETDATE()
				WHERE IdExpressAccountServiceCart = @ExpressAccountServiceCartId

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