BEGIN TRANSACTION

BEGIN TRY
--Script
ALTER TABLE DefaultValuesPerCountry
  ADD CodeOfReferenceCorpForInvoice NVARCHAR(10) NULL

	COMMIT TRANSACTION
	print 'Columna agregada exitosamente'

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