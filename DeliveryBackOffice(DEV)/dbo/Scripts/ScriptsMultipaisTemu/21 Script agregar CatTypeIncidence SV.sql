--SELECT * FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence]

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatTypeIncidence]
           ([NameIncidence]
           ,[DescriptionIncidence]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[ServiceType]
           ,[OrderId]
           ,[Code]
           ,[IncidenceClasificationId]
           ,[IsForcedIncidence]
           ,[ValidatesLocation]
           ,[HasConfirmationProcess]
           ,[NotifiesOrigin]
           ,[NameIncidencePublic]
           ,[EvidenceRequirement]
           ,[CourierInstructions]
           ,[CountryId])
     SELECT
            NameIncidence
           ,DescriptionIncidence
           ,RowStatus
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,ServiceType
           ,OrderId
           ,Code
           ,IncidenceClasificationId
           ,IsForcedIncidence
           ,ValidatesLocation
           ,HasConfirmationProcess
           ,NotifiesOrigin
           ,NameIncidencePublic
           ,EvidenceRequirement
           ,CourierInstructions
           ,'SV'
	FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence]
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
