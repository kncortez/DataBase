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
		('Membresías', 'Membresías', 1, 1, 'evasquez', '2024-07-17 14:27:39.657', NULL, NULL, 'Membresías', 'https://forzadelivery.com/images/Tienda/17%20membership%20card_1_1.gif', 'HN'),
		('Guías Prepago', 'Guías Prepago', 2, 1, 'evasquez', '2024-07-17 14:27:39.657', NULL, NULL, 'Paquetes', 'https://forzadelivery.com/images/Tienda/47-%20Delivery%20completed_1.gif', 'HN'),
		('Planes de Descuento', 'Planes de Descuento', 3, 1, 'SYS-BHERRERA', '2024-07-17 14:27:39.657', NULL, NULL, 'Planes', 'https://forzadelivery.com/images/Tienda/37%20Price%20Tag_1.gif', 'HN');

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;