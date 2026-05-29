CREATE PROCEDURE dbo.support_AnularTransaccionPorOrderNumber
    @OrderNumber     NVARCHAR(50),
    @SupportComment  NVARCHAR(50),
    @Mode            INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NewOrderNumber NVARCHAR(150);
    SET @NewOrderNumber = N'x_' + @SupportComment + N'_' + @OrderNumber;

    /* ==============================
        VALIDACIONES GENERALES
       ============================== */

    IF NOT EXISTS (
        SELECT 1
        FROM DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates WITH (NOLOCK)
        WHERE OrderNumber = @OrderNumber
    )
    BEGIN
        RAISERROR('No existe en RegistrationofTransactionProcessStates',16,1);
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM DeliveryBackOffice.dbo.SubscriptionPaymentLog WITH (NOLOCK)
        WHERE [Authorization] = @OrderNumber
    )
    BEGIN
        RAISERROR('No existe en SubscriptionPaymentLog',16,1);
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM DeliveryBackOffice.dbo.Subscription s WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.SubscriptionPaymentLog spl WITH (NOLOCK)
            ON s.IdSubscription = spl.SubscriptionId
        WHERE spl.[Authorization] = @OrderNumber
    )
    BEGIN
        RAISERROR('No existe Subscription asociada',16,1);
        RETURN;
    END;

    /* ==============================
        MODO 1 - PREVIEW
       ============================== */

    IF @Mode = 1
    BEGIN
        ;SELECT 
            'RegistrationofTransactionProcessStates' AS Tabla,
            rg.OrderNumber AS OrderNumber_Actual,
            rg.Vaucher     AS Vaucher_Actual,
            @NewOrderNumber AS Nuevo_Valor
        FROM DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates rg WITH (NOLOCK)
        WHERE rg.OrderNumber = @OrderNumber;

        ;SELECT 
            'SubscriptionPaymentLog' AS Tabla,
            spl.[Authorization] AS AuthorizationValue,
            spl.RowStatus       AS RowStatus_Actual,
            0                   AS RowStatus_Nuevo
        FROM DeliveryBackOffice.dbo.SubscriptionPaymentLog spl WITH (NOLOCK)
        WHERE spl.[Authorization] = @OrderNumber;

        ;SELECT 
            'Subscription' AS Tabla,
            s.IdSubscription,
            s.RowStatus AS RowStatus_Actual,
            0           AS RowStatus_Nuevo
        FROM DeliveryBackOffice.dbo.Subscription s WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.SubscriptionPaymentLog spl WITH (NOLOCK)
            ON s.IdSubscription = spl.SubscriptionId
        WHERE spl.[Authorization] = @OrderNumber;

        PRINT 'VALIDACIÓN EXITOSA: Es posible realizar el cambio.';
        RETURN;
    END;

    /* ==============================
        MODO 2
       ============================== */

    IF @Mode = 2
    BEGIN
        BEGIN TRY
            BEGIN TRAN;

            UPDATE rg
            SET 
                rg.OrderNumber = @NewOrderNumber,
                rg.Vaucher     = @NewOrderNumber
            FROM DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates rg
            INNER JOIN DeliveryBackOffice.dbo.SubscriptionPaymentLog spl
                ON rg.OrderNumber = spl.[Authorization]
            WHERE rg.OrderNumber = @OrderNumber;

            UPDATE DeliveryBackOffice.dbo.SubscriptionPaymentLog
            SET RowStatus = 0
            WHERE [Authorization] = @OrderNumber;

            UPDATE s
            SET RowStatus = 0
            FROM DeliveryBackOffice.dbo.Subscription s
            INNER JOIN DeliveryBackOffice.dbo.SubscriptionPaymentLog spl
                ON s.IdSubscription = spl.SubscriptionId
            WHERE spl.[Authorization] = @OrderNumber;

            COMMIT;

            PRINT 'EJECUCIÓN COMPLETADA';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK;
            THROW;
        END CATCH

        RETURN;
    END;

    /* ==============================
        MODO 3
       ============================== */

    IF @Mode = 3
    BEGIN
        BEGIN TRY
            BEGIN TRAN;

            UPDATE DeliveryBackOffice.dbo.RegistrationofTransactionProcessStates
            SET 
                OrderNumber = @NewOrderNumber,
                Vaucher     = @NewOrderNumber
            WHERE OrderNumber = @OrderNumber;

            COMMIT;

            PRINT 'MODO 3 OK';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK;
            THROW;
        END CATCH

        RETURN;
    END;

    RAISERROR('Modo inválido. Use 1, 2 o 3.',16,1);
END;