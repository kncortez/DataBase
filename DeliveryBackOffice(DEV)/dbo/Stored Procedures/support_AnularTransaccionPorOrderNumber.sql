CREATE PROCEDURE dbo.support_AnularTransaccionPorOrderNumber
    @OrderNumber       VARCHAR(50),
    @ComentarioSoporte VARCHAR(50),
    @Modo              INT  -- 1 = Preview | 2 = Ejecutar | 3 = Telemercadeo
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NuevoOrderNumber VARCHAR(150);

    SET @NuevoOrderNumber =
        'x_' + @ComentarioSoporte + '_' + @OrderNumber;

    /* ==============================
        VALIDACIONES GENERALES
       ============================== */
    IF NOT EXISTS (
        SELECT 1
        FROM RegistrationofTransactionProcessStates WITH (NOLOCK)
        WHERE OrderNumber = @OrderNumber
    )
    BEGIN
        RAISERROR('No existe en RegistrationofTransactionProcessStates',16,1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM SubscriptionPaymentLog WITH (NOLOCK)
        WHERE [Authorization] = @OrderNumber
    )
    BEGIN
        RAISERROR('No existe en SubscriptionPaymentLog',16,1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Subscription s WITH (NOLOCK)
        INNER JOIN SubscriptionPaymentLog spl WITH (NOLOCK)
            ON s.IdSubscription = spl.SubscriptionId
        WHERE spl.[Authorization] = @OrderNumber
    )
    BEGIN
        RAISERROR('No existe Subscription asociada',16,1);
        RETURN;
    END

    /* ==============================
       👁️ MODO 1 - PREVIEW
       ============================== */
    IF @Modo = 1
    BEGIN
        SELECT 
            'RegistrationofTransactionProcessStates' AS Tabla,
            OrderNumber AS OrderNumber_Actual,
            Vaucher     AS Vaucher_Actual,
            @NuevoOrderNumber AS Nuevo_Valor
        FROM RegistrationofTransactionProcessStates WITH (NOLOCK)
        WHERE OrderNumber = @OrderNumber;

        SELECT 
            'SubscriptionPaymentLog' AS Tabla,
            [Authorization] AS Authorization,
            RowStatus       AS RowStatus_Actual,
            0               AS RowStatus_Nuevo
        FROM SubscriptionPaymentLog WITH (NOLOCK)
        WHERE [Authorization] = @OrderNumber;

        SELECT 
            'Subscription' AS Tabla,
            s.IdSubscription,
            s.RowStatus AS RowStatus_Actual,
            0           AS RowStatus_Nuevo
        FROM Subscription s WITH (NOLOCK)
        INNER JOIN SubscriptionPaymentLog spl WITH (NOLOCK)
            ON s.IdSubscription = spl.SubscriptionId
        WHERE spl.[Authorization] = @OrderNumber;

        PRINT 'VALIDACIÓN EXITOSA: Es posible realizar el cambio.';
        RETURN;
    END

    /* ==============================
        MODO 2 - EJECUCIÓN COMPLETA
       ============================== */
    IF @Modo = 2
    BEGIN
        BEGIN TRY
            BEGIN TRAN;

            UPDATE rg
            SET 
                rg.OrderNumber = @NuevoOrderNumber,
                rg.Vaucher     = @NuevoOrderNumber
            FROM RegistrationofTransactionProcessStates rg
            INNER JOIN SubscriptionPaymentLog spl WITH (NOLOCK)
                ON rg.OrderNumber = spl.[Authorization]
            WHERE rg.OrderNumber = @OrderNumber;

            UPDATE SubscriptionPaymentLog
            SET RowStatus = 0
            WHERE [Authorization] = @OrderNumber;

            UPDATE s
            SET RowStatus = 0
            FROM Subscription s
            INNER JOIN SubscriptionPaymentLog spl WITH (NOLOCK)
                ON s.IdSubscription = spl.SubscriptionId
            WHERE spl.[Authorization] = @OrderNumber;

            COMMIT TRAN;

            PRINT 'EJECUCIÓN COMPLETADA: Cambios aplicados correctamente.';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRAN;
            RAISERROR(ERROR_MESSAGE(),16,1);
        END CATCH

        RETURN;
    END

    /* ==============================
        MODO 3 - TELEMERCADEO
       (Solo Process)
       ============================== */
    IF @Modo = 3
    BEGIN
        BEGIN TRY
            BEGIN TRAN;

            UPDATE RegistrationofTransactionProcessStates
            SET 
                OrderNumber = @NuevoOrderNumber,
                Vaucher     = @NuevoOrderNumber
            WHERE OrderNumber = @OrderNumber;

            COMMIT TRAN;

            PRINT 'MODO 3 EJECUTADO: Actualización solo en Process.';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRAN;
            RAISERROR(ERROR_MESSAGE(),16,1);
        END CATCH

        RETURN;
    END

    /* ==============================
        MODO INVÁLIDO
       ============================== */
    RAISERROR('Modo inválido. Use 1, 2 o 3.',16,1);
END;
GO


