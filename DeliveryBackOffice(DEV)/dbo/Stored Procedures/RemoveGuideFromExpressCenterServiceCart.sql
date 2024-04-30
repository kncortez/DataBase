-- =============================================
-- Author:		<Andres Ruiz>
-- Create date: <2023-05-30>
-- Description:	<Elimina y anula una guía del carrito de compra de express center>
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[RemoveGuideFromExpressCenterServiceCart]
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

		DECLARE @ExpressAccountServiceCartId AS INT;			-- ExpressAccountServiceCart
		DECLARE @ExpressAccountServiceCartDetailId AS INT		-- ExpressAccountServiceCartDetail
		DECLARE @GEN_STATUS_ORDER_ID AS INT;			-- StatusOrder
		DECLARE @SOL_STATUS_ORDER_ID AS INT;			-- StatusOrder
		DECLARE @NULL_STATUS_ORDER_ID AS INT;			-- StatusOrder
		DECLARE @TR_ID AS INT;							-- MembershipSubscriptionLog
		DECLARE @ActualGuideStatus AS INT;
		DECLARE @CouponSerie AS NVARCHAR(20);			-- Cupon relacionado con guia

		SET @GEN_STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'Generado');

		SET @SOL_STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'Solicitado');

		SET @NULL_STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'Anulado');

		SELECT TOP 1 @ExpressAccountServiceCartId = IdExpressAccountServiceCart
		FROM		[dbo].[ExpressAccountServiceCart] ACSC
		WHERE		[ACSC].[AccountId] = @IdAccount
			AND		[ACSC].[IsPending] = 1
			AND		[ACSC].[RowStatus] = 1
		ORDER BY	[ACSC].[DateCreated] DESC;

		IF @ExpressAccountServiceCartId IS NOT NULL
			BEGIN
				--Desactivar otros carritos
				UPDATE	[dbo].[ExpressAccountServiceCart]
				SET		[IsPending] = 0,
						[RowStatus] = 0
				WHERE	[IsPending] = 1
					AND [RowStatus] = 1
					AND [IdExpressAccountServiceCart] <> @ExpressAccountServiceCartId
					AND [AccountId] = @IdAccount;

				SELECT	@ExpressAccountServiceCartDetailId = IdExpressAccountServiceCartDetail
				FROM	[dbo].[ExpressAccountServiceCartDetail] ASCD
				WHERE	[ASCD].[ExpressAccountServiceCartId] = @ExpressAccountServiceCartId
					AND [ASCD].[GuideSerie] = @GuideSerie
					AND [ASCD].[GuideNumber] = @GuideNumber
					AND [ASCD].[RowStatus] = 1;

				IF @ExpressAccountServiceCartDetailId IS NOT NULL
					BEGIN
	
						IF NOT EXISTS (SELECT 1
						FROM	[dbo].[Cost] C WITH (NOLOCK)
						WHERE   [C].[ProductNumber] = CONCAT(@GuideSerie, @GuideNumber)
							AND [C].[TotalAmountPaid] IS NOT NULL
							AND [C].[TotalAmountPaid] > 0
							AND [C].[RowStatus] = 1)
					
							BEGIN

								SELECT
									@ActualGuideStatus = DO.StatusOrderId
								FROM
									[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
								WHERE
									DO.Guide_Serie = @GuideSerie
									AND
									DO.Guide_Number = @GuideNumber

								IF (@ActualGuideStatus IN (@GEN_STATUS_ORDER_ID, @SOL_STATUS_ORDER_ID))

								BEGIN
					
									UPDATE	[dbo].[DeliveryOrder]
									SET		[StatusOrderId] = @NULL_STATUS_ORDER_ID,
											[TokenUpdated] = @Token,
											[DateUpdated] = GETDATE()
									WHERE	[Guide_Serie] = @GuideSerie
										AND [Guide_Number] = @GuideNumber;

									INSERT INTO [dbo].[DeliveryOrderDetail] 
												([Guide_Serie],
												[Guide_Number],
												[StatusOrderId],
												[UserCreated],
												[DateCreated],
												[DateCreatedInSystem],
												[RowStatus])
									VALUES		(@GuideSerie,
												@GuideNumber, 
												@NULL_STATUS_ORDER_ID, 
												@Token, 
												GETDATE(), 
												GETDATE(), 
												1);

									UPDATE	[dbo].[ExpressAccountServiceCartDetail]
									SET		[RowStatus] = 0,
											[TokenUpdated] = @Token,
											[DateUpdated] = GETDATE()
									WHERE	[IdExpressAccountServiceCartDetail] = @ExpressAccountServiceCartDetailId;

					-- *********************** INICIA ACTUALIZACIÓN ANULACION DE TRANSACCIONES EN CON MEMBRESÍA O SUSCRIPCIÓN *******************************************
									-- Obtener ID de suscripción con transacción asociada 
									SET @TR_ID = (SELECT [MSL].[SubscriptionId]
													FROM	[dbo].[MembershipSubscriptionLog] MSL
													WHERE	[MSL].[LogGuideSerie] = @GuideSerie
														AND [MSL].[LogGuideNumber] = @GuideNumber
														AND [MSL].[RowStatus] = 1
														AND [MSL].[SubscriptionId] IS NOT NULL );

									IF (@TR_ID > 0)
										BEGIN
											-- Descontar transacción de suscripción
											UPDATE	[dbo].[Subscription]
											SET		[ActualServiceCount] = [ActualServiceCount] - 1,
													[TokenUpdated] = @Token,
													[DateUpdated] = SYSDATETIME()
											WHERE	[IdSubscription] = @TR_ID;

											-- Anular transacción de suscripción o membresía asociada
											UPDATE	[dbo].[MembershipSubscriptionLog]
											SET		[RowStatus] = 0,
													[TokenUpdated] = @Token,
													[DateUpdated] = SYSDATETIME()
											WHERE	[LogGuideSerie] = @GuideSerie
												AND [LogGuideNumber] = @GuideNumber
												AND [RowStatus] = 1;
										END
									-- Obtener ID de membresía con transacción asociada
									SET @TR_ID = (SELECT [MSL].[MembershipId]
													FROM	[dbo].[MembershipSubscriptionLog] MSL
													WHERE	[MSL].[LogGuideSerie] = @GuideSerie
														AND [MSL].[LogGuideNumber] = @GuideNumber
														AND [MSL].[RowStatus] = 1
														AND [MSL].[SubscriptionId] IS NULL );

									IF (@TR_ID > 0)
										BEGIN
											-- Descontar transacción de memebresía
											UPDATE	[dbo].[Membership]
											SET		[ActualServiceCount] = [ActualServiceCount] - 1,
													[TokenUpdated] = @Token,
													[DateUpdated] = SYSDATETIME()
											WHERE	[IdMembership] = @TR_ID;

											-- Anular transacción de suscripción o membresía asociada
											UPDATE	[dbo].[MembershipSubscriptionLog]
											SET		[RowStatus] = 0,
													[TokenUpdated] = @Token,
													[DateUpdated] = SYSDATETIME()
											WHERE	[LogGuideSerie] = @GuideSerie
												AND [LogGuideNumber] = @GuideNumber
												AND [RowStatus] = 1;
										END
					-- *********************** FINALIZA ACTUALIZACIÓN ANULACION DE TRANSACCIONES EN CON MEMBRESÍA O SUSCRIPCIÓN **********************************

									IF NOT EXISTS	(SELECT TOP 1 1
													FROM	[dbo].[ExpressAccountServiceCartDetail] ASCD
													WHERE	[ASCD].[ExpressAccountServiceCartId] = @ExpressAccountServiceCartId
														AND [ASCD].[RowStatus] = 1)
										BEGIN
											--Deshabilitar carrito sin servicios
											UPDATE	[DBO].[ExpressAccountServiceCart]
											SET		[IsPending] = 0,
													[RowStatus] = 0,
													[TokenUpdated] = @Token,
													[DateUpdated] = GETDATE()
											WHERE	[IdExpressAccountServiceCart] = @ExpressAccountServiceCartId;

										END

					  -- *********************** INICIA ACTUALIZACIÓN DESASOCIAR CUPON *******************************************

									SELECT @CouponSerie = PromoCouponSerie  FROM [DeliveryBackOffice].[dbo].[PromoCoupon]
									WHERE GuideSerieDestination  = @GuideSerie AND GuideNumberDestination =  @GuideNumber
							
									IF (@CouponSerie IS NOT NULL)
										BEGIN
											--Actualiza el cupon para liberarlo
											UPDATE
											[DeliveryBackOffice].[dbo].[PromoCoupon]
											SET
												GuideSerieDestination = NULL
												,GuideNumberDestination = NULL
												,TokenUpdated = @Token
												,DateUpdated = GETDATE()
											WHERE    GuideSerieDestination = @GuideSerie 
												 AND GuideNumberDestination = @GuideNumber
												 AND PromoCouponSerie = @CouponSerie;

											SELECT 5 'StatusCode' ,'Guía anulada satisfactoriamente. El cupón ' +
											@CouponSerie + ' fue liberado exitosamente.' 'Description';

										END;
									ELSE
										BEGIN
											SELECT 1 'StatusCode' ,'Guide remove successfully' 'Description';
										END;

					-- *********************** FINALIZA ACTUALIZACIÓN DESASOCIAR CUPON *******************************************

								END

								ELSE
								BEGIN

									SELECT 4 'StatusCode' ,'Guide is already in process' 'Description';

								END
							END
				ELSE
					BEGIN
						SELECT 4 'StatusCode' ,'Guide is already paid' 'Description';
					END
					END
				ELSE
					BEGIN
						SELECT 3 'StatusCode' ,'Guide not found in Service Cart' 'Description';
					END

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