BEGIN TRY
    BEGIN TRANSACTION;

    --======================================= EJECUTAR MANUALMENTE DE PRIMERO =======================================

    /* WhatsAppLinkRequestSent: 1 = ya se envió el mensaje solicitando link Zigi */
	ALTER TABLE DeliveryBackOffice.dbo.PaymentZigi
	ADD LinkRequestSent bit NOT NULL
	CONSTRAINT DF_PaymentZigi_LinkRequestSent DEFAULT (0) WITH VALUES;

	/* WhatsAppPaymentConfirmSent: 1 = ya se envió el mensaje de confirmación de pago Zigi */
	ALTER TABLE DeliveryBackOffice.dbo.PaymentZigi
	ADD PaymentConfirmSent bit NOT NULL
	CONSTRAINT DF_PaymentZigi_PaymentConfirmSent DEFAULT (0) WITH VALUES;

	--========================================== FIN EJECUCION MANUALMENTE ==========================================

	EXEC sys.sp_addextendedproperty
	  @name = N'MS_Description',
	  @value = N'Indica si se envió el WhatsApp para solicitar el link de Zigi (1=Enviado, 0=No enviado).',
	  @level0type = N'SCHEMA', @level0name = N'dbo',
	  @level1type = N'TABLE',  @level1name = N'PaymentZigi',
	  @level2type = N'COLUMN', @level2name = N'LinkRequestSent';

	EXEC sys.sp_addextendedproperty
	  @name = N'MS_Description',
	  @value = N'Indica si se envió el WhatsApp de confirmación de pago de Zigi (1=Enviado, 0=No enviado).',
	  @level0type = N'SCHEMA', @level0name = N'dbo',
	  @level1type = N'TABLE',  @level1name = N'PaymentZigi',
	  @level2type = N'COLUMN', @level2name = N'PaymentConfirmSent';

	-- IMPORTANTE: marcar existentes como ENVIADOS (1) para no disparar históricos
    UPDATE DeliveryBackOffice.dbo.PaymentZigi SET LinkRequestSent = 1;
	UPDATE DeliveryBackOffice.dbo.PaymentZigi SET PaymentConfirmSent = 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
