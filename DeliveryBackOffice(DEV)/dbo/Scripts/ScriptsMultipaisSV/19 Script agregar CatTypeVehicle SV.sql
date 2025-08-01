--SELECT * FROM CatTypeVehicle

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatTypeVehicle]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[PackageSize]
           ,[IdCountry])
	SELECT 
		Name
		,Description
		,1
		,'SYS-WOROZCO'
		, GETDATE()
		, NULL
		, NULL
		, PackageSize
		, 'SV'
	FROM DeliveryBackOffice.dbo.CatTypeVehicle
	WHERE IdCountry = 'HN'
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
