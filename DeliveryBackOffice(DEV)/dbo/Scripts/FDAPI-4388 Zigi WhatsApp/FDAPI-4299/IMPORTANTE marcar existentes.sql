	-- IMPORTANTE: marcar existentes como ENVIADOS (1) para no disparar históricos
    UPDATE DeliveryBackOffice.dbo.PaymentZigi SET LinkRequestSent = 1;
	UPDATE DeliveryBackOffice.dbo.PaymentZigi SET PaymentConfirmSent = 1;