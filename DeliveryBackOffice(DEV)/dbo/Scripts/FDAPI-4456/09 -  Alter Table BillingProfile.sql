BEGIN TRY
    BEGIN TRANSACTION;

    ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
    ADD NRC NVARCHAR(200);

    ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
    ADD TypeIdentificationDocumentCode NVARCHAR(100);

    ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
    ADD IdDocument NVARCHAR(20);

    ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
    ADD DistrictId INT;

    ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
    ADD StateId INT;

    ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
    ADD ActivityCode NVARCHAR(100);

    ALTER TABLE DeliveryBackOffice.dbo.BillingProfile
    ADD Inv_type INT;

    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena información datos de facturación favoritos, clientes individuales', @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Número de Registro del Contribuyente (NRC)', @level2type = N'COLUMN', @level2name = 'NRC',@level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de documento de identificación del comprador', @level2type = N'COLUMN', @level2name = 'TypeIdentificationDocumentCode', @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Número de identificación', @level2type = N'COLUMN', @level2name = 'IdDocument', @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del distrito', @level2type = N'COLUMN', @level2name = 'DistrictId', @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

    EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del estado', @level2type = N'COLUMN', @level2name = 'StateId',@level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

    COMMIT TRANSACTION;
    PRINT 'Tabla Billing Profile actualizada exitosamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;
