-- Actualiza el Rate por default en la tabla RatebyCustomer para el cliente con RbcIdCustomer = 101534
BEGIN TRY
	BEGIN TRANSACTION
	UPDATE RatebyCustomer SET
		RbcIdRate = 5108
	WHERE RbcIdCustomer = 101534;

	COMMIT TRANSACTION;
	PRINT 'Actualización completada exitosamente.';
 
END TRY
BEGIN CATCH
 
	ROLLBACK TRANSACTION;
	PRINT 'ERROR: ' + ERROR_MESSAGE();
	THROW;
 
END CATCH;