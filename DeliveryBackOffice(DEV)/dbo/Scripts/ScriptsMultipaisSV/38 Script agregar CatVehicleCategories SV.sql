--SELECT * FROM DeliveryBackOffice.dbo.CatVehicleCategories
--WHERE IdCountry = 'HN'

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatVehicleCategories]
           ([Name]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[Length]
           ,[Width]
           ,[High]
           ,[UnitType]
           ,[IdCountry])
    SELECT [name], RowStatus, 'SYS-WOROZCO',GETDATE(),NULL,NULL,NULL,NULL, NULL, NULL,'SV'
	FROM dbo.CatVehicleCategories
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
