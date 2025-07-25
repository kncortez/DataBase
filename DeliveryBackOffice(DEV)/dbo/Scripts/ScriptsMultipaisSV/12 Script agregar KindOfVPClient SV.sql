--SELECT * FROM KindOfVPClient WITH(NOLOCK)
--WHERE IdCountry = 'HN'

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[KindOfVPClient]
           ([KindOfVPName]
           ,[KindOfVPStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdated]
           ,[IdCountry])
	SELECT
		KindOfVPName
		, KindOfVPStatus
		, 'SYS-WOROZCO'
		, GETDATE()
		, NULL
		, NULL
		, 'SV'
	FROM KindOfVPClient WITH(NOLOCK)
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
