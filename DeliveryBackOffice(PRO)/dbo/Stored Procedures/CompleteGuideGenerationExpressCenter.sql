-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-05-26>
-- Description:	< Metodo para finalizar el proceso de generación de guías en express center tomando en cuenta cupones >
-- =============================================

CREATE PROCEDURE [dbo].[CompleteGuideGenerationExpressCenter]
	@IdStatus int = 15,
	@SystemId INT = 2,
	@Token NVARCHAR(50),
	@AccountId INT = NULL,
	@VisitPointClientId INT = NULL,
	@VisitPointClientPortfolioId INT = NULL,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@CouponSerie NVARCHAR(20) = NULL,
	@Voucher NVARCHAR(300) = '',
	@TblDeliveryOrdersList [TblDeliveryOrdersList2] READONLY
AS
BEGIN

	-- Variables "globales"
	DECLARE @IdCreditCardPayment INT = (SELECT TOP 1 CTOIOM.tio_pk_id FROM [DeliveryBackOffice].[dbo].[ctgTypeOfInOutOfMoney] CTOIOM WITH(NOLOCK) WHERE CTOIOM.tio_pk_name = 'pago con tarjeta' COLLATE Latin1_General_CI_AI);
	DECLARE @IdDatafonoPayment INT = (SELECT TOP 1 CTOIOM.tio_pk_id FROM [DeliveryBackOffice].[dbo].[ctgTypeOfInOutOfMoney] CTOIOM WITH(NOLOCK) WHERE CTOIOM.tio_pk_name = 'Datafono' COLLATE Latin1_General_CI_AI);
	
	DECLARE @TypeExpressCenter INT = (SELECT TOP 1 CT.IdCustomerType FROM [DeliveryBackOffice].[dbo].[CustomerType] CT WITH(NOLOCK) WHERE CT.[Description] = 'REDISTRIBUIDOR' COLLATE Latin1_General_CI_AI);

	-- Manejo cuando dato viene vacio o es 0
	IF(@VisitPointClientId = 0)
		SET @VisitPointClientId = NULL
		
	IF(@VisitPointClientPortfolioId = 0)
		SET @VisitPointClientPortfolioId = NULL

	-- Variables de respuesta
	DECLARE @JsonResponse NVARCHAR(MAX) = '';

	DECLARE @CouponDataReponse AS TABLE (
		CouponSerie NVARCHAR(20),
		CouponFinalDate DATETIME,
		CouponPromo NVARCHAR(200),
		PromoId INT
	);

	-- Variables de control de flujo
	DECLARE @GuideIsReturn BIT = 0;
	DECLARE @CouponCreated BIT = 0;
	DECLARE @CouponIsValid BIT = 0;
	DECLARE @CouponIsReal BIT = 0;
	DECLARE @CouponUpdated BIT = 0;
	DECLARE @DOAlreadyUpdated BIT = 0;
	DECLARE @DOPDAlreadyUpdated BIT = 0;
	DECLARE @CoUpdated BIT = 0;
	DECLARE @CostId INT = 0;

	-- Variables adicionales de datos
	DECLARE @CustomerId INT = 0;
	DECLARE @CustomerType INT = 0;
	DECLARE @VisitPointClientIdByUser INT = 0;

	-- Variables de valores
	DECLARE @OldPriceshipment DECIMAL(14,2) = 0;
	DECLARE @UpdatedValue DECIMAL(14,2) = 0;

	-- Datos del cliente para promo (Nos basamos en la guía para averiguar si fue impersonada o no)
	SELECT
		TOP 1
			@CustomerId = Cu.IdCustomer
			,@CustomerType = Cu.IdCustomerType
			,@GuideIsReturn = ISNULL(DO.IsReturn,0)
			,@VisitPointClientIdByUser = IIF(VPC.CodeOfReference = 0, NULL, VPC.CodeOfReference)
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
			ON
				DO.Sender_ID = VPC.CodeOfReference
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
			ON
				ISNULL(DO.IdCustomer, VPC.CustomerID) = Cu.IdCustomer
	WHERE
		DO.Guide_Serie = @GuideSerie
		AND
		DO.Guide_Number = @GuideNumber

	--SELECT
	--	@CustomerId = Cu.IdCustomer
	--	,@CustomerType = ISNULL(Cu.IdCustomerType, 0)
	--FROM
	--	[DeliveryBackOffice].[dbo].[Account] Acc WITH(NOLOCK)
	--	INNER JOIN
	--		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
	--		ON
	--			Acc.IdCustomer = Cu.IdCustomer
	--			AND
	--			Acc.AccIdAccount = @AccountId
	--WHERE
	--	Acc.AccIdAccount = @AccountId

	-- Punto de visita por cuenta ingresada (Por ingresada)
	--SET @VisitPointClientIdByUser = (
	--	SELECT CodeOfReference FROM DeliveryBackOffice.dbo.VisitPointClient VPC
	--	JOIN VisitPointByUser VPU
	--		ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
	--			AND VPU.RowStatus = 1
	--	JOIN RegisterUser ru
	--		ON VPU.RegisterUserID = ru.UsrIdUser
	--			AND ru.UsrRowStatus = 1
	--	JOIN [dbo].[RolByUserByAccount] rua
	--		ON rua.RuaIdUser = ru.UsrIdUser
	--	WHERE rua.RuaIdAccount = @AccountId
	--)

	BEGIN TRANSACTION
	BEGIN TRY
	
		-- Si es posible generar o redimir un cupon
		IF(EXISTS(SELECT TOP 1 1 FROM @TblDeliveryOrdersList))
		BEGIN

			-- Obtener valor anterior y valor con descuento aplicado
			SET @OldPriceshipment = (
				SELECT TOP 1 DO.PriceShippment FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
			)

			SET @UpdatedValue = (
				SELECT TOP 1 TDOL.PriceShippment FROM @TblDeliveryOrdersList TDOL WHERE TDOL.Guide_Serie = @GuideSerie AND TDOL.Guide_Number = @GuideNumber
			)

		END

		-- Generación de cupon
		IF( LTRIM(RTRIM(ISNULL(@CouponSerie, ''))) = '' AND EXISTS(SELECT TOP 1 1 FROM @TblDeliveryOrdersList) AND @GuideIsReturn = 0)
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
						(CatPromoId, PromoCouponSerie, GuideSerieOrigin, GuideNumberOrigin, CustomerOrigin, VisitPointClientOrigin, VisitPointClientPortfolioOrigin, SystemOrigin, CatDiscountTypeId, CatValueTypeId, CouponValue, StartActiveDate, FinalActiveDate, RowStatus, DateCreated, TokenCreated)
					OUTPUT
						inserted.PromoCouponSerie, inserted.FinalActiveDate, inserted.CatPromoId INTO @CouponDataReponse (CouponSerie, CouponFinalDate, PromoId)
					SELECT
						NCD.PromoId
						,CONCAT(@GuideSerie, @GuideNumber) + RIGHT('000' + CAST(CEILING(RAND()*100) AS NVARCHAR), 2)
						,@GuideSerie
						,@GuideNumber
						,@CustomerId
						,ISNULL(@VisitPointClientIdByUser, @VisitPointClientId)
						,@VisitPointClientPortfolioId
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
		ELSE IF (LTRIM(RTRIM(ISNULL(@CouponSerie, ''))) != '' AND EXISTS(SELECT TOP 1 1 FROM @TblDeliveryOrdersList) AND @GuideIsReturn = 0)
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
			SET @CouponIsReal = ISNULL((
				SELECT
					TOP 1
						1
				FROM
					[DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH(NOLOCK)
				WHERE
					PC.PromoCouponSerie = @CouponSerie
			), 0)

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
					VisitPointClientDestination = ISNULL(@VisitPointClientIdByUser, @VisitPointClientId),
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
					, StatusOrderId = @IdStatus
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
				from dbo.DeliveryOrderPaymentDetail pay
						inner join @TblDeliveryOrdersList t 
						on (t.Guide_Number = pay.GuideNumber and t.Guide_Serie = pay.GuideSerie) 

				IF(@@ROWCOUNT > 0)
				BEGIN
					SET @DOPDAlreadyUpdated = 1;
				END

				DECLARE @PromoName NVARCHAR(50) = '';

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
						,PaymentDate = GETDATE()
						,TokenUpdated = @Token
						,DateUpdated = GETDATE()
					WHERE
						IdCost = @CostId

					IF(ISNULL(@UpdatedValue, 0) > 0)
					BEGIN

						IF(NOT EXISTS( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CostDetail] CD WHERE CD.IdCost = @CostId ))
						BEGIN

							-- Nuevo valor en cost detail
							INSERT INTO
								[DeliveryBackOffice].[dbo].[CostDetail]
								(IdCost, Amount, IdTypeOfMoney, Voucher, RowStatus, TokenCreated, DateCreated)
							SELECT
								TOP 1
									@CostId
									,@UpdatedValue
									,TDOL.IdWayToPayment
									,IIF(TDOL.IdWayToPayment = 2 OR TDOL.IdWayToPayment = 6, @Voucher, '')
									,1
									,@Token
									,GETDATE()
							FROM
								@TblDeliveryOrdersList TDOL

						END
						ELSE
						BEGIN

							-- Actuaizar nuevo valor a Cost detail
							UPDATE
								[DeliveryBackOffice].[dbo].[CostDetail] 
							SET
								Amount = @UpdatedValue
								,TokenUpdated = @Token
								,DateUpdated = GETDATE()
							WHERE
								IdCost = @CostId

						END

					END
				END

				IF(
					EXISTS( 
						SELECT TOP 1 1 
						FROM 
							[DeliveryBackOffice].[dbo].[BreakdownOfPayment] BOP WITH(NOLOCK)
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
						PromoCouponId = (SELECT TOP 1 PC.IdPromoCoupon FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC WHERE PC.PromoCouponSerie = @CouponSerie)
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

		-- Flujo de SetServiceRecollect
		DECLARE @ValidateTransaction INT = (
			SELECT 
				DopId 
			FROM 
				[DeliveryBackOffice].[dbo].DeliveryOrderPaymentTransaction do
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
						, StatusOrderId = @IdStatus
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
					from dbo.DeliveryOrderPaymentDetail pay
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
								,IIF(@VisitPointClientId IS NULL , NULL, @VisitPointClientId)
						FROM 
							@TblDeliveryOrdersList tdop
						WHERE 
							tdop.PriceShippment != 0
							OR
							tdop.CODAmountProccess != 0

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

						IF(@CostId > 0)
						BEGIN

							UPDATE
								[DeliveryBackOffice].[dbo].[Cost] 
							SET
								TotalAmount = @UpdatedValue
								,TotalAmountPaid = @UpdatedValue
								,PaymentDate = GETDATE()
								,TokenUpdated = @Token
								,DateUpdated = GETDATE()
							WHERE
								IdCost = @CostId

						END
						ELSE
						BEGIN

							DECLARE @PaidWithCreditCard BIT = 0;
							SET @PaidWithCreditCard = ISNULL((
								SELECT
									TOP 1
										1
								FROM
									@TblDeliveryOrdersList TBOL
								WHERE
									TBOL.IdWayToPayment IN (@IdCreditCardPayment, @IdDatafonoPayment)
									AND
									@CustomerType NOT IN (@TypeExpressCenter)
							),0);

							DECLARE @ExecResult INT = 0;
							-- Revalorizar guía para generar registros
							EXEC @ExecResult =[dbo].[spws_revalue_guide]
								@GuideSerie  = @GuideSerie
								,@GuideNumber = @GuideNumber
								,@CodeApp = '' -- CodeApp generico de forza
								,@Format ='Non'
								,@CalculateTaxes = 'false' -- Dado a nuevas tarifas, no cálcular impuestos
								,@IdModule = 1
								,@SetUpdate = 'true' -- Actualizar registros
								,@Token = @Token
								,@ParIsCreditCard = @PaidWithCreditCard
								
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
							
							UPDATE
								[DeliveryBackOffice].[dbo].[Cost] 
							SET
								TotalAmount = @UpdatedValue
								,TotalAmountPaid = @UpdatedValue
								,PaymentDate = GETDATE()
								,TokenUpdated = @Token
								,DateUpdated = GETDATE()
							WHERE
								IdCost = @CostId

						END

						IF(NOT EXISTS( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CostDetail] CD WHERE CD.IdCost = @CostId ))
						BEGIN

							-- Nuevo valor en cost detail
							INSERT INTO
								[DeliveryBackOffice].[dbo].[CostDetail]
								(IdCost, Amount, IdTypeOfMoney, Voucher, RowStatus, TokenCreated, DateCreated)
							SELECT
								TOP 1
									@CostId
									,@UpdatedValue
									,TDOL.IdWayToPayment
									,IIF(TDOL.IdWayToPayment = 2 OR TDOL.IdWayToPayment = 6, @Voucher, '')
									,1
									,@Token
									,GETDATE()
							FROM
								@TblDeliveryOrdersList TDOL

						END
						ELSE
						BEGIN

							DECLARE @TypePayment INT = 0;

							SELECT
								@TypePayment = TDOL.IdWayToPayment
							FROM
								@TblDeliveryOrdersList TDOL

							-- Actuaizar nuevo valor a Cost detail
							UPDATE
								[DeliveryBackOffice].[dbo].[CostDetail] 
							SET
								Amount = @UpdatedValue
								,Voucher = IIF(@TypePayment = 2 OR @TypePayment = 6, @Voucher, '')
								,IdTypeOfMoney = @TypePayment
								,TokenUpdated = @Token
								,DateUpdated = GETDATE()
							WHERE
								IdCost = @CostId

						END

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
		
		IF @@TRANCOUNT > 0
		BEGIN

			IF(LTRIM(RTRIM(ISNULL(@CouponSerie, ''))) != '' AND @CouponIsValid = 0)
			BEGIN
				-- Error, cupon a aplicar no es valido
				ROLLBACK TRANSACTION;

				SET @JsonResponse =  
				( 
					SELECT STUFF(( 
						SELECT 
							',{' + 
								'"IdResult":401' + ',' +
								'"messageResult":"Cupon no esta vigente"' + ',' +
								'"Coupon": { } ' +
							'}'
						FOR XML PATH(''), TYPE 
					) 
					.value('.', 'varchar(max)'),1,1,'' 
					)
				) 

			END
			ELSE IF (LTRIM(RTRIM(ISNULL(@CouponSerie, ''))) != '' AND @CouponIsReal = 0)
			BEGIN
				-- Error, cupon a aplicar no es real
				ROLLBACK TRANSACTION;

				SET @JsonResponse =  
				( 
					SELECT STUFF(( 
						SELECT 
							',{' + 
								'"IdResult":407' + ',' +
								'"messageResult":"Cupon no es valido, por favor verifique su información"' + ',' +
								'"Coupon": { } ' + 
							'}'
						FOR XML PATH(''), TYPE 
					) 
					.value('.', 'varchar(max)'),1,1,'' 
					)
				) 
			END
			ELSE IF(@CouponCreated = 1)
			BEGIN

				COMMIT TRANSACTION;

				SET @JsonResponse =  
				( 
					SELECT STUFF(( 
							SELECT 
								TOP 1
									',{' + 
										'"IdResult":200' + ',' +
										'"messageResult":"Muchas gracias por usar nuestros servicios"' + ',' +
										'"Coupon": {' +
											'"CouponSerie": "' + CDR.CouponSerie + '",' +
											'"FinalDate": "' + CONVERT(NVARCHAR, CDR.CouponFinalDate ,103) + '",' +
											'"Promo": "' + CDR.CouponPromo + '"' +
										'} ' +
									'}'
							FROM
								@CouponDataReponse CDR
						FOR XML PATH(''), TYPE 
					) 
					.value('.', 'varchar(max)'),1,1,'' 
					)
				) 

			END
			ELSE IF(@CouponUpdated = 1 AND @CoUpdated = 1)
			BEGIN

				COMMIT TRANSACTION;

				SET @JsonResponse =  
				( 
					SELECT STUFF(( 
							SELECT 
								',{' + 
									'"IdResult":200' + ',' +
									'"messageResult":"Muchas gracias por usar nuestros servicios"' + ',' +
									'"Coupon": {} ' + 
								'}'
						FOR XML PATH(''), TYPE 
					) 
					.value('.', 'varchar(max)'),1,1,'' 
					)
				) 

			END
			ELSE IF(@CouponUpdated = 1 AND @CoUpdated = 0)
			BEGIN

				ROLLBACK TRANSACTION;

				SET @JsonResponse =  
				( 
					SELECT STUFF(( 
						SELECT 
							',{' + 
								'"IdResult":407' + ',' +
								'"messageResult":"Cupon no es valido, por favor verifique su información"' + ',' +
								'"messageError":"No se actualizo la tabla de Breakdown"' + ',' +
								'"Coupon": { } ' +
							'}'
						FOR XML PATH(''), TYPE 
					) 
					.value('.', 'varchar(max)'),1,1,'' 
					)
				) 

			END
			ELSE
			BEGIN

				COMMIT TRANSACTION;

				SET @JsonResponse =  
				( 
					SELECT STUFF(( 
							SELECT 
								',{' + 
									'"IdResult":200' + ',' +
									'"messageResult":"Muchas gracias por usar nuestros servicios"' + ',' +
									'"Coupon": {} ' + 
								'}'
						FOR XML PATH(''), TYPE 
					) 
					.value('.', 'varchar(max)'),1,1,'' 
					)
				) 

			END

			IF(@JsonResponse IS NULL)
			BEGIN

				SET @JsonResponse =  
				( 
					SELECT STUFF(( 
						SELECT 
							',{' + 
								'"IdResult":407' + ',' +
								'"messageResult":"Cupon no es valido, por favor verifique su información"' + ',' +
								'"Coupon": { } ' +
							'}'
						FOR XML PATH(''), TYPE 
					) 
					.value('.', 'varchar(max)'),1,1,'' 
					)
				) 

			END
			 
			select ('[' + @JsonResponse +  ']') JsonResponse
		END

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		
		SET @JsonResponse =  
		( 
			SELECT STUFF(( 
				SELECT 
					',{' + 
						'"IdResult":401' + ',' +
						'"messageResult":"Cupon no esta vigente"' + ',' +
						'"messageError":"' + ERROR_MESSAGE() + '"' + ',' +
						'"Coupon": { } ' + 
					'}'
				FOR XML PATH(''), TYPE 
			) 
			.value('.', 'varchar(max)'),1,1,'' 
			)
		) 
			 
		select ('[' + @JsonResponse +  ']') JsonOutput 

		--Insert en tabla de log
		INSERT INTO [dbo].[RoutePreparationLogError]
					([ErrorDescription]
					,[ErrorNumber]
					,[ErrorProcedure]
					,[ErrorLine]
					,[GuideSerie]
					,[GuideNumber]
					,[TokenCreated]
					,[DateCreated])
				VALUES
					(CAST(ERROR_MESSAGE() AS VARCHAR(300))
					,ERROR_NUMBER()
					,CAST(ERROR_PROCEDURE() AS VARCHAR(100))
					,ERROR_LINE()
					,''
					,0
					,''
					,GETDATE())
			
	END CATCH

END
