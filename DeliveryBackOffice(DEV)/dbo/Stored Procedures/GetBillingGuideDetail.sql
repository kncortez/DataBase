
-- =============================================
-- Author:		<Morales, Oscar>
-- Create date: <2021-11-03>
-- Description:	<Recupera información detallada de la guía a facturar>
-- =============================================
-- =============================================
-- Author:		<Ruiz, Andres>
-- Create date: <2022-05-31>
-- Description:	< Adicion de manejo de cupones para que la información de la factura sea correcta >
-- =============================================
CREATE PROCEDURE [dbo].[GetBillingGuideDetail]
		@GuideSerie NVARCHAR(2),
		@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @ProductNumber VARCHAR(100) = CONCAT(@GuideSerie,@GuideNumber) 
	DECLARE @TypeService VARCHAR(3)
	DECLARE @Segment VARCHAR(MAX)
	DECLARE @NameArticle VARCHAR(100)
	DECLARE @NameArticleWeight VARCHAR(100)
	DECLARE @NameArticleSecure VARCHAR(100)
	DECLARE @Amount DECIMAL(18,2)
	DECLARE @AmountWeight DECIMAL (18,2)
	DECLARE @AmountSecure DECIMAL (18,2)

	-- Valores si cupon fue aplicado
	DECLARE @AppliedCoupon INT = 0;
	DECLARE @DiscountType NVARCHAR(10) = '';
	DECLARE @ValueType NVARCHAR(50) = '';
	DECLARE @PromoValue DECIMAL(5,2) = 0;

	-- Valores si membresia o suscripción fue aplicado
	DECLARE @AppliedSalesPackage INT = 0;
	DECLARE @SalesPackageType INT = 0;
	DECLARE @IsFixedValueDiscount BIT = 0;

	DECLARE @BreakdownOfPayment AS TABLE(
		Description VARCHAR(100) NULL
		,Amount DECIMAL(18,2) NULL
	)

	DECLARE @GuideDetail AS TABLE(
		SAPCode NVARCHAR(50) NULL
		,Name NVARCHAR(100) NULL
		,Description NVARCHAR(100) NULL
		,Price DECIMAL(14,2) NULL
		,Category VARCHAR(50) NULL
		,SendToInvoice BIT NULL
	)


	SET @TypeService = COALESCE((SELECT do.TypeService 
							FROM DeliveryOrder do WITH(NOLOCK)
							WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber), 'NDD')

	SET @Segment = (SELECT [dbo].[fn_get_segment] (@GuideSerie,@GuideNumber))
	
	IF @Segment IS NULL
		SET @Segment = 'LOC'
	
	IF @TypeService = 'SDD'
	BEGIN
		SET @NameArticleWeight = 'SAME DAY EXCEDENTE DE PESO'
		SET @NameArticleSecure = 'SAME DAY SEGURO'

		IF @Segment = 'FOR'
			SET @NameArticle = 'SAME DAY DELIVERY FORANEO'
		ELSE
			SET @NameArticle = 'SAME DAY DELIVERY LOCAL'
	END
	ELSE
	BEGIN
		SET @NameArticleWeight = 'NEXT DAY EXCEDENTE DE PESO'
		SET @NameArticleSecure = 'NEXT DAY SEGURO'

		IF @Segment = 'FOR'
			SET @NameArticle = 'NEXT DAY DELIVERY FORANEO'
		ELSE
			SET @NameArticle = 'NEXT DAY DELIVERY LOCAL'
	END

	INSERT INTO @BreakdownOfPayment
	SELECT Description, Amount
	FROM [DeliveryBackOffice].[dbo].[BreakdownOfPayment] bdp WITH(NOLOCK)
	WHERE bdp.IdCost = (
		SELECT TOP 1 IdCost FROM Cost WHERE ProductNumber = @ProductNumber ORDER BY IdCost DESC
	)

	SELECT
		TOP 1
			@AppliedCoupon = ISNULL(BOP.PromoCouponId,0)
	FROM
		[DeliveryBackOffice].[dbo].[BreakdownOfPayment] BOP WITH(NOLOCK)
	WHERE 
		BOP.IdCost = (
			SELECT TOP 1 Co.IdCost FROM [DeliveryBackOffice].[dbo].[Cost] Co WHERE Co.ProductNumber = @ProductNumber ORDER BY IdCost DESC
		)
		AND
		BOP.PromoCouponId IS NOT NULL

	SELECT
		TOP 1
			@AppliedSalesPackage = 1
	FROM
		[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSL WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[Membership] Mmbrshp WITH(NOLOCK)
			ON
				MSL.MembershipId = Mmbrshp.IdMembership
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Subscription] Sbscrptn WITH(NOLOCK)
			ON
				MSL.SubscriptionId = Sbscrptn.IdSubscription
	WHERE
		MSL.LogGuideSerie = @GuideSerie
		AND
		MSL.LogGuideNumber = @GuideNumber
		AND
		MSL.RowStatus = 1

	-- Asegurar que sea 0
	IF(ISNULL(@AppliedSalesPackage, 0) = 0)
		SET @AppliedSalesPackage = 0;

	IF(@AppliedSalesPackage > 0)
	BEGIN
		SELECT
			TOP 1
				@SalesPackageType = (
										CASE 
											-- Es membresia
											WHEN MSL.MembershipId IS NOT NULL AND MSL.SubscriptionId IS NULL THEN 1
											-- Es suscripción
											WHEN MSL.MembershipId IS NOT NULL AND MSL.SubscriptionId IS NOT NULL THEN 2
											-- Error indefinido
											ELSE 0 
										END
									),
				@IsFixedValueDiscount = (
											CASE 
												-- Es membresia
												WHEN MSL.MembershipId IS NOT NULL AND MSL.SubscriptionId IS NULL THEN
													(
														CASE
															-- Dentro de los servicios de monto fijo
															WHEN MSL.LogServiceNumber <= Mmbrshp.MembershipMaxServiceFixedValue THEN 1
															-- Fuera de los servicios de monto fijo
															ELSE 0
														END
													)
												-- Es suscripción
												WHEN MSL.MembershipId IS NOT NULL AND MSL.SubscriptionId IS NOT NULL THEN
													(
														CASE
															-- Dentro de los servicios de monto fijo
															WHEN MSL.LogServiceNumber <= Sbscrptn.SubscriptionMaxServiceFixedValue THEN 1
															-- Fuera de los servicios de monto fijo
															ELSE 0
														END
													)
												-- Indeterminado
												ELSE 0 
											END
										),
				@Amount = (
								CASE 
									-- Es membresia
									WHEN MSL.MembershipId IS NOT NULL AND MSL.SubscriptionId IS NULL THEN
										(
											CASE
												-- Dentro de los servicios de monto fijo
												WHEN MSL.LogServiceNumber <= Mmbrshp.MembershipMaxServiceFixedValue THEN MSL.LogGuideNewValue
												-- Fuera de los servicios de monto fijo
												ELSE 
													-- Tipo de valor bajo rango del servicio
													MSL.LogGuideOriginalValue
											END
										)
									-- Es suscripción
									WHEN MSL.MembershipId IS NOT NULL AND MSL.SubscriptionId IS NOT NULL THEN
										(
											CASE
												-- Dentro de los servicios de monto fijo
												WHEN MSL.LogServiceNumber <= Sbscrptn.SubscriptionMaxServiceFixedValue THEN MSL.LogGuideNewValue
												-- Fuera de los servicios de monto fijo
												ELSE 
													-- Tipo de valor bajo rango del servicio
													MSL.LogGuideOriginalValue
											END
										)
									-- Indeterminado
									ELSE 'N/A' 
								END
							),
				@ValueType = (
								CASE 
									-- Es membresia
									WHEN MSL.MembershipId IS NOT NULL AND MSL.SubscriptionId IS NULL THEN
										(
											CASE
												-- Dentro de los servicios de monto fijo
												WHEN MSL.LogServiceNumber <= Mmbrshp.MembershipMaxServiceFixedValue THEN 'Porcentaje'
												-- Fuera de los servicios de monto fijo
												ELSE 
													-- Tipo de valor bajo rango del servicio
													(
														SELECT
															TOP 1
																ISNULL(CVT.ValueTypeName, 'Porcentaje')
														FROM
															[DeliveryBackOffice].[dbo].[MembershipDiscountRange] MDR WITH(NOLOCK)
															INNER JOIN
																[DeliveryBackOffice].[dbo].[CatValueType] CVT WITH(NOLOCK)
																ON
																	MDR.ValueTypeId = CVT.IdCatValueType
														WHERE
															MDR.MembershipId = Mmbrshp.IdMembership
															AND
															MSL.LogServiceNumber BETWEEN MDR.DiscountLowServiceRange AND ISNULL(MDR.DiscountTopServiceRange, 1000000000)
													)
											END
										)
									-- Es suscripción
									WHEN MSL.MembershipId IS NOT NULL AND MSL.SubscriptionId IS NOT NULL THEN
										(
											CASE
												-- Dentro de los servicios de monto fijo
												WHEN MSL.LogServiceNumber <= Sbscrptn.SubscriptionMaxServiceFixedValue THEN 'Porcentaje'
												-- Fuera de los servicios de monto fijo
												ELSE 
													-- Tipo de valor bajo rango del servicio
													(
														SELECT
															TOP 1
																ISNULL(CVT.ValueTypeName, 'Porcentaje')
														FROM
															[DeliveryBackOffice].[dbo].[SubscriptionDiscountRange] SDR WITH(NOLOCK)
															INNER JOIN
																[DeliveryBackOffice].[dbo].[CatValueType] CVT WITH(NOLOCK)
																ON
																	SDR.ValueTypeId = CVT.IdCatValueType
														WHERE
															SDR.SubscriptionId = Sbscrptn.IdSubscription
															AND
															MSL.LogServiceNumber BETWEEN SDR.DiscountLowServiceRange AND ISNULL(SDR.DiscountTopServiceRange, 1000000000)
													)
											END
										)
									-- Indeterminado
									ELSE 'N/A' 
								END
							),
				@PromoValue = (
								CASE 
									-- Es membresia
									WHEN MSL.MembershipId IS NOT NULL AND MSL.SubscriptionId IS NULL THEN
										(
											CASE
												-- Dentro de los servicios de monto fijo
												WHEN MSL.LogServiceNumber <= Mmbrshp.MembershipMaxServiceFixedValue THEN 0
												-- Fuera de los servicios de monto fijo
												ELSE 
													-- Tipo de valor bajo rango del servicio
													(
														SELECT
															TOP 1
																ISNULL(MDR.DiscountValue, 0)
														FROM
															[DeliveryBackOffice].[dbo].[MembershipDiscountRange] MDR WITH(NOLOCK)
														WHERE
															MDR.MembershipId = Mmbrshp.IdMembership
															AND
															MSL.LogServiceNumber BETWEEN MDR.DiscountLowServiceRange AND ISNULL(MDR.DiscountTopServiceRange, 1000000000)
													)
											END
										)
									-- Es suscripción
									WHEN MSL.MembershipId IS NOT NULL AND MSL.SubscriptionId IS NOT NULL THEN
										(
											CASE
												-- Dentro de los servicios de monto fijo
												WHEN MSL.LogServiceNumber <= Sbscrptn.SubscriptionMaxServiceFixedValue THEN 0
												-- Fuera de los servicios de monto fijo
												ELSE 
													-- Tipo de valor bajo rango del servicio
													(
														SELECT
															TOP 1
																ISNULL(SDR.DiscountValue, 0)
														FROM
															[DeliveryBackOffice].[dbo].[SubscriptionDiscountRange] SDR WITH(NOLOCK)
														WHERE
															SDR.SubscriptionId = Sbscrptn.IdSubscription
															AND
															MSL.LogServiceNumber BETWEEN SDR.DiscountLowServiceRange AND ISNULL(SDR.DiscountTopServiceRange, 1000000000)
													)
											END
										)
									-- Indeterminado
									ELSE 0 
								END
							)
		FROM
			[DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSL WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[Membership] Mmbrshp WITH(NOLOCK)
				ON
					MSL.MembershipId = Mmbrshp.IdMembership
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Subscription] Sbscrptn WITH(NOLOCK)
				ON
					MSL.SubscriptionId = Sbscrptn.IdSubscription
		WHERE
			MSL.LogGuideSerie = @GuideSerie
			AND
			MSL.LogGuideNumber = @GuideNumber
			AND
			MSL.RowStatus = 1

		SET @DiscountType = 'TOT';
	END

	IF(ISNULL(@AppliedSalesPackage, 0) > 0 AND ISNULL(@IsFixedValueDiscount, 0) = 1)
	BEGIN

		INSERT INTO @GuideDetail
		SELECT ca.SAPCode
			, ca.Name
			, CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber)
			, @Amount
			, ca.Category
			, 1
		FROM CatArticleSAP ca
		WHERE ca.Name = @NameArticle

	END
	ELSE
	BEGIN

		IF(@AppliedCoupon > 0)
		BEGIN

			SELECT 
				TOP 1 
					@Amount = PromoC.OriginalAmount
					,@DiscountType = CTD.ShortName
					,@ValueType = CVT.ValueTypeName
					,@PromoValue = PromoC.CouponValue
			FROM 
				[DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH(NOLOCK) 
				INNER JOIN
					[DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD WITH(NOLOCK)
					ON
						PromoC.CatDiscountTypeId = CTD.IdCatTypeDiscount
				INNER JOIN
					[DeliveryBackOffice].[dbo].[CatValueType] CVT WITH(NOLOCK)
					ON
						PromoC.CatValueTypeId = CVT.IdCatValueType
			WHERE 
				PromoC.GuideSerieDestination = @GuideSerie 
				AND 
				PromoC.GuideNumberDestination = @GuideNumber

		END
		ELSE
		BEGIN

			SET @Amount = (
				SELECT 
					TOP 1 
						DO.PriceShippment 
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) 
				WHERE 
					DO.Guide_Serie = @GuideSerie 
					AND 
					DO.Guide_Number = @GuideNumber);

		END

		IF @Amount IS NOT NULL AND @Amount > 0
		BEGIN

			IF (SELECT COUNT(*) FROM @BreakdownOfPayment) > 0
			BEGIN
			
				-- Excendente de peso
				SET @AmountWeight = (SELECT Amount FROM @BreakdownOfPayment WHERE Description LIKE '%PESO%')

				IF @AmountWeight IS NOT NULL AND @AmountWeight > 0
				BEGIN
					SET @AmountWeight = @AmountWeight * 1.12
					
					SET @Amount = @Amount - @AmountWeight
					
					IF(@AmountWeight IS NOT NULL AND @AmountWeight > 0 AND (@AppliedCoupon > 0 OR @AppliedSalesPackage > 0))
					BEGIN

						SET @AmountWeight = (
							SELECT
								(
									CASE
										WHEN @ValueType = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN @DiscountType = 'TOT' THEN
													@AmountWeight - ROUND(((@AmountWeight * @PromoValue) / 100), 1)
												ELSE 
													@AmountWeight
											END
										ELSE @AmountWeight
									END
								)
						)

					END

				END

				-- Seguro
				SET @AmountSecure = (SELECT Amount FROM @BreakdownOfPayment WHERE Description LIKE '%SEGURO%')
				
				IF @AmountSecure IS NOT NULL AND @AmountSecure > 0
				BEGIN
					SET @AmountSecure = @AmountSecure * 1.12

					SET @Amount = @Amount - @AmountSecure

					IF(@AmountSecure IS NOT NULL AND @AmountSecure > 0 AND (@AppliedCoupon > 0 OR @AppliedSalesPackage > 0))
					BEGIN

						SET @AmountSecure = (
							SELECT
								(
									CASE
										WHEN @ValueType = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
											CASE
												WHEN @DiscountType = 'TOT' THEN
													@AmountSecure - ROUND(((@AmountSecure * @PromoValue) / 100), 1)
												ELSE 
													@AmountSecure
											END
										ELSE @AmountSecure
									END
								)
						)

					END
				END

				IF(@Amount IS NOT NULL AND @Amount > 0 AND (@AppliedCoupon > 0 OR @AppliedSalesPackage > 0))
				BEGIN

					SET @Amount = (
						SELECT
							(
								CASE
									WHEN @ValueType = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
										CASE
											WHEN @DiscountType = 'TOT' THEN
												@Amount - ROUND(((@Amount * @PromoValue) / 100), 1)
											ELSE 
												@Amount
										END
									ELSE @Amount
								END
							)
					)

				END

				INSERT INTO @GuideDetail
				SELECT ca.SAPCode
					, ca.Name
					, CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber)
					, @Amount
					, ca.Category
					, 1
				FROM CatArticleSAP ca
				WHERE ca.Name = @NameArticle


				IF @AmountWeight IS NOT NULL AND @AmountWeight > 0
					INSERT INTO @GuideDetail
					SELECT ca.SAPCode
						, ca.Name
						, CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber)
						, @AmountWeight
						, ca.Category
						, 0
					FROM CatArticleSAP ca
					WHERE ca.Name = @NameArticleWeight

				IF @AmountSecure IS NOT NULL AND @AmountSecure > 0
					INSERT INTO @GuideDetail
					SELECT ca.SAPCode
						, ca.Name
						, CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber)
						, @AmountSecure
						, ca.Category
						, 0
					FROM CatArticleSAP ca
					WHERE ca.Name = @NameArticleSecure

			END
			ELSE
			BEGIN
				INSERT INTO @GuideDetail
				SELECT ca.SAPCode
					, ca.Name
					, CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber)
					, @Amount
					, ca.Category
					, 1
				FROM CatArticleSAP ca
				WHERE ca.Name = @NameArticle
			END

		END

	END

	SELECT * FROM @GuideDetail

	SET NOCOUNT OFF;
END	