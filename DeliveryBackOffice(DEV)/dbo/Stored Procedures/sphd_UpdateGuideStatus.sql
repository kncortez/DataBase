
-- =============================================
-- Author:		<César, Sazo>
-- Create date: <20/10/2021>
-- Description:	< Cambio de estado de pantalla de administración de checkpoints >
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <01/06/2022>
-- Description:	< liberación de cupones y anulación de los mismos >
-- =============================================
-- Author:		<Edelman Vásquez>
-- Update date: <07/06/2022>
-- Description:	<Control de mensajes de errores, indicando por que una anulación no procede>
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[sphd_UpdateGuideStatus]
	@Guide_Serie VARCHAR(2),
	@Guide_Number INT,  
	@newStatus INT,
	@UserToken VARCHAR(50),
	@Observations VARCHAR(200)
AS
BEGIN

	DECLARE @VoidStatus INT = (SELECT TOP 1 SO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) WHERE SO.OrderDescription = 'Anulado' COLLATE Latin1_General_CI_AI)

	DECLARE @IsCouponOrigin   BIT = 0;
	DECLARE @IsCouponRedeemer BIT = 0;
	DECLARE @RowStatus1 BIT = 0;

	DECLARE @ResultOperation VARCHAR(200);
	DECLARE @ResultCode INT;
	SET @RowStatus1  = ISNULL((SELECT top 1 1 FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH(NOLOCK) WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number AND StatusOrderId <> 7),0);
	
	--Variabes Membresías y suscripciones
	DECLARE @MembershipId INT
	DECLARE @SubscriptionId INT
	DECLARE @MembershipSubscriptionLogId BIGINT
	DECLARE @PointsByServiceLogId INT = NULL
	DECLARE @PointsToReceive INT = 0
	-------------------------------------

	SET @IsCouponOrigin = ISNULL((
		SELECT	
			TOP 1
				1
		FROM
			[DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH(NOLOCK)
		WHERE
			PromoC.GuideSerieOrigin = @Guide_Serie
			AND
			PromoC.GuideNumberOrigin = @Guide_Number
			AND
			PromoC.RowStatus = 1
	),0);

	SET @IsCouponRedeemer = ISNULL((
		SELECT	
			TOP 1
				1
		FROM
			[DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH(NOLOCK)
		WHERE
			PromoC.GuideSerieDestination = @Guide_Serie
			AND
			PromoC.GuideNumberDestination = @Guide_Number
			AND
			PromoC.RowStatus = 1
	),0);
	
	BEGIN TRANSACTION
	BEGIN TRY	
	--- Valida que sea Guía que genera cupon y que el estado es anular id= 7
		IF(@IsCouponOrigin = 1 AND @newStatus = @VoidStatus)
		BEGIN

			DECLARE @IsCouponRedeemed BIT = 0;
			SET @IsCouponRedeemed = ISNULL((
				SELECT	
					TOP 1
						1
				FROM
					[DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH(NOLOCK)
				WHERE
					PromoC.GuideSerieOrigin = @Guide_Serie
					AND
					PromoC.GuideNumberOrigin = @Guide_Number
					AND
					PromoC.GuideSerieDestination IS NOT NULL
					AND
					PromoC.GuideNumberDestination IS NOT NULL
					AND
					PromoC.RedeemedDate IS NOT NULL
					AND
					PromoC.RowStatus = 1
			),0);
			--Validar que no tenga cupón redimido
			IF(@IsCouponRedeemed = 0)
			BEGIN
				-- Cupon no ha sido redimido
				SET @ResultOperation  ='Guía y Cupón Anulado Exitosamente!!'
				UPDATE
					[DeliveryBackOffice].[dbo].[PromoCoupon]
				SET
					RowStatus = 0
					,SystemDestination = NULL
					,CustomerDestination = NULL
					,VisitPointClientDestination = NULL
					,VisitPointClientPortfolioDestination = NULL
					,GuideSerieDestination = NULL
					,GuideNumberDestination = NULL
					,ServiceManagementDestination = NULL
					,RedeemedDate = NULL
					,OriginalAmount = NULL
					,DiscountAmount = NULL
					,FinalAmount = NULL
					,DateUpdated = GETDATE()
					,TokenUpdated = @UserToken
				WHERE
					GuideSerieOrigin = @Guide_Serie
					AND
					GuideNumberOrigin = @Guide_Number
				
				UPDATE 
					DeliveryBackOffice.dbo.DeliveryOrder	
				SET 
					StatusOrderId = @newStatus
				WHERE 
					Guide_Serie =  @Guide_Serie
					AND 
					Guide_Number = @Guide_Number

				INSERT INTO 
					DeliveryBackOffice.dbo.DeliveryOrderDetail
					(Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations)
				VALUES 
					(@Guide_Serie, @Guide_Number, @newStatus, @UserToken, GETDATE(), GETDATE(), @Observations) 
					
			--Membresías y suscripciones
			--Oscar Morales 25/07/2022
			SET @MembershipSubscriptionLogId = NULL

			SELECT
				@MembershipSubscriptionLogId = IdMembershipSubscriptionLog
			   ,@MembershipId = MembershipId
			   ,@SubscriptionId = SubscriptionId
			FROM MembershipSubscriptionLog
			WHERE LogGuideSerie = @Guide_Serie
			AND LogGuideNumber = @Guide_Number
			AND RowStatus = 1

			IF @MembershipSubscriptionLogId IS NOT NULL
			BEGIN

				UPDATE MembershipSubscriptionLog 
				SET RowStatus = 0
					,TokenUpdated = @UserToken
					,DateUpdated = GETDATE()
				WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId

				IF @SubscriptionId IS NULL
				BEGIN
					
					UPDATE Membership 
					SET ActualServiceCount = ActualServiceCount - 1
						,TokenUpdated = @UserToken
						,DateUpdated = GETDATE()
					WHERE IdMembership = @MembershipId
				END
				ELSE
				BEGIN
					
					UPDATE Subscription
					SET ActualServiceCount = ActualServiceCount - 1
						,TokenUpdated = @UserToken
						,DateUpdated = GETDATE()
					WHERE IdSubscription = @SubscriptionId
				END

			END
			--Termina Membresías y suscripciones
					
			-- puntos forza

			SELECT
				@PointsByServiceLogId = PBSL.IdPointsByServiceLog
				,@MembershipId = PBSL.MembershipId
				,@PointsToReceive = PBSL.PointsConsumed
			FROM
				[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
			WHERE
				PBSL.GuideSerie = @Guide_Serie
				AND
				PBSL.GuideNumber = @Guide_Number
				AND
				ISNULL(PBSL.PointsConsumed, 0) > 0
				AND 
				PBSL.RowStatus = 1

			IF(@PointsByServiceLogId IS NOT NULL)
			BEGIN

				-- Inactivar registro de bitacora
				UPDATE
					[DeliveryBackOffice].[dbo].[PointsByServiceLog]
				SET
					RowStatus = 0,
					TokenUpdated = @UserToken,
					DateUpdated = GETDATE()
				WHERE
					IdPointsByServiceLog = @PointsByServiceLogId

				-- Devolver puntos forza
				UPDATE
					[DeliveryBackOffice].[dbo].[Membership]
				SET
					AvailablePoints = ISNULL(AvailablePoints, 0) + @PointsToReceive
					,TokenUpdated = @UserToken
					,DateUpdated = GETDATE()
				WHERE
					IdMembership = @MembershipId

			END
			-- Termina puntos forza

				IF(@@TRANCOUNT > 0)
					COMMIT TRANSACTION;
					
			END
			  ELSE
				BEGIN

				SET @ResultOperation  ='No es Posible anular la guía, contiene un cupón Canjeado!!'
				IF(@@TRANCOUNT > 0)
						COMMIT TRANSACTION;

				END

		END
		--Valida si guía tiene cupón redimido
		ELSE IF(@IsCouponRedeemer = 1 AND @newStatus = @VoidStatus )
		BEGIN
		SET @ResultOperation  = 'Guía  Anulada Exitosamente!!'
			UPDATE
				[DeliveryBackOffice].[dbo].[PromoCoupon]
			SET
				SystemDestination = NULL
				,CustomerDestination = NULL
				,VisitPointClientDestination = NULL
				,VisitPointClientPortfolioDestination = NULL
				,GuideSerieDestination = NULL
				,GuideNumberDestination = NULL
				,ServiceManagementDestination = NULL
				,RedeemedDate = NULL
				,OriginalAmount = NULL
				,DiscountAmount = NULL
				,FinalAmount = NULL
				,DateUpdated = GETDATE()
				,TokenUpdated = @UserToken
			WHERE
				GuideSerieDestination = @Guide_Serie
				AND
				GuideNumberDestination = @Guide_Number
				
			UPDATE 
				DeliveryBackOffice.dbo.DeliveryOrder	
			SET 
				StatusOrderId = @newStatus
			WHERE 
				Guide_Serie =  @Guide_Serie
				AND 
				Guide_Number = @Guide_Number

			INSERT INTO 
				DeliveryBackOffice.dbo.DeliveryOrderDetail
				(Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations)
			VALUES 
				(@Guide_Serie, @Guide_Number, @newStatus, @UserToken, GETDATE(), GETDATE(), @Observations) 
			
			--Membresías y suscripciones
			--Oscar Morales 25/07/2022
			SET @MembershipSubscriptionLogId = NULL

			SELECT
				@MembershipSubscriptionLogId = IdMembershipSubscriptionLog
			   ,@MembershipId = MembershipId
			   ,@SubscriptionId = SubscriptionId
			FROM MembershipSubscriptionLog
			WHERE LogGuideSerie = @Guide_Serie
			AND LogGuideNumber = @Guide_Number
			AND RowStatus = 1

			IF @MembershipSubscriptionLogId IS NOT NULL
			BEGIN

				UPDATE MembershipSubscriptionLog 
				SET RowStatus = 0
					,TokenUpdated = @UserToken
					,DateUpdated = GETDATE()
				WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId

				IF @SubscriptionId IS NULL
				BEGIN
					
					UPDATE Membership 
					SET ActualServiceCount = ActualServiceCount - 1
						,TokenUpdated = @UserToken
						,DateUpdated = GETDATE()
					WHERE IdMembership = @MembershipId
				END
				ELSE
				BEGIN
					
					UPDATE Subscription
					SET ActualServiceCount = ActualServiceCount - 1
						,TokenUpdated = @UserToken
						,DateUpdated = GETDATE()
					WHERE IdSubscription = @SubscriptionId
				END

			END
			--Termina Membresías y suscripciones
					
			-- puntos forza

			SELECT
				@PointsByServiceLogId = PBSL.IdPointsByServiceLog
				,@MembershipId = PBSL.MembershipId
				,@PointsToReceive = PBSL.PointsConsumed
			FROM
				[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
			WHERE
				PBSL.GuideSerie = @Guide_Serie
				AND
				PBSL.GuideNumber = @Guide_Number
				AND
				ISNULL(PBSL.PointsConsumed, 0) > 0
				AND 
				PBSL.RowStatus = 1

			IF(@PointsByServiceLogId IS NOT NULL)
			BEGIN

				-- Inactivar registro de bitacora
				UPDATE
					[DeliveryBackOffice].[dbo].[PointsByServiceLog]
				SET
					RowStatus = 0,
					TokenUpdated = @UserToken,
					DateUpdated = GETDATE()
				WHERE
					IdPointsByServiceLog = @PointsByServiceLogId

				-- Devolver puntos forza
				UPDATE
					[DeliveryBackOffice].[dbo].[Membership]
				SET
					AvailablePoints = ISNULL(AvailablePoints, 0) + @PointsToReceive
					,TokenUpdated = @UserToken
					,DateUpdated = GETDATE()
				WHERE
					IdMembership = @MembershipId

			END
			-- Termina puntos forza

			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION;
				
				
		END
		--Valida si guía esta anulada
		ELSE IF(@IsCouponRedeemer = 0 AND @IsCouponOrigin = 0 AND @RowStatus1 = 0)  
		BEGIN
		SET @ResultOperation  = 'Guía  ya fue anulada!!'
			
					
			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION;
				
				
		END
		ELSE IF (@RowStatus1 = 1 AND @IsCouponRedeemer = 0 AND @IsCouponOrigin = 0 )
		BEGIN
			DECLARE @StatusDecription NVARCHAR(100) = (SELECT OrderDescription FROM StatusOrder WHERE StatusOrderId = @newStatus)
				SET @ResultOperation  =CONCAT('Se ha cambiado el estado de la guía a "', @StatusDecription ,'" exitosamente!!')
			UPDATE 
				DeliveryBackOffice.dbo.DeliveryOrder	
			SET 
				StatusOrderId = @newStatus
			WHERE 
				Guide_Serie =  @Guide_Serie
				AND 
				Guide_Number = @Guide_Number

			INSERT INTO 
				DeliveryBackOffice.dbo.DeliveryOrderDetail
				(Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations)
			VALUES 
				(@Guide_Serie, @Guide_Number, @newStatus, @UserToken, GETDATE(), GETDATE(), @Observations)
				
			--Membresías y suscripciones
			--Oscar Morales 25/07/2022
			IF @newStatus = @VoidStatus
			BEGIN
				SET @MembershipSubscriptionLogId = NULL

				SELECT
					@MembershipSubscriptionLogId = IdMembershipSubscriptionLog
				   ,@MembershipId = MembershipId
				   ,@SubscriptionId = SubscriptionId
				FROM MembershipSubscriptionLog
				WHERE LogGuideSerie = @Guide_Serie
				AND LogGuideNumber = @Guide_Number
				AND RowStatus = 1

				IF @MembershipSubscriptionLogId IS NOT NULL
				BEGIN

					UPDATE MembershipSubscriptionLog 
					SET RowStatus = 0
						,TokenUpdated = @UserToken
						,DateUpdated = GETDATE()
					WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId

					IF @SubscriptionId IS NULL
					BEGIN
					
						UPDATE Membership 
						SET ActualServiceCount = ActualServiceCount - 1
							,TokenUpdated = @UserToken
							,DateUpdated = GETDATE()
						WHERE IdMembership = @MembershipId
					END
					ELSE
					BEGIN
					
						UPDATE Subscription
						SET ActualServiceCount = ActualServiceCount - 1
							,TokenUpdated = @UserToken
							,DateUpdated = GETDATE()
						WHERE IdSubscription = @SubscriptionId
					END

				END
			END
			--Termina Membresías y suscripciones
					
			-- puntos forza

			SELECT
				@PointsByServiceLogId = PBSL.IdPointsByServiceLog
				,@MembershipId = PBSL.MembershipId
				,@PointsToReceive = PBSL.PointsConsumed
			FROM
				[DeliveryBackOffice].[dbo].[PointsByServiceLog] PBSL WITH(NOLOCK)
			WHERE
				PBSL.GuideSerie = @Guide_Serie
				AND
				PBSL.GuideNumber = @Guide_Number
				AND
				ISNULL(PBSL.PointsConsumed, 0) > 0
				AND 
				PBSL.RowStatus = 1

			IF(@PointsByServiceLogId IS NOT NULL)
			BEGIN

				-- Inactivar registro de bitacora
				UPDATE
					[DeliveryBackOffice].[dbo].[PointsByServiceLog]
				SET
					RowStatus = 0,
					TokenUpdated = @UserToken,
					DateUpdated = GETDATE()
				WHERE
					IdPointsByServiceLog = @PointsByServiceLogId

				-- Devolver puntos forza
				UPDATE
					[DeliveryBackOffice].[dbo].[Membership]
				SET
					AvailablePoints = ISNULL(AvailablePoints, 0) + @PointsToReceive
					,TokenUpdated = @UserToken
					,DateUpdated = GETDATE()
				WHERE
					IdMembership = @MembershipId

			END
			-- Termina puntos forza
				
              IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION;
		    END
			ELSE
			BEGIN
			SET @ResultOperation  ='Guía No Existe!!'
			END 
					
			
			  SELECT 1  [blnResult],
			          @Guide_Serie + Convert(varchar,@Guide_Number) + ': ' +
			          @ResultOperation [ResultDescription]
			
    
	END TRY
	
		BEGIN CATCH

			ROLLBACK TRANSACTION;

				SELECT
					 0  [blnResult], @ResultOperation [ResultDescription]

		 END CATCH
 
 
END

