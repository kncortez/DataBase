--SCRIPT AGREGAR VALORES A CatDeliveryOptions DE SV
SELECT * FROM DeliveryBackOffice.dbo.CatDeliveryOptions

BEGIN TRY
    BEGIN TRANSACTION;

	INSERT INTO [dbo].[CatDeliveryOptions]
			   ([Name]
			   ,[Description]
			   ,[RowStatus]
			   ,[TokenCreated]
			   ,[DateCreated]
			   ,[TokenUpdated]
			   ,[DateUpdated]
			   ,[IdCountry])
		 VALUES
			   ('Casa'
			   ,'Opción de entrega casa'
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
			   ,NULL
			   ,'SV')

	INSERT INTO [dbo].[CatDeliveryOptions]
			   ([Name]
			   ,[Description]
			   ,[RowStatus]
			   ,[TokenCreated]
			   ,[DateCreated]
			   ,[TokenUpdated]
			   ,[DateUpdated]
			   ,[IdCountry])
		 VALUES
			   ('Oficina'
			   ,'Opción de entrega oficina'
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
			   ,NULL
			   ,'SV')

	INSERT INTO [dbo].[CatDeliveryOptions]
			   ([Name]
			   ,[Description]
			   ,[RowStatus]
			   ,[TokenCreated]
			   ,[DateCreated]
			   ,[TokenUpdated]
			   ,[DateUpdated]
			   ,[IdCountry])
		 VALUES
			   ('Express Center'
			   ,'Opción de entrega Express Center'
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
			   ,NULL
			   ,'SV')

	INSERT INTO [dbo].[CatDeliveryOptions]
			   ([Name]
			   ,[Description]
			   ,[RowStatus]
			   ,[TokenCreated]
			   ,[DateCreated]
			   ,[TokenUpdated]
			   ,[DateUpdated]
			   ,[IdCountry])
		 VALUES
			   ('Smart Locker'
			   ,'Opción de entrega Smart Locker'
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
			   ,NULL
			   ,'SV')

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;