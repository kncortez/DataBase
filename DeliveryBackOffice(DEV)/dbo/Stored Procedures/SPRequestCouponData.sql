
-- =============================================
-- Author:		<Author,,Edelman Vásquez>
-- Create date: <Create Date,26/05/2022>
-- Description:	<Description,Método para pre redimir cupón>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <01/06/2022>
-- Description:	< Prebloqueo de cupones >
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2022-07-05>
-- Description:	< Generación de registros inexistentes de Cost en guías problematicas >
-- =============================================
CREATE PROCEDURE [dbo].[SPRequestCouponData]
    -- Add the parameters for the stored procedure here
    @CouponSerie NVARCHAR(20)
  , @SystemOrigin INT
  , @CustomerId INT
  , @VisitPointClient INT
  , @VisitPointClientPortfolio INT
  , @GuideSerie NVARCHAR(2)
  , @GuideNumber INT
  , @Token VARCHAR(50)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Manejo cuando dato viene vacio o es 0
    IF (@VisitPointClient = 0)
        SET @VisitPointClient = NULL;

    IF (@VisitPointClientPortfolio = 0)
        SET @VisitPointClientPortfolio = NULL;

    -- Variables de respuesta
    DECLARE @JsonResponse NVARCHAR(MAX) = N'';
    DECLARE @JsonBreakdown NVARCHAR(MAX) = N'';

    DECLARE @CouponData AS TABLE
    (
        couponserie NVARCHAR(20)
      , couponfinaldate DATETIME
      , couponpromoid INT
      , couponvaluetipeid INT
      , coupondiscounttypeid INT
      , couponvalue INT
    );

    -- Variables de control de flujo
    DECLARE @ClientType INT;
    DECLARE @ClientId INT;

    -- Variables de retorno
    DECLARE @OldAmount DECIMAL(14, 2);
    DECLARE @DiscountAmount DECIMAL(14, 2);
    DECLARE @NewAmount DECIMAL(14, 2);

    DECLARE @ValueTipeName VARCHAR(20);
    DECLARE @TypeDiscountName VARCHAR(20);
    DECLARE @PromoValue INT;

    DECLARE @PhoneOrigin NVARCHAR(50) = N'';
    DECLARE @PhoneDestination NVARCHAR(50) = N'';

    DECLARE @GuideIsImpersonated BIT = 0;

    -- Variables de revalorización
    DECLARE @CodeAppRevalue NVARCHAR(50) =
            (
                SELECT TOP 1
                       Ec.UserKey
                FROM [DeliveryBackOffice].[dbo].[Ecommerce] Ec WITH (NOLOCK)
                WHERE Ec.IdCountry = 'GT'
                      AND Ec.IdCustomer = 6
            );
    DECLARE @MustUpdateRevalue BIT = 1; -- Actualizar DB con revalorización
    DECLARE @TaxesRevalue BIT = 0; -- Calcular impuestos, por defecto 0 por el cambio de tarifas y que no se aplican cupónes a corporativos

    -- Validar Cliente - Esto se podrá usar cuando sea necesario validar que el cupon no se pueda transferir
    SELECT @ClientId   = Ac.IdCustomer
         , @ClientType = Cu.IdCustomerType
    FROM dbo.Account            Ac WITH (NOLOCK)
        INNER JOIN dbo.Customer Cu WITH (NOLOCK)
            ON Ac.IdCustomer = Cu.IdCustomer
    WHERE Ac.AccIdAccount = @CustomerId;

    BEGIN TRY
        -- Validación de cupón
        IF (RTRIM(LTRIM(ISNULL(@CouponSerie, ''))) <> '')
        BEGIN

            -- Valor original de la guía y teléfono del remitente de la guía a aplicarle el cupon
            SELECT @ClientId                  = Cu.IdCustomer
                 , @ClientType                = Cu.IdCustomerType
                 , @OldAmount                 = DO.PriceShippment
                 , @PhoneDestination          = RTRIM(LTRIM(ISNULL(DO.Sender_Phone, '')))
                 , @VisitPointClient
                                              = IIF(DO.OriginSenderId IS NULL OR DO.OriginSenderId = 0
                             , IIF(@ClientType = 2, DO.Sender_ID, NULL)
                             , DO.OriginSenderId)
                 , @VisitPointClientPortfolio = DO.VisitpointClientPortfolioId
            FROM dbo.DeliveryOrder                                      DO WITH (NOLOCK)
                LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
                    ON DO.Sender_ID = VPC.CodeOfReference
                LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]         Cu WITH (NOLOCK)
                    ON ISNULL(DO.IdCustomer, VPC.CustomerID) = Cu.IdCustomer
            WHERE DO.Guide_Number = @GuideNumber
                  AND DO.Guide_Serie = @GuideSerie;

            -- Teléfono de la guía que origino el cupon
            SELECT @PhoneOrigin = RTRIM(LTRIM(ISNULL(DO.Sender_Phone, '')))
            FROM DeliveryBackOffice.dbo.DeliveryOrder               DO WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH (NOLOCK)
                    ON DO.Guide_Serie = PC.GuideSerieOrigin
                       AND DO.Guide_Number = PC.GuideNumberOrigin
            WHERE PC.PromoCouponSerie = @CouponSerie;

            -- Obtener datos del cupon
            INSERT INTO @CouponData
            (
                couponserie
              , couponfinaldate
              , couponpromoid
              , couponvaluetipeid
              , coupondiscounttypeid
              , couponvalue
            )
            SELECT PC.PromoCouponSerie
                 , PC.FinalActiveDate
                 , PC.CatPromoId
                 , PC.CatValueTypeId
                 , PC.CatDiscountTypeId
                 , PC.CouponValue
            FROM dbo.PromoCoupon PC WITH (NOLOCK)
            WHERE
                -- Validar el usuario que lo genera
                (
                    PC.CustomerOrigin = @ClientId
                    AND
                    (
                        (
                            -- Cliente individual e impersonado
                            @ClientType = 3
                            OR @ClientType = 1
                        )
                        OR
                        (
                            -- Express bajo cartera de clientes
                            (PC.VisitPointClientOrigin = @VisitPointClient)
                            AND (PC.VisitPointClientPortfolioOrigin = @VisitPointClientPortfolio)
                        )
                        OR
                        (
                            -- Express center en punto vacio
                            PC.VisitPointClientOrigin = @VisitPointClient
                            AND @PhoneOrigin = @PhoneDestination
                        )
                    )
                )
                -- Bloqueo de cupones
                AND
                (
                    PC.GuideNumberDestination IS NULL
                    OR PC.GuideNumberDestination = @GuideNumber
                )
                AND
                (
                    PC.GuideSerieDestination IS NULL
                    OR PC.GuideSerieDestination = @GuideSerie
                )
                AND
                -- Validaciones normales de cupones
                PC.RedeemedDate IS NULL
                AND PC.PromoCouponSerie = @CouponSerie
                AND PC.FinalActiveDate >= GETDATE()
                AND PC.RowStatus = 1;

            --Validar que hay datos
            IF (EXISTS (SELECT TOP 1 1 FROM @CouponData))
            BEGIN

                -- Transacción interna para bloqueo de cupones
                BEGIN TRANSACTION Block_Coupon_Redemption;
                BEGIN TRY

                    UPDATE PromoC
                    SET PromoC.GuideSerieDestination = @GuideSerie
                      , PromoC.GuideNumberDestination = @GuideNumber
                      , PromoC.TokenUpdated = @Token
                      , PromoC.DateUpdated = GETDATE()
                    FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
                    WHERE PromoC.PromoCouponSerie = @CouponSerie;

                    COMMIT TRANSACTION Block_Coupon_Redemption;

                END TRY
                BEGIN CATCH

                    ROLLBACK TRANSACTION Block_Coupon_Redemption;

                END CATCH;

                -- Identificador de Cost, esto va a servir para obtener el BreakdownOfPayment de la guía
                DECLARE @CostId INT = 0;
                SET @CostId
                    = ISNULL((
                                 SELECT TOP 1
                                        Co.IdCost
                                 FROM [DeliveryBackOffice].[dbo].[Cost] Co WITH (NOLOCK)
                                 WHERE (
                                           (
                                               Co.GuideSerie = ISNULL(@GuideSerie, 'FD')
                                               AND Co.GuideNumber = @GuideNumber
                                           )
                                           OR
                                           (
                                               Co.ProductNumber = CONCAT(ISNULL(@GuideSerie, 'FD'), @GuideNumber)
                                               AND Co.GuideSerie IS NULL
                                               AND Co.GuideNumber IS NULL
                                           )
                                       )
                                       AND Co.RowStatus = 1
                                 ORDER BY Co.DateCreated DESC
                             )
                           , 0
                            );

                -- Valor del descuento a generar
                SET @DiscountAmount =
                (
                    SELECT CASE
                               WHEN CVT.ValueTypeName = 'Porcentaje' COLLATE Latin1_General_CI_AI THEN
                                   CASE
                                       WHEN CTD.ShortName = 'TOT' THEN
                                           ROUND(((@OldAmount * CD.couponvalue) / 100), 1)
                                       ELSE
                                           0
                                   END
                               WHEN CVT.ValueTypeName = 'Monto' COLLATE Latin1_General_CI_AI THEN
                                   CASE
                                       WHEN CTD.ShortName = 'TOT' THEN
                                           CASE
                                               WHEN CD.couponvalue > @OldAmount THEN
                                                   @OldAmount
                                               ELSE
                                                   @OldAmount - CD.couponvalue
                                           END
                                       ELSE
                                           0
                                   END
                               WHEN CVT.ValueTypeName = 'Servicio' COLLATE Latin1_General_CI_AI THEN
                                   CASE
                                       WHEN CTD.ShortName = 'TOT' THEN
                                           @OldAmount
                                       ELSE
                                           0
                                   END
                               ELSE
                                   0
                           END
                    FROM @CouponData                                            CD
                        INNER JOIN [DeliveryBackOffice].[dbo].[CatTypeDiscount] CTD WITH (NOLOCK)
                            ON CD.coupondiscounttypeid = CTD.IdCatTypeDiscount
                        INNER JOIN [DeliveryBackOffice].[dbo].[CatValueType]    CVT WITH (NOLOCK)
                            ON CD.couponvaluetipeid = CVT.IdCatValueType
                );

                -- Obtener datos de Promoción
                DECLARE @PromoName NVARCHAR(200) = N'';
                SET @PromoName = ISNULL((
                                            SELECT TOP 1
                                                   CP.PromoDescription
                                            FROM [DeliveryBackOffice].[dbo].[CatPromo] CP WITH (NOLOCK)
                                                INNER JOIN @CouponData                 CD
                                                    ON CP.IdPromo = CD.couponpromoid
                                            WHERE CP.RowStatus = 1
                                        )
                                      , ''
                                       );

                IF (
                       @OldAmount > 0
                       AND @DiscountAmount IS NOT NULL
                       AND @CostId > 0
                       AND @PromoName != ''
                   )
                BEGIN

                    -- Existe el registro de la guía en la tabla Cost

                    -- Valor nuevo de la guía
                    SET @NewAmount = ROUND(@OldAmount - @DiscountAmount, 1);

                    -- Nuevo BreakdownOfPayment temporal
                    DECLARE @TempBreakdown AS TABLE
                    (
                        RowNumber INT
                      , Description NVARCHAR(200)
                      , Amount DECIMAL(14, 2)
                    );

                    INSERT INTO @TempBreakdown
                    (
                        RowNumber
                      , Description
                      , Amount
                    )
                    SELECT ROW_NUMBER() OVER (ORDER BY BOP.Description)
                         , BOP.Description
                         , BOP.Amount
                    FROM [DeliveryBackOffice].[dbo].[BreakdownOfPayment] BOP WITH (NOLOCK)
                    WHERE BOP.Amount > 0
                          AND BOP.IdCost = @CostId
                          AND BOP.RowStatus = 1;

                    INSERT INTO @TempBreakdown
                    (
                        RowNumber
                      , Description
                      , Amount
                    )
                    VALUES
                    (0, @PromoName, -@DiscountAmount);

                    SET @JsonBreakdown =
                    (
                        SELECT STUFF(
                                        (
                                            SELECT ',{' + '"RowNumber":' + CAST(TB.RowNumber AS NVARCHAR) + ','
                                                   + '"IdCost":' + CAST(@CostId AS NVARCHAR) + ',' + '"Description":"'
                                                   + TB.Description + '",' + '"Amount":' + CAST(TB.Amount AS NVARCHAR)
                                                   + ',' + '"ModIdModule":0' + ',' + '"RowStatus":true' + ','
                                                   + '"TokenCreated":null' + '}'
                                            FROM @TempBreakdown TB
                                            FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)')
                                      , 1
                                      , 1
                                      , ''
                                    )
                    );

                    IF (@JsonBreakdown IS NOT NULL)
                    BEGIN

                        SET @JsonResponse =
                        (
                            SELECT STUFF(
                                            (
                                                SELECT ',{' + '"idResult":200' + ',' + '"newAmount":'
                                                       + CAST(@NewAmount AS NVARCHAR) + ',' + '"UpdateBreackdown":['
                                                       + @JsonBreakdown + ']' + '}'
                                                FOR XML PATH(''), TYPE
                                            ).value('.', 'varchar(max)')
                                          , 1
                                          , 1
                                          , ''
                                        )
                        );

                    END;

                END;
                ELSE IF (
                            @OldAmount > 0
                            AND @DiscountAmount IS NOT NULL
                            AND ISNULL(@CostId, 0) = 0
                            AND @PromoName != ''
                        )
                BEGIN

                    -- Los datos estan bien pero no existe registro de la guía en la tabla Cost

                    DECLARE @ExecResult INT = 0;
                    -- Revalorizar guía para generar registros
                    EXEC @ExecResult = [dbo].[spws_revalue_guide] @GuideSerie = @GuideSerie
                                                                , @GuideNumber = @GuideNumber
                                                                , @CodeApp = @CodeAppRevalue      -- CodeApp generico de forza
                                                                , @Format = 'Non'
                                                                , @CalculateTaxes = @TaxesRevalue -- Dado a nuevas tarifas, no cálcular impuestos
                                                                , @IdModule = 1
                                                                , @SetUpdate = @MustUpdateRevalue -- Actualizar registros
                                                                , @Token = @Token;

                    -- Reverificar el registro de la tabla Cost
                    SET @CostId
                        = ISNULL((
                                     SELECT TOP 1
                                            Co.IdCost
                                     FROM [DeliveryBackOffice].[dbo].[Cost] Co WITH (NOLOCK)
                                     WHERE (
                                               (
                                                   Co.GuideSerie = ISNULL(@GuideSerie, 'FD')
                                                   AND Co.GuideNumber = @GuideNumber
                                               )
                                               OR
                                               (
                                                   Co.ProductNumber = CONCAT(ISNULL(@GuideSerie, 'FD'), @GuideNumber)
                                                   AND Co.GuideSerie IS NULL
                                                   AND Co.GuideNumber IS NULL
                                               )
                                           )
                                           AND Co.RowStatus = 1
                                     ORDER BY Co.DateCreated DESC
                                 )
                               , 0
                                );

                    IF (@CostId > 0)
                    BEGIN
                        -- Se pudo recuperar y generar registro en tabla Cost y BreakdownOfPayment

                        -- Valor nuevo de la guía
                        SET @NewAmount = ROUND(@OldAmount - @DiscountAmount, 1);

                        -- Nuevo BreakdownOfPayment temporal
                        DECLARE @TempBreakdown2 AS TABLE
                        (
                            RowNumber INT
                          , Description NVARCHAR(200)
                          , Amount DECIMAL(14, 2)
                        );

                        INSERT INTO @TempBreakdown2
                        (
                            RowNumber
                          , Description
                          , Amount
                        )
                        SELECT ROW_NUMBER() OVER (ORDER BY BOP.Description)
                             , BOP.Description
                             , BOP.Amount
                        FROM [DeliveryBackOffice].[dbo].[BreakdownOfPayment] BOP WITH (NOLOCK)
                        WHERE BOP.Amount > 0
                              AND BOP.IdCost = @CostId
                              AND BOP.RowStatus = 1;

                        INSERT INTO @TempBreakdown2
                        (
                            RowNumber
                          , Description
                          , Amount
                        )
                        VALUES
                        (0, @PromoName, -@DiscountAmount);

                        SET @JsonBreakdown =
                        (
                            SELECT STUFF(
                                            (
                                                SELECT ',{' + '"RowNumber":' + CAST(TB.RowNumber AS NVARCHAR) + ','
                                                       + '"IdCost":' + CAST(@CostId AS NVARCHAR) + ','
                                                       + '"Description":"' + TB.Description + '",' + '"Amount":'
                                                       + CAST(TB.Amount AS NVARCHAR) + ',' + '"ModIdModule":0' + ','
                                                       + '"RowStatus":true' + ',' + '"TokenCreated":null' + '}'
                                                FROM @TempBreakdown2 TB
                                                FOR XML PATH(''), TYPE
                                            ).value('.', 'varchar(max)')
                                          , 1
                                          , 1
                                          , ''
                                        )
                        );

                        IF (@JsonBreakdown IS NOT NULL)
                        BEGIN

                            SET @JsonResponse =
                            (
                                SELECT STUFF(
                                                (
                                                    SELECT ',{' + '"idResult":200' + ',' + '"newAmount":'
                                                           + CAST(@NewAmount AS NVARCHAR) + ','
                                                           + '"UpdateBreackdown":[' + @JsonBreakdown + ']' + '}'
                                                    FOR XML PATH(''), TYPE
                                                ).value('.', 'varchar(max)')
                                              , 1
                                              , 1
                                              , ''
                                            )
                            );

                        END;

                    END;
                    ELSE
                    BEGIN

                        -- No se puede continuar el procesamiento del cupón, falta algun dato importante
						PRINT 'error 1'
                        SET @JsonResponse =
                        (
                            SELECT STUFF(
                                            (
                                                SELECT ',{' + '"IdResult":407' + ','
                                                       + '"Message":"Cupon no es valido, por favor verifique su información"'
                                                       + ',' + '"Coupon": { } ' + '}'
                                                FOR XML PATH(''), TYPE
                                            ).value('.', 'varchar(max)')
                                          , 1
                                          , 1
                                          , ''
                                        )
                        );

                    END;

                END;
                ELSE
                BEGIN

                    -- No se puede continuar el procesamiento del cupón, falta algun dato importante
					PRINT 'error 2'
                    SET @JsonResponse =
                    (
                        SELECT STUFF(
                                        (
                                            SELECT ',{' + '"IdResult":407' + ','
                                                   + '"Message":"Cupon no es valido, por favor verifique su información"'
                                                   + ',' + '"Coupon": { } ' + '}'
                                            FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)')
                                      , 1
                                      , 1
                                      , ''
                                    )
                    );

                END;

            END;
            ELSE
            BEGIN

                DECLARE @IsCouponRedeemed BIT = 0;
                DECLARE @IsCouponNOTUsable BIT = 0;
                DECLARE @IsCouponBloqued BIT = 0;

                SET @IsCouponRedeemed = ISNULL((
                                                   SELECT TOP 1
                                                          1
                                                   FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH (NOLOCK)
                                                   WHERE PC.PromoCouponSerie = @CouponSerie
                                                         AND PC.RedeemedDate IS NOT NULL
                                                         AND PC.RowStatus = 1
                                               )
                                             , 0
                                              );

                SET @IsCouponNOTUsable = ISNULL((
                                                    SELECT TOP 1
                                                           1
                                                    FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH (NOLOCK)
                                                    WHERE PC.PromoCouponSerie = @CouponSerie
                                                          AND GETDATE() >= PC.FinalActiveDate
                                                          AND PC.RedeemedDate IS NULL
                                                          AND PC.RowStatus = 1
                                                )
                                              , 0
                                               );

                SET @IsCouponBloqued = ISNULL((
                                                  SELECT TOP 1
                                                         1
                                                  FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH (NOLOCK)
                                                  WHERE PC.PromoCouponSerie = @CouponSerie
                                                        AND PC.FinalActiveDate >= GETDATE()
                                                        AND PC.GuideSerieDestination IS NOT NULL
                                                        AND PC.GuideNumberDestination IS NOT NULL
                                                        AND PC.RedeemedDate IS NULL
                                                        AND PC.RowStatus = 1
                                              )
                                            , 0
                                             );

				PRINT @IsCouponRedeemed
                IF (@IsCouponRedeemed = 1)
                BEGIN
				 PRINT 'error 3'
                    SET @JsonResponse =
                    (
                        SELECT STUFF(
                                        (
                                            SELECT ',{' + '"IdResult":408' + ','
                                                   + '"Message":"Cupon no es valido, ya fue canjeado anteriormente."'
                                                   + ',' + '"Coupon": { } ' + '}'
                                            FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)')
                                      , 1
                                      , 1
                                      , ''
                                    )
                    );

                END;
                ELSE IF (@IsCouponNOTUsable = 1)
                BEGIN

                    SET @JsonResponse =
                    (
                        SELECT STUFF(
                                        (
                                            SELECT ',{' + '"IdResult":401' + ','
                                                   + '"Message":"Cupon ya no esta vigente."' + ',' + '"Coupon": { } '
                                                   + '}'
                                            FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)')
                                      , 1
                                      , 1
                                      , ''
                                    )
                    );

                END;
                ELSE IF (@IsCouponBloqued = 1)
                BEGIN

                    SET @JsonResponse =
                    (
                        SELECT STUFF(
                                        (
                                            SELECT ',{' + '"IdResult":408' + ','
                                                   + '"Message":"Cupon esta siendo utilizado por otro servicio, por favor, verifique su información."'
                                                   + ',' + '"Coupon": { } ' + '}'
                                            FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)')
                                      , 1
                                      , 1
                                      , ''
                                    )
                    );

                END;
                ELSE
                BEGIN
				PRINT 'error 4'
                    SET @JsonResponse =
                    (
                        SELECT STUFF(
                                        (
                                            SELECT ',{' + '"IdResult":407' + ','
                                                   + '"Message":"Cupon no es valido, por favor verifique su información"'
                                                   + ',' + '"Coupon": { } ' + '}'
                                            FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)')
                                      , 1
                                      , 1
                                      , ''
                                    )
                    );

                END;

            END;
        END;
        ELSE
        BEGIN
            -- Flujo para otro manejo de cupones que no sea por identificador del cupon
            -- En este caso: 26/05/2022 es un error que no se envie cupon
			PRINT 'errror 5'
            SET @JsonResponse =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{' + '"IdResult":407' + ','
                                           + '"Message":"Cupon no es valido, por favor verifique su información"' + ','
                                           + '"Coupon": { } ' + '}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)')
                              , 1
                              , 1
                              , ''
                            )
            );

        END;

        IF (@JsonResponse IS NULL)
        BEGIN
		PRINT 'error 6'
            SET @JsonResponse =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{' + '"IdResult":407' + ','
                                           + '"Message":"Cupon no es valido, por favor verifique su información"' + ','
                                           + '"Coupon": { } ' + '}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)')
                              , 1
                              , 1
                              , ''
                            )
            );

        END;

        SELECT ('[' + @JsonResponse + ']') JsonOutput;

    END TRY
    BEGIN CATCH

        SET @JsonResponse =
        (
            SELECT STUFF(
                            (
                                SELECT ',{' + '"IdResult":401' + ',' + '"Message":"Cupon no esta vigente"' + ','
                                       + '"messageError":"' + ERROR_MESSAGE() + '"' + ',' + '"Coupon": { } ' + '}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)')
                          , 1
                          , 1
                          , ''
                        )
        );

        SELECT ('[' + @JsonResponse + ']') JsonOutput;

        SELECT 0                 [blnResult]
             , ERROR_NUMBER()    AS [ErrorNumber]
             , ERROR_SEVERITY()  AS [ErrorSeverity]
             , ERROR_STATE()     AS [ErrorState]
             , ERROR_PROCEDURE() AS [ErrorProcedure]
             , ERROR_LINE()      AS [ErrorLine]
             , ERROR_MESSAGE()   AS [ErrorMessage];

    END CATCH;
END; 
