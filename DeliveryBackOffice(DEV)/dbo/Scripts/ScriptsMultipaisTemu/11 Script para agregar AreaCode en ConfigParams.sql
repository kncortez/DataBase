BEGIN TRY
    BEGIN TRANSACTION;

	--SCRIPT PARA INSERTAR EL VALOR DE AreaCode DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('AreaCode'
		,'Codigo de área para los números telefonicos'
		,'503'
		,1
		,GETDATE()
		,'SV'
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