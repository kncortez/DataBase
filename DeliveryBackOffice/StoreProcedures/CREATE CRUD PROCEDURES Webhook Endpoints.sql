USE DeliveryBackOffice;
GO

--region PROCEDURE dbo.get_WebhookEndpoint
IF OBJECT_ID('dbo.get_WebhookEndpoint') IS NOT NULL
BEGIN 
    DROP PROC dbo.get_WebhookEndpoint
END
GO
CREATE PROC dbo.get_WebhookEndpoint
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
GO
--endregion

--region PROCEDURE dbo.set_WebhookEndpoint
IF OBJECT_ID('dbo.set_WebhookEndpoint') IS NOT NULL
BEGIN 
    DROP PROC dbo.set_WebhookEndpoint
END 
GO
CREATE PROC dbo.set_WebhookEndpoint
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
GO
--endregion


--region PROCEDURE dbo.remove_WebhookEndpoint
IF OBJECT_ID('dbo.remove_WebhookEndpoint') IS NOT NULL
BEGIN 
    DROP PROC dbo.remove_WebhookEndpoint
END 
GO
CREATE PROC dbo.remove_WebhookEndpoint
	@IdCustomer int,
    @URI nvarchar(max),
    @IdEcommerce int,
    @WebhookTypeId int
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    UPDATE dbo.WebhookEndpoint
		 SET   RowStatus = 1
		  WHERE  IdCustomer = @IdCustomer AND IdEcommerce = @IdEcommerce AND URI = @URI AND WebhookTypeId = @WebhookTypeId

    COMMIT
GO
--endregion