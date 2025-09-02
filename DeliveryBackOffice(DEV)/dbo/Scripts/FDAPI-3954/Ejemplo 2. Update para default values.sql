-- Iniciar transacción
BEGIN TRANSACTION

BEGIN TRY

   UPDATE DefaultValuesPerCountry
      SET CodeOfReferenceCorpForInvoice = 999
   WHERE IdCountry ='GT';

   UPDATE DefaultValuesPerCountry
      SET CodeOfReferenceCorpForInvoice = 948850
   WHERE IdCountry ='HN';

   UPDATE DefaultValuesPerCountry
      SET CodeOfReferenceCorpForInvoice = 1378846 --A configurar
   WHERE IdCountry ='SV';

	COMMIT TRANSACTION
	print 'Actualición de datos realizada exitosa'

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
