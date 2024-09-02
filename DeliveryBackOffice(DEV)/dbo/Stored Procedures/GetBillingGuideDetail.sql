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
-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <2022-05-31>
-- Description:	< Actualización para manejo de membresías y suscripciones >
-- =============================================
CREATE PROCEDURE [dbo].[GetBillingGuideDetail]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    DECLARE @ProductNumber VARCHAR(100) = CONCAT(@GuideSerie, @GuideNumber);
	DECLARE @IsCOD BIT
    DECLARE @TypeService VARCHAR(3);
    DECLARE @Segment VARCHAR(MAX);
    DECLARE @NameArticle VARCHAR(100);
    DECLARE @NameArticleWeight VARCHAR(100);
    DECLARE @NameArticleSecure VARCHAR(100);
    DECLARE @NameArticleCollect VARCHAR(100);
    DECLARE @Amount DECIMAL(18, 2);
    DECLARE @AmountWeight DECIMAL(18, 2);
    DECLARE @AmountSecure DECIMAL(18, 2);
    DECLARE @AmountCollect DECIMAL(18, 2);
    DECLARE @CountryByGuide NVARCHAR(2);

    DECLARE @CostId INT;

    -- Valores si cupon fue aplicado
    DECLARE @AppliedCoupon INT = 0;
    DECLARE @DiscountType NVARCHAR(10) = N'';
    DECLARE @ValueType NVARCHAR(50) = N'';
    DECLARE @PromoValue DECIMAL(5, 2) = 0;

    -- Valores si membresia o suscripción fue aplicado
    DECLARE @AppliedMembership INT = 0;
    DECLARE @AppliedSubscription INT = 0;
    DECLARE @SalesPackageType INT = 0;
    DECLARE @IsFixedValueDiscount BIT = 0;

    DECLARE @BreakdownOfPayment AS TABLE
    (
        Description VARCHAR(100) NULL,
        Amount DECIMAL(18, 2) NULL
    );

    DECLARE @GuideDetail AS TABLE
    (
        SAPCode NVARCHAR(50) NULL,
        Name NVARCHAR(100) NULL,
        Description NVARCHAR(100) NULL,
        Price DECIMAL(14, 2) NULL,
        Category VARCHAR(50) NULL,
        SendToInvoice BIT NULL
    );


    SELECT 
		@TypeService = ISNULL(do.TypeService, 'STD')
		,@IsCOD = (CASE WHEN do.Collect_OnDelivery > 0 THEN 1 ELSE 0 END)
        ,@CountryByGuide = SenderCountryId
    FROM DeliveryOrder do WITH (NOLOCK)
    WHERE do.Guide_Serie = @GuideSerie
            AND do.Guide_Number = @GuideNumber
			
    SET @Segment =
    (
        SELECT [dbo].[fn_get_segment](@GuideSerie, @GuideNumber)
    );
	DECLARE @DescriptionReturn NVARCHAR(MAX);

    SET @CostId =
    (
        SELECT TOP 1
               Co.IdCost
        FROM [DeliveryBackOffice].[dbo].[Cost] Co
        WHERE Co.ProductNumber = @ProductNumber
        ORDER BY IdCost DESC
    );
	
	IF @TypeService IS NULL
		SET @TypeService = 'STD'
	DECLARE @IsLastMileReturn INT = (SELECT ISNULL(IsLastMileReturn,0)  FROM [dbo].[DeliveryOrder] DO WITH(NOLOCK)
														
														Where  
														Guide_Serie = @GuideSerie And Guide_Number = @GuideNumber
													)

    IF @Segment IS NULL
        SET @Segment = 'LOC';
		
	SET @NameArticleSecure = 'GARANTIA MERCANCIAS';

	-- FRESH DELIVERY
    IF (@TypeService = 'FDD')
    BEGIN
		SET @NameArticle = 'TARIFA DE ENVIO FRESH';
		SET @NameArticleWeight = 'RECARGO POR PESO FRESH';
		SET @NameArticleCollect = 'TARIFA COLLECT FRESH';
    END;
	-- COD
    ELSE IF (@TypeService = 'COD' OR @IsCOD = 1)
    BEGIN
		SET @NameArticle = 'TARIFA DE ENVIO COD';
		SET @NameArticleWeight = 'RECARGO POR PESO COD';
		SET @NameArticleCollect = 'TARIFA COLLECT COD';
    END;
	-- ESTANDAR
	ELSE
	BEGIN

		SET @NameArticle = 'TARIFA DE ENVIO ESTANDAR';
		SET @NameArticleWeight = 'RECARGO POR PESO ESTANDAR';
		SET @NameArticleCollect = 'TARIFA COLLECT ESTANDAR';
			
	END

	IF (@IsLastMileReturn = 1)
	BEGIN
		    
		SELECT @DescriptionReturn = 
			COALESCE(@DescriptionReturn, '') + 
			IIF
			(
				[UD].[IdUndefinedDescriptions] = 1, 
				REPLACE([Description],'+++',CONCAT(@GuideSerie,@GuideNumber,'. +++ ')),
				IIF
				(
					[UD].[IdUndefinedDescriptions] = 2,
					REPLACE([Description],'Q ##',CONCAT(@GuideSerie,@GuideNumber,'. Q ##')),
					REPLACE([Description],'Q',CONCAT(@GuideSerie,@GuideNumber,'. Q'))
				)
			)
			FROM 
				[DeliveryBackOffice].[dbo].[UndefinedDescriptions] UD  WITH(NOLOCK) 
	
	END

    INSERT INTO @BreakdownOfPayment
    SELECT Description,
           Amount
    FROM [DeliveryBackOffice].[dbo].[BreakdownOfPayment] bdp WITH (NOLOCK)
    WHERE bdp.IdCost = @CostId;

    -- Busca cupón aplicado
    SELECT TOP 1
           @AppliedCoupon = ISNULL(BOP.PromoCouponId, 0)
    FROM [DeliveryBackOffice].[dbo].[BreakdownOfPayment] BOP WITH (NOLOCK)
    WHERE BOP.IdCost = @CostId
          AND BOP.PromoCouponId IS NOT NULL;


    -- Busca membresía aplicada
    SELECT @AppliedMembership = 1,
           @SalesPackageType = 1,
           @IsFixedValueDiscount = (CASE
                                        WHEN [MSL].[LogServiceNumber] <= [M].[MembershipMaxServiceFixedValue] THEN
                                            1
                                        ELSE
                                            0
                                    END
                                   ),
           @Amount = (CASE
                          WHEN [MSL].[LogServiceNumber] <= [M].[MembershipMaxServiceFixedValue] THEN
                              [MSL].[LogGuideNewValue]
                          ELSE
                              [MSL].[LogGuideOriginalValue]
                      END
                     ),
           @ValueType = (CASE
                             WHEN [MSL].[LogServiceNumber] <= [M].[MembershipMaxServiceFixedValue] THEN
                                 'Porcentaje'
                             ELSE
    (
        SELECT TOP 1
               ISNULL(CVT.ValueTypeName, 'Porcentaje')
        FROM [DeliveryBackOffice].[dbo].[MembershipDiscountRange] MDR WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[CatValueType] CVT WITH (NOLOCK)
                ON MDR.ValueTypeId = CVT.IdCatValueType
        WHERE MDR.MembershipId = [M].[IdMembership]
              AND MSL.LogServiceNumber
              BETWEEN MDR.DiscountLowServiceRange AND ISNULL(MDR.DiscountTopServiceRange, 1000000000)
    )
                         END
                        ),
           @PromoValue = (CASE
                              WHEN [MSL].[LogServiceNumber] <= [M].[MembershipMaxServiceFixedValue] THEN
                                  0
                              ELSE
    (
        SELECT TOP 1
               ISNULL(MDR.DiscountValue, 0)
        FROM [DeliveryBackOffice].[dbo].[MembershipDiscountRange] MDR WITH (NOLOCK)
        WHERE MDR.MembershipId = [M].[IdMembership]
              AND MSL.LogServiceNumber
              BETWEEN MDR.DiscountLowServiceRange AND ISNULL(MDR.DiscountTopServiceRange, 1000000000)
    )
                          END
                         ),
           @DiscountType = N'TOT'
    FROM [dbo].[MembershipSubscriptionLog] MSL WITH (NOLOCK)
        INNER JOIN [dbo].[Membership] M
            ON [MSL].[MembershipId] = [M].[IdMembership]
    WHERE [MSL].[LogGuideSerie] = @GuideSerie
          AND [MSL].[LogGuideNumber] = @GuideNumber
          AND [MSL].[SubscriptionId] IS NULL
          AND [MSL].[RowStatus] = 1;

    -- Busca suscripción aplicada
    SELECT @AppliedSubscription = 1,
           @SalesPackageType = 2,
           @IsFixedValueDiscount = (CASE
                                        WHEN [MSL].[LogServiceNumber] <= [S].[SubscriptionMaxServiceFixedValue] THEN
                                            1
                                        ELSE
                                            0
                                    END
                                   ),
           @Amount = (CASE
                          WHEN [MSL].[LogServiceNumber] <= [S].[SubscriptionMaxServiceFixedValue] THEN
                              [MSL].[LogGuideNewValue]
                          ELSE
                              [MSL].[LogGuideOriginalValue]
                      END
                     ),
           @ValueType = (CASE
                             WHEN [MSL].[LogServiceNumber] <= [S].[SubscriptionMaxServiceFixedValue] THEN
                                 'Porcentaje'
                             ELSE
    (
        SELECT TOP 1
               ISNULL(CVT.ValueTypeName, 'Porcentaje')
        FROM [DeliveryBackOffice].[dbo].[SubscriptionDiscountRange] SDR WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[CatValueType] CVT WITH (NOLOCK)
                ON SDR.ValueTypeId = CVT.IdCatValueType
        WHERE SDR.SubscriptionId = [S].[IdSubscription]
              AND MSL.LogServiceNumber
              BETWEEN SDR.DiscountLowServiceRange AND ISNULL(SDR.DiscountTopServiceRange, 1000000000)
    )
                         END
                        ),
           @PromoValue = (CASE
                              WHEN [MSL].[LogServiceNumber] <= [S].[SubscriptionMaxServiceFixedValue] THEN
                                  0
                              ELSE
    (
        SELECT TOP 1
               ISNULL(SDR.DiscountValue, 0)
        FROM [DeliveryBackOffice].[dbo].[SubscriptionDiscountRange] SDR WITH (NOLOCK)
        WHERE SDR.SubscriptionId = [S].[IdSubscription]
              AND MSL.LogServiceNumber
              BETWEEN SDR.DiscountLowServiceRange AND ISNULL(SDR.DiscountTopServiceRange, 1000000000)
    )
                          END
                         ),
           @DiscountType = N'TOT'
    FROM [dbo].[MembershipSubscriptionLog] MSL WITH (NOLOCK)
        INNER JOIN [dbo].[Subscription] S
            ON [MSL].[SubscriptionId] = [S].[IdSubscription]
    WHERE [MSL].[LogGuideSerie] = @GuideSerie
          AND [MSL].[LogGuideNumber] = @GuideNumber
          AND [MSL].[SubscriptionId] IS NOT NULL
          AND [MSL].[RowStatus] = 1;

    IF (@AppliedCoupon > 0)
    BEGIN

		PRINT 'APPLIED COUPON'
        SELECT TOP 1
               @Amount = PromoC.OriginalAmount,
               @DiscountType = CTD.ShortName,
               @ValueType = CVT.ValueTypeName,
               @PromoValue = PromoC.CouponValue
        FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD WITH (NOLOCK)
                ON PromoC.CatDiscountTypeId = CTD.IdCatTypeDiscount
            INNER JOIN [DeliveryBackOffice].[dbo].[CatValueType] CVT WITH (NOLOCK)
                ON PromoC.CatValueTypeId = CVT.IdCatValueType
        WHERE PromoC.GuideSerieDestination = @GuideSerie
              AND PromoC.GuideNumberDestination = @GuideNumber;
    END;
    ELSE
    BEGIN
        SET @Amount =
        (
            SELECT TOP 1
                   DO.PriceShippment
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
            WHERE DO.Guide_Serie = @GuideSerie
                  AND DO.Guide_Number = @GuideNumber
        );
    END;

    IF
    (
        SELECT COUNT(*)FROM @BreakdownOfPayment
    ) > 0
    BEGIN
		-- Pago collect
		SET @AmountCollect =
		(
			SELECT Amount FROM @BreakdownOfPayment WHERE Description LIKE '%PAGO%DESTINO%'
		);

		IF @AmountCollect IS NOT NULL AND @AmountCollect > 0
		BEGIN
		
			SET @Amount = @Amount - @AmountCollect
			
			IF(@AmountCollect IS NOT NULL AND @AmountCollect > 0 AND @AppliedCoupon > 0)
			BEGIN

				SET @AmountCollect = (
					SELECT
						(
							CASE
								WHEN @ValueType = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
									CASE
										WHEN @DiscountType = 'TOT' THEN
											@AmountCollect - ROUND(((@AmountCollect * @PromoValue) / 100), 1)
										ELSE 
											@AmountCollect
									END
								ELSE @AmountCollect
							END
						)
				)

			END

		END

        -- Excendente de peso
        SET @AmountWeight =
        (
            SELECT Amount FROM @BreakdownOfPayment WHERE Description LIKE '%PESO%'
        );
		
		IF @AmountWeight IS NOT NULL AND @AmountWeight > 0
		BEGIN
					
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
        SET @AmountSecure =
        (
            SELECT Amount FROM @BreakdownOfPayment WHERE Description LIKE '%SEGURO%'
        );
		
		IF @AmountSecure IS NOT NULL AND @AmountSecure > 0
		BEGIN

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
		
		IF(@Amount IS NOT NULL AND @Amount > 0 AND (((@AppliedMembership > 0 OR @AppliedSubscription > 0) AND @IsFixedValueDiscount = 0)))
		BEGIN			
			SET @Amount = (
				SELECT
					(
						CASE
							WHEN @ValueType = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN 
								CASE
									WHEN @DiscountType = 'TOT' THEN
										@Amount -- ROUND(((@Amount * @PromoValue) / 100), 1)
									ELSE 
										@Amount
								END
							ELSE @Amount
						END
					)
			)
			
			PRINT @Amount
		END

		IF(@Amount IS NOT NULL AND @Amount > 0 AND @AppliedCoupon > 0 AND @IsFixedValueDiscount = 0)
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

        IF @Amount IS NOT NULL
           AND @Amount > 0
            INSERT INTO @GuideDetail
            SELECT ca.SAPCode,
                   ca.Name,
                   CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber),
                   @Amount,
                   ca.Category,
                   1
            FROM CatArticleSAP ca
            WHERE ca.Name = @NameArticle
              AND ISNULL(ca.IdCountry,'GT') = @CountryByGuide;
			
        IF @AmountCollect IS NOT NULL
           AND @AmountCollect > 0
            INSERT INTO @GuideDetail
            SELECT ca.SAPCode,
                   ca.Name,
                   CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber),
                   @AmountCollect,
                   ca.Category,
                   1
            FROM CatArticleSAP ca
            WHERE ca.Name = @NameArticleCollect
              AND ISNULL(ca.IdCountry,'GT') = @CountryByGuide;

        IF @AmountWeight IS NOT NULL
           AND @AmountWeight > 0
            INSERT INTO @GuideDetail
            SELECT ca.SAPCode,
                   ca.Name,
                   CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber),
                   @AmountWeight,
                   ca.Category,
                   1
            FROM CatArticleSAP ca
            WHERE ca.Name = @NameArticleWeight
              AND ISNULL(ca.IdCountry,'GT') = @CountryByGuide;

        IF @AmountSecure IS NOT NULL
           AND @AmountSecure > 0
            INSERT INTO @GuideDetail
            SELECT ca.SAPCode,
                   ca.Name,
                   CONCAT(ca.Description, '. ', @GuideSerie, @GuideNumber),
                   @AmountSecure,
                   ca.Category,
                   1
            FROM CatArticleSAP ca
            WHERE ca.Name = @NameArticleSecure
              AND ISNULL(ca.IdCountry,'GT') = @CountryByGuide;
    END;

		

	SELECT	SAPCode,
			Name ,
			Case
			   when @IsLastMileReturn = 1 Then REPLACE(REPLACE ( @DescriptionReturn, '##' , Price ),'+++',+ char(10))  
			   Else [Description] End [Description] ,
			Price,
			Category,
			SendToInvoice
	FROM @GuideDetail;

	SET NOCOUNT OFF;
END	