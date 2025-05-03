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