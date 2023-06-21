

-- =============================================
-- Author:		<Andrés Ruíz>
-- Create date: <2023-06-06>
-- Description:	< Procesamiento final de generación de cupones desde carrito de compras >
-- =============================================
CREATE PROCEDURE [dbo].[spHW_CompleteCouponProcessFromServiceCart]
	@IdAccount BIGINT, -- Cuenta del usuario
	@IdCustomer INT, -- cliente del usuario
	@Token NVARCHAR(50),
	@SystemName NVARCHAR(50), -- Hermes Web, Hermes Web-ExpressCenter, Hermes Web-Corporativo
	@InputGuidesList TblListGuides READONLY,
	@ImpersonatedCustomerId INT = NULL, -- Cliente impersonado
	@ImpersonatedCustomerAccountId BIGINT = NULL, -- Cliente impersonado
	@ClientPortfolioId INT = NULL -- Cliente impersonado

AS
BEGIN

	-- Variables para apoyo de control de flujo
	DECLARE @CustomerType INT -- Tipo de cliente procesando 
	DECLARE @CustomerVisitPointClient INT -- Punto de visita de cliente, de ser necesario
	DECLARE @SystemId INT =
	(
		SELECT 
			TOP (1)
				[CS].[SysIdSystem]
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
		WHERE
			[CS].[SysNameSystem] = @SystemName  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @IndividualType INT = -- Tipo de cliente individual (Nivel: [DeliveryBackOffice].[dbo].[Customer])
	(
		SELECT 
			TOP (1)
				[CT].[IdCustomerType]
		FROM
			[DeliveryBackOffice].[dbo].[CustomerType] CT  WITH(NOLOCK) 
		WHERE
			[CT].[Description] = 'INDIVIDUAL'  COLLATE Latin1_General_CI_AI 
	);
	DECLARE @RedistributorType INT = -- Tipo de cliente redistribuidor/express center (Nivel: [DeliveryBackOffice].[dbo].[Customer])
	(
		SELECT 
			TOP (1)
				[CT].[IdCustomerType]
		FROM
			[DeliveryBackOffice].[dbo].[CustomerType] CT  WITH(NOLOCK) 
		WHERE
			[CT].[Description] = 'REDISTRIBUIDOR'  COLLATE Latin1_General_CI_AI 
	);
	DECLARE @CorporateType INT = -- Tipo de cliente corporativo (Nivel: [DeliveryBackOffice].[dbo].[Customer])
	(
		SELECT 
			TOP (1)
				[CT].[IdCustomerType]
		FROM
			[DeliveryBackOffice].[dbo].[CustomerType] CT  WITH(NOLOCK) 
		WHERE
			[CT].[Description] = 'CORPORATIVO'  COLLATE Latin1_General_CI_AI 
	);
	DECLARE @IndividualAccountType INT = -- Tipo de cuenta individual (Nivel: [DeliveryBackOffice].[dbo].[Account])
	(
		SELECT 
			TOP (1)
				CTA.[TacIdTypeAccount]
		FROM
			[DeliveryBackOffice].[dbo].[CatTypeAccount] CTA  WITH(NOLOCK) 
		WHERE
			[CTA].[TacShortName] = 'IND'  COLLATE Latin1_General_CI_AI 
	)

	DECLARE @InmediateTimePaymentId INT = -- Tiempo de pago inmediato
	(
		SELECT 
			TOP (1)
				[CPT].[TimePlaId] 
		FROM 
			[DeliveryBackOffice].[dbo].[CatPaymentTime] CPT  WITH(NOLOCK) 
		WHERE 
			[CPT].[TimePlaName] = 'Ahora'
	);
	DECLARE @GeneratedGuideStatus INT = -- Estado de guía "Generado"
	(
		SELECT 
			TOP (1)
				[SO].[StatusOrderId]
		FROM
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			[SO].[OrderDescription] = 'Generado'  COLLATE Latin1_General_CI_AI 
	);

	-- Guías validas de carrito de compras para procesar
	DECLARE @ValidGuides TABLE
	(
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		PriceShipment DECIMAL(18,2)
	);

	DECLARE @ManualCouponGuides TABLE
	(
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		PriceShipment DECIMAL(18,2)
	);

	-- Primer proceso de encapsulación, errores sin ingreso de datos a base de datos
	BEGIN TRY

		-- Validación para revisar si cliente es impersonado
		IF( ISNULL(@ImpersonatedCustomerId, 0) = 0 AND ISNULL(@ImpersonatedCustomerAccountId, 0) = 0 )
		BEGIN
			-- No es cliente impersonado
			-- Obtener tipo de cliente de quien solicita procesamiento de cupones
			SET @CustomerType =
			ISNULL((
				SELECT 
					TOP (1) 
						[Cu].[IdCustomerType] 
				FROM 
					[DeliveryBackOffice].[dbo].[Account] Acc  WITH(NOLOCK) 
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Customer] Cu  WITH(NOLOCK) 
						ON
							[Cu].[IdCustomer] = [Acc].[IdCustomer]
				WHERE
					[Acc].[AccIdAccount] = @IdAccount
					AND
					[Acc].[AccRowStatus] = 1
			),0);
			-- Obtener punto de visita de cliente de quien solicita procesamiento de cupones, de ser posible
			SET @CustomerVisitPointClient =
			ISNULL((
				SELECT 
					TOP (1) 
						[VPC].[CodeOfReference] 
				FROM 
					[DeliveryBackOffice].[dbo].[Account] Acc  WITH(NOLOCK) 
					INNER JOIN
						[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA  WITH(NOLOCK) 
						ON
							[RBUBA].[RuaIdAccount] = [Acc].[AccIdAccount]
							AND
							[RBUBA].[RuaRowStatus] = 1
					INNER JOIN
						[DeliveryBackOffice].[dbo].[RegisterUser] RU  WITH(NOLOCK) 
						ON
							[RU].[UsrIdUser] = [RBUBA].[RuaIdUser]
					INNER JOIN
						[DeliveryBackOffice].[dbo].[VisitPointByUser] VPBU  WITH(NOLOCK) 
						ON
							[VPBU].[RegisterUserID] = [RU].[UsrIdUser]
					INNER JOIN
						[DeliveryBackOffice].[dbo].[VisitPointClient] VPC  WITH(NOLOCK) 
						ON
							[VPC].[IdVisitPointClient] = [VPBU].[IdVisitPointClient]
				WHERE
					[Acc].[AccIdAccount] = @IdAccount
					AND
					[Acc].[AccRowStatus] = 1
			),0);
		
			-- En caso no se identifique tipo de cliente mediante cuenta, buscar mediante cliente
			IF ( ISNULL(@CustomerType, 0) = 0 )
			BEGIN
				-- Buscar mediante identificador de cliente indicado
				SET @CustomerType =
				ISNULL((
					SELECT 
						TOP (1) 
							[Cu].[IdCustomerType] 
					FROM 
						[DeliveryBackOffice].[dbo].[Customer] Cu  WITH(NOLOCK) 
					WHERE
						[Cu].[IdCustomer] = @IdCustomer
				),0);
			END
		END
		ELSE
		BEGIN

			-- Cliente impersonado
			-- Buscar tipo de cliente impersonado mediante cuenta, de ser posible
			SET @CustomerType =
			ISNULL((
				SELECT 
					TOP (1) 
						[Cu].[IdCustomerType] 
				FROM 
					[DeliveryBackOffice].[dbo].[Account] Acc  WITH(NOLOCK) 
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Customer] Cu  WITH(NOLOCK) 
						ON
							[Cu].[IdCustomer] = [Acc].[IdCustomer]
				WHERE
					[Acc].[AccIdAccount] = @ImpersonatedCustomerAccountId
					AND
					[Acc].[AccRowStatus] = 1
			),0);

			-- Buscar punto de visita para otras validaciones, de ser posible
			SET @CustomerVisitPointClient =
			ISNULL((
				SELECT 
					TOP (1) 
						[VPC].[CodeOfReference] 
				FROM 
					[DeliveryBackOffice].[dbo].[Account] Acc  WITH(NOLOCK) 
					INNER JOIN
						[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA  WITH(NOLOCK) 
						ON
							[RBUBA].[RuaIdAccount] = [Acc].[AccIdAccount]
							AND
							[RBUBA].[RuaRowStatus] = 1
					INNER JOIN
						[DeliveryBackOffice].[dbo].[RegisterUser] RU  WITH(NOLOCK) 
						ON
							[RU].[UsrIdUser] = [RBUBA].[RuaIdUser]
					INNER JOIN
						[DeliveryBackOffice].[dbo].[VisitPointByUser] VPBU  WITH(NOLOCK) 
						ON
							[VPBU].[RegisterUserID] = [RU].[UsrIdUser]
					INNER JOIN
						[DeliveryBackOffice].[dbo].[VisitPointClient] VPC  WITH(NOLOCK) 
						ON
							[VPC].[IdVisitPointClient] = [VPBU].[IdVisitPointClient]
				WHERE
					[Acc].[AccIdAccount] = @ImpersonatedCustomerAccountId
					AND
					[Acc].[AccRowStatus] = 1
			),0);
		
			-- Buscar mediante identificador de cliente indicado
			IF ( ISNULL(@CustomerType, 0) = 0 )
			BEGIN
				SET @CustomerType =
				ISNULL((
					SELECT 
						TOP (1) 
							[Cu].[IdCustomerType] 
					FROM 
						[DeliveryBackOffice].[dbo].[Customer] Cu  WITH(NOLOCK) 
					WHERE
						[Cu].[IdCustomer] = @ImpersonatedCustomerId
				),0);
			END
		END

		-- Tipo de cliente individual
		IF ( @CustomerType = @IndividualType AND ISNULL(@ImpersonatedCustomerId, 0) = 0 AND ISNULL(@ImpersonatedCustomerAccountId, 0) = 0  )
		BEGIN
			-- Verificar por guías validas para proceso
			INSERT INTO @ValidGuides
			(
				[GuideSerie],
				[GuideNumber],
				[PriceShipment]
			)
			SELECT 
				[IGL].[Guide_Serie]
				,[IGL].[Guide_Number]
				,[DO].[PriceShippment]
			FROM
				[DeliveryBackOffice].[dbo].[AccountServiceCart] AccSC  WITH(NOLOCK) 
				INNER JOIN
					[DeliveryBackOffice].[dbo].[AccountServiceCartDetail] ASCD  WITH(NOLOCK) 
					ON
						[ASCD].[AccountServiceCartId] = [AccSC].[IdAccountServiceCart]
						AND
						[ASCD].[RowStatus] = 1
				INNER JOIN
					@InputGuidesList IGL
					ON
						[ASCD].[GuideSerie] = [IGL].[Guide_Serie]
						AND
						[ASCD].[GuideNumber] = [IGL].[Guide_Number]
				-- Indicadas como pago inmediato
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD  WITH(NOLOCK) 
					ON
						[IGL].[Guide_Serie] = [DOPD].[GuideSerie]
						AND
						[IGL].[Guide_Number] = [DOPD].[GuideNumber]
						AND
						[DOPD].[TimePlaId] = @InmediateTimePaymentId
				-- Estado generado
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
					ON
						[IGL].[Guide_Serie] = [DO].[Guide_Serie]
						AND
						[IGL].[Guide_Number] = [DO].[Guide_Number]
						AND
						[DO].[StatusOrderId] = @GeneratedGuideStatus
				-- No generaron cupones
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[PromoCoupon] PCOrigin  WITH(NOLOCK) 
					ON
						[IGL].[Guide_Serie] = [PCOrigin].[GuideSerieOrigin]
						AND
						[IGL].[Guide_Number] = [PCOrigin].[GuideNumberOrigin]
						AND
						[PCOrigin].[RowStatus] = 1
				-- No consumieron cupones
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[PromoCoupon] PCDestiny  WITH(NOLOCK) 
					ON
						[IGL].[Guide_Serie] = [PCDestiny].[GuideSerieDestination]
						AND
						[IGL].[Guide_Number] = [PCDestiny].[GuideNumberDestination]
						AND
						[PCDestiny].[RowStatus] = 1
				-- Sin pago exitoso o registrado
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[Cost] Co  WITH(NOLOCK) 
					ON
						[IGL].[Guide_Serie] = [Co].[GuideSerie]
						AND
						[IGL].[Guide_Number] = [Co].[GuideNumber]
						AND
						[Co].[TotalAmountPaid] > 0
						AND
						[Co].[RowStatus] = 1
				-- Sin descuento de monto fijo por membresía
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSLMembership  WITH(NOLOCK) 
					ON
						[MSLMembership].[LogGuideSerie] = [IGL].[Guide_Serie]
						AND
						[MSLMembership].[LogGuideNumber] = [IGL].[Guide_Number]
						AND
						[MSLMembership].[SubscriptionId] IS NULL
						AND
						[MSLMembership].[RowStatus] = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[Membership] MMBSHP  WITH(NOLOCK) 
					ON
						[MSLMembership].[MembershipId] = [MMBSHP].[IdMembership]
				-- Sin descuento de monto fijo por suscripción
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSLSubscription  WITH(NOLOCK) 
					ON
						[MSLSubscription].[LogGuideSerie] = [IGL].[Guide_Serie]
						AND
						[MSLSubscription].[LogGuideNumber] = [IGL].[Guide_Number]
						AND
						[MSLSubscription].[SubscriptionId] IS NOT NULL
						AND
						[MSLSubscription].[RowStatus] = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[Subscription] SBSCRPTN  WITH(NOLOCK) 
					ON
						[MSLMembership].[SubscriptionId] = [SBSCRPTN].[IdSubscription]
 			WHERE
				[AccSC].[AccountId] = ISNULL(@ImpersonatedCustomerAccountId, @IdAccount)
				AND
				[AccSC].[RowStatus] = 1
				AND
				[AccSC].[IsPending] = 1
				-- Validaciones
				AND
				[PCOrigin].[IdPromoCoupon] IS NULL -- Guía que no haya generado un cupón
				AND
				[PCDestiny].[IdPromoCoupon] IS NULL -- Guía que no haya precanjeado/canjeado un cupón
				AND
				[Co].[IdCost] IS NULL -- Guía que se identifique no tiene pago asociado
				AND
				-- Guía no esta en bitácora de membresía y, si esta, no esta en las de monto fijo
				([MSLMembership].[IdMembershipSubscriptionLog] IS NULL OR [MSLMembership].[LogServiceNumber] > [MMBSHP].[MembershipMaxServiceFixedValue])
				AND
				-- Guía no esta en bitácora de suscripción y, si esta, no esta en las de monto fijo
				([MSLSubscription].[IdMembershipSubscriptionLog] IS NULL OR [MSLSubscription].[LogServiceNumber] > [SBSCRPTN].[SubscriptionMaxServiceFixedValue])
		END
		-- Tipo de cliente redistribuidor
		ELSE IF ( @CustomerType = @RedistributorType OR (ISNULL(@ImpersonatedCustomerId, 0) > 0 OR ISNULL(@ImpersonatedCustomerAccountId, 0) > 0) )
		BEGIN
			-- Verificar por guías validas para proceso
			INSERT INTO @ValidGuides
			(
				[GuideSerie],
				[GuideNumber],
				[PriceShipment]
			)
			SELECT 
				[IGL].[Guide_Serie]
				,[IGL].[Guide_Number]
				,[DO].[PriceShippment]
			FROM
				[DeliveryBackOffice].[dbo].[ExpressAccountServiceCart] EASC  WITH(NOLOCK) 
				INNER JOIN
					[DeliveryBackOffice].[dbo].[ExpressAccountServiceCartDetail] EASCD  WITH(NOLOCK) 
					ON
						[EASCD].[ExpressAccountServiceCartId] = EASC.[IdExpressAccountServiceCart]
						AND
						[EASCD].[RowStatus] = 1
				INNER JOIN
					@InputGuidesList IGL
					ON
						[EASCD].[GuideSerie] = [IGL].[Guide_Serie]
						AND
						[EASCD].[GuideNumber] = [IGL].[Guide_Number]
				-- Indicadas como pago inmediato
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD  WITH(NOLOCK) 
					ON
						[IGL].[Guide_Serie] = [DOPD].[GuideSerie]
						AND
						[IGL].[Guide_Number] = [DOPD].[GuideNumber]
						AND
						[DOPD].[TimePlaId] = @InmediateTimePaymentId
				-- Estado generado
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
					ON
						[IGL].[Guide_Serie] = [DO].[Guide_Serie]
						AND
						[IGL].[Guide_Number] = [DO].[Guide_Number]
						AND
						[DO].[StatusOrderId] = @GeneratedGuideStatus
				-- No generaron cupones
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[PromoCoupon] PCOrigin  WITH(NOLOCK) 
					ON
						[IGL].[Guide_Serie] = [PCOrigin].[GuideSerieOrigin]
						AND
						[IGL].[Guide_Number] = [PCOrigin].[GuideNumberOrigin]
						AND
						[PCOrigin].[RowStatus] = 1
				-- No consumieron cupones
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[PromoCoupon] PCDestiny  WITH(NOLOCK) 
					ON
						[IGL].[Guide_Serie] = [PCDestiny].[GuideSerieDestination]
						AND
						[IGL].[Guide_Number] = [PCDestiny].[GuideNumberDestination]
						AND
						[PCDestiny].[RowStatus] = 1
				-- Sin pago exitoso o registrado
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[Cost] Co  WITH(NOLOCK) 
					ON
						[IGL].[Guide_Serie] = [Co].[GuideSerie]
						AND
						[IGL].[Guide_Number] = [Co].[GuideNumber]
						AND
						[Co].[TotalAmountPaid] > 0
						AND
						[Co].[RowStatus] = 1
				-- Sin descuento de monto fijo por membresía
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSLMembership  WITH(NOLOCK) 
					ON
						[MSLMembership].[LogGuideSerie] = [IGL].[Guide_Serie]
						AND
						[MSLMembership].[LogGuideNumber] = [IGL].[Guide_Number]
						AND
						[MSLMembership].[SubscriptionId] IS NULL
						AND
						[MSLMembership].[RowStatus] = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[Membership] MMBSHP  WITH(NOLOCK) 
					ON
						[MSLMembership].[MembershipId] = [MMBSHP].[IdMembership]
				-- Sin descuento de monto fijo por suscripción
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSLSubscription  WITH(NOLOCK) 
					ON
						[MSLSubscription].[LogGuideSerie] = [IGL].[Guide_Serie]
						AND
						[MSLSubscription].[LogGuideNumber] = [IGL].[Guide_Number]
						AND
						[MSLSubscription].[SubscriptionId] IS NOT NULL
						AND
						[MSLSubscription].[RowStatus] = 1
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[Subscription] SBSCRPTN  WITH(NOLOCK) 
					ON
						[MSLMembership].[SubscriptionId] = [SBSCRPTN].[IdSubscription]
 			WHERE
				[EASC].[AccountId] = @IdAccount
				AND
				(
					[EASC].[CustomerId] = @ImpersonatedCustomerId
					OR
					[EASC].[CustomerPortfolioId] = @ClientPortfolioId
				)
				AND
				[EASC].[RowStatus] = 1
				AND
				[EASC].[IsPending] = 1
				-- Validaciones
				AND
				[PCOrigin].[IdPromoCoupon] IS NULL -- Guía que no haya generado un cupón
				AND
				[PCDestiny].[IdPromoCoupon] IS NULL -- Guía que no haya precanjeado/canjeado un cupón
				AND
				[Co].[IdCost] IS NULL -- Guía que se identifique no tiene pago asociado
				AND
				-- Guía no esta en bitácora de membresía y, si esta, no esta en las de monto fijo
				([MSLMembership].[IdMembershipSubscriptionLog] IS NULL OR [MSLMembership].[LogServiceNumber] > [MMBSHP].[MembershipMaxServiceFixedValue])
				AND
				-- Guía no esta en bitácora de suscripción y, si esta, no esta en las de monto fijo
				([MSLSubscription].[IdMembershipSubscriptionLog] IS NULL OR [MSLSubscription].[LogServiceNumber] > [SBSCRPTN].[SubscriptionMaxServiceFixedValue])
		END
		--  Tipo de cliente corporativo, detener proceso
		ELSE IF ( @CustomerType = @CorporateType AND ISNULL(@ImpersonatedCustomerId, 0) = 0 AND ISNULL(@ImpersonatedCustomerAccountId, 0) = 0  )
		BEGIN
			;THROW 50001, 'Tipo de cliente no valido en proceso actualmente.', 2;
		END
		ELSE
		-- Tipo de cliente incorrecto, detener proceso
		BEGIN
			;THROW 50000, 'Tipo de cliente no reconocido, proporcionar más información.', 2;
		END

		-- Verificar por cupones ingresados manualmente
		INSERT INTO @ManualCouponGuides
		(
		    [GuideSerie],
		    [GuideNumber],
		    [PriceShipment]
		)
		SELECT
			[PC].[GuideSerieDestination]
			,[PC].[GuideNumberDestination]
			,[DO].[PriceShippment]
		FROM
			[DeliveryBackOffice].[dbo].[PromoCoupon] PC  WITH(NOLOCK) 
			INNER JOIN
				@InputGuidesList IGL
				ON
					[PC].[GuideSerieDestination] = [IGL].[Guide_Serie]
					AND
					[PC].[GuideNumberDestination] = [IGL].[Guide_Number]
			INNER JOIN
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
				ON
					[DO].[Guide_Serie] = [PC].[GuideSerieDestination] 
					AND 
					[DO].[Guide_Number] = [PC].[GuideNumberDestination]
		WHERE
			[PC].[RowStatus] = 1
	
		-- Sin guías validas a procesar y no hayan cupones manuales, detener proceso
		IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @ValidGuides ) AND NOT EXISTS ( SELECT TOP 1 1 FROM @ManualCouponGuides ) )
		BEGIN
			;THROW 50002, 'Sin guías validas en carrito de compras para proceso de verificación de cupones.', 1;
		END

		-- Manejo de cupones validos para día y cobertura disponible
		DECLARE @PromoTable TABLE
		(
			IdPromo INT,
			PromoDescription NVARCHAR(200),
			ValueType INT,
			PromoValue DECIMAL(5,2),
			DiscontType INT,
			LimitPromoTime DECIMAL(5,2),
			MinimumGuideExpected INT
		)

		-- Ingreso de promoción a aplicar
		INSERT INTO @PromoTable
		(
			[IdPromo],
			[PromoDescription],
			[ValueType],
			[PromoValue],
			[DiscontType],
			[LimitPromoTime],
			[MinimumGuideExpected]
		)
		SELECT 
			TOP (1) 
				[CP].[IdPromo]
				,[CP].[PromoDescription]
				,[CP].[CatValueTypeId]
				,[CP].[PromoValue]
				,[CP].[CatDiscountTypeId]
				,[CP].[LimitPromoTime]
				,[CP].[MinimumGuideExpected]
		FROM 
			[DeliveryBackOffice].[dbo].[CatPromo] CP  WITH(NOLOCK)
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[PromoCoverage] PC  WITH(NOLOCK) 
				ON
					[PC].[CatPromoId] = [CP].[IdPromo]
		WHERE
			[CP].[RowStatus] = 1
			AND
			-- Revisar cobertura de la promoción
			(
				PC.CustomerId = ISNULL(@ImpersonatedCustomerId,@IdCustomer)
				OR 
				PC.CustomerTypeId = @CustomerType
				OR 
				PC.VisitPointClientId = @CustomerVisitPointClient
			)
			AND
			-- Proceso dentro de fechas de promoción
			GETDATE() BETWEEN [CP].[StartPromoDate] AND [CP].[FinishPromoDate]
			AND
			-- Día exacto que aplica promoción
			(
				DATEPART(WEEKDAY, GETDATE()) = 1 AND [CP].[Sunday] = 1
				OR
				DATEPART(WEEKDAY, GETDATE()) = 2 AND [CP].[Monday] = 1
				OR
				DATEPART(WEEKDAY, GETDATE()) = 3 AND [CP].[Tuesday] = 1
				OR
				DATEPART(WEEKDAY, GETDATE()) = 4 AND [CP].[Wednesday] = 1
				OR
				DATEPART(WEEKDAY, GETDATE()) = 5 AND [CP].[Thursday] = 1
				OR
				DATEPART(WEEKDAY, GETDATE()) = 6 AND [CP].[Friday] = 1
				OR
				DATEPART(WEEKDAY, GETDATE()) = 7 AND [CP].[Saturday] = 1
			)
		ORDER BY
			[CP].[PromoWeight] DESC
		
		-- Sin poder aplicar promociones y no hayan cupones manuales, detener proceso
		IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @PromoTable ) AND NOT EXISTS ( SELECT TOP 1 1 FROM @ManualCouponGuides ) )
		BEGIN

			;THROW 50000, 'Sin promoción valida para aplicar', 1;

		END

		-- Cantidad de guías no es apta para promoción y no hayan cupones manuales, detener proceso
		IF 
		(
			(
				(
					SELECT
						COUNT(DISTINCT [VG].[GuideNumber])
					FROM
						@ValidGuides VG
				)
				/
				(
					SELECT 
						TOP (1) 
							[PT].[MinimumGuideExpected] 
					FROM 
						@PromoTable PT
				)
			)
			<= 0
			AND NOT EXISTS ( SELECT TOP 1 1 FROM @ManualCouponGuides ) 
		)
		BEGIN
			;THROW 50000, 'Cantidad de guías en carrito de compras no apta para promoción.', 1;
		END

		-- Temporal para procesamiento de guías para determinar guías para generación y guías de canjeo
		DECLARE @TempValidGuide TABLE
		(
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			PriceShipment DECIMAL(18,2)
		);

		-- Ingreso de guías a partir de las validas
		INSERT INTO @TempValidGuide
		(
			[GuideSerie],
			[GuideNumber],
			[PriceShipment]
		)
		SELECT 
			[VG].[GuideSerie],
			[VG].[GuideNumber],
			[VG].[PriceShipment] 
		FROM
			@ValidGuides VG

		-- Tabla auxiliar para procesamiento de brain de cupones
		DECLARE @PromoProcess TABLE
		(
			GuideSerieOrigin NVARCHAR(2),
			GuideNumberOrigin INT,
			GuideSerieDestiny NVARCHAR(2),
			GuideNumberDestiny INT,
			PromoToApply INT
		);

		-- Si hay promociones y guías validas, realizar proceso de pregeneración de cupones
		IF ( EXISTS ( SELECT TOP 1 1 FROM @PromoTable ) AND EXISTS ( SELECT TOP 1 1 FROM @ValidGuides ) )
		BEGIN
			-- Procesamiento de cupones
			WHILE 
			(
				-- Mientras exista una cantidad posible de guías para generar cupón
				FLOOR
				(
					(
						SELECT
							COUNT(DISTINCT [VG].[GuideNumber])
						FROM
							@TempValidGuide VG
					)
					/
					(
						SELECT 
							TOP (1) 
								[PT].[MinimumGuideExpected] 
						FROM 
							@PromoTable PT
					)
				)
				> 0
			)
			BEGIN
				-- Guía origen de cupón
				DECLARE @PossibleGuideOriginSerie NVARCHAR(2)
				DECLARE @PossibleGuideOriginNumber INT

				-- Guía destino de cupón
				DECLARE @PossibleGuideDestinySerie NVARCHAR(2)
				DECLARE @PossibleGuideDestinyNumber INT

				-- Cantidad auxiliar para remover por factor de guías
				DECLARE @FactorToRemove INT = (
					SELECT 
						TOP (1) 
							[PT].[MinimumGuideExpected] 
					FROM 
						@PromoTable PT
				) - 2; -- Cantidad minima menos guía origen y guía destino
				
				IF ( ISNULL(@FactorToRemove,0) < 0 )
				BEGIN
					SET @FactorToRemove = 0;
				END

				-- Obtener guía origen
				SELECT
					TOP (1)
						@PossibleGuideOriginSerie = [TVG].[GuideSerie],
						@PossibleGuideOriginNumber = [TVG].[GuideNumber]
				FROM
					@TempValidGuide TVG
				ORDER BY
					[TVG].[PriceShipment] DESC

				-- Obtener guía destino
				SELECT
					TOP (1)
						@PossibleGuideDestinySerie = [TVG].[GuideSerie],
						@PossibleGuideDestinyNumber = [TVG].[GuideNumber]
				FROM
					@TempValidGuide TVG
				WHERE
					[TVG].[GuideNumber] <> @PossibleGuideOriginNumber
				ORDER BY
					[TVG].[PriceShipment] ASC

				-- Ingresar a proceso de cupones con tipo de promoción a aplicar
				INSERT INTO @PromoProcess
				(
					[GuideSerieOrigin],
					[GuideNumberOrigin],
					[GuideSerieDestiny],
					[GuideNumberDestiny],
					[PromoToApply]
				)
				VALUES
				(   
					@PossibleGuideOriginSerie, -- GuideSerieOrigin - nvarchar(2)
					@PossibleGuideOriginNumber, -- GuideNumberOrigin - int
					@PossibleGuideDestinySerie, -- GuideSerieDestiny - nvarchar(2)
					@PossibleGuideDestinyNumber, -- GuideNumberDestiny - int
					(SELECT TOP (1) [PT].[IdPromo] FROM @PromoTable PT ORDER BY [PT].[IdPromo] ASC)  -- PromoToApply - int
				)

				-- Eliminar guía de origen de temporal de procesamiento
				DELETE FROM @TempValidGuide
				WHERE [GuideSerie] = @PossibleGuideOriginSerie AND [GuideNumber] = @PossibleGuideOriginNumber
				-- Eliminar guía de destino de temporal de procesamiento
				DELETE FROM @TempValidGuide
				WHERE [GuideSerie] = @PossibleGuideDestinySerie AND [GuideNumber] = @PossibleGuideDestinyNumber
				-- Eliminar guías adicionales si factor lo requiere
				IF ( ISNULL(@FactorToRemove,0) > 0 )
				BEGIN

					WHILE (ISNULL(@FactorToRemove,0) > 0)
					BEGIN

						-- Guía origen de cupón
						DECLARE @PossibleGuideAuxSerie NVARCHAR(2)
						DECLARE @PossibleGuideAuxNumber INT

						SELECT
							TOP (1)
								@PossibleGuideAuxSerie = [TVG].[GuideSerie],
								@PossibleGuideAuxNumber = [TVG].[GuideNumber]
						FROM
							@TempValidGuide TVG
						ORDER BY
							[TVG].[PriceShipment] DESC

						DELETE FROM @TempValidGuide
						WHERE [GuideSerie] = @PossibleGuideAuxSerie AND [GuideNumber] = @PossibleGuideAuxNumber

						SET @FactorToRemove = @FactorToRemove - 1;

					END

				END
			END

		END
		-- Error al realizar proceso de cupones y no hayan cupones manuales, detener proceso
		IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @PromoProcess ) AND NOT EXISTS ( SELECT TOP 1 1 FROM @ManualCouponGuides )  )
		BEGIN
			;THROW 50004, 'No se pudieron procesar carrito de compras para generación de cupones', 2;
		END

		-- Inicio de transacción de proceso de brain
		-- Segundo proceso de encapsulación, errores con manipulación de datos en base de datos (COMMIT/ROLLBACK)
		BEGIN TRANSACTION 
		BEGIN TRY

			-- Variables para proceso transaccional
			DECLARE @ProcessServiceCartId BIGINT; -- Carrito de compras a procesar
			DECLARE @ProcessServiceCartLastProcess BIGINT; -- Último procesamiento de cupones de carrito
			DECLARE @CountTotalProcessedGuides INT; -- Cantidad de guías procesadas por brain de cupones
			DECLARE @CountTotalMatchedProcessedGuides INT; -- Cantidad de guías verificadas de proceso de brain de cupones contra reproceso de verificación
			-- Procesamiento exitoso de ingreso de datos
			DECLARE @SuccessfulProcess TABLE 
			(
				IdPromoCouponProcessLog INT,
				GuideSerie NVARCHAR(2),
				GuideNumber INT
			);
		
			-- Si proceso cupones automaticos
			IF ( EXISTS ( SELECT TOP 1 1 FROM @PromoProcess ) )
			BEGIN
			    -- Buscar carrito de compras
				-- Cliente es individual y no es impersonado
				IF ( @CustomerType = @IndividualType AND ISNULL(@ImpersonatedCustomerId, 0) = 0 AND ISNULL(@ImpersonatedCustomerAccountId, 0) = 0 )
				BEGIN
					-- Pertenece a un individual
					-- Buscar identificador del carrito de compras e intento de procesamiento
					SELECT 
						TOP (1) 
							@ProcessServiceCartId = [PCPL].[AccountServiceCartId],
							@ProcessServiceCartLastProcess = [PCPL].[ProcessAttempt]
					FROM 
						[DeliveryBackOffice].[dbo].[PromoCouponProcessLog] PCPL  WITH(NOLOCK) 
						INNER JOIN
							[DeliveryBackOffice].[dbo].[AccountServiceCart] AccSC  WITH(NOLOCK) 
							ON
								[AccSC].[IdAccountServiceCart] = [PCPL].[AccountServiceCartId]
					WHERE
						[AccSC].[AccountId] = ISNULL(@ImpersonatedCustomerAccountId, @IdAccount)
						AND
						[AccSC].[IsPending] = 1
						AND
						[AccSC].[RowStatus] = 1
						AND
						[PCPL].[RowStatus] = 1
					ORDER BY
						[AccSC].[DateCreated] DESC

					-- No existe procesamiento del carrito de compras activo
					IF ( ISNULL(@ProcessServiceCartLastProcess, 0) = 0 AND NOT EXISTS ( SELECT TOP 1 1 FROM @ManualCouponGuides ) )
					BEGIN
						;THROW 50000, 'No existe procesamiento de cupones anterior, revisión no es valida en proceso.', 1;
					END
					-- Ya existe procesamiento anterior activo
					ELSE IF (ISNULL(@ProcessServiceCartLastProcess, 0) > 0)
					BEGIN
						SET @CountTotalProcessedGuides =
						(
							SELECT 
								COUNT (DISTINCT [PCPL].[IdPromoCouponProcessLog]) 
							FROM
								[DeliveryBackOffice].[dbo].[PromoCouponProcessLog] PCPL  WITH(NOLOCK) 
							WHERE
								[PCPL].[ProcessAttempt] = @ProcessServiceCartLastProcess
								AND
								[PCPL].[AccountServiceCartId] = @ProcessServiceCartId
								AND
								[PCPL].[RowStatus] = 1
						)

						SET @CountTotalMatchedProcessedGuides =
						(
							SELECT 
								COUNT (DISTINCT [PCPL].[IdPromoCouponProcessLog]) 
							FROM
								[DeliveryBackOffice].[dbo].[PromoCouponProcessLog] PCPL  WITH(NOLOCK) 
								INNER JOIN
									(
									SELECT 
										[VGStart].[GuideSerie] [GuideSerieOrigin],
										[VGStart].[GuideNumber] [GuideNumberOrigin],
										[VGStart].[PriceShipment] [PriceShipmentOrigin],
										[PT].[IdPromo],
										[PT].[PromoDescription],
										[CVT].[ValueTypeName],
										[PT].[PromoValue],
										[CTD].[ShortName],
										[PT].[LimitPromoTime],
										[PT].[MinimumGuideExpected],
										[VGEnd].[GuideSerie] [GuideSerieDestiny],
										[VGEnd].[GuideNumber] [GuideNumberDestiny],
										[VGEnd].[PriceShipment] [PriceShipmentDestiny] 
									FROM
										@ValidGuides VGStart
										LEFT JOIN
											@PromoProcess PP
											ON
												[VGStart].[GuideSerie] = [PP].[GuideSerieOrigin]
												AND
												[VGStart].[GuideNumber] = [PP].[GuideNumberOrigin]
										LEFT JOIN
											@PromoTable PT
											ON
												[PP].[PromoToApply] = [PT].[IdPromo]
										LEFT JOIN
											@ValidGuides VGEnd
											ON
												[VGEnd].[GuideSerie] = [PP].[GuideSerieDestiny]
												AND
												[VGEnd].[GuideNumber] = [PP].[GuideNumberDestiny]
										LEFT JOIN
											[DeliveryBackOffice].[dbo].[CatValueType] CVT  WITH(NOLOCK) 
											ON
												[PT].[ValueType] = [CVT].[IdCatValueType]
										LEFT JOIN
											[DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD  WITH(NOLOCK) 
											ON
												[PT].[DiscontType] = [CTD].[IdCatTypeDiscount]
									) PP
									ON
										[PCPL].[GuideSerieOrigin] = [PP].[GuideSerieOrigin]
										AND
										[PCPL].[GuideNumberOrigin] = [PP].[GuideNumberOrigin]
										AND
										ISNULL([PCPL].[CatPromoId], 0) = ISNULL([PP].[IdPromo], 0)
										AND
										ISNULL([PCPL].[GuideSerieDestiny], 'FD') = ISNULL([PP].[GuideSerieDestiny], 'FD')
										AND
										ISNULL([PCPL].[GuideNumberDestiny], 0) = ISNULL([PP].[GuideNumberDestiny], 0)
							WHERE
								[PCPL].[ProcessAttempt] = @ProcessServiceCartLastProcess
								AND
								[PCPL].[AccountServiceCartId] = @ProcessServiceCartId
								AND
								[PCPL].[RowStatus] = 1
						)

						IF ( @CountTotalMatchedProcessedGuides <> @CountTotalProcessedGuides )
						BEGIN
							;THROW 50005, 'La cantidad de guías procesadas contra la verificación no coinciden en datos', 2;
						END
					
						-- Ingreso y canjeo de cupones generados por brain 
						INSERT INTO [DeliveryBackOffice].[dbo].[PromoCoupon]
						(
							[CatPromoId],
							[PromoCouponSerie],
							[GuideSerieOrigin],
							[GuideNumberOrigin],
							[ServiceManagementOrigin],
							[SystemOrigin],
							[CustomerOrigin],
							[VisitPointClientOrigin],
							[VisitPointClientPortfolioOrigin],
							[GuideSerieDestination],
							[GuideNumberDestination],
							[ServiceManagementDestination],
							[SystemDestination],
							[CustomerDestination],
							[VisitPointClientDestination],
							[VisitPointClientPortfolioDestination],
							[CatDiscountTypeId],
							[CatValueTypeId],
							[CouponValue],
							[OriginalAmount],
							[DiscountAmount],
							[FinalAmount],
							[RedeemedDate],
							[StartActiveDate],
							[FinalActiveDate],
							[RowStatus],
							[DateCreated],
							[TokenCreated]
						)
						OUTPUT [Inserted].[IdPromoCoupon], [Inserted].[GuideSerieDestination], [Inserted].[GuideNumberDestination] INTO @SuccessfulProcess ([IdPromoCouponProcessLog], [GuideSerie], [GuideNumber])
						SELECT 
							[PCPL].[CatPromoId]
							,CONCAT([PCPL].[GuideSerieOrigin], [PCPL].[GuideNumberOrigin], RIGHT(CONCAT('000', RAND([PCPL].[GuideNumberOrigin] + CHECKSUM(GETDATE()))), 3))
							,[PCPL].[GuideSerieOrigin]
							,[PCPL].[GuideNumberOrigin]
							,NULL
							,@SystemId
							,NULL
							,NULL
							,NULL
							,[PCPL].[GuideSerieDestiny]
							,[PCPL].[GuideNumberDestiny]
							,NULL
							,@SystemId
							,NULL
							,NULL
							,NULL
							,[CP].[CatDiscountTypeId]
							,[CP].[CatValueTypeId]
							,[CP].[PromoValue]
							,[PCPL].[DestinyGuideAmount]
							,ROUND
							(
								(
									CASE
										WHEN [CVT].[ValueTypeName] = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													ROUND((([PCPL].[DestinyGuideAmount] * [CP].[PromoValue]) / 100), 1)
												ELSE 0
											END
										WHEN [CVT].[ValueTypeName] = 'Monto' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													CASE
														WHEN [CP].[PromoValue] > [PCPL].[DestinyGuideAmount] THEN
															[PCPL].[DestinyGuideAmount]
														ELSE
															[PCPL].[DestinyGuideAmount] - [CP].[PromoValue]
													END
												ELSE 0
											END
										WHEN [CVT].[ValueTypeName] = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													[PCPL].[DestinyGuideAmount]
												ELSE 0
											END
										ELSE 0
									END
								)
							,1)
							,ROUND((
								(
									[PCPL].[DestinyGuideAmount] - 
									(
										CASE
											WHEN [CVT].[ValueTypeName] = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [CTD].[ShortName] = 'TOT' THEN
														ROUND((([PCPL].[DestinyGuideAmount] * [CP].[PromoValue]) / 100), 1)
													ELSE 0
												END
											WHEN [CVT].[ValueTypeName] = 'Monto' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [CTD].[ShortName] = 'TOT' THEN
														CASE
															WHEN [CP].[PromoValue] > [PCPL].[DestinyGuideAmount] THEN
																[PCPL].[DestinyGuideAmount]
															ELSE
																[PCPL].[DestinyGuideAmount] - [CP].[PromoValue]
														END
													ELSE 0
												END
											WHEN [CVT].[ValueTypeName] = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [CTD].[ShortName] = 'TOT' THEN
														[PCPL].[DestinyGuideAmount]
													ELSE 0
												END
											ELSE 0
										END
									)
								)
							),1)
							,GETDATE()
							,GETDATE()
							,(
								CASE
									WHEN [CP].[LimitPromoTime] = 24.00 THEN
										DATEADD(SECOND, -1, CAST(DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) AS DATETIME))
									ELSE
										DATEADD(MINUTE, (ISNULL([CP].[LimitPromoTime], 1) * 60), GETDATE())
								END
							)
							,1
							,GETDATE()
							,@Token
						FROM
							[DeliveryBackOffice].[dbo].[PromoCouponProcessLog] PCPL  WITH(NOLOCK)
							INNER JOIN
								[DeliveryBackOffice].[dbo].[CatPromo] CP  WITH(NOLOCK) 
								ON
									[CP].[IdPromo] = [PCPL].[CatPromoId]
							INNER JOIN
								[DeliveryBackOffice].[dbo].[CatValueType] CVT  WITH(NOLOCK) 
								ON
									[CP].[CatValueTypeId] = [CVT].[IdCatValueType]
							INNER JOIN
								[DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD  WITH(NOLOCK) 
								ON
									[CTD].[IdCatTypeDiscount] = [CP].[CatDiscountTypeId]
						WHERE	
							[PCPL].[ProcessAttempt] = @ProcessServiceCartLastProcess
							AND
							[PCPL].[AccountServiceCartId] = @ProcessServiceCartId
							AND
							[PCPL].[CatPromoId] IS NOT NULL
							AND
							[PCPL].[RowStatus] = 1
					
						UPDATE
							[DeliveryBackOffice].[dbo].[PromoCouponProcessLog]
						SET
							[RowStatus] = 0
							,[DateUpdated] = GETDATE()
							,[TokenUpdated] = @Token
						WHERE
							[AccountServiceCartId] = @ProcessServiceCartId
							AND
							[RowStatus] = 1

					END
			
				END
				-- Cliente es redistribuidor o es impersonado
				ELSE IF ( @CustomerType = @RedistributorType OR (ISNULL(@ImpersonatedCustomerId, 0) > 0 OR ISNULL(@ImpersonatedCustomerAccountId, 0) > 0) )
				BEGIN

					SELECT 
						TOP (1) 
							@ProcessServiceCartId = [PCPL].[ExpressAccountServiceCartId],
							@ProcessServiceCartLastProcess = [PCPL].[ProcessAttempt]
					FROM 
						[DeliveryBackOffice].[dbo].[PromoCouponProcessLog] PCPL  WITH(NOLOCK) 
						INNER JOIN
							[DeliveryBackOffice].[dbo].[ExpressAccountServiceCart] EASC  WITH(NOLOCK) 
							ON
								EASC.[IdExpressAccountServiceCart] = [PCPL].[ExpressAccountServiceCartId]
					WHERE
						[EASC].[AccountId] = @IdAccount
						AND
						(
							[EASC].[CustomerId] = @ImpersonatedCustomerId
							OR
							[EASC].[CustomerPortfolioId] = @ClientPortfolioId
						)
						AND
						[EASC].[IsPending] = 1
						AND
						[EASC].[RowStatus] = 1
						AND
						[PCPL].[RowStatus] = 1
					ORDER BY
						[EASC].[DateCreated] DESC

					IF ( ISNULL(@ProcessServiceCartLastProcess, 0) = 0 AND NOT EXISTS ( SELECT TOP 1 1 FROM @ManualCouponGuides ) )
					BEGIN
						;THROW 50000, 'No existe procesamiento de cupones anterior, revisión no es valida en proceso.', 1;
					END
					ELSE IF (ISNULL(@ProcessServiceCartLastProcess, 0) > 0)
					BEGIN
					
						SET @CountTotalProcessedGuides =
						(
							SELECT 
								COUNT (DISTINCT [PCPL].[IdPromoCouponProcessLog]) 
							FROM
								[DeliveryBackOffice].[dbo].[PromoCouponProcessLog] PCPL  WITH(NOLOCK) 
							WHERE
								[PCPL].[ProcessAttempt] = @ProcessServiceCartLastProcess
								AND
								[PCPL].[ExpressAccountServiceCartId] = @ProcessServiceCartId
								AND
								[PCPL].[RowStatus] = 1
						)

						SET @CountTotalMatchedProcessedGuides =
						(
							SELECT 
								COUNT (DISTINCT [PCPL].[IdPromoCouponProcessLog]) 
							FROM
								[DeliveryBackOffice].[dbo].[PromoCouponProcessLog] PCPL  WITH(NOLOCK) 
								INNER JOIN
									(
									SELECT 
										[VGStart].[GuideSerie] [GuideSerieOrigin],
										[VGStart].[GuideNumber] [GuideNumberOrigin],
										[VGStart].[PriceShipment] [PriceShipmentOrigin],
										[PT].[IdPromo],
										[PT].[PromoDescription],
										[CVT].[ValueTypeName],
										[PT].[PromoValue],
										[CTD].[ShortName],
										[PT].[LimitPromoTime],
										[PT].[MinimumGuideExpected],
										[VGEnd].[GuideSerie] [GuideSerieDestiny],
										[VGEnd].[GuideNumber] [GuideNumberDestiny],
										[VGEnd].[PriceShipment] [PriceShipmentDestiny] 
									FROM
										@ValidGuides VGStart
										LEFT JOIN
											@PromoProcess PP
											ON
												[VGStart].[GuideSerie] = [PP].[GuideSerieOrigin]
												AND
												[VGStart].[GuideNumber] = [PP].[GuideNumberOrigin]
										LEFT JOIN
											@PromoTable PT
											ON
												[PP].[PromoToApply] = [PT].[IdPromo]
										LEFT JOIN
											@ValidGuides VGEnd
											ON
												[VGEnd].[GuideSerie] = [PP].[GuideSerieDestiny]
												AND
												[VGEnd].[GuideNumber] = [PP].[GuideNumberDestiny]
										LEFT JOIN
											[DeliveryBackOffice].[dbo].[CatValueType] CVT  WITH(NOLOCK) 
											ON
												[PT].[ValueType] = [CVT].[IdCatValueType]
										LEFT JOIN
											[DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD  WITH(NOLOCK) 
											ON
												[PT].[DiscontType] = [CTD].[IdCatTypeDiscount]
									) PP
									ON
										[PCPL].[GuideSerieOrigin] = [PP].[GuideSerieOrigin]
										AND
										[PCPL].[GuideNumberOrigin] = [PP].[GuideNumberOrigin]
										AND
										ISNULL([PCPL].[CatPromoId], 0) = ISNULL([PP].[IdPromo], 0)
										AND
										ISNULL([PCPL].[GuideSerieDestiny], 'FD') = ISNULL([PP].[GuideSerieDestiny], 'FD')
										AND
										ISNULL([PCPL].[GuideNumberDestiny], 0) = ISNULL([PP].[GuideNumberDestiny], 0)
							WHERE
								[PCPL].[ProcessAttempt] = @ProcessServiceCartLastProcess
								AND
								[PCPL].[ExpressAccountServiceCartId] = @ProcessServiceCartId
								AND
								[PCPL].[RowStatus] = 1
						)

						IF ( @CountTotalMatchedProcessedGuides <> @CountTotalProcessedGuides )
						BEGIN
							;THROW 50005, 'La cantidad de guías procesadas contra la verificación no coinciden en datos', 2;
						END
					
						-- Ingreso y canjeo de cupones generados por brain 
						INSERT INTO [DeliveryBackOffice].[dbo].[PromoCoupon]
						(
							[CatPromoId],
							[PromoCouponSerie],
							[GuideSerieOrigin],
							[GuideNumberOrigin],
							[ServiceManagementOrigin],
							[SystemOrigin],
							[CustomerOrigin],
							[VisitPointClientOrigin],
							[VisitPointClientPortfolioOrigin],
							[GuideSerieDestination],
							[GuideNumberDestination],
							[ServiceManagementDestination],
							[SystemDestination],
							[CustomerDestination],
							[VisitPointClientDestination],
							[VisitPointClientPortfolioDestination],
							[CatDiscountTypeId],
							[CatValueTypeId],
							[CouponValue],
							[OriginalAmount],
							[DiscountAmount],
							[FinalAmount],
							[RedeemedDate],
							[StartActiveDate],
							[FinalActiveDate],
							[RowStatus],
							[DateCreated],
							[TokenCreated]
						)
						OUTPUT [Inserted].[IdPromoCoupon], [Inserted].[GuideSerieDestination], [Inserted].[GuideNumberDestination] INTO @SuccessfulProcess ([IdPromoCouponProcessLog], [GuideSerie], [GuideNumber])
						SELECT 
							[PCPL].[CatPromoId]
							,CONCAT([PCPL].[GuideSerieOrigin], [PCPL].[GuideNumberOrigin], RIGHT(CONCAT('000', RAND([PCPL].[GuideNumberOrigin] + CHECKSUM(GETDATE()))), 3))
							,[PCPL].[GuideSerieOrigin]
							,[PCPL].[GuideNumberOrigin]
							,NULL
							,@SystemId
							,NULL
							,NULL
							,NULL
							,[PCPL].[GuideSerieDestiny]
							,[PCPL].[GuideNumberDestiny]
							,NULL
							,@SystemId
							,NULL
							,NULL
							,NULL
							,[CP].[CatDiscountTypeId]
							,[CP].[CatValueTypeId]
							,[CP].[PromoValue]
							,[PCPL].[DestinyGuideAmount]
							,ROUND
							(
								(
									CASE
										WHEN [CVT].[ValueTypeName] = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													ROUND((([PCPL].[DestinyGuideAmount] * [CP].[PromoValue]) / 100), 1)
												ELSE 0
											END
										WHEN [CVT].[ValueTypeName] = 'Monto' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													CASE
														WHEN [CP].[PromoValue] > [PCPL].[DestinyGuideAmount] THEN
															[PCPL].[DestinyGuideAmount]
														ELSE
															[PCPL].[DestinyGuideAmount] - [CP].[PromoValue]
													END
												ELSE 0
											END
										WHEN [CVT].[ValueTypeName] = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													[PCPL].[DestinyGuideAmount]
												ELSE 0
											END
										ELSE 0
									END
								)
							,1)
							,ROUND((
								(
									[PCPL].[DestinyGuideAmount] - 
									(
										CASE
											WHEN [CVT].[ValueTypeName] = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [CTD].[ShortName] = 'TOT' THEN
														ROUND((([PCPL].[DestinyGuideAmount] * [CP].[PromoValue]) / 100), 1)
													ELSE 0
												END
											WHEN [CVT].[ValueTypeName] = 'Monto' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [CTD].[ShortName] = 'TOT' THEN
														CASE
															WHEN [CP].[PromoValue] > [PCPL].[DestinyGuideAmount] THEN
																[PCPL].[DestinyGuideAmount]
															ELSE
																[PCPL].[DestinyGuideAmount] - [CP].[PromoValue]
														END
													ELSE 0
												END
											WHEN [CVT].[ValueTypeName] = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [CTD].[ShortName] = 'TOT' THEN
														[PCPL].[DestinyGuideAmount]
													ELSE 0
												END
											ELSE 0
										END
									)
								)
							),1)
							,GETDATE()
							,GETDATE()
							,(
								CASE
									WHEN [CP].[LimitPromoTime] = 24.00 THEN
										DATEADD(SECOND, -1, CAST(DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) AS DATETIME))
									ELSE
										DATEADD(MINUTE, (ISNULL([CP].[LimitPromoTime], 1) * 60), GETDATE())
								END
							)
							,1
							,GETDATE()
							,@Token
						FROM
							[DeliveryBackOffice].[dbo].[PromoCouponProcessLog] PCPL  WITH(NOLOCK)
							INNER JOIN
								[DeliveryBackOffice].[dbo].[CatPromo] CP  WITH(NOLOCK) 
								ON
									[CP].[IdPromo] = [PCPL].[CatPromoId]
							INNER JOIN
								[DeliveryBackOffice].[dbo].[CatValueType] CVT  WITH(NOLOCK) 
								ON
									[CP].[CatValueTypeId] = [CVT].[IdCatValueType]
							INNER JOIN
								[DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD  WITH(NOLOCK) 
								ON
									[CTD].[IdCatTypeDiscount] = [CP].[CatDiscountTypeId]
						WHERE	
							[PCPL].[ProcessAttempt] = @ProcessServiceCartLastProcess
							AND
							[PCPL].[ExpressAccountServiceCartId] = @ProcessServiceCartId
							AND
							[PCPL].[CatPromoId] IS NOT NULL
							AND
							[PCPL].[RowStatus] = 1
					
						UPDATE
							[DeliveryBackOffice].[dbo].[PromoCouponProcessLog]
						SET
							[RowStatus] = 0
							,[DateUpdated] = GETDATE()
							,[TokenUpdated] = @Token
						WHERE
							[ExpressAccountServiceCartId] = @ProcessServiceCartId
							AND
							[RowStatus] = 1
					
					END
		
				END
				-- Cliente es corporativo, detener proceso (ROLLBACK)
				ELSE IF ( @CustomerType = @CorporateType AND ISNULL(@ImpersonatedCustomerId, 0) = 0 AND ISNULL(@ImpersonatedCustomerAccountId, 0) = 0 )
				BEGIN
					;THROW 50001, 'Tipo de cliente no valido en proceso actualmente.', 2;
				END
				-- Cliente no identificado, detener proceso (ROLLBACK)
				ELSE
				BEGIN
					;THROW 50000, 'Tipo de cliente no reconocido, proporcionar más información.', 2;
				END

			END

			IF ( EXISTS ( SELECT TOP 1 1 FROM @ManualCouponGuides ) )
			BEGIN
				-- Cliente es individual y no es impersonado
				IF ( @CustomerType = @IndividualType AND ISNULL(@ImpersonatedCustomerId, 0) = 0 AND ISNULL(@ImpersonatedCustomerAccountId, 0) = 0 )
				BEGIN
					-- Pertenece a un individual
					-- Canjeo de cupones ingresados manualmente
					UPDATE
						[PC]
					SET
						[PC].[OriginalAmount] = [DO].[PriceShippment]
						,[PC].[DiscountAmount] = ROUND
						(
							(
								CASE
									WHEN [CVT].[ValueTypeName] = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [CTD].[ShortName] = 'TOT' THEN
												ROUND((([DO].[PriceShippment] * [PC].[CouponValue]) / 100), 1)
											ELSE 0
										END
									WHEN [CVT].[ValueTypeName] = 'Monto' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [CTD].[ShortName] = 'TOT' THEN
												CASE
													WHEN [PC].[CouponValue] > [DO].[PriceShippment] THEN
														[DO].[PriceShippment]
													ELSE
														[DO].[PriceShippment] - [PC].[CouponValue]
												END
											ELSE 0
										END
									WHEN [CVT].[ValueTypeName] = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [CTD].[ShortName] = 'TOT' THEN
												[DO].[PriceShippment]
											ELSE 0
										END
									ELSE 0
								END
							)
						,1)
						,[PC].[FinalAmount] = ROUND((
							(
								[DO].[PriceShippment] - 
								(
									CASE
										WHEN [CVT].[ValueTypeName] = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													ROUND((([DO].[PriceShippment] * [PC].[CouponValue]) / 100), 1)
												ELSE 0
											END
										WHEN [CVT].[ValueTypeName] = 'Monto' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													CASE
														WHEN [PC].[CouponValue] > [DO].[PriceShippment] THEN
															[DO].[PriceShippment]
														ELSE
															[DO].[PriceShippment] - [PC].[CouponValue]
													END
												ELSE 0
											END
										WHEN [CVT].[ValueTypeName] = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													[DO].[PriceShippment]
												ELSE 0
											END
										ELSE 0
									END
								)
							)
						),1)
						,[PC].[RedeemedDate] = GETDATE()
						,[PC].[DateUpdated] = GETDATE()
						,[PC].[TokenUpdated] = @Token
					OUTPUT [Inserted].[IdPromoCoupon], [Inserted].[GuideSerieDestination], [Inserted].[GuideNumberDestination] INTO @SuccessfulProcess ([IdPromoCouponProcessLog], [GuideSerie], [GuideNumber])
					FROM
						[DeliveryBackOffice].[dbo].[PromoCoupon] PC  WITH(NOLOCK) 
						INNER JOIN
							@InputGuidesList IGL
							ON
								[PC].[GuideSerieDestination] = [IGL].[Guide_Serie]
								AND
								[PC].[GuideNumberDestination] = [IGL].[Guide_Number]
						INNER JOIN
							[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
							ON
								[IGL].[Guide_Serie] = [DO].[Guide_Serie]
								AND
								[IGL].[Guide_Number] = [DO].[Guide_Number]
						INNER JOIN
							[DeliveryBackOffice].[dbo].[CatValueType] CVT  WITH(NOLOCK) 
							ON
								[PC].[CatValueTypeId] = [CVT].[IdCatValueType]
						INNER JOIN
							[DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD  WITH(NOLOCK) 
							ON
								[CTD].[IdCatTypeDiscount] = [PC].[CatDiscountTypeId]
					WHERE
						[PC].[RowStatus] = 1

				END
				-- Cliente es redistribuidor o es impersonado
				ELSE IF ( @CustomerType = @RedistributorType OR (ISNULL(@ImpersonatedCustomerId, 0) > 0 OR ISNULL(@ImpersonatedCustomerAccountId, 0) > 0) )
				BEGIN

					-- Canjeo de cupones ingresados manualmente
					UPDATE
						[PC]
					SET
						[PC].[OriginalAmount] = [DO].[PriceShippment]
						,[PC].[DiscountAmount] = ROUND
						(
							(
								CASE
									WHEN [CVT].[ValueTypeName] = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [CTD].[ShortName] = 'TOT' THEN
												ROUND((([DO].[PriceShippment] * [PC].[CouponValue]) / 100), 1)
											ELSE 0
										END
									WHEN [CVT].[ValueTypeName] = 'Monto' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [CTD].[ShortName] = 'TOT' THEN
												CASE
													WHEN [PC].[CouponValue] > [DO].[PriceShippment] THEN
														[DO].[PriceShippment]
													ELSE
														[DO].[PriceShippment] - [PC].[CouponValue]
												END
											ELSE 0
										END
									WHEN [CVT].[ValueTypeName] = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [CTD].[ShortName] = 'TOT' THEN
												[DO].[PriceShippment]
											ELSE 0
										END
									ELSE 0
								END
							)
						,1)
						,[PC].[FinalAmount] = ROUND((
							(
								[DO].[PriceShippment] - 
								(
									CASE
										WHEN [CVT].[ValueTypeName] = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													ROUND((([DO].[PriceShippment] * [PC].[CouponValue]) / 100), 1)
												ELSE 0
											END
										WHEN [CVT].[ValueTypeName] = 'Monto' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													CASE
														WHEN [PC].[CouponValue] > [DO].[PriceShippment] THEN
															[DO].[PriceShippment]
														ELSE
															[DO].[PriceShippment] - [PC].[CouponValue]
													END
												ELSE 0
											END
										WHEN [CVT].[ValueTypeName] = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN [CTD].[ShortName] = 'TOT' THEN
													[DO].[PriceShippment]
												ELSE 0
											END
										ELSE 0
									END
								)
							)
						),1)
						,[PC].[RedeemedDate] = GETDATE()
						,[PC].[DateUpdated] = GETDATE()
						,[PC].[TokenUpdated] = @Token
					OUTPUT [Inserted].[IdPromoCoupon], [Inserted].[GuideSerieDestination], [Inserted].[GuideNumberDestination] INTO @SuccessfulProcess ([IdPromoCouponProcessLog], [GuideSerie], [GuideNumber])
					FROM
						[DeliveryBackOffice].[dbo].[PromoCoupon] PC  WITH(NOLOCK) 
						INNER JOIN
							@InputGuidesList IGL
							ON
								[PC].[GuideSerieDestination] = [IGL].[Guide_Serie]
								AND
								[PC].[GuideNumberDestination] = [IGL].[Guide_Number]
						INNER JOIN
							[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
							ON
								[IGL].[Guide_Serie] = [DO].[Guide_Serie]
								AND
								[IGL].[Guide_Number] = [DO].[Guide_Number]
						INNER JOIN
							[DeliveryBackOffice].[dbo].[CatValueType] CVT  WITH(NOLOCK) 
							ON
								[PC].[CatValueTypeId] = [CVT].[IdCatValueType]
						INNER JOIN
							[DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD  WITH(NOLOCK) 
							ON
								[CTD].[IdCatTypeDiscount] = [PC].[CatDiscountTypeId]
					WHERE
						[PC].[RowStatus] = 1
					
				END
				-- Cliente es corporativo, detener proceso (ROLLBACK)
				ELSE IF ( @CustomerType = @CorporateType AND ISNULL(@ImpersonatedCustomerId, 0) = 0 AND ISNULL(@ImpersonatedCustomerAccountId, 0) = 0 )
				BEGIN
					;THROW 50001, 'Tipo de cliente no valido en proceso actualmente.', 2;
				END
				-- Cliente no identificado, detener proceso (ROLLBACK)
				ELSE
				BEGIN
					;THROW 50000, 'Tipo de cliente no reconocido, proporcionar más información.', 2;
				END

			END
			
			-- No ingreso correctamente procesamiento, detener proceso (ROLLBACK)
			IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @SuccessfulProcess ) )
			BEGIN
				;THROW 50005, 'No se ingreso correctamente proceso de cupones', 5;
			END

			-- Actualizar monto de costo
			UPDATE
				[Co]
			SET
				[Co].[TotalAmount] = [PC].[FinalAmount]
				,[Co].[TokenUpdated] = @Token
				,[Co].[DateUpdated] = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[Cost] Co
				INNER JOIN
					@SuccessfulProcess SP
					ON
						[Co].[GuideSerie] = [SP].[GuideSerie]
						AND
						[Co].[GuideNumber] = [SP].[GuideNumber]
				INNER JOIN
					[DeliveryBackOffice].[dbo].[PromoCoupon] PC  WITH(NOLOCK) 
					ON
						[SP].[IdPromoCouponProcessLog] = [PC].[IdPromoCoupon]

			-- Ingresar descuento de cupon
			INSERT INTO [DeliveryBackOffice].[dbo].[BreakdownOfPayment]
			(
			    [IdCost],
			    [Description],
			    [Amount],
			    [ModIdModule],
			    [RowStatus],
			    [TokenCreated],
			    [DateCreated],
			    [PromoCouponId]
			)
			SELECT 
				[Co].[IdCost]
				,CAST([CP].[PromoDescription] AS NVARCHAR(100))
				,-[PC].[DiscountAmount]
				,NULL
				,1
				,@Token
				,GETDATE()
				,[SP].[IdPromoCouponProcessLog]
			FROM
				[DeliveryBackOffice].[dbo].[Cost] Co  WITH(NOLOCK) 
				INNER JOIN
					@SuccessfulProcess SP
					ON
						[Co].[GuideSerie] = [SP].[GuideSerie]
						AND
						[Co].[GuideNumber] = [SP].[GuideNumber]
				INNER JOIN
					[DeliveryBackOffice].[dbo].[PromoCoupon] PC  WITH(NOLOCK) 
					ON
						[SP].[IdPromoCouponProcessLog] = [PC].[IdPromoCoupon]
				INNER JOIN
					[DeliveryBackOffice].[dbo].[CatPromo] CP  WITH(NOLOCK) 
					ON
						[PC].[CatPromoId] = [CP].[IdPromo]

			-- Actualizar guías a monto final
			UPDATE
				[DO]
			SET
				[DO].[PriceShippment] = [PC].[FinalAmount]
				,[DO].[DateUpdated] = GETDATE()
				,[DO].[TokenUpdated] = @Token
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
				INNER JOIN
					@SuccessfulProcess SP
					ON
						[DO].[Guide_Serie] = [SP].[GuideSerie]
						AND
						[DO].[Guide_Number] = [SP].[GuideNumber]
				INNER JOIN
					[DeliveryBackOffice].[dbo].[PromoCoupon] PC  WITH(NOLOCK) 
					ON
						[SP].[IdPromoCouponProcessLog] = [PC].[IdPromoCoupon]
		
			COMMIT TRANSACTION
		
			-- Devolver respuesta como individual
			IF ( @CustomerType = @IndividualType AND ISNULL(@ImpersonatedCustomerId, 0) = 0 AND ISNULL(@ImpersonatedCustomerAccountId, 0) = 0  )
			BEGIN
				SELECT
					200 [ResponseCode],
					'Proceso realizado exitosamente' [ResponseMessage]

			END
			-- Devolver respuesta como redistribuidor o cliente impersonado
			ELSE IF (  @CustomerType = @RedistributorType OR (ISNULL(@ImpersonatedCustomerId, 0) > 0 OR ISNULL(@ImpersonatedCustomerAccountId, 0) > 0)  )
			BEGIN
				SELECT
					200 [ResponseCode],
					'Proceso realizado exitosamente' [ResponseMessage]

			END
			-- Devolver respuesta como corporativo
			ELSE IF ( @CustomerType = @CorporateType AND ISNULL(@ImpersonatedCustomerId, 0) = 0 AND ISNULL(@ImpersonatedCustomerAccountId, 0) = 0  )
			BEGIN
				SELECT
					204 [ResponseCode],
					'Tipo de cliente no valido en proceso actualmente' [ResponseMessage]
			END
			-- Devolver respuesta como otros
			ELSE
			BEGIN
				SELECT
					204 [ResponseCode],
					'Tipo de cliente no reconocido, proporcionar más información' [ResponseMessage]
			END

		END TRY
		BEGIN CATCH
			-- Manejo de errores con ROLLBACK
			ROLLBACK TRANSACTION;

			IF ( ERROR_STATE() IN (1,3) )
			BEGIN
				SELECT
					404 [ResponseCode],
					ERROR_MESSAGE() [ResponseMessage]
			END
			ELSE IF ( ERROR_STATE() = 2 )
			BEGIN
				SELECT
					204 [ResponseCode],
					ERROR_MESSAGE() [ResponseMessage]
			END
			ELSE
			BEGIN
				SELECT
					500 [ResponseCode],
					ERROR_MESSAGE() [ResponseMessage]
			END

		END CATCH

	END TRY
	BEGIN CATCH
		-- Manejo de errores sin ROLLBACK
		IF ( ERROR_STATE() IN (1,3) )
		BEGIN
			SELECT
				404 [ResponseCode],
				ERROR_MESSAGE() [ResponseMessage]
		END
		ELSE IF ( ERROR_STATE() = 2 )
		BEGIN
			SELECT
				204 [ResponseCode],
				ERROR_MESSAGE() [ResponseMessage]
		END
		ELSE
		BEGIN
			SELECT
				500 [ResponseCode],
				ERROR_MESSAGE() [ResponseMessage]
		END

	END CATCH

END