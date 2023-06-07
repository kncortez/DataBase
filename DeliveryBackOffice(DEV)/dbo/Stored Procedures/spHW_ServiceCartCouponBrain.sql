

-- =============================================
-- Author:		<Andrés Ruíz>
-- Create date: <2023-06-05>
-- Description:	< Brain para generación de cupones a partir de carrito de compras de usuario >
-- =============================================
CREATE PROCEDURE [dbo].[spHW_ServiceCartCouponBrain]

	@IdAccount BIGINT , -- Cuenta del usuario
	@IdCustomer INT, -- cliente del usuario
	@Token NVARCHAR(50),
	@InputGuidesList TblListGuides READONLY,
	@ImpersonatedCustomerId INT = NULL, -- Cliente impersonado
	@ImpersonatedCustomerAccountId BIGINT = NULL, -- Cliente impersonado
	@ClientPortfolioId INT = NULL -- Cliente impersonado

AS
BEGIN
	-- Variables para apoyo de control de flujo
	DECLARE @CustomerType INT -- Tipo de cliente procesando 
	DECLARE @CustomerVisitPointClient INT -- Punto de visita de cliente, de ser necesario
	DECLARE @ProcessServiceCartId BIGINT; -- Carrito de compras a procesar
	DECLARE @ProcessServiceCartLastProcess BIGINT; -- Último procesamiento de cupones de carrito
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
		
		-- Desactivar procesos previos
		SELECT 
			TOP (1) 
				@ProcessServiceCartId = [PCPL].[AccountServiceCartId]
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

		UPDATE
			[DeliveryBackOffice].[dbo].[PromoCouponProcessLog]
		SET
			[RowStatus] = 0
			,[TokenUpdated] = @Token
			,[DateUpdated] = GETDATE()
		WHERE
			[AccountServiceCartId] = @ProcessServiceCartId
			AND
			[RowStatus] = 1

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
	
		-- Sin guías validas a procesar, detener proceso
		IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @ValidGuides ) )
		BEGIN
			;THROW 50002, 'Sin guías validas en carrito de compras para proceso de cupones.', 1;
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
		
		-- Sin poder aplicar promociones, detener proceso
		IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @PromoTable ) )
		BEGIN

			;THROW 50000, 'Sin promoción valida para aplicar', 1;

		END

		-- Cantidad de guías no es apta para promoción, detener proceso
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
		END

		-- Error al realizar proceso de cupones, detener proceso
		IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @PromoProcess ) )
		BEGIN
			;THROW 50004, 'No se pudieron procesar carrito de compras para generación de cupones', 2;
		END

		-- Inicio de transacción de proceso de brain
		-- Segundo proceso de encapsulación, errores con manipulación de datos en base de datos (COMMIT/ROLLBACK)
		BEGIN TRANSACTION 
		BEGIN TRY

			-- Procesamiento exitoso de ingreso de datos
			DECLARE @SuccessfulProcess TABLE 
			(
				IdPromoCouponProcessLog BIGINT
			);
		
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
				IF ( ISNULL(@ProcessServiceCartLastProcess, 0) = 0 )
				BEGIN

					INSERT INTO [DeliveryBackOffice].[dbo].[PromoCouponProcessLog]
					(
						[AccountServiceCartId],
						[ExpressAccountServiceCartId],
						[ProcessAttempt],
						[CatPromoId],
						[GuideSerieOrigin],
						[GuideNumberOrigin],
						[GuideSerieDestiny],
						[GuideNumberDestiny],
						[OriginGuideAmount],
						[DestinyGuideAmount],
						[RowStatus],
						[DateCreated],
						[TokenCreated]
					)
					OUTPUT [Inserted].[IdPromoCouponProcessLog] INTO @SuccessfulProcess([IdPromoCouponProcessLog])
					SELECT 
						[AccSC].[IdAccountServiceCart]
						,NULL
						,ISNULL(@ProcessServiceCartLastProcess, 1)
						,[PP].[IdPromo]
						,[PP].[GuideSerieOrigin]
						,[PP].[GuideNumberOrigin]
						,[PP].[GuideSerieDestiny]
						,[PP].[GuideNumberDestiny]
						,[PP].[PriceShipmentOrigin]
						,[PP].[PriceShipmentDestiny]
						,1
						,GETDATE()
						,@Token
					FROM
						[DeliveryBackOffice].[dbo].[AccountServiceCart] AccSC  WITH(NOLOCK) 
						CROSS JOIN
							(
								SELECT 
									[VGStart].[GuideSerie] [GuideSerieOrigin],
									[VGStart].[GuideNumber] [GuideNumberOrigin],
									[VGStart].[PriceShipment] [PriceShipmentOrigin],
									[PT].[IdPromo],
									[PT].[PromoDescription],
									[PT].[ValueType],
									[PT].[PromoValue],
									[PT].[DiscontType],
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
							) PP
					WHERE
						[AccSC].[AccountId] = ISNULL(@ImpersonatedCustomerAccountId, @IdAccount)
						AND
						[AccSC].[RowStatus] = 1
						AND
						[AccSC].[IsPending] = 1

				END
				-- Ya existe procesamiento anterior activo
				ELSE
				BEGIN

					UPDATE
						[DeliveryBackOffice].[dbo].[PromoCouponProcessLog]
					SET
						[RowStatus] = 0
						,[TokenUpdated] = @Token
						,[DateUpdated] = GETDATE()
					WHERE
						[AccountServiceCartId] = @ProcessServiceCartId
						AND
						[RowStatus] = 1

					INSERT INTO [DeliveryBackOffice].[dbo].[PromoCouponProcessLog]
					(
						[AccountServiceCartId],
						[ExpressAccountServiceCartId],
						[ProcessAttempt],
						[CatPromoId],
						[GuideSerieOrigin],
						[GuideNumberOrigin],
						[GuideSerieDestiny],
						[GuideNumberDestiny],
						[OriginGuideAmount],
						[DestinyGuideAmount],
						[RowStatus],
						[DateCreated],
						[TokenCreated]
					)
					OUTPUT [Inserted].[IdPromoCouponProcessLog] INTO @SuccessfulProcess([IdPromoCouponProcessLog])
					SELECT 
						[AccSC].[IdAccountServiceCart]
						,NULL
						,@ProcessServiceCartLastProcess + 1
						,[PP].[IdPromo]
						,[PP].[GuideSerieOrigin]
						,[PP].[GuideNumberOrigin]
						,[PP].[GuideSerieDestiny]
						,[PP].[GuideNumberDestiny]
						,[PP].[PriceShipmentOrigin]
						,[PP].[PriceShipmentDestiny]
						,1
						,GETDATE()
						,@Token
					FROM
						[DeliveryBackOffice].[dbo].[AccountServiceCart] AccSC  WITH(NOLOCK) 
						CROSS JOIN
							(
								SELECT 
									[VGStart].[GuideSerie] [GuideSerieOrigin],
									[VGStart].[GuideNumber] [GuideNumberOrigin],
									[VGStart].[PriceShipment] [PriceShipmentOrigin],
									[PT].[IdPromo],
									[PT].[PromoDescription],
									[PT].[ValueType],
									[PT].[PromoValue],
									[PT].[DiscontType],
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
							) PP
					WHERE
						[AccSC].[AccountId] = ISNULL(@ImpersonatedCustomerAccountId, @IdAccount)
						AND
						[AccSC].[RowStatus] = 1
						AND
						[AccSC].[IsPending] = 1
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

				IF ( ISNULL(@ProcessServiceCartLastProcess, 0) = 0 )
				BEGIN

					INSERT INTO [DeliveryBackOffice].[dbo].[PromoCouponProcessLog]
					(
						[AccountServiceCartId],
						[ExpressAccountServiceCartId],
						[ProcessAttempt],
						[CatPromoId],
						[GuideSerieOrigin],
						[GuideNumberOrigin],
						[GuideSerieDestiny],
						[GuideNumberDestiny],
						[OriginGuideAmount],
						[DestinyGuideAmount],
						[RowStatus],
						[DateCreated],
						[TokenCreated]
					)
					OUTPUT [Inserted].[IdPromoCouponProcessLog] INTO @SuccessfulProcess([IdPromoCouponProcessLog])
					SELECT 
						NULL
						,[EASC].[IdExpressAccountServiceCart]
						,ISNULL(@ProcessServiceCartLastProcess, 1)
						,[PP].[IdPromo]
						,[PP].[GuideSerieOrigin]
						,[PP].[GuideNumberOrigin]
						,[PP].[GuideSerieDestiny]
						,[PP].[GuideNumberDestiny]
						,[PP].[PriceShipmentOrigin]
						,[PP].[PriceShipmentDestiny]
						,1
						,GETDATE()
						,@Token
					FROM
						[DeliveryBackOffice].[dbo].[ExpressAccountServiceCart] EASC  WITH(NOLOCK) 
						CROSS JOIN
							(
								SELECT 
									[VGStart].[GuideSerie] [GuideSerieOrigin],
									[VGStart].[GuideNumber] [GuideNumberOrigin],
									[VGStart].[PriceShipment] [PriceShipmentOrigin],
									[PT].[IdPromo],
									[PT].[PromoDescription],
									[PT].[ValueType],
									[PT].[PromoValue],
									[PT].[DiscontType],
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
							) PP
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

				END
				ELSE
				BEGIN

					UPDATE
						[DeliveryBackOffice].[dbo].[PromoCouponProcessLog]
					SET
						[RowStatus] = 0
						,[TokenUpdated] = @Token
						,[DateUpdated] = GETDATE()
					WHERE
						[ExpressAccountServiceCartId] = @ProcessServiceCartId
						AND
						[RowStatus] = 1

					INSERT INTO [DeliveryBackOffice].[dbo].[PromoCouponProcessLog]
					(
						[AccountServiceCartId],
						[ExpressAccountServiceCartId],
						[ProcessAttempt],
						[CatPromoId],
						[GuideSerieOrigin],
						[GuideNumberOrigin],
						[GuideSerieDestiny],
						[GuideNumberDestiny],
						[OriginGuideAmount],
						[DestinyGuideAmount],
						[RowStatus],
						[DateCreated],
						[TokenCreated]
					)
					OUTPUT [Inserted].[IdPromoCouponProcessLog] INTO @SuccessfulProcess([IdPromoCouponProcessLog])
					SELECT 
						NULL
						,[EASC].[IdExpressAccountServiceCart]
						,@ProcessServiceCartLastProcess + 1
						,[PP].[IdPromo]
						,[PP].[GuideSerieOrigin]
						,[PP].[GuideNumberOrigin]
						,[PP].[GuideSerieDestiny]
						,[PP].[GuideNumberDestiny]
						,[PP].[PriceShipmentOrigin]
						,[PP].[PriceShipmentDestiny]
						,1
						,GETDATE()
						,@Token
					FROM
						[DeliveryBackOffice].[dbo].[ExpressAccountServiceCart] EASC  WITH(NOLOCK) 
						CROSS JOIN
							(
								SELECT 
									[VGStart].[GuideSerie] [GuideSerieOrigin],
									[VGStart].[GuideNumber] [GuideNumberOrigin],
									[VGStart].[PriceShipment] [PriceShipmentOrigin],
									[PT].[IdPromo],
									[PT].[PromoDescription],
									[PT].[ValueType],
									[PT].[PromoValue],
									[PT].[DiscontType],
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
							) PP
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

			-- No ingreso correctamente procesamiento, detener proceso (ROLLBACK)
			IF ( NOT EXISTS ( SELECT TOP 1 1 FROM @SuccessfulProcess ) )
			BEGIN
				;THROW 50005, 'No se ingreso correctamente proceso de cupones', 5;
			END
		
			-- Proceso a base de datos exitoso
			COMMIT TRANSACTION
		
			-- Devolver respuesta como individual
			IF ( @CustomerType = @IndividualType )
			BEGIN
				SELECT
					200 [ResponseCode],
					'Proceso realizado exitosamente' [ResponseMessage]

				-- SELECCIONAR CARRITO DE INDIVIDUALES
				SELECT
					ascd.IdAccountServiceCartDetail
					,ascd.GuideSerie
					,ascd.GuideNumber
					,do.Pieces_Dry
					,do.Pieces_Cold
					, ROUND((
						CASE
							WHEN [PPDest].[RowNum] IS NOT NULL THEN 
								(
									[do].[PriceShippment] - 
									(
										CASE
											WHEN [PPDest].ValueTypeName = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [PPDest].ShortName = 'TOT' THEN
														ROUND((([do].[PriceShippment] * [PPDest].[PromoValue]) / 100), 1)
													ELSE 0
												END
											WHEN [PPDest].ValueTypeName = 'Monto' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [PPDest].ShortName = 'TOT' THEN
														CASE
															WHEN [PPDest].[PromoValue] > [do].[PriceShippment] THEN
																[do].[PriceShippment]
															ELSE
																[do].[PriceShippment] - [PPDest].[PromoValue]
														END
													ELSE 0
												END
											WHEN [PPDest].ValueTypeName = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [PPDest].ShortName = 'TOT' THEN
														[do].[PriceShippment]
													ELSE 0
												END
											ELSE 0
										END
									)
								)
							ELSE 
								do.PriceShippment
						END
					),1) [PriceShippment]
					,do.Sender_ID
					,CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) ReceiverName
					,do.Receiver_Address
					,do.IsCollect
					,do.Collect_OnDelivery
					,ISNULL(CAST(do.DCBA_ID AS NVARCHAR), '') 'DCBA_ID'
					,ISNULL(CAST(do.InsuranceAmount AS NVARCHAR),'') InsuranceAmount
					,(CASE WHEN ISNULL(MSL.IdMembershipSubscriptionLog, 0) > 0 THEN 'true' ELSE 'false' END) UsedMembership
					,CAST(ISNULL((CASE WHEN [PPDest].[RowNum] IS NULL THEN 0 ELSE 1 END),0) AS BIT) [AppliedCoupon]
					,CAST(ISNULL((CASE WHEN [PPOri].[PromoToApply] IS NULL THEN 0 ELSE 1 END),0) AS BIT) [GeneratedCoupon]
				FROM AccountServiceCartDetail ascd
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON do.Guide_Serie = ascd.GuideSerie
					AND do.Guide_Number = ascd.GuideNumber
				LEFT JOIN DeliveryBackOffice.dbo.MembershipSubscriptionLog MSL WITH(NOLOCK)
					ON ascd.GuideSerie = MSL.LogGuideSerie
					AND ascd.GuideNumber = MSL.LogGuideNumber
					AND MSL.RowStatus = 1
				LEFT JOIN 
					(
						SELECT 
							ROW_NUMBER() OVER (ORDER BY (SELECT 0)) [RowNum],
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
					) PPDest
					ON
						[ascd].[GuideSerie] = [PPDest].[GuideSerieDestiny]
						AND
						[ascd].[GuideNumber] = [PPDest].[GuideNumberDestiny]
				LEFT JOIN @PromoProcess PPOri 
					ON [ascd].[GuideSerie] = [PPOri].[GuideSerieOrigin]
					AND [ascd].[GuideNumber] = [PPOri].[GuideNumberOrigin]
					AND [PPOri].[PromoToApply] IS NOT NULL
				WHERE ascd.AccountServiceCartId = @ProcessServiceCartId
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
				WHERE ascd.AccountServiceCartId = @ProcessServiceCartId
				AND ascd.RowStatus = 1
				UNION
				SELECT
					[PP].[GuideSerieDestiny]
					,[PP].[GuideNumberDestiny]
					,[PP].[PromoDescription]
					,ROUND(-(
						(
							(
								CASE
									WHEN [PP].ValueTypeName = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [PP].ShortName = 'TOT' THEN
												ROUND((([PP].[PriceShipmentDestiny] * [PP].[PromoValue]) / 100), 1)
											ELSE 0
										END
									WHEN [PP].ValueTypeName = 'Monto' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [PP].ShortName = 'TOT' THEN
												CASE
													WHEN [PP].[PromoValue] > [PP].[PriceShipmentDestiny] THEN
														[PP].[PriceShipmentDestiny]
													ELSE
														[PP].[PriceShipmentDestiny] - [PP].[PromoValue]
												END
											ELSE 0
										END
									WHEN [PP].ValueTypeName = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [PP].ShortName = 'TOT' THEN
												[PP].[PriceShipmentDestiny]
											ELSE 0
										END
									ELSE 0
								END
							)
						)
					),1)
				FROM
					(
						SELECT 
							ROW_NUMBER() OVER (ORDER BY (SELECT 0)) [RowNum],
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
				WHERE
					[PP].[GuideNumberDestiny] IS NOT NULL
				ORDER BY 
					[ascd].[GuideSerie],
					[ascd].[GuideNumber]

			END
			-- Devolver respuesta como redistribuidor o cliente impersonado
			ELSE IF (  @CustomerType = @RedistributorType OR (ISNULL(@ImpersonatedCustomerId, 0) > 0 OR ISNULL(@ImpersonatedCustomerAccountId, 0) > 0)  )
			BEGIN
				SELECT
					200 [ResponseCode],
					'Proceso realizado exitosamente' [ResponseMessage]

				-- SELECCIONAR CARRITO DE EXPRESS CENTER
				SELECT
					eascd.IdExpressAccountServiceCartDetail
					,eascd.GuideSerie
					,eascd.GuideNumber
					,do.Pieces_Dry
					,do.Pieces_Cold
					, ROUND((
						CASE
							WHEN [PPDest].[RowNum] IS NOT NULL THEN 
								(
									[do].[PriceShippment] - 
									(
										CASE
											WHEN [PPDest].ValueTypeName = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [PPDest].ShortName = 'TOT' THEN
														ROUND((([do].[PriceShippment] * [PPDest].[PromoValue]) / 100), 1)
													ELSE 0
												END
											WHEN [PPDest].ValueTypeName = 'Monto' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [PPDest].ShortName = 'TOT' THEN
														CASE
															WHEN [PPDest].[PromoValue] > [do].[PriceShippment] THEN
																[do].[PriceShippment]
															ELSE
																[do].[PriceShippment] - [PPDest].[PromoValue]
														END
													ELSE 0
												END
											WHEN [PPDest].ValueTypeName = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
												CASE
													WHEN [PPDest].ShortName = 'TOT' THEN
														[do].[PriceShippment]
													ELSE 0
												END
											ELSE 0
										END
									)
								)
							ELSE 
								do.PriceShippment
						END
					),1) [PriceShippment]
					,do.Sender_ID
					,CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) ReceiverName
					,do.Receiver_Address
					,do.IsCollect
					,do.Collect_OnDelivery
					,ISNULL(CAST(do.DCBA_ID AS NVARCHAR), '') 'DCBA_ID'
					,ISNULL(CAST(do.InsuranceAmount AS NVARCHAR),'') InsuranceAmount
					,(CASE WHEN ISNULL(MSL.IdMembershipSubscriptionLog, 0) > 0 THEN 'true' ELSE 'false' END) UsedMembership
					,CAST(ISNULL((CASE WHEN [PPDest].[RowNum] IS NULL THEN 0 ELSE 1 END),0) AS BIT) [AppliedCoupon]
					,CAST(ISNULL((CASE WHEN [PPOri].[PromoToApply] IS NULL THEN 0 ELSE 1 END),0) AS BIT) [GeneratedCoupon]
				FROM DeliveryBackOffice.dbo.ExpressAccountServiceCartDetail eascd  WITH(NOLOCK) 
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
					ON do.Guide_Serie = eascd.GuideSerie
					AND do.Guide_Number = eascd.GuideNumber
				LEFT JOIN DeliveryBackOffice.dbo.MembershipSubscriptionLog MSL WITH(NOLOCK)
					ON eascd.GuideSerie = MSL.LogGuideSerie
					AND eascd.GuideNumber = MSL.LogGuideNumber
					AND MSL.RowStatus = 1
				LEFT JOIN 
					(
						SELECT 
							ROW_NUMBER() OVER (ORDER BY (SELECT 0)) [RowNum],
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
					) PPDest
					ON
						[eascd].[GuideSerie] = [PPDest].[GuideSerieDestiny]
						AND
						[eascd].[GuideNumber] = [PPDest].[GuideNumberDestiny]
				LEFT JOIN @PromoProcess PPOri 
					ON [eascd].[GuideSerie] = [PPOri].[GuideSerieOrigin]
					AND [eascd].[GuideNumber] = [PPOri].[GuideNumberOrigin]
					AND [PPOri].[PromoToApply] IS NOT NULL
				WHERE eascd.ExpressAccountServiceCartId = @ProcessServiceCartId
				AND eascd.RowStatus = 1
				
				SELECT
					eascd.GuideSerie GuideSerie
					,eascd.GuideNumber GuideNumber
					,bop.[Description] [Description]
					,bop.Amount Amount
				FROM DeliveryBackOffice.dbo.ExpressAccountServiceCartDetail eascd  WITH(NOLOCK) 
				INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
					ON [eascd].[GuideSerie] = [DO].[Guide_Serie]
					AND [eascd].[GuideNumber] = [DO].[Guide_Number]
				INNER JOIN DeliveryBackOffice.dbo.Cost c WITH (NOLOCK)
					ON CONCAT(eascd.GuideSerie, eascd.GuideNumber) = c.ProductNumber
						AND c.RowStatus = 1
				INNER JOIN DeliveryBackOffice.dbo.BreakdownOfPayment bop WITH (NOLOCK)
					ON c.IdCost = bop.IdCost
						AND bop.RowStatus = 1
						AND bop.Amount <> 0
				WHERE eascd.ExpressAccountServiceCartId = @ProcessServiceCartId
				AND eascd.RowStatus = 1
				UNION
				SELECT
					[PP].[GuideSerieDestiny]
					,[PP].[GuideNumberDestiny]
					,[PP].[PromoDescription]
					,ROUND(-(
						(
							(
								CASE
									WHEN [PP].ValueTypeName = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [PP].ShortName = 'TOT' THEN
												ROUND((([PP].[PriceShipmentDestiny] * [PP].[PromoValue]) / 100), 1)
											ELSE 0
										END
									WHEN [PP].ValueTypeName = 'Monto' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [PP].ShortName = 'TOT' THEN
												CASE
													WHEN [PP].[PromoValue] > [PP].[PriceShipmentDestiny] THEN
														[PP].[PriceShipmentDestiny]
													ELSE
														[PP].[PriceShipmentDestiny] - [PP].[PromoValue]
												END
											ELSE 0
										END
									WHEN [PP].ValueTypeName = 'Servicio' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN [PP].ShortName = 'TOT' THEN
												[PP].[PriceShipmentDestiny]
											ELSE 0
										END
									ELSE 0
								END
							)
						)
					),1)
				FROM
					(
						SELECT 
							ROW_NUMBER() OVER (ORDER BY (SELECT 0)) [RowNum],
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
				WHERE
					[PP].[GuideNumberDestiny] IS NOT NULL
				ORDER BY 
					[eascd].[GuideSerie],
					[eascd].[GuideNumber]

				SELECT 
					CAST((CASE WHEN [EASC].[CustomerId] IS NOT NULL THEN 1 ELSE 0 END) AS BIT) [IsImpersonated],
					[EASC].[CustomerId],
					[EASC].[CustomerPortfolioId],
					(
						CASE
							WHEN [Cu].[IdCustomerType] = @IndividualType THEN 'IND'
							WHEN [Cu].[IdCustomerType] = @CorporateType THEN 'COR'
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
					[EASC].[IdExpressAccountServiceCart] = @ProcessServiceCartId
					AND
					[EASC].[RowStatus] = 1;

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