-- =============================================
-- Author:		<Andres,Ruiz>
-- Updated date:<2022-05-26>
-- Description:	< Se adiciona generación y manejo de cupones posterior a la transaccion de una tarjeta de credito/debito >
-- =============================================
CREATE PROCEDURE [dbo].[GetInfoFAC] 
	@Type VARCHAR(100) = 'GetResponseFAC',
	@OrderNumber VARCHAR(100) = NULL, --Guide
	@AccountId INT = 0,

	@Token NVARCHAR(50) = '',
	@SystemId INT = NULL,
	@VisitPointClientId INT = NULL,
	@VisitPointClientPortfolioId INT = NULL,
	@CouponSerie NVARCHAR(20) = NULL,
	@TblDeliveryOrdersList [TblDeliveryOrdersList2] READONLY
AS
BEGIN
	
	-- Manejo cuando dato viene vacio o es 0
	IF(@VisitPointClientId = 0)
		SET @VisitPointClientId = NULL
		
	IF(@VisitPointClientPortfolioId = 0)
		SET @VisitPointClientPortfolioId = NULL

	-- Variables de respuesta
	DECLARE @jsonResult NVARCHAR(MAX)

	-- Nuevas variables de respuesta
	DECLARE @CouponDataReponse AS TABLE (
		CouponSerie NVARCHAR(20),
		CouponFinalDate DATETIME,
		CouponPromo NVARCHAR(200),
		PromoId INT
	);

	-- Variables de control de flujo
	DECLARE @CountRows INT = 0
	DECLARE @CostCount INT = 0
	DECLARE @Guia VARCHAR(500)
	DECLARE @IdCost BIGINT
	DECLARE @Amount DECIMAL(18, 2)
	DECLARE @CostDetailCount INT = 0
	DECLARE @TransactionAmount DECIMAL(18, 2) = 0
	DECLARE @TransactionTokenUpdated VARCHAR(500) = NULL
	DECLARE @IdProduct INT = 0
	DECLARE @TransactionTokeCreated VARCHAR(500) = NULL
	DECLARE @IdBreakdownOfPayment INT = 0
	DECLARE @AmountPickup INT = 0
	DECLARE @IdHeaderRecolection INT = 0

	-- Variables adicionales de control de flujo
	DECLARE @CouponCreated BIT = 0;
	DECLARE @CouponIsValid BIT = 0;
	DECLARE @CouponIsReal BIT = 0;
	DECLARE @CouponUpdated BIT = 0;
	DECLARE @DOAlreadyUpdated BIT = 0;
	DECLARE @DOPDAlreadyUpdated BIT = 0;
	DECLARE @CoUpdated BIT = 0;

	-- Variables adicionales de datos
	DECLARE @CustomerId INT = 0;
	DECLARE @CustomerType INT = 0;
	DECLARE @VisitPointClientIdByUser INT = 0;
	
	DECLARE @GuideSerie NVARCHAR(2) = '';
	DECLARE @GuideNumber INT = 0;
	DECLARE @OldPriceshipment DECIMAL(14,2) = 0;
	DECLARE @UpdatedValue DECIMAL(14,2) = 0;

	-- Datos del cliente para promo
	SELECT
		@CustomerId = Cu.IdCustomer
		,@CustomerType = ISNULL(Cu.IdCustomerType, 0)
	FROM
		[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
			ON
				Acc.IdCustomer = Cu.IdCustomer
				AND
				Acc.AccIdAccount = @AccountId
	WHERE
		Acc.AccIdAccount = @AccountId

	-- Punto de visita por cuenta ingresada
	SET @VisitPointClientIdByUser = (
		SELECT CodeOfReference FROM DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
		INNER JOIN VisitPointByUser VPU WITH(NOLOCK)
			ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
				AND VPU.RowStatus = 1
		INNER JOIN RegisterUser ru WITH(NOLOCK)
			ON VPU.RegisterUserID = ru.UsrIdUser
				AND ru.UsrRowStatus = 1
		INNER JOIN [dbo].[RolByUserByAccount] rua WITH(NOLOCK)
			ON rua.RuaIdUser = ru.UsrIdUser
		WHERE rua.RuaIdAccount = @AccountId
	)

	IF(ISNULL(@Token,'') = '')
	BEGIN

		SELECT
			TOP 1
				@Token = TL.TknIdToken
		FROM
			[DeliveryBackOffice].[dbo].[TokenLog] TL WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH(NOLOCK)
				ON
					RBUBA.RuaIdUser = TL.TknIdUser
		WHERE
			CAST(TL.TknDateCreated AS DATE) = CAST(GETDATE() AS DATE)
			AND
			TL.TknRowStatus = 1
			AND
			RBUBA.RuaIdAccount = @AccountId

	END

	BEGIN TRANSACTION
	BEGIN TRY

		IF (@Type = 'GetResponseFAC')
		BEGIN

			-- Garantizar que si se registro la transacción del cobro a la tarjeta (¿?)
			SET @CountRows = (SELECT
					COUNT(1)
				FROM CreditCardTransactionByCustomer
				WHERE OrderNumber = @OrderNumber
				AND RowStatus = 1);

			IF (@CountRows > 0)
			BEGIN

				
				-- Si es posible generar o redimir un cupon
				IF(EXISTS(SELECT TOP 1 1 FROM @TblDeliveryOrdersList))
				BEGIN

					-- Obtener serie y numero de guía
					SELECT
						TOP 1
							@GuideSerie = TDOL.Guide_Serie
							,@GuideNumber = TDOL.Guide_Number
					FROM
						@TblDeliveryOrdersList TDOL
		
					-- Obtener valor anterior y valor con descuento aplicado
					SET @OldPriceshipment = (
						SELECT TOP 1 DO.PriceShippment FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
					)

					SET @UpdatedValue = (
						SELECT TOP 1 TDOL.PriceShippment FROM @TblDeliveryOrdersList TDOL WHERE TDOL.Guide_Serie = @GuideSerie AND TDOL.Guide_Number = @GuideNumber
					)

				END

				IF( LTRIM(RTRIM(ISNULL(@CouponSerie, ''))) = '' AND EXISTS(SELECT TOP 1 1 FROM @TblDeliveryOrdersList))
				BEGIN

							-- SE debe generar un cupon
					DECLARE @NewCouponData AS TABLE (
						PromoId INT,
						CouponFinalDate DATETIME,
						CouponDiscountType INT,
						CouponValueType INT,
						CouponValue DECIMAL(5,2),
						PromoName NVARCHAR(200)
					)

					IF(EXISTS (
						SELECT 
							TOP 1 
								1 
						FROM 
							[DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH(NOLOCK) 
						WHERE 
							PC.GuideSerieOrigin = @GuideSerie 
							AND 
							PC.GuideNumberOrigin = @GuideNumber 
							AND 
							PC.RowStatus = 1
						)
					)
					BEGIN

						INSERT INTO 
							@CouponDataReponse
							(CouponSerie, CouponFinalDate, CouponPromo, PromoId)
						SELECT
							-- Top 1 para generar cupon de promo con mayor peso
							TOP 1
								PromoC.PromoCouponSerie,
								PromoC.FinalActiveDate,
								CPromo.PromoDescription,
								PromoC.CatPromoId
						FROM
							[DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH(NOLOCK)
							INNER JOIN
								[DeliveryBackOffice].[dbo].[CatPromo] CPromo WITH(NOLOCK)
								ON
									PromoC.CatPromoId = CPromo.IdPromo
						WHERE
							PromoC.GuideSerieOrigin = @GuideSerie 
							AND 
							PromoC.GuideNumberOrigin = @GuideNumber 
							AND 
							PromoC.RowStatus = 1

					END
					ELSE
					BEGIN

						-- Insertar datos de promo valida
						INSERT INTO 
							@NewCouponData
							(PromoId, CouponFinalDate, CouponDiscountType, CouponValueType, CouponValue, PromoName)
						SELECT
							-- Top 1 para generar cupon de promo con mayor peso
							TOP 1
								CPromo.IdPromo,
								(
									CASE
										WHEN CPromo.LimitPromoTime = 24.00 THEN DATEADD(SECOND,-1,CAST(DATEADD(DAY,1,CAST(GETDATE() AS DATE)) AS DATETIME))
										ELSE DATEADD(MINUTE,(ISNULL(CPromo.LimitPromoTime,1) * 60),GETDATE())
									END
								),
								CPromo.CatDiscountTypeId,
								CPromo.CatValueTypeId,
								CPromo.PromoValue,
								CPromo.PromoDescription
						FROM
							[DeliveryBackOffice].[dbo].[CatPromo] CPromo WITH(NOLOCK)
							INNER JOIN
								[DeliveryBackOffice].[dbo].[PromoCoverage] PCov WITH(NOLOCK)
								ON
									CPromo.IdPromo = PCov.CatPromoId
						WHERE
							-- Validación de día de la semana correcta
							(
									( CPromo.Monday = 1 AND DATEPART(WEEKDAY, GETDATE()) = 2 )
								OR
									( CPromo.Tuesday = 1 AND DATEPART(WEEKDAY, GETDATE()) = 3 )
								OR
									( CPromo.Wednesday = 1 AND DATEPART(WEEKDAY, GETDATE()) = 4 )
								OR
									( CPromo.Thursday = 1 AND DATEPART(WEEKDAY, GETDATE()) = 5 )
								OR
									( CPromo.Friday = 1 AND DATEPART(WEEKDAY, GETDATE()) = 6 )
								OR
									( CPromo.Saturday = 1 AND DATEPART(WEEKDAY, GETDATE()) = 7 )
								OR
									( CPromo.Sunday = 1 AND DATEPART(WEEKDAY, GETDATE()) = 1 )
							)
							-- Validación de rango de fechas correcto para la promo
							AND
								( GETDATE() BETWEEN CPromo.StartPromoDate AND CPromo.FinishPromoDate )
							-- Validación de cobertura de promo
							AND
								(
									PCov.CustomerId = @CustomerId
									OR
									PCov.CustomerTypeId = @CustomerType
									OR
									PCov.VisitPointClientId = ISNULL(@VisitPointClientId, @VisitPointClientIdByUser)
								)
							--- Promo esta activa
							AND
								CPromo.RowStatus = 1
						ORDER BY
							-- Aplicar promoción de mayor peso
							CPromo.PromoWeight DESC

						IF(EXISTS( SELECT TOP 1 1 FROM @NewCouponData ))
						BEGIN

							-- Insertar nuevo cupon
							INSERT INTO
								[DeliveryBackOffice].[dbo].[PromoCoupon]
								(CatPromoId, PromoCouponSerie, GuideSerieOrigin, GuideNumberOrigin, CustomerOrigin, VisitPointClientOrigin, SystemOrigin, CatDiscountTypeId, CatValueTypeId, CouponValue, StartActiveDate, FinalActiveDate, RowStatus, DateCreated, TokenCreated)
							OUTPUT
								inserted.PromoCouponSerie, inserted.FinalActiveDate, inserted.CatPromoId INTO @CouponDataReponse (CouponSerie, CouponFinalDate, PromoId)
							SELECT
								NCD.PromoId
								,CONCAT(@GuideSerie, @GuideNumber) + RIGHT('000' + CAST(CEILING(RAND()*100) AS NVARCHAR), 2)
								,@GuideSerie
								,@GuideNumber
								,@CustomerId
								,ISNULL(@VisitPointClientId, @VisitPointClientIdByUser)
								,@SystemId
								,NCD.CouponDiscountType
								,NCD.CouponValueType
								,NCD.CouponValue
								,GETDATE()
								,NCD.CouponFinalDate
								,1
								,GETDATE()
								,@Token
							FROM
								@NewCouponData NCD

							SET @CouponCreated = (
								CASE
									WHEN (SELECT TOP 1 1 FROM @CouponDataReponse) > 0 THEN 1
									ELSE 0
								END
							)

							-- Actualizar nombre de promo en cupon a devolver
							UPDATE
								@CouponDataReponse
							SET
								CouponPromo = NCD.PromoName
							FROM
								@NewCouponData NCD
								INNER JOIN
									@CouponDataReponse CD
									ON
										NCD.PromoId = CD.PromoId

						END

					END

				END
				-- Redención de cupon
				ELSE IF (LTRIM(RTRIM(ISNULL(@CouponSerie, ''))) != '' AND EXISTS(SELECT TOP 1 1 FROM @TblDeliveryOrdersList))
				BEGIN

					SET @CouponIsValid = ISNULL((
						SELECT
							TOP 1
								1
						FROM
							[DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH(NOLOCK)
						WHERE
							PC.RedeemedDate IS NULL
							AND
							PC.PromoCouponSerie = @CouponSerie
							AND
							PC.FinalActiveDate >= GETDATE()
							AND
							PC.RowStatus = 1
					),0)

					IF(@CouponIsValid = 1)
					BEGIN

						-- Registrar consumo de cupon y valores originales
						UPDATE
							[DeliveryBackOffice].[dbo].[PromoCoupon]
						SET
							SystemDestination = @SystemId,
							GuideSerieDestination = @GuideSerie,
							GuideNumberDestination = @GuideNumber,
							CustomerDestination = @CustomerId,
							VisitPointClientDestination = ISNULL(@VisitPointClientId, @VisitPointClientIdByUser),
							VisitPointClientPortfolioDestination = @VisitPointClientPortfolioId,
							OriginalAmount = @OldPriceshipment,
							DiscountAmount = IIF(@UpdatedValue <= 0, @OldPriceshipment, (@OldPriceshipment - @UpdatedValue)),
							FinalAmount = IIF(@UpdatedValue <= 0, 0, @UpdatedValue),
							RedeemedDate = GETDATE(),
							DateUpdated = GETDATE(),
							TokenUpdated = @Token
						WHERE
							PromoCouponSerie = @CouponSerie
							AND
							RowStatus = 1

						IF(@@ROWCOUNT > 0)
						BEGIN
							SET @CouponUpdated = 1;
						END

						UPDATE 
							dbo.DeliveryOrder 
						SET 
							PriceShippment = IIF(t.PriceShippment <= 0, 0, t.PriceShippment)
							, StatusOrderId = 15
							, IsCollect = t.IsCollect
						FROM 
							dbo.DeliveryOrder ord
							INNER JOIN 
								@TblDeliveryOrdersList t 
								ON 
									t.Guide_Number = ord.Guide_Number 
									AND 
									t.Guide_Serie = ord.Guide_Serie
						

						IF(@@ROWCOUNT > 0)
						BEGIN
							SET @DOAlreadyUpdated = 1;
						END
			

						update  dbo.DeliveryOrderPaymentDetail 
						set ShipmentCompleted  = t.ShipmentCompleted , PayTypeId = t.IdTypePayment
						, TypeofInOutMoneyId = t.IdWayToPayment, TimePlaId = t.IdTimePayment
						from dbo.DeliveryOrderPaymentDetail pay WITH(NOLOCK)
								inner join @TblDeliveryOrdersList t 
								on (t.Guide_Number = pay.GuideNumber and t.Guide_Serie = pay.GuideSerie) 

						IF(@@ROWCOUNT > 0)
						BEGIN
							SET @DOPDAlreadyUpdated = 1;
						END

						DECLARE @PromoName NVARCHAR(50) = '';
						DECLARE @CostId INT = 0;

						SET @CostId = ISNULL((
							SELECT
								TOP 1
									Co.IdCost
							FROM
								[DeliveryBackOffice].[dbo].[Cost] Co WITH(NOLOCK)
							WHERE
								Co.ProductNumber = CONCAT(@GuideSerie, @GuideNumber)
								AND
								Co.IdProduct = 1
								AND
								Co.RowStatus = 1
						), 0)

						SET @PromoName = ISNULL((
							SELECT
								TOP 1
									IIF(LEN(CP.PromoDescription) > 100, SUBSTRING(CP.PromoDescription,1,99), CP.PromoDescription)
							FROM
								[DeliveryBackOffice].[dbo].[CatPromo] CP WITH(NOLOCK)
								INNER JOIN
									[DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH(NOLOCK)
									ON
										CP.IdPromo = PC.CatPromoId
							WHERE
								PC.PromoCouponSerie = @CouponSerie
						), 0)

						IF(ISNULL(@CostId, 0) > 0)
						BEGIN
							-- Actuaizar nuevo valor a Cost
							UPDATE
								[DeliveryBackOffice].[dbo].[Cost] 
							SET
								TotalAmount = @UpdatedValue
								,TotalAmountPaid = @UpdatedValue
							WHERE
								IdCost = @CostId

							-- Actuaizar nuevo valor a Cost
							UPDATE
								[DeliveryBackOffice].[dbo].[CostDetail] 
							SET
								Amount = @UpdatedValue
							WHERE
								IdCost = @CostId
						END

						IF(
							EXISTS( 
								SELECT TOP 1 1 
								FROM 
									[DeliveryBackOffice].[dbo].[BreakdownOfPayment] BOP  WITH(NOLOCK)
								WHERE 
									BOP.IdCost = @CostId 
									AND 
									BOP.Description = @PromoName COLLATE Latin1_General_CI_AI AND BOP.RowStatus = 1)
						)
						BEGIN

							UPDATE
								[DeliveryBackOffice].[dbo].[BreakdownOfPayment]
							SET
								RowStatus = 1,
								Amount = IIF(@UpdatedValue <= 0, -@OldPriceshipment, -(@OldPriceshipment - @UpdatedValue)),
								DateUpdated = GETDATE(),
								TokenUpdated = @Token,
								PromoCouponId = (SELECT TOP 1 PC.IdPromoCoupon FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH(NOLOCK) WHERE PC.PromoCouponSerie = @CouponSerie)
							WHERE
								IdCost = @CostId
								AND
								Description = @PromoName COLLATE Latin1_General_CI_AI

							IF(SCOPE_IDENTITY() > 0)
								SET @CoUpdated = 1;

						END
						ELSE
						BEGIN

							INSERT INTO
								[DeliveryBackOffice].[dbo].[BreakdownOfPayment]
								(IdCost, Description, Amount, RowStatus, DateCreated, TokenCreated, PromoCouponId)
							VALUES
								(@CostId, @PromoName, IIF(@UpdatedValue <= 0, -@OldPriceshipment, -(@OldPriceshipment - @UpdatedValue)), 1, GETDATE(), @Token, (SELECT TOP 1 PC.IdPromoCoupon FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC WHERE PC.PromoCouponSerie = @CouponSerie))

							IF(@@ROWCOUNT > 0)
								SET @CoUpdated = 1;

						END
					END

				END

				IF(EXISTS(SELECT TOP 1 1 FROM @TblDeliveryOrdersList))
				BEGIN
					-- Flujo de SetServiceRecoelct de filtro 2
					DECLARE @ValidateTransaction INT = (
						SELECT 
							DopId 
						FROM 
							[DeliveryBackOffice].[dbo].DeliveryOrderPaymentTransaction do WITH(NOLOCK)
							INNER JOIN @TblDeliveryOrdersList tpo
								ON do.GuideNumber = tpo.Guide_Number
									AND do.GuideSerie = tpo.Guide_Serie
									AND do.TypeServiceId = tpo.IdTypeService
					)

					IF (@ValidateTransaction IS NULL)
					BEGIN

							IF(@DOAlreadyUpdated = 0)
							BEGIN

								update 
									dbo.DeliveryOrder 
								set 
									PriceShippment = IIF(t.PriceShippment <= 0, 0, t.PriceShippment)
									, StatusOrderId = 15
									, IsCollect = t.IsCollect
								from 
									dbo.DeliveryOrder ord
								inner join 
									@TblDeliveryOrdersList t 
									on 
										t.Guide_Number = ord.Guide_Number 
										and 
										t.Guide_Serie = ord.Guide_Serie

							END

							IF(@DOPDAlreadyUpdated = 0)
							BEGIN

								update  dbo.DeliveryOrderPaymentDetail 
								set ShipmentCompleted  = t.ShipmentCompleted , PayTypeId = t.IdTypePayment
								, TypeofInOutMoneyId = t.IdWayToPayment, TimePlaId = t.IdTimePayment
								from dbo.DeliveryOrderPaymentDetail pay WITH(NOLOCK)
									 inner join @TblDeliveryOrdersList t 
									 on (t.Guide_Number = pay.GuideNumber and t.Guide_Serie = pay.GuideSerie) 

							END

							IF (@AccountId != 0)
							BEGIN

								IF(@UpdatedValue > 0)
								BEGIN

									INSERT INTO 
										dbo.DeliveryOrderPaymentTransaction
										(  
											[GuideNumber]
											,[GuideSerie]
											,[PayTypeId]
											,[TypeofInOutMoneyId]
											,[TimePlaId]
											,[amount]
											,[PaymentRecollections]
											,[PaymentNow]
											,[PaymentDelivery]
											,[StartDate]
											,[EndDate]
											,[ShipmentCompleted]
											,[RecollectionCompleted]
											,[PaidGuide]
											,[TokenCreated]
											,[DateCreated]
											,[TokenUpdated]
											,[DateUpdated]
											,[TransaccionFAC]
											,[IdHeaderRecolection]
											,[TypeServiceId]
											,[AccountId]
											,[CODAmountProcess]
											,[Fel]
											,[VisitPoint]
										)
									SELECT
											Guide_Number 
											,Guide_Serie
											,IdTypePayment
											,IdWayToPayment
											,IdTimePayment
											,tdop.PriceShippment
											,tdop.PaymentRecollections
											,tdop.PaymentNow
											,tdop.PaymentDelivery
											,null
											,null
											,tdop.ShipmentCompleted
											,tdop.RecollectionCompleted
											,tdop.PaidGuide
											,@Token
											,getdate()
											,null
											,null
											,null
											,null
											,tdop.IdTypeService
											,IIF(@AccountId=0,null, @AccountId)
											,tdop.CODAmountProccess
											,null
											,IIF(@VisitPointClientIdByUser=0,null, @VisitPointClientIdByUser)
									FROM 
										@TblDeliveryOrdersList tdop
									WHERE 
										tdop.PriceShippment != 0
										OR
										tdop.CODAmountProccess != 0

								 END
								 --ELSE IF ( (@OldPriceshipment - @UpdatedValue) <= 0 )
								 --BEGIN

									--INSERT INTO 
									--	dbo.DeliveryOrderPaymentTransaction
									--	(  
									--		[GuideNumber]
									--		,[GuideSerie]
									--		,[PayTypeId]
									--		,[TypeofInOutMoneyId]
									--		,[TimePlaId]
									--		,[amount]
									--		,[PaymentRecollections]
									--		,[PaymentNow]
									--		,[PaymentDelivery]
									--		,[StartDate]
									--		,[EndDate]
									--		,[ShipmentCompleted]
									--		,[RecollectionCompleted]
									--		,[PaidGuide]
									--		,[TokenCreated]
									--		,[DateCreated]
									--		,[TokenUpdated]
									--		,[DateUpdated]
									--		,[TransaccionFAC]
									--		,[IdHeaderRecolection]
									--		,[TypeServiceId]
									--		,[AccountId]
									--		,[CODAmountProcess]
									--		,[Fel]
									--		,[VisitPoint]
									--	)
									--SELECT
									--		Guide_Number 
									--		,Guide_Serie
									--		,IdTypePayment
									--		,IdWayToPayment
									--		,IdTimePayment
									--		,@OldPriceshipment
									--		,tdop.PaymentRecollections
									--		,tdop.PaymentNow
									--		,tdop.PaymentDelivery
									--		,null
									--		,null
									--		,tdop.ShipmentCompleted
									--		,tdop.RecollectionCompleted
									--		,tdop.PaidGuide
									--		,@Token
									--		,getdate()
									--		,null
									--		,null
									--		,null
									--		,null
									--		,tdop.IdTypeService
									--		,IIF(@AccountId=0,null, @AccountId)
									--		,tdop.CODAmountProccess
									--		,null
									--		,IIF(@VisitPointClientIdByUser=0,null, @VisitPointClientIdByUser)
									--FROM 
									--	@TblDeliveryOrdersList tdop
									--WHERE 
									--	tdop.CODAmountProccess != 0

									--INSERT INTO 
									--	dbo.DeliveryOrderPaymentTransaction
									--	(  
									--		[GuideNumber]
									--		,[GuideSerie]
									--		,[PayTypeId]
									--		,[TypeofInOutMoneyId]
									--		,[TimePlaId]
									--		,[amount]
									--		,[PaymentRecollections]
									--		,[PaymentNow]
									--		,[PaymentDelivery]
									--		,[StartDate]
									--		,[EndDate]
									--		,[ShipmentCompleted]
									--		,[RecollectionCompleted]
									--		,[PaidGuide]
									--		,[TokenCreated]
									--		,[DateCreated]
									--		,[TokenUpdated]
									--		,[DateUpdated]
									--		,[TransaccionFAC]
									--		,[IdHeaderRecolection]
									--		,[TypeServiceId]
									--		,[AccountId]
									--		,[CODAmountProcess]
									--		,[Fel]
									--		,[VisitPoint]
									--	)
									--SELECT
									--		Guide_Number 
									--		,Guide_Serie
									--		,IdTypePayment
									--		,IdWayToPayment
									--		,IdTimePayment
									--		,IIF(@OldPriceshipment > 0, -@OldPriceshipment, @OldPriceshipment)
									--		,tdop.PaymentRecollections
									--		,tdop.PaymentNow
									--		,tdop.PaymentDelivery
									--		,null
									--		,null
									--		,tdop.ShipmentCompleted
									--		,tdop.RecollectionCompleted
									--		,tdop.PaidGuide
									--		,@Token
									--		,getdate()
									--		,null
									--		,null
									--		,null
									--		,null
									--		,tdop.IdTypeService
									--		,IIF(@AccountId=0,null, @AccountId)
									--		,tdop.CODAmountProccess
									--		,null
									--		,IIF(@VisitPointClientIdByUser=0,null, @VisitPointClientIdByUser)
									--FROM 
									--	@TblDeliveryOrdersList tdop
									--WHERE 
									--	tdop.CODAmountProccess != 0

								 --END

							END
			
					END
				END

				-- Flujo normal de GetInfoFac
				SET @jsonResult = (SELECT
						STUFF((SELECT
								',{' + 
								'"CustomerReference":"' + CONVERT(VARCHAR, CustomerReference) + '",' +
								'"ReferenceNumber":"' + CONVERT(VARCHAR, ReferenceNumber) + '",' +
								'"ReasonCode":"' + CONVERT(VARCHAR, ReasonCode) + '",' +
								'"ReasonDescription":"' + CONVERT(VARCHAR, ReasonDescription) + '",' +
								'"StatusSend":"' + CONVERT(VARCHAR, StatusSend) + '",' +
									IIF(EXISTS(SELECT TOP 1 1 FROM @CouponDataReponse), 
										(
											SELECT TOP 1
												'"Coupon":{' +
													'"CouponSerie":"' + CDR.CouponSerie + '",' +
													'"FinalDate":"' + CONVERT(NVARCHAR, CDR.CouponFinalDate ,103) + '",' +
													'"Promo":"' + CDR.CouponPromo + '"}'
											FROM
												@CouponDataReponse CDR
										)
									,'"Coupon":{}') +
								+ '}'
							FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
							WHERE
							OrderNumber = @OrderNumber
							AND RowStatus = 1
							FOR XML PATH (''), TYPE)
						.value('.', 'varchar(max)'), 1, 1, ''
						))

				--=====================DETALLE_PAGOS.INI======================

				/*Actualiza el ID de transacción del pago realizado con tarjeta*/
				--TransaccionFAC.INI

				IF (@OrderNumber != '')
				BEGIN

					DECLARE @AcceptedGuides AS TABLE (
						GuideSerie NVARCHAR(2),
						GuideNumber INT,
						INDEX INDX_TEMP_AcceptedGuides_Guides NONCLUSTERED (GuideSerie, GuideNumber)
					);

					-- Guías individuales FD
					INSERT INTO @AcceptedGuides
						(GuideSerie, GuideNumber)
					SELECT
						DISTINCT
							SUBSTRING(CCTBC.OrderNumber,1,2),
							SUBSTRING(CCTBC.OrderNumber,3, LEN(CCTBC.OrderNumber))
					FROM
						DeliveryBackOffice.dbo.CreditCardTransactionByCustomer CCTBC WITH(NOLOCK)
						INNER JOIN
							DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
							ON
								SUBSTRING(CCTBC.OrderNumber,1,2) = DO.Guide_Serie
								AND
								SUBSTRING(CCTBC.OrderNumber,3, LEN(CCTBC.OrderNumber)) = DO.Guide_Number
					WHERE
						CCTBC.OrderNumber = @OrderNumber

					-- Guías agrupadas por HR
					INSERT INTO @AcceptedGuides
						(GuideSerie, GuideNumber)
					SELECT
						DISTINCT
							CCTBCD.SerieNumber,
							CCTBCD.ProductNumber
					FROM
						DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail CCTBCD WITH(NOLOCK)
						INNER JOIN
							DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
							ON
								CCTBCD.ProductNumber = DO.Guide_Number
								AND
								CCTBCD.SerieNumber = DO.Guide_Serie
					WHERE
						CCTBCD.OrderNumber = @OrderNumber

					DECLARE @SchedulePickups AS TABLE(
						IdSchedulePickup INT
					);

					INSERT INTO @SchedulePickups
					SELECT
						DISTINCT
							DOPD.IdHeaderRecolection
					FROM
						DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD WITH(NOLOCK)
						INNER JOIN
							@AcceptedGuides AG
							ON
								DOPD.GuideSerie = AG.GuideSerie
								AND
								DOPD.GuideNumber = AG.GuideNumber
						
					-- Actualizar datos de guías con transacción realizada
					UPDATE 
						DOPD
					SET 
						DOPD.TransaccionFAC = ISNULL(@OrderNumber, '')
					FROM
						DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD WITH(NOLOCK)
						INNER JOIN
							@AcceptedGuides AG
							ON
								DOPD.GuideSerie = AG.GuideSerie
								AND
								DOPD.GuideNumber = AG.GuideNumber
					WHERE 
						TransaccionFAC IS NULL

					UPDATE 
						SP
					SET 
						SP.TransaccionFAC = @OrderNumber
					FROM
						DeliveryBackOffice.dbo.SchedulePickup SP WITH(NOLOCK)
						INNER JOIN
							@SchedulePickups SPS
							ON
								SP.SchedulePickupId = SPS.IdSchedulePickup

				END
			--TransaccionFAC.FIN

			--=====================DETALLE_PAGOS.FIN======================
			END
		END

		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION;

		SELECT
			'' + @jsonResult + '' FormatJson

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SET @jsonResult =  
		( 
			SELECT STUFF(( 
				SELECT 
					',{' + 
						'"IdResult":401' + ',' +
						'"messageError":"' + ERROR_MESSAGE() + '"' + ',' +
						'"lineError":"' + ERROR_LINE() + '"' + ',' +
						'"Coupon": { } ' + ',' +
					'}'
				FOR XML PATH(''), TYPE 
			) 
			.value('.', 'varchar(max)'),1,1,'' 
			)
		) 
			 
		select ('[' + @jsonResult +  ']') JsonOutput 

	END CATCH
	

END
