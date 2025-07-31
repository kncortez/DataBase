
--INGRESAR INFORMACION DE CORREO Y TELEFONO POR PAIS PARA COMPROBANTE

--SELECT * FROM DeliveryBackOffice.dbo.ConfigParams --Ejemplo develop

BEGIN TRY
    BEGIN TRANSACTION;

	--EMAIL SV
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
		,'Valor de correo electrónico para el comprobante en El Salvador'
		,'infosv@forzadelivery.com' --VALOR
		,1
		,GETDATE(),'SV',NULL)

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
		,'Valor del teléfono para el comprobante en El Salvador'
		,'(+503) 2377-5300' --VALOR
		,1
		,GETDATE(),'SV',NULL)

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
