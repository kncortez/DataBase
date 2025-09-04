BEGIN TRY
    BEGIN TRANSACTION;
    /*
        Configuración de Servicio Webhook para el cliente AEROPOST  -- FDAPI-4374
    */

    DECLARE @AeropostId INT = (SELECT IdCustomer FROM DeliveryBackOffice.dbo.Customer WITH(NOLOCK) WHERE CountryID = 'HN' AND Name LIKE '%AEROPOST%'); --82153
    DECLARE @CatTypeConnectionID INT = (SELECT IdCatTypeConnection FROM DeliveryBackOffice.dbo.WebhookCatTypeConnection WITH(NOLOCK) WHERE CatTypeConnectionName = 'API');
    DECLARE @WebhookTypeId INT = (SELECT IdWebhookType FROM DeliveryBackOffice.dbo.WebhookType WHERE WebhookName = 'GuideStatusChange');
    DECLARE @TokenUser VARCHAR(50) = 'SYS-TGARCIA';

    -- SELECT * FROM WebhookEndpoint WITH(NOLOCK) WHERE CustomerId = 82153;

    INSERT INTO [DeliveryBackOffice].[dbo].[WebhookEndpoint]
            ([WebhookTypeId]
            ,[CustomerId]
            ,[WebhookEndpointURI]
            ,[RowStatus]
            ,[DateCreated]
            ,[TokenCreated]
            ,[DateUpdated]
            ,[TokenUpdated]
            ,[TypeConnectionId]
            ,[Hostname]
            ,[UserName]
            ,[Password]
            ,[Port]
            ,[RemoteRoute]
            ,[IsCountryRequired])
        VALUES
            (@WebhookTypeId
            ,@AeropostId
            ,'https://api.shipper.aeropost.com/api/lmp/parcels/{tracking_code}/status'
            ,1
            ,GETDATE()
            ,@TokenUser
            ,NULL
            ,NULL
            ,@CatTypeConnectionID
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,0);

    DECLARE @NewWebhookEndpointId BIGINT = SCOPE_IDENTITY();

    --SELECT TOP 100 * FROM [DeliveryBackOffice].[dbo].[WebhookEndpointHeader] WITH(NOLOCK);

    INSERT INTO [DeliveryBackOffice].[dbo].[WebhookEndpointHeader]
            ([WebhookEndpointId]
            ,[WebhookHeaderName]
            ,[WebhookHeaderValue]
            ,[RowStatus]
            ,[DateCreated]
            ,[TokenCreated]
            ,[DateUpdated]
            ,[TokenUpdated])
        VALUES
            (@NewWebhookEndpointId
            ,'Authorization'
            ,'Bearer 146|7H6yZAXoqqxF9mxAIhUyu3IPLd07Ut7Yag7D9TKK7f475d8e'
            ,1
            ,GETDATE()
            ,@TokenUser
            ,NULL
            ,NULL);


    INSERT INTO [DeliveryBackOffice].[dbo].[WebhookEndpointHeader]
            ([WebhookEndpointId]
            ,[WebhookHeaderName]
            ,[WebhookHeaderValue]
            ,[RowStatus]
            ,[DateCreated]
            ,[TokenCreated]
            ,[DateUpdated]
            ,[TokenUpdated])
        VALUES
            (@NewWebhookEndpointId
            ,'Accept'
            ,'application/json'
            ,1
            ,GETDATE()
            ,@TokenUser
            ,NULL
            ,NULL);

    --SELECT TOP 100 * FROM WebhookRestrinctionByUser WITH(NOLOCK) ORDER BY 1 DESC;


    INSERT INTO [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser]
            ([CustomerId],[WebhookTypeId],[StatusOrderId],[StatusExternalName],[RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
        VALUES 
        (@AeropostId, @WebhookTypeId, 50, NULL, 1, @TokenUser, GETDATE(), NULL, NULL),
        (@AeropostId, @WebhookTypeId, 5, NULL, 1, @TokenUser, GETDATE(), NULL, NULL),
        (@AeropostId, @WebhookTypeId, 22, NULL, 1, @TokenUser, GETDATE(), NULL, NULL),
        (@AeropostId, @WebhookTypeId, 4, NULL, 1, @TokenUser, GETDATE(), NULL, NULL),
        (@AeropostId, @WebhookTypeId, 14, NULL, 1, @TokenUser, GETDATE(), NULL, NULL),
        (@AeropostId, @WebhookTypeId, 23, NULL, 1, @TokenUser, GETDATE(), NULL, NULL),
        (@AeropostId, @WebhookTypeId, 35, NULL, 1, @TokenUser, GETDATE(), NULL, NULL)

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;