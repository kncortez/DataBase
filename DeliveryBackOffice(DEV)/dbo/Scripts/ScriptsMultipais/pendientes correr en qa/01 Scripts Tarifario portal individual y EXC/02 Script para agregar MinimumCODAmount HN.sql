--SCRIPT PARA INSERTAR EL VALOR DE MinimumCODAmount DE HN EN ConfigParams
BEGIN TRY
    BEGIN TRANSACTION;
    
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('MinimumCODAmount'
		,'Monto minimo de COD permitido en la generación de una guía'
		,'90'
		,1
		,GETDATE()
		,'HN'
		,NULL)

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
