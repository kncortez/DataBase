CREATE PROCEDURE dbo.SupportGenerateNewCoupon
    @GuideSerie NVARCHAR(2) = 'FD',
    @GuideNumber INT = 4566935,
    @Token NVARCHAR(50) = ''
AS
BEGIN

    BEGIN TRY

        -- Variables adicionales de datos
        DECLARE @CustomerId INT = 0;
        DECLARE @CustomerType INT = 0;
        DECLARE @VisitPointClientId INT = 0;
        DECLARE @VisitPointClientPortfolioId INT = NULL;

        DECLARE @CouponDataReponse AS TABLE
        (
            CouponSerie NVARCHAR(20),
            CouponFinalDate DATETIME,
            CouponPromo NVARCHAR(200),
            PromoId INT
        );


        BEGIN TRANSACTION;
        IF (NOT EXISTS
        (
            SELECT TOP 1
                   1
            FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
            WHERE PromoC.GuideSerieOrigin = @GuideSerie
                  AND PromoC.GuideNumberOrigin = @GuideNumber
        )
           )
        BEGIN

            SELECT TOP 1
                   @CustomerId = Cu.IdCustomer,
                   @CustomerType = Cu.IdCustomerType,
                   @VisitPointClientId = IIF(VPC.CodeOfReference = 0, NULL, VPC.CodeOfReference),
                   @VisitPointClientPortfolioId
                       = IIF(DO.VisitpointClientPortfolioId = 0, NULL, DO.VisitpointClientPortfolioId)
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
                LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
                    ON DO.Sender_ID = VPC.CodeOfReference
                LEFT JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH (NOLOCK)
                    ON ISNULL(DO.IdCustomer, VPC.CustomerID) = Cu.IdCustomer
            WHERE DO.Guide_Serie = @GuideSerie
                  AND DO.Guide_Number = @GuideNumber;

            -- SE debe generar un cupon
            DECLARE @NewCouponData AS TABLE
            (
                PromoId INT,
                CouponFinalDate DATETIME,
                CouponDiscountType INT,
                CouponValueType INT,
                CouponValue DECIMAL(5, 2),
                PromoName NVARCHAR(200)
            );

            -- Insertar datos de promo valida
            INSERT INTO @NewCouponData
            (
                PromoId,
                CouponFinalDate,
                CouponDiscountType,
                CouponValueType,
                CouponValue,
                PromoName
            )
            SELECT
            -- Top 1 para generar cupon de promo con mayor peso
                TOP 1
                CPromo.IdPromo,
                (CASE
                     WHEN CPromo.LimitPromoTime = 24.00 THEN
                         DATEADD(SECOND, -1, CAST(DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) AS DATETIME))
                     ELSE
                         DATEADD(MINUTE, (ISNULL(CPromo.LimitPromoTime, 1) * 60), GETDATE())
                 END
                ),
                CPromo.CatDiscountTypeId,
                CPromo.CatValueTypeId,
                CPromo.PromoValue,
                CPromo.PromoDescription
            FROM [DeliveryBackOffice].[dbo].[CatPromo] CPromo WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[PromoCoverage] PCov WITH (NOLOCK)
                    ON CPromo.IdPromo = PCov.CatPromoId
            WHERE
                -- Validación de día de la semana correcta
                (
                    (
                        CPromo.Monday = 1
                        AND DATEPART(WEEKDAY, GETDATE()) = 2
                    )
                    OR
                    (
                        CPromo.Tuesday = 1
                        AND DATEPART(WEEKDAY, GETDATE()) = 3
                    )
                    OR
                    (
                        CPromo.Wednesday = 1
                        AND DATEPART(WEEKDAY, GETDATE()) = 4
                    )
                    OR
                    (
                        CPromo.Thursday = 1
                        AND DATEPART(WEEKDAY, GETDATE()) = 5
                    )
                    OR
                    (
                        CPromo.Friday = 1
                        AND DATEPART(WEEKDAY, GETDATE()) = 6
                    )
                    OR
                    (
                        CPromo.Saturday = 1
                        AND DATEPART(WEEKDAY, GETDATE()) = 7
                    )
                    OR
                    (
                        CPromo.Sunday = 1
                        AND DATEPART(WEEKDAY, GETDATE()) = 1
                    )
                )
                -- Validación de rango de fechas correcto para la promo
                AND (GETDATE()
                BETWEEN CPromo.StartPromoDate AND CPromo.FinishPromoDate
                    )
                -- Validación de cobertura de promo
                AND
                (
                    PCov.CustomerId = @CustomerId
                    OR PCov.CustomerTypeId = @CustomerType
                    OR PCov.VisitPointClientId = @VisitPointClientId
                )
                --- Promo esta activa
                AND CPromo.RowStatus = 1
            ORDER BY
                -- Aplicar promoción de mayor peso
                CPromo.PromoWeight DESC;

            IF (EXISTS (SELECT TOP 1 1 FROM @NewCouponData))
            BEGIN

                -- Insertar nuevo cupon
                INSERT INTO [DeliveryBackOffice].[dbo].[PromoCoupon]
                (
                    CatPromoId,
                    PromoCouponSerie,
                    GuideSerieOrigin,
                    GuideNumberOrigin,
                    CustomerOrigin,
                    VisitPointClientOrigin,
                    VisitPointClientPortfolioOrigin,
                    SystemOrigin,
                    CatDiscountTypeId,
                    CatValueTypeId,
                    CouponValue,
                    StartActiveDate,
                    FinalActiveDate,
                    RowStatus,
                    DateCreated,
                    TokenCreated
                )
                OUTPUT inserted.PromoCouponSerie,
                       inserted.FinalActiveDate,
                       inserted.CatPromoId
                INTO @CouponDataReponse
                (
                    CouponSerie,
                    CouponFinalDate,
                    PromoId
                )
                SELECT NCD.PromoId,
                       CONCAT(@GuideSerie, @GuideNumber) + RIGHT('000' + CAST(CEILING(RAND() * 100) AS NVARCHAR), 2),
                       @GuideSerie,
                       @GuideNumber,
                       @CustomerId,
                       @VisitPointClientId,
                       @VisitPointClientPortfolioId,
                       2,
                       NCD.CouponDiscountType,
                       NCD.CouponValueType,
                       NCD.CouponValue,
                       GETDATE(),
                       NCD.CouponFinalDate,
                       1,
                       GETDATE(),
                       @Token
                FROM @NewCouponData NCD;

                -- Actualizar nombre de promo en cupon a devolver
                UPDATE @CouponDataReponse
                SET CouponPromo = NCD.PromoName
                FROM @NewCouponData NCD
                    INNER JOIN @CouponDataReponse CD
                        ON NCD.PromoId = CD.PromoId;

                SELECT *
                FROM @CouponDataReponse;

            END;

        END;
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
		SELECT ERROR_NUMBER(),
		ERROR_LINE(),
		ERROR_MESSAGE()
    END CATCH;



END;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportGenerateNewCoupon] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportGenerateNewCoupon] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportGenerateNewCoupon] TO [cvaldes]
    AS [dbo];

