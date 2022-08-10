
-- =============================================
-- Author:		<Andres,Ruiz>
-- Updated date:<2022-05-26>
-- Description:	< Se adiciona generación y manejo de cupones posterior a la transaccion de una tarjeta de credito/debito >
-- =============================================

CREATE PROCEDURE [dbo].[spws_set_facapidelcreditcardtransaction]
@Type as int = -1
,@System							as int			      	
,@CardNumber					as nvarchar(50)	  	  	
,@TypeCardNumber				as nvarchar(5)	      	
,@Currency						as int			      	
,@Ammount						as decimal(18,2)      	= NULL	
,@OrderNumber					as nvarchar(38)	  		= ''
,@Signature						as nvarchar(100)	  	=NULL	
,@CustomerReference				as int				  	
,@ReferenceNumber				as varchar(50)	      	= ''
,@ECIIndicator					as varchar(2)	      	= ''
,@Authenticationresult			as varchar(1)	      	= ''
,@TransactionStain				as varchar(50)	      	= ''
,@CAVV							as nvarchar(50)	  		= ''
,@ReasonCode					as nvarchar(50)	  		= NULL
,@ReasonDescription				as nvarchar(100)	  	= NULL
,@StatusSend					as int				  	= NULL
,@RowStatus						as bit				  	= 1
,@TokenCreated					as nvarchar(50)	  		= ''
,@DateCreated					as datetime		  		
,@TokenUpdated					as nvarchar(50)	  		= NULL
,@DateUpdated			 		as datetime		  		= NULL
--,@Token			 				as nvarchar(50)	  		= ''
,@AccountId INT = 0
,@VisitPointClientId INT = NULL
,@VisitPointClientPortfolioId INT = NULL
,@CouponSerie NVARCHAR(20) = NULL
,@TblDeliveryOrdersList [TblDeliveryOrdersList2] READONLY

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
		SELECT CodeOfReference FROM DeliveryBackOffice.dbo.VisitPointClient VPC
		JOIN VisitPointByUser VPU
			ON VPC.IdVisitPointClient = VPU.IdVisitPointClient
				AND VPU.RowStatus = 1
		JOIN RegisterUser ru
			ON VPU.RegisterUserID = ru.UsrIdUser
				AND ru.UsrRowStatus = 1
		JOIN [dbo].[RolByUserByAccount] rua
			ON rua.RuaIdUser = ru.UsrIdUser
		WHERE rua.RuaIdAccount = @AccountId
	)

	DECLARE @IdTransaction BIGINT= 0

	BEGIN TRANSACTION
	BEGIN TRY

	-- Flujo normal de authorizeTransaction
	IF	(@Type = 1)
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
						,@System
						,NCD.CouponDiscountType
						,NCD.CouponValueType
						,NCD.CouponValue
						,GETDATE()
						,NCD.CouponFinalDate
						,1
						,GETDATE()
						,@TokenCreated
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
					SystemDestination = @System,
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
					TokenUpdated = @TokenCreated
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
				from dbo.DeliveryOrderPaymentDetail pay
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
							[DeliveryBackOffice].[dbo].[BreakdownOfPayment] BOP 
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
						TokenUpdated = @TokenCreated,
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
						(@CostId, @PromoName, IIF(@UpdatedValue <= 0, -@OldPriceshipment, -(@OldPriceshipment - @UpdatedValue)), 1, GETDATE(), @TokenCreated, (SELECT TOP 1 PC.IdPromoCoupon FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC WHERE PC.PromoCouponSerie = @CouponSerie))

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
									,@TokenCreated
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

					END
			
			END
		END

			-- Flujo normal de spws_set_facapidelcreditcardtransaction
			SELECT @IdTransaction 	= isnull([IdTransaction],0)			
			FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH(NOLOCK)
			WHERE OrderNumber = @OrderNumber
			and  cast(@DateCreated AS DATE)  = CAST(DateCreated AS DATE) 
			if (@IdTransaction = 0)
			Begin 

			insert into DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
			(
			[System]					
			,CardNumber				
			,TypeCardNumber			
			,Currency				
			,Ammount				
			,OrderNumber			
			,[Signature]				
			,CustomerReference		
			,ReferenceNumber		
			,ECIIndicator			
			,Authenticationresult	
			,TransactionStain		
			,CAVV					
			,ReasonCode				
			,ReasonDescription		
			,StatusSend				
			,RowStatus				
			,TokenCreated			
			,DateCreated			
			,TokenUpdated			
			,DateUpdated	
			--,Token
			)
			values
			(
			@System					
			,@CardNumber				
			,@TypeCardNumber			
			,@Currency				
			,@Ammount				
			,@OrderNumber			
			,@Signature				
			,@CustomerReference		
			,@ReferenceNumber		
			,@ECIIndicator			
			,@Authenticationresult	
			,@TransactionStain		
			,@CAVV					
			,@ReasonCode				
			,@ReasonDescription		
			,@StatusSend				
			,@RowStatus				
			,@TokenCreated			
			,@DateCreated			
			,@TokenUpdated			
			,@DateUpdated			 
			--,@Token
			)
			SET @IdTransaction = isnull(@@Identity,0)
			end 
			else if (@IdTransaction > 0 )
			begin 
				update DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
				 SET 
					[System]				= @System					
			,		CardNumber				= @CardNumber				
			,		TypeCardNumber			= @TypeCardNumber
			,		Currency				= @Currency
			,		Ammount					= @Ammount
			,		OrderNumber				= @OrderNumber			
			,		[Signature]				= @Signature				
			,		CustomerReference		= @CustomerReference		
			,		ReferenceNumber			= @ReferenceNumber		
			,		ECIIndicator			= @ECIIndicator			
			,		Authenticationresult	= @Authenticationresult	
			,		TransactionStain		= @TransactionStain		
			,		CAVV					= @CAVV					
			,		ReasonCode				= @ReasonCode				
			,		ReasonDescription		= @ReasonDescription		
			,		StatusSend				= @StatusSend				
			,		RowStatus				= @RowStatus				
			,		TokenCreated			= @TokenCreated			
			,		DateCreated				= @DateCreated			
			,		TokenUpdated			= @TokenUpdated			
			,		DateUpdated				= @DateUpdated
				 where IdTransaction = @IdTransaction
				 AND OrderNumber = @OrderNumber
				 And StatusSend <> 1
				 AND cast(@DateCreated AS DATE)  = CAST(DateCreated AS DATE)

			end 

		-- 17-02-2022 Insert into CostDetail so we can save transaction data for Brain

		DECLARE @PaymentTable AS TblPaymentList

		INSERT INTO @PaymentTable
		(
			RowNumber,
			IdTypeOfMoney,
			Voucher,
			Amount,
			Responsible
		)
		VALUES
		(   
		0,    -- RowNumber - int
		2, -- IdTypeOfMoney - int
		@OrderNumber, -- Voucher - varchar(100)
		@Ammount, -- Amount - decimal(18, 2)
		@Signature  -- Responsible - nvarchar(100)
		)

		EXEC dbo.SetPaymentCost @TypeProduct = 1,    -- int
							@ProductNumber = @OrderNumber, -- varchar(20)
							@TblDetail = @PaymentTable,   -- TblPaymentList
							@FullPayment = @Ammount, -- decimal(12, 2)
							@TypeCharge = 1,     -- int
							@Token = @TokenCreated,         -- varchar(50)
							@CODPayment = NULL,  -- decimal(12, 2)
							@Responsible = @Signature    -- varchar(100)
		-- end 17-02-2022  ------------------------------------------------------------

		INSERT INTO DenariusLog_Dev.dbo.LOG_Http_Interceptor 
			([TypeOfUse], 
			[IdSystem], 
			[EntityObjectName], 
			[TransactionID], 
			[RQ_Method], 
			[RQ_Uri], 
			[RQ_Service], 
			[RQ_Header], 
			[RQ_Body], 
			[RQ_Object], 
			[RQ_Datetime], 
			[RQ_LauValue], 
			[RQ_Token], 
			[RQ_IdOrder], 
			[RS_Service], 
			[RS_StatusCode], 
			[RS_ReasonPhrase], 
			[RS_ReasonCode], 
			[RS_ReasonCodeMessage], 
			[RS_Header], 
			[RS_Body], 
			[RS_Object], 
			[RS_Datetime], 
			[RS_IdOrder], 
			[RS_LauValue], 
			[RS_Token])
			VALUES(
			'Push'																
			,15  																
			,'DeliveryBackOffice.dbo.CreditCardTransaction' 					
			,@IdTransaction														
			,'SOAP'																
			,'https://ecm.firstatlanticcommerce.com/PGService/Services.svc'		
			,1 																	
			,null 																
			,null 																
			,null																
			,@DateCreated														
			,null																
			,null 																
			,1 																	
			,2 																	
			,0 																	
			,null 		 														
			,@ReasonCode 														
			,@ReasonDescription													
			,null 																
			,null 																
			, null 																
			,@DateCreated														
			,@OrderNumber														
			,null 																
			,@TokenUpdated														
			)

		END
		ELSE IF (@Type = 2)
		BEGIN

			SELECT 
			@IdTransaction 		= [IdTransaction]			
			FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH(NOLOCK)
			WHERE OrderNumber = @OrderNumber

			update DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
			 SET ReasonCode = @ReasonCode
			  ,ReasonDescription = @ReasonDescription
			  ,DateUpdated = @DateUpdated
			  ,TokenUpdated = @TokenUpdated
			  ,ECIIndicator = @ECIIndicator
			  ,Authenticationresult = @Authenticationresult
			  ,ReferenceNumber = (CASE WHEN LTRIM(RTRIM(ISNULL(@ReferenceNumber,''))) <> '' THEN @ReferenceNumber ELSE ReferenceNumber END)
			  ,[Signature] = (CASE WHEN LTRIM(RTRIM(ISNULL(@Signature,''))) <> '' THEN @Signature ELSE [Signature] END)
			  ,TransactionStain	 = @TransactionStain	
			  ,CAVV = @CAVV	
			  ,StatusSend = @StatusSend
			 where IdTransaction = @IdTransaction
			 AND OrderNumber = @OrderNumber
			 AND StatusSend <> 1
			 AND cast(@DateUpdated AS DATE)  = CAST(DateCreated AS DATE)

			INSERT INTO DenariusLog_Dev.dbo.LOG_Http_Interceptor 
			([TypeOfUse], 
			[IdSystem], 
			[EntityObjectName], 
			[TransactionID], 
			[RQ_Method], 
			[RQ_Uri], 
			[RQ_Service], 
			[RQ_Header], 
			[RQ_Body], 
			[RQ_Object], 
			[RQ_Datetime], 
			[RQ_LauValue], 
			[RQ_Token], 
			[RQ_IdOrder], 
			[RS_Service], 
			[RS_StatusCode], 
			[RS_ReasonPhrase], 
			[RS_ReasonCode], 
			[RS_ReasonCodeMessage], 
			[RS_Header], 
			[RS_Body], 
			[RS_Object], 
			[RS_Datetime], 
			[RS_IdOrder], 
			[RS_LauValue], 
			[RS_Token])
			VALUES(
			'Push'															
			,15  															
			,'DeliveryBackOffice.dbo.CreditCardTransaction' 				
			,@IdTransaction													
			,'SOAP'															
			,'https://ecm.firstatlanticcommerce.com/PGService/Services.svc'	
			,1 																
			,null 															
			,null 															
			,null															
			,@DateUpdated													
			,null															
			,null 															
			,1 																
			,2 																
			,0 																
			,null 															
			,@ReasonCode 													
			,@ReasonDescription												
			,null 															
			,null 															
			,null															
			,@DateUpdated													
			,@OrderNumber												
			,null 															
			,@TokenUpdated													
			)

		END

		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION;

		select 200 Code,'Success' Description
		, (SELECT TOP 1 CouponSerie FROM @CouponDataReponse) coupSerie
		, (SELECT TOP 1 CONVERT(NVARCHAR, CouponFinalDate, 103) FROM @CouponDataReponse) coupDate
		, (SELECT TOP 1 CouponPromo FROM @CouponDataReponse) coupPromo

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		
		SELECT 'Error al procesar transacción' AS message,
			'FALSE'	blnResult,
			CAST(-1 AS VARCHAR(5)) IdResult,
			CAST(500 AS VARCHAR(5)) StatusResult,
			CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
			CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
			CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
			CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
			CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
			CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage;

	END CATCH
	
END
