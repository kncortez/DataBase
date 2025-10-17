--SELECT * FROM [DeliveryBackOffice].[dbo].[ContentTitle]

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[ContentTitle]
           ([TypeContentId]
           ,[ContentTitle]
           ,[ContentDescription]
           ,[RowStatus]
           ,[DateCreated]
           ,[TokenCreated]
           ,[DateUpdated]
           ,[TokenUpdated]
           ,[CountryId])
     SELECT
		  TypeContentId
		, ContentTitle
		, ContentDescription
		, RowStatus
		, GETDATE()
		, 'SYS-WOROZCO'
		, NULL
		, NULL
		, 'SV'
	 FROM [DeliveryBackOffice].[dbo].[ContentTitle]
	 WHERE CountryId = 'HN'
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
