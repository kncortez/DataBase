--SELECT * FROM  DeliveryBackOffice.dbo.CatBusinessSegment
--WHERE IdCountry ='HN'

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatBusinessSegment]
           ([BusinessSegmentName]
           ,[BusinessSegmentDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdCountry])
	SELECT 
		  BusinessSegmentName
		, BusinessSegmentDescription
		, RowStatus
		, 'SYS-WOROZCO'
		, GETDATE()
		, NULL
		, NULL
		, 'SV'
	FROM  DeliveryBackOffice.dbo.CatBusinessSegment
	WHERE IdCountry ='HN'
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;

