BEGIN TRY
    BEGIN TRAN;

    DECLARE @StatusOrderId INT;

    INSERT INTO StatusOrder
    (
        OrderDescription,
        CatCheckpointTypeId,
        CatStatusTypeId,
        StatusMessage,
        StatusOrderTrackingDescription,
        RowStatus,
        TokenCreated,
        DateCreated,
        TokenUpdated,
        DateUpdated,
        NextSteps,
        CatStatusProcessId
    )
    VALUES
    (
        'Reversión Entrega Desktop',
        2, -- Checkpoint de proceso
        1, -- Interno
        'La entrega de la guía ha sido revertida desde Hermes Desktop',
        'Entrega revertida manualmente para reproceso',
        1,
        'SYS-BPEDROZA',
        GETDATE(),
        NULL,
        NULL,
        'Reasignar guía a flujo operativo',
        3 -- En instalaciones
    );

    -- Obtener el Id recién insertado
    SET @StatusOrderId = SCOPE_IDENTITY();

    INSERT INTO WebhookRestrinctionByUser
    (
        CustomerId,
        WebhookTypeId,
        StatusOrderId,
        StatusExternalName,
        RowStatus,
        TokenCreated,
        DateCreated,
        TokenUpdated,
        DateUpdated
    )
    VALUES
    (
        1106,
        1,
        @StatusOrderId,
        NULL,
        1,
        'SYS-BPEDROZA',
        GETDATE(),
        NULL,
        NULL
    );

    COMMIT TRAN;
END TRY
BEGIN CATCH
    ROLLBACK TRAN;

    -- Manejo básico del error
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
