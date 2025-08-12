BEGIN TRANSACTION

BEGIN TRY
--Script
    ALTER TABLE DefaultValuesPerCountry
    ADD CodeOfReferenceCorpForInvoice NVARCHAR(10) NULL

    EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code Of Reference que se usa por defecto para facturas corporativas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'CodeOfReferenceCorpForInvoice';
    
	COMMIT TRANSACTION
	print 'Columna agregada exitosamente'

END TRY
BEGIN CATCH
	-- Revertir transacción en caso de error
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
    
	-- Capturar información del error
	SELECT ERROR_MESSAGE(),
			ERROR_SEVERITY(),
			ERROR_STATE()

END CATCH