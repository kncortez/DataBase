-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-19>
-- Description:	<Elimina y anula una guía del carrito de compra>
-- =============================================
-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <2022-12-29>
-- Description:	<Se anula transacción de membresía o suscripción enlazada>
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

		DECLARE @AccountServiceCartId AS INT;			-- AccountServiceCart
		DECLARE @AccountServicecartDetailId AS INT		-- AccountServiceCartDetail
		DECLARE @GEN_STATUS_ORDER_ID AS INT;			-- StatusOrder
		DECLARE @SOL_STATUS_ORDER_ID AS INT;			-- StatusOrder
		DECLARE @NULL_STATUS_ORDER_ID AS INT;			-- StatusOrder
		DECLARE @TR_ID AS INT;							-- MembershipSubscriptionLog
		DECLARE @ActualGuideStatus AS INT;

		SET @GEN_STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'Generado');

		SET @SOL_STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'Solicitado');

		SET @NULL_STATUS_ORDER_ID = (SELECT	[SO].[StatusOrderId]
									FROM	[dbo].[StatusOrder] SO
									WHERE	[SO].[OrderDescription] = 'Anulado');

		SELECT TOP 1 @AccountServiceCartId = IdAccountServiceCart
		FROM		[dbo].[AccountServiceCart] ACSC
		WHERE		[ACSC].[AccountId] = @IdAccount
			AND		[ACSC].[IsPending] = 1
			AND		[ACSC].[RowStatus] = 1
		ORDER BY	[ACSC].[DateCreated] DESC;

		IF @AccountServiceCartId IS NOT NULL
			BEGIN
				--Desactivar otros carritos
				UPDATE	[dbo].[AccountServiceCart]
				SET		[IsPending] = 0,
						[RowStatus] = 0
				WHERE	[IsPending] = 1
					AND [RowStatus] = 1
					AND [IdAccountServiceCart] <> @AccountServiceCartId
					AND [AccountId] = @IdAccount;

				SELECT	@AccountServicecartDetailId = IdAccountServiceCartDetail
				FROM	[dbo].[AccountServiceCartDetail] ASCD
				WHERE	[ASCD].[AccountServiceCartId] = @AccountServiceCartId
					AND [ASCD].[GuideSerie] = @GuideSerie
					AND [ASCD].[GuideNumber] = @GuideNumber
					AND [ASCD].[RowStatus] = 1;

				IF @AccountServicecartDetailId IS NOT NULL
					BEGIN
	
						IF NOT EXISTS (
                                       SELECT 1
                                         FROM [dbo].[Cost] C WITH (NOLOCK)
                                        WHERE [C].GuideSerie = @GuideSerie
                                          AND [C].GuideNumber = @GuideNumber
                                          AND [C].[TotalAmountPaid] IS NOT NULL
                                          AND [C].[TotalAmountPaid] > 0
                                          AND [C].[RowStatus] = 1
                                       )
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

									UPDATE	[dbo].[AccountServiceCartDetail]
									SET		[RowStatus] = 0,
											[TokenUpdated] = @Token,
											[DateUpdated] = GETDATE()
									WHERE	[IdAccountServiceCartDetail] = @AccountServicecartDetailId;

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
													FROM	[dbo].[AccountServiceCartDetail] ASCD
													WHERE	[ASCD].[AccountServiceCartId] = @AccountServiceCartId
														AND [ASCD].[RowStatus] = 1)
										BEGIN
											--Deshabilitar carrito sin servicios
											UPDATE	[DBO].[AccountServiceCart]
											SET		[IsPending] = 0,
													[RowStatus] = 0,
													[TokenUpdated] = @Token,
													[DateUpdated] = GETDATE()
											WHERE	[IdAccountServiceCart] = @AccountServiceCartId;

										END
					
									SELECT 1 'StatusCode' ,'Guide remove successfully' 'Description';

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