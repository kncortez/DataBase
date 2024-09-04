
--SCRIPT PARA AGREGAR NUEVA COLUMNA DE PAÍS EN CONFIGPARAMS

BEGIN TRY
    BEGIN TRANSACTION;

	ALTER TABLE DeliveryBackOffice.dbo.ConfigParams
	ADD IdCountry VARCHAR(2);

	ALTER TABLE DeliveryBackOffice.dbo.ConfigParams
	ADD CONSTRAINT FK_ConfigParams_CatCountry FOREIGN KEY (IdCountry)
	REFERENCES DeliveryBackOffice.dbo.CatCountry(IdCountry);

	--SCRIPT PARA AGREGAR NUEVA COLUMNA DE MONEDA EN CONFIGPARAMS

	ALTER TABLE DeliveryBackOffice.dbo.ConfigParams
	ADD IdCurrencyCOD INT;

	ALTER TABLE DeliveryBackOffice.dbo.ConfigParams
	ADD CONSTRAINT FK_ConfigParams_CatCurrencyCOD FOREIGN KEY (IdCurrencyCOD)
	REFERENCES DeliveryBackOffice.dbo.CatCurrencyCOD (IdCatCurrencyCOD);

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;

