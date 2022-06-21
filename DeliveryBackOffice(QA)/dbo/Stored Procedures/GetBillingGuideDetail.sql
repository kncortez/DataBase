
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
					
				IF(@AmountWeight IS NOT NULL AND @AmountWeight > 0 AND @AppliedCoupon > 0)
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

				IF(@AmountSecure IS NOT NULL AND @AmountSecure > 0 AND @AppliedCoupon > 0)
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

			IF(@Amount IS NOT NULL AND @Amount > 0 AND @AppliedCoupon > 0)
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

	SELECT * FROM @GuideDetail



	SET NOCOUNT OFF;
END	