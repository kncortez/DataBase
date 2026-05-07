BEGIN TRY
    BEGIN TRANSACTION;
    
	INSERT INTO DeliveryBackOffice.dbo.CatProductCategory
			   ([CatProductCategoryName]
			   ,[CatProductCategoryDescription]
			   ,[CatProductCategoryOrder]
			   ,[RowStatus]
			   ,[TokenCreated]
			   ,[DateCreated]
			   ,[TokenUpdated]
			   ,[DateUpdated]
			   ,[TechnicalDescription]
			   ,[ImageURL]
			   ,[IdCountry])
	VALUES
		('Membresías', 'Membresías', 1, 1, 'SYS-BHERRERA', GETDATE(), NULL, NULL, 'Membresías', NULL, 'SV'),
		('Guías Prepago', 'Guías Prepago', 2, 1, 'SYS-BHERRERA', GETDATE(), NULL, NULL, 'Paquetes', NULL, 'SV'),
		('Planes de Descuento', 'Planes de Descuento', 7, 1, 'SYS-BHERRERA', GETDATE(), NULL, NULL, 'Planes', NULL, 'SV');

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;