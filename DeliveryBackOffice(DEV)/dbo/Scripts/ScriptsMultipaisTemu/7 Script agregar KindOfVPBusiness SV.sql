--SELECT * FROM KindOfVPBusiness WITH(NOLOCK)
--WHERE IdCountry = 'HN'

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[KindOfVPBusiness]
           ([KindOfVPNameBussiness]
           ,[Shorthand]
           ,[StatusKindOfVPBusiness]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdated]
           ,[IdCountry])
     SELECT
		KindOfVPNameBussiness
		,Shorthand
		,StatusKindOfVPBusiness
		,'SYS-WOROZCO'
		,GETDATE()
		,NULL
		,NULL
		,'SV'
	 FROM KindOfVPBusiness
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
