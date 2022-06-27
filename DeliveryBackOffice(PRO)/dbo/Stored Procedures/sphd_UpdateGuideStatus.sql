
-- =============================================
-- Author:		<César, Sazo>
-- Create date: <20/10/2021>
-- Description:	< Cambio de estado de pantalla de administración de checkpoints >
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <01/06/2022>
-- Description:	< liberación de cupones y anulación de los mismos >
-- =============================================
-- Author:		<Edelman Vásquez>
-- Update date: <07/06/2022>
-- Description:	<Control de mensajes de errores, indicando por que una anulación no procede>
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[sphd_UpdateGuideStatus]
    @Guide_Serie VARCHAR(2),
    @Guide_Number INT,
    @newStatus INT,
    @UserToken VARCHAR(50),
    @Observations VARCHAR(200)
AS
BEGIN

    DECLARE @VoidStatus INT =
            (
                SELECT TOP 1
                       SO.StatusOrderId
                FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
                WHERE SO.OrderDescription = 'Anulado' COLLATE Latin1_General_CI_AI
            );

    DECLARE @IsCouponOrigin BIT = 0;
    DECLARE @IsCouponRedeemer BIT = 0;
    DECLARE @RowStatus1 BIT = 0;

    DECLARE @ResultOperation VARCHAR(200);
    DECLARE @ResultCode INT;
    SET @RowStatus1 = ISNULL(
                      (
                          SELECT TOP 1
                                 1
                          FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH (NOLOCK)
                          WHERE Guide_Serie = @Guide_Serie
                                AND Guide_Number = @Guide_Number
                                AND StatusOrderId <> 7
                      ),
                      0
                            );


    SET @IsCouponOrigin = ISNULL(
                          (
                              SELECT TOP 1
                                     1
                              FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
                              WHERE PromoC.GuideSerieOrigin = @Guide_Serie
                                    AND PromoC.GuideNumberOrigin = @Guide_Number
                                    AND PromoC.RowStatus = 1
                          ),
                          0
                                );

    SET @IsCouponRedeemer = ISNULL(
                            (
                                SELECT TOP 1
                                       1
                                FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
                                WHERE PromoC.GuideSerieDestination = @Guide_Serie
                                      AND PromoC.GuideNumberDestination = @Guide_Number
                                      AND PromoC.RowStatus = 1
                            ),
                            0
                                  );

    BEGIN TRANSACTION;
    BEGIN TRY
        --- Valida que sea Guía que genera cupon y que el estado es anular id= 7
        IF (@IsCouponOrigin = 1 AND @newStatus = @VoidStatus)
        BEGIN

            DECLARE @IsCouponRedeemed BIT = 0;
            SET @IsCouponRedeemed = ISNULL(
                                    (
                                        SELECT TOP 1
                                               1
                                        FROM [DeliveryBackOffice].[dbo].[PromoCoupon] PromoC WITH (NOLOCK)
                                        WHERE PromoC.GuideSerieOrigin = @Guide_Serie
                                              AND PromoC.GuideNumberOrigin = @Guide_Number
                                              AND PromoC.GuideSerieDestination IS NOT NULL
                                              AND PromoC.GuideNumberDestination IS NOT NULL
                                              AND PromoC.RedeemedDate IS NOT NULL
                                              AND PromoC.RowStatus = 1
                                    ),
                                    0
                                          );
            --Validar que no tenga cupón redimido
            IF (@IsCouponRedeemed = 0)
            BEGIN
                -- Cupon no ha sido redimido
                SET @ResultOperation = 'Guía y Cupón Anulado Exitosamente!!';
                UPDATE [DeliveryBackOffice].[dbo].[PromoCoupon]
                SET RowStatus = 0,
                    SystemDestination = NULL,
                    CustomerDestination = NULL,
                    VisitPointClientDestination = NULL,
                    VisitPointClientPortfolioDestination = NULL,
                    GuideSerieDestination = NULL,
                    GuideNumberDestination = NULL,
                    ServiceManagementDestination = NULL,
                    RedeemedDate = NULL,
                    OriginalAmount = NULL,
                    DiscountAmount = NULL,
                    FinalAmount = NULL,
                    DateUpdated = GETDATE(),
                    TokenUpdated = @UserToken
                WHERE GuideSerieOrigin = @Guide_Serie
                      AND GuideNumberOrigin = @Guide_Number;

                UPDATE DeliveryBackOffice.dbo.DeliveryOrder
                SET StatusOrderId = @newStatus
                WHERE Guide_Serie = @Guide_Serie
                      AND Guide_Number = @Guide_Number;

                INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                (
                    Guide_Serie,
                    Guide_Number,
                    StatusOrderId,
                    UserCreated,
                    DateCreated,
                    DateCreatedInSystem,
                    Observations
                )
                VALUES
                (@Guide_Serie, @Guide_Number, @newStatus, @UserToken, GETDATE(), GETDATE(), @Observations);



                IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;

            END;
            ELSE
            BEGIN

                SET @ResultOperation = 'No es Posible anular la guía, contiene un cupón Canjeado!!';
                IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;

            END;

        END;
        --Valida si guía tiene cupón redimido
        ELSE IF (@IsCouponRedeemer = 1 AND @newStatus = @VoidStatus)
        BEGIN
            SET @ResultOperation = 'Guía  Anulada Exitosamente!!';
            UPDATE [DeliveryBackOffice].[dbo].[PromoCoupon]
            SET SystemDestination = NULL,
                CustomerDestination = NULL,
                VisitPointClientDestination = NULL,
                VisitPointClientPortfolioDestination = NULL,
                GuideSerieDestination = NULL,
                GuideNumberDestination = NULL,
                ServiceManagementDestination = NULL,
                RedeemedDate = NULL,
                OriginalAmount = NULL,
                DiscountAmount = NULL,
                FinalAmount = NULL,
                DateUpdated = GETDATE(),
                TokenUpdated = @UserToken
            WHERE GuideSerieDestination = @Guide_Serie
                  AND GuideNumberDestination = @Guide_Number;

            UPDATE DeliveryBackOffice.dbo.DeliveryOrder
            SET StatusOrderId = @newStatus
            WHERE Guide_Serie = @Guide_Serie
                  AND Guide_Number = @Guide_Number;

            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
            (
                Guide_Serie,
                Guide_Number,
                StatusOrderId,
                UserCreated,
                DateCreated,
                DateCreatedInSystem,
                Observations
            )
            VALUES
            (@Guide_Serie, @Guide_Number, @newStatus, @UserToken, GETDATE(), GETDATE(), @Observations);


            IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;


        END;
        --Valida si guía esta anulada
        ELSE IF (@IsCouponRedeemer = 0 AND @IsCouponOrigin = 0 AND @RowStatus1 = 0)
        BEGIN
            SET @ResultOperation = 'Guía  ya fue anulada!!';


            IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;


        END;
        ELSE IF (@RowStatus1 = 1 AND @IsCouponRedeemer = 0 AND @IsCouponOrigin = 0)
        BEGIN
            SET @ResultOperation = 'Guía Anulada Exitosamente!!';
            UPDATE DeliveryBackOffice.dbo.DeliveryOrder
            SET StatusOrderId = @newStatus
            WHERE Guide_Serie = @Guide_Serie
                  AND Guide_Number = @Guide_Number;

            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
            (
                Guide_Serie,
                Guide_Number,
                StatusOrderId,
                UserCreated,
                DateCreated,
                DateCreatedInSystem,
                Observations
            )
            VALUES
            (@Guide_Serie, @Guide_Number, @newStatus, @UserToken, GETDATE(), GETDATE(), @Observations);

            IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;
        END;
        ELSE
        BEGIN
            SET @ResultOperation = 'Guía No Existe!!';
        END;


        SELECT 1 [blnResult],
               @Guide_Serie + CONVERT(VARCHAR, @Guide_Number) + ': ' + @ResultOperation [ResultDescription];


    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 0 [blnResult],
               @ResultOperation [ResultDescription];

    END CATCH;


END;