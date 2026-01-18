BEGIN TRY
    BEGIN TRAN;

	update WebhookEndpoint
	set WebhookEndpointURI = 'https://webhook.site/7d2051d0-2532-4991-aedc-d7cfc90b0db5'
	where CustomerId = 1106

    COMMIT TRAN;
END TRY
BEGIN CATCH
    ROLLBACK TRAN;

    -- Manejo básico del error
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
