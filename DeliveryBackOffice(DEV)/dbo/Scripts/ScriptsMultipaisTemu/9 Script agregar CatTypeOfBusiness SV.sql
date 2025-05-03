--SELECT * FROM DeliveryBackOffice.dbo.CatTypeOfBusiness WITH(NOLOCK)
--WHERE CountryID = 'HN'

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatTypeOfBusiness]
           ([TypeOfBusinessName]
           ,[TypeOfBusinessDescription]
           ,[CountryID]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
	SELECT 
		TypeOfBusinessName
		, TypeOfBusinessDescription
		, 'SV'
		, RowStatus
		, 'SYS-WOROZCO'
		, GETDATE()
		, NULL
		, NULL
	FROM DeliveryBackOffice.dbo.CatTypeOfBusiness
	WHERE CountryID = 'HN'
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
