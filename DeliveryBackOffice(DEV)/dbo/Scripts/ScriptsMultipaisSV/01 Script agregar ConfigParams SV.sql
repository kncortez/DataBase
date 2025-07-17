BEGIN TRY
    BEGIN TRANSACTION;

    --SCRIPT PARA INSERTAR EL VALOR DE MinimumCODAmount DE SV EN ConfigParams
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
		,'3.75'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE MinimumCODAmount DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('MinCODCommissionAmount'
		,'Monto de comision de COD minimo a descontar'
		,'3.9'
		,1
		,GETDATE()
		,'SV'
		,NULL)

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

	--SCRIPT PARA INSERTAR EL VALOR DE MaximumCODAmount DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('MaximumCODAmount'
		,'Monto maximo de COD permitido en la generación de una guía'
		,'6250'
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
