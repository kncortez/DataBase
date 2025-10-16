--SELECT *  FROM DeliveryBackOffice.dbo.CatArticle 
--WHERE IdCountry = 'HN'

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated]
           ,[ArtTokenUpdated]
           ,[ArtDateUpdated]
           ,[ArtHeight]
           ,[ArtWidth]
           ,[ArtLength]
           ,[ArtMassWeight]
           ,[IdCountry])
	SELECT 
			[ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,[ArtHeight]
           ,[ArtWidth]
           ,[ArtLength]
           ,[ArtMassWeight]
           ,'SV'
	FROM DeliveryBackOffice.dbo.CatArticle
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
