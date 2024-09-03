
--INGRESAR INFORMACION DE CORREO Y TELEFONO POR PAIS PARA COMPROBANTE

--SELECT * FROM DeliveryBackOffice.dbo.ConfigParams --Ejemplo develop

BEGIN TRY
    BEGIN TRANSACTION;

	--EMAIL GT
	INSERT INTO [dbo].[ConfigParams]
			   ([Name]
			   ,[Description]
			   ,[Value]
			   ,[Status]
			   ,[CreateDate]
			   ,[IdCountry]
			   ,[IdCurrencyCOD])
	VALUES
		('VoucherEmail'
		,'Valor de correo electrónico para el comprobante en Guatemala'
		,'info@forzadelivery.com' --VALOR
		,1
		,GETDATE(),'GT',NULL)

	--EMAIL HN
	INSERT INTO [dbo].[ConfigParams]
			   ([Name]
			   ,[Description]
			   ,[Value]
			   ,[Status]
			   ,[CreateDate]
			   ,[IdCountry]
			   ,[IdCurrencyCOD])
	VALUES
		('VoucherEmail'
		,'Valor de correo electrónico para el comprobante en Honduras'
		,'infohn@forzadelivery.com' --VALOR
		,1
		,GETDATE(),'HN',NULL)

	--PHONE GT
	INSERT INTO [dbo].[ConfigParams]
			   ([Name]
			   ,[Description]
			   ,[Value]
			   ,[Status]
			   ,[CreateDate]
			   ,[IdCountry]
			   ,[IdCurrencyCOD])
	VALUES
		('VoucherPhone'
		,'Valor del teléfono para el comprobante en Guatemala'
		,'(+502) 2377-5300' --VALOR
		,1
		,GETDATE(),'GT',NULL)

	--PHONE HN
	INSERT INTO [dbo].[ConfigParams]
			   ([Name]
			   ,[Description]
			   ,[Value]
			   ,[Status]
			   ,[CreateDate]
			   ,[IdCountry]
			   ,[IdCurrencyCOD])
	VALUES
		('VoucherPhone'
		,'Valor del teléfono para el comprobante en Honduras'
		,'(+504) 2377-5300' --VALOR
		,1
		,GETDATE(),'HN',NULL)

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
