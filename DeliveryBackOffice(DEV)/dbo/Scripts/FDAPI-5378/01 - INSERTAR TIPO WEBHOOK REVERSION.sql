
BEGIN TRY
    BEGIN TRAN;

    DECLARE @TypeWebhook INT;

INSERT INTO WebhookType( 	WebhookName,	WebhookDescription,	RowStatus,	DateCreated,	TokenCreated,	DateUpdated,	TokenUpdated)
VALUES('ReversalDeliveredGuides','Reversión de entrega de guías',1,GETDATE(),'SYS-BPEDROZA', NULL,NULL);

 SET @TypeWebhook = SCOPE_IDENTITY();

INSERT INTO WebhookEndpoint
(
    WebhookTypeId,
    CustomerId,
    WebhookEndpointURI,
    RowStatus,
    DateCreated,
    TokenCreated,
    DateUpdated,
    TokenUpdated,
    TypeConnectionId,
    Hostname,
    UserName,
    [Password],
    Port,
    RemoteRoute,
    IsCountryRequired,
    RestrictValidatedIncidents,
    IsPartyResponsibleRequired
)
SELECT TOP 1
    @TypeWebhook,
    CustomerId,
    'https://webhook.site/7d2051d0-2532-4991-aedc-d7cfc90b0db5',
    1,
    GETDATE() ,
    'SYS-BPEDROZA',
    NULL,
    NULL,
    TypeConnectionId,
    Hostname,
    UserName,
    [Password],
    Port,
    RemoteRoute,
    IsCountryRequired,
    RestrictValidatedIncidents,
    IsPartyResponsibleRequired
FROM WebhookEndpoint
WHERE CustomerId = 1106;


 COMMIT TRAN;
END TRY
BEGIN CATCH
    ROLLBACK TRAN;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

	END CATCH;