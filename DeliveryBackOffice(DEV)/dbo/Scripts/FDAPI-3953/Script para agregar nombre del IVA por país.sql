--SELECT * FROM DeliveryBackOffice.dbo.DefaultValuesPerCountry WITH(NOLOCK)

--Script para agregar nombre del IVA por país
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- 1. Agregar la columna
	ALTER TABLE dbo.DefaultValuesPerCountry
	ADD VATShortName VARCHAR(10) NULL;

	-- 2. Actualizar los valores existentes según el código de país
	UPDATE dbo.DefaultValuesPerCountry
	SET VATShortName = CASE IdCountry
		WHEN 'GT' THEN 'IVA'   -- Guatemala
		WHEN 'HN' THEN 'ISV'   -- Honduras
		WHEN 'SV' THEN 'IVA'   -- El Salvador
		ELSE NULL
	END;

	EXEC sp_addextendedproperty
    @name = 'MS_Description',
    @value = 'Abreviación del Impuesto al Valor Agregado por país (VAT: Value Added Tax)',
    @level0type = 'SCHEMA',  @level0name = 'dbo',
    @level1type = 'TABLE',   @level1name = 'DefaultValuesPerCountry',
    @level2type = 'COLUMN',  @level2name = 'VATShortName';
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
