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

	INSERT INTO DeliveryBackOffice.dbo.ConfigParams
	(
		Name,
		Description,
		Value,
		Status,
		CreateDate,
		IdCountry,
		IdCurrencyCOD
	)
	VALUES
	('UrlNetWork','Url de facebook','https://www.facebook.com/profile.php?id=61575901449458',1, GETDATE(),'SV', NULL),
	('UrlNetWork','Url de instagram','https://www.instagram.com/forzadeliverysv?igsh=anFrMWJ2eWN5c2dn',1, GETDATE(),'SV', NULL),
	('UrlNetWork','Url de Linkedin','https://www.linkedin.com/company/107254935/admin/dashboard/',1, GETDATE(),'SV', NULL),
	('UrlNetWork','Url de Whatsapp','',1, GETDATE(),'SV', NULL),
	('PBX','Numero de telefono','2535-1818',1, GETDATE(),'SV', NULL)

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;