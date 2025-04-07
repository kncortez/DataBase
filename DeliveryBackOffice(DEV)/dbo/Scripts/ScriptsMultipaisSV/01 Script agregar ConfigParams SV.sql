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

	--SCRIPT PARA INSERTAR EL VALOR DE URLLinkdeEntrega DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('URLLinkdeEntrega'
		,'URL de confirmación de datos'
		,'https://portal.forzadelivery.com/design/individual/mis-links/'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE PBX DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('PBX'
		,'Numero de telefono'
		,'2276-1919'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE MinRangeCODComisison1Param DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('MinRangeCODComisison1Param'
		,'Minimo de rango para comision COD Anticipado rango 1 - 300'
		,'1'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE MinRangeCODComisison2Param DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('MinRangeCODComisison2Param'
		,'Minimo de rango para comision COD Anticipado rango 301 - 600'
		,'38'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE MaxRangeCODComisison1Param DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('MaxRangeCODComisison1Param'
		,'Maximo de rango para comision COD Anticipado rango 1 - 300'
		,'300'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE MaxRangeCODComisison2Param DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('MaxRangeCODComisison2Param'
		,'Maximo de rango para comision COD Anticipado rango 301 - 600'
		,'75'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE ValueCODComisison1Param DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('ValueCODComisison1Param'
		,'Valor de comision COD Anticipado rango 1 - 300'
		,'1'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE ValueCODComisison2Param DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('ValueCODComisison2Param'
		,'Valor de comision COD Anticipado rango 301 - 600'
		,'1'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE ValueCODComisison3Param DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('ValueCODComisison3Param'
		,'Valor de comision COD Anticipado rango 601 - 800'
		,'1'
		,1
		,GETDATE()
		,'SV'
		,NULL)

	--SCRIPT PARA INSERTAR EL VALOR DE GuideAmountCODAnticipatedParam DE SV EN ConfigParams
	INSERT INTO [dbo].[ConfigParams]
		([Name]
		,[Description]
		,[Value]
		,[Status]
		,[CreateDate]
		,[IdCountry]
		,[IdCurrencyCOD])
	VALUES
		('GuideAmountCODAnticipatedParam'
		,'Valor maximo por guia para validacion general de COD Anticipado'
		,'100'
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
