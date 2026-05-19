BEGIN TRY
	BEGIN TRANSACTION
        
        ALTER TABLE VisitPointClient ADD isReturnWarehouse INT NOT NULL CONSTRAINT DF_VisitPointClient_isReturnWarehouse DEFAULT 0;
        
    COMMIT TRANSACTION;
	PRINT 'Campo creado exitosamente.';

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION;
	PRINT 'ERROR: ' + ERROR_MESSAGE();
	THROW;

END CATCH;