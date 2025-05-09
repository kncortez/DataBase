BEGIN TRY
    BEGIN TRANSACTION;

    --SCRIPT PARA INSERTAR EL VALOR DE ReturnPercentParam DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('ReturnPercentParam'
		,'Porcentaje de devolucion general para COD Anticipado'
		,'2'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE MinGuidesPerMonthParam DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('MinGuidesPerMonthParam'
		,'Cantidad Minima de guias general para COD Anticipado'
		,'12'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE IsOldestParam DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('IsOldestParam'
		,'Antiguedad en dias de generacion de primera guia general para COD Anticipado'
		,'60'
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
