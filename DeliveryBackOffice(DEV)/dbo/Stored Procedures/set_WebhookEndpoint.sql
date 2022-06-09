CREATE PROC [dbo].[set_WebhookEndpoint]
    @IdCustomer int,
    @URI nvarchar(max),
    @IdEcommerce int,
    @WebhookTypeId int
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @COUNT INT

    BEGIN TRAN
	SET @COUNT = (SELECT COUNT(*)
    FROM   dbo.WebhookEndpoint
    WHERE  IdCustomer = @IdCustomer AND IdEcommerce = @IdEcommerce AND RowStatus = 0);

	IF @COUNT > 0 
	BEGIN
		UPDATE dbo.WebhookEndpoint
		 SET   URI = @URI, IdEcommerce = @IdEcommerce, WebhookTypeId = @WebhookTypeId
		  WHERE  IdCustomer = @IdCustomer AND IdEcommerce = @IdEcommerce
	END
	ELSE
	BEGIN
    	 INSERT INTO dbo.WebhookEndpoint ( IdCustomer, URI, RowStatus, IdEcommerce, CreatedDate, 
                                     WebhookTypeId)
		 SELECT  @IdCustomer, @URI, 0, @IdEcommerce, GETDATE(), @WebhookTypeId
    END

    COMMIT
