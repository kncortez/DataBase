--SELECT * FROM DeliveryBackOffice.dbo.CatVehicleBrand
--WHERE RowStatus = 1 AND IdCountry = 'HN'

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatVehicleBrand]
           ([Name]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdCountry])
    SELECT [name], RowStatus, 'SYS-WOROZCO', GETDATE(), NULL, NULL,'SV'
	FROM CatVehicleBrand
	WHERE RowStatus = 1 AND IdCountry = 'HN'
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
