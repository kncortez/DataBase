BEGIN TRANSACTION

BEGIN TRY

   UPDATE DefaultValuesPerCountry
   SET RegxPayerTaxNumber ='^\d{14}$'
   WHERE IdCountry IN ('SV');

   UPDATE DefaultValuesPerCountry 
   SET CodeOfReferenceCorpForInvoice = 1378846
   WHERE IdCountry IN ('SV');

   UPDATE DefaultValuesPerCountry 
   SET RegxPassport ='^[A-Z]{3}[0-9]{6}$'
   WHERE IdCountry IN ('SV');

   UPDATE AddInfoByConfigSV
   SET [Value] = '90005000002'
   WHERE [Name]  = 'Secuencial'

  	COMMIT TRANSACTION
	print 'Campos actualizados exitosamente'

END TRY
BEGIN CATCH
	-- Revertir transacción en caso de error
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
    
	-- Capturar información del error
	SELECT ERROR_MESSAGE(),
			ERROR_SEVERITY(),
			ERROR_STATE()

END CATCH