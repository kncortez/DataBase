CREATE PROC [dbo].[get_WebhookEndpoint]
    @IdCustomer int,
    @IdEcommerce int
AS
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    SELECT WebhookEndpointId, IdCustomer, URI, RowStatus, IdEcommerce, CreatedDate, WebhookTypeId
    FROM   dbo.WebhookEndpoint
	WHERE  IdCustomer = @IdCustomer AND IdEcommerce = @IdEcommerce AND RowStatus = 0;

    COMMIT
