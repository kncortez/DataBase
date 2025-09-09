BEGIN TRY
    BEGIN TRANSACTION;

    --======================================= EJECUTAR MANUALMENTE DE PRIMERO =======================================

    /* ZigiBuyerId: Identificador de Zigi para diferenciar el usuario que hace el pago */
	ALTER TABLE DeliveryBackOffice.dbo.PaymentZigi
	ADD ZigiBuyerId nvarchar(50);

	/* ZigiBankAccount: Numero de cuenta bancaria donde Zigi relaciona el pago */
	ALTER TABLE DeliveryBackOffice.dbo.PaymentZigi
	ADD ZigiBankAccount nvarchar(50);

	--========================================== FIN EJECUCION MANUALMENTE ==========================================

	EXECUTE sp_addextendedproperty 
		@name = N'MS_Description', 
		@value = N'Identificador unico proporcionado por Zigi para diferenciar el usuario que hace el pago', 
		@level0type = N'SCHEMA', 
		@level0name = N'dbo', 
		@level1type = N'TABLE', 
		@level1name = N'PaymentZigi', 
		@level2type = N'COLUMN', 
		@level2name = N'ZigiBuyerId';
	
	EXECUTE sp_addextendedproperty 
		@name = N'MS_Description', 
		@value = N'Numero de cuenta bancaria donde Zigi relaciona el pago', 
		@level0type = N'SCHEMA', 
		@level0name = N'dbo', 
		@level1type = N'TABLE', 
		@level1name = N'PaymentZigi', 
		@level2type = N'COLUMN', 
		@level2name = N'ZigiBankAccount';



    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
